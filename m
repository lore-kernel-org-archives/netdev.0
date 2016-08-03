From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next  10/18] liquidio support for new device cn23xx
Date: Wed, 3 Aug 2016 11:55:41 -0700
Message-ID: <1470250549-10993-11-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0042.outbound.protection.outlook.com ([104.47.33.42]:24441
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932296AbcHCUdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 16:33:49 -0400
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds firmware download support for cn23xx
device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    |  55 +++++++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   6 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 158 +++++++++++++++------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 4 files changed, 176 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index d4b17a6..ee01340 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -214,6 +214,40 @@ void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct)
 		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_CNT_INT)));
 }
 
+static int cn23xx_pf_soft_reset(struct octeon_device *oct)
+{
+	octeon_write_csr64(oct, CN23XX_WIN_WR_MASK_REG, 0xFF);
+
+	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: BIST enabled for CN23XX soft reset\n",
+		oct->octeon_id);
+
+	octeon_write_csr64(oct, CN23XX_SLI_SCRATCH1, 0x1234ULL);
+
+	/* Initiate chip-wide soft reset */
+	lio_pci_readq(oct, CN23XX_RST_SOFT_RST);
+	lio_pci_writeq(oct, 1, CN23XX_RST_SOFT_RST);
+
+	/* Wait for 100ms as Octeon resets. */
+	mdelay(100);
+
+	if (octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1) == 0x1234ULL) {
+		dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Soft reset failed\n",
+			oct->octeon_id);
+		return 1;
+	}
+
+	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: Reset completed\n",
+		oct->octeon_id);
+
+	/* restore the  reset value*/
+	octeon_write_csr64(oct, CN23XX_WIN_WR_MASK_REG, 0xFF);
+
+	/** Complete DPI init is done at firmware level. */
+	/*cn23xx_set_dpi_regs(oct);*/
+
+	return 0;
+}
+
 static void cn23xx_enable_error_reporting(struct octeon_device *oct)
 {
 	u32 regval;
@@ -1051,6 +1085,7 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 	oct->fn_list.process_interrupt_regs = cn23xx_interrupt_handler;
 	oct->fn_list.msix_interrupt_handler = cn23xx_pf_msix_interrupt_handler;
 
+	oct->fn_list.soft_reset = cn23xx_pf_soft_reset;
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
 
@@ -1151,3 +1186,23 @@ void cn23xx_dump_iq_regs(struct octeon_device *oct)
 		CVM_CAST64(octeon_read_csr64(
 			oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
 }
+
+int cn23xx_fw_lock(struct octeon_device *oct)
+{
+	dev_dbg(&oct->pci_dev->dev, "%s : PF = %d\n", __func__, oct->pf_num);
+	return 0;
+}
+
+int cn23xx_fw_unlock(struct octeon_device *oct)
+{
+	dev_dbg(&oct->pci_dev->dev, "%s : PF = %d\n", __func__, oct->pf_num);
+	return 0;
+}
+
+int cn23xx_fw_loaded(struct octeon_device *oct)
+{
+	u64 val;
+
+	val = octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1);
+	return (val >> 1) & 1ULL;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index 36252e7..ec25ea3 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -52,4 +52,10 @@ int validate_cn23xx_pf_config_info(struct octeon_device *oct,
 				   struct octeon_config *conf23xx);
 
 void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct);
+
+int cn23xx_fw_lock(struct octeon_device *oct);
+
+int cn23xx_fw_unlock(struct octeon_device *oct);
+
+int cn23xx_fw_loaded(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 152d4ef..88783d3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1314,7 +1314,9 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 	case OCT_DEV_PCI_MAP_DONE:
 
 		/* Soft reset the octeon device before exiting */
-		oct->fn_list.soft_reset(oct);
+		if (!(OCTEON_CN23XX_PF(oct)) ||
+		    (OCTEON_CN23XX_PF(oct) && (oct->octeon_id == 0)))
+			oct->fn_list.soft_reset(oct);
 
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
@@ -3793,6 +3795,9 @@ static void nic_starter(struct work_struct *work)
 		return;
 	}
 
+	if (oct->fw_locked)
+		cn23xx_fw_unlock(oct);
+
 	atomic_set(&oct->status, OCT_DEV_RUNNING);
 
 	if (oct->app_mode && oct->app_mode == CVM_DRV_NIC_APP) {
@@ -3818,6 +3823,7 @@ static void nic_starter(struct work_struct *work)
 static int octeon_device_init(struct octeon_device *octeon_dev)
 {
 	int j, ret;
+	int fw_locked = 0, fw_loaded = 0;
 	char bootcmd[] = "\n";
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)octeon_dev->priv;
@@ -3839,15 +3845,43 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	octeon_dev->app_mode = CVM_DRV_INVALID_APP;
 
-	/* Do a soft reset of the Octeon device. */
-	if (octeon_dev->fn_list.soft_reset(octeon_dev))
+	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		cn23xx_fw_lock(octeon_dev);
+		fw_locked = 1;
+		if (!cn23xx_fw_loaded(octeon_dev)) {
+			fw_loaded = 0;
+			/* Do a soft reset of the Octeon device. */
+			if (octeon_dev->fn_list.soft_reset(octeon_dev)) {
+				cn23xx_fw_unlock(octeon_dev);
+				return 1;
+			}
+			/*Lock again soft reset equivalent to unlock */
+			cn23xx_fw_lock(octeon_dev);
+			/* things might have changed */
+			if (!cn23xx_fw_loaded(octeon_dev)) {
+				fw_loaded = 0;
+			} else {
+				cn23xx_fw_unlock(octeon_dev);
+				fw_locked = 0;
+				fw_loaded = 1;
+			}
+		} else {
+			cn23xx_fw_unlock(octeon_dev);
+			fw_locked = 0;
+			fw_loaded = 1;
+		}
+	} else if (octeon_dev->fn_list.soft_reset(octeon_dev)) {
 		return 1;
+	}
 
 	/* Initialize the dispatch mechanism used to push packets arriving on
 	 * Octeon Output queues.
 	 */
-	if (octeon_init_dispatch_list(octeon_dev))
+	if (octeon_init_dispatch_list(octeon_dev)) {
+		if (fw_locked)
+			cn23xx_fw_unlock(octeon_dev);
 		return 1;
+	}
 
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
 				    OPCODE_NIC_CORE_DRV_ACTIVE,
@@ -3866,6 +3900,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
 		ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
 		if (ret) {
+			if (fw_locked)
+				cn23xx_fw_lock(octeon_dev);
 			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: Failed to configure device registers\n");
 			return ret;
 		}
@@ -3875,6 +3911,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	 */
 	if (octeon_setup_sc_buffer_pool(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev, "sc buffer pool allocation failed\n");
+		if (fw_locked)
+			cn23xx_fw_unlock(octeon_dev);
 		return 1;
 	}
 	atomic_set(&octeon_dev->status, OCT_DEV_SC_BUFF_POOL_INIT_DONE);
@@ -3886,6 +3924,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		/* On error, release any previously allocated queues */
 		for (j = 0; j < octeon_dev->num_iqs; j++)
 			octeon_delete_instr_queue(octeon_dev, j);
+		if (fw_locked)
+			cn23xx_fw_unlock(octeon_dev);
 		return 1;
 	}
 	atomic_set(&octeon_dev->status, OCT_DEV_INSTR_QUEUE_INIT_DONE);
@@ -3895,6 +3935,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	 */
 	if (octeon_setup_response_list(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev, "Response list allocation failed\n");
+		if (fw_locked)
+			cn23xx_fw_unlock(octeon_dev);
 		return 1;
 	}
 	atomic_set(&octeon_dev->status, OCT_DEV_RESP_LIST_INIT_DONE);
@@ -3904,6 +3946,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		/* Release any previously allocated queues */
 		for (j = 0; j < octeon_dev->num_oqs; j++)
 			octeon_delete_droq(octeon_dev, j);
+		if (fw_locked)
+			cn23xx_fw_unlock(octeon_dev);
 		return 1;
 	}
 
@@ -3912,6 +3956,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
 		if (octeon_allocate_ioq_vector(octeon_dev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: ioq vector allocation failed\n");
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
 			return 1;
 		}
 
@@ -3946,56 +3992,76 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_IO_QUEUES_DONE);
 
-	dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
-
-	if (ddr_timeout == 0)
-		dev_info(&octeon_dev->pci_dev->dev, "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
+	if ((!OCTEON_CN23XX_PF(octeon_dev)) ||
+	    (OCTEON_CN23XX_PF(octeon_dev) && !fw_loaded)) {
+		dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
+		if (ddr_timeout == 0) {
+			dev_info(&octeon_dev->pci_dev->dev,
+				 "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
+		}
 
-	schedule_timeout_uninterruptible(HZ * LIO_RESET_SECS);
+		schedule_timeout_uninterruptible(HZ * LIO_RESET_SECS);
 
-	/* Wait for the octeon to initialize DDR after the soft-reset. */
-	while (ddr_timeout == 0) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (schedule_timeout(HZ / 10)) {
-			/* user probably pressed Control-C */
+		/* Wait for the octeon to initialize DDR after the soft-reset.*/
+		while (ddr_timeout == 0) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			if (schedule_timeout(HZ / 10)) {
+				/* user probably pressed Control-C */
+				return 1;
+			}
+		}
+		ret = octeon_wait_for_ddr_init(octeon_dev, &ddr_timeout);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"DDR not initialized. Please confirm that board is configured to boot from Flash, ret: %d\n",
+				ret);
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
 			return 1;
 		}
-	}
-	ret = octeon_wait_for_ddr_init(octeon_dev, &ddr_timeout);
-	if (ret) {
-		dev_err(&octeon_dev->pci_dev->dev,
-			"DDR not initialized. Please confirm that board is configured to boot from Flash, ret: %d\n",
-			ret);
-		return 1;
-	}
 
-	if (octeon_wait_for_bootloader(octeon_dev, 1000) != 0) {
-		dev_err(&octeon_dev->pci_dev->dev, "Board not responding\n");
-		return 1;
-	}
+		if (octeon_wait_for_bootloader(octeon_dev, 1000) != 0) {
+			dev_err(&octeon_dev->pci_dev->dev, "Board not responding\n");
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
+			return 1;
+		}
 
-	/* Divert uboot to take commands from host instead. */
-	ret = octeon_console_send_cmd(octeon_dev, bootcmd, 50);
+		/* Divert uboot to take commands from host instead. */
+		ret = octeon_console_send_cmd(octeon_dev, bootcmd, 50);
 
-	dev_dbg(&octeon_dev->pci_dev->dev, "Initializing consoles\n");
-	ret = octeon_init_consoles(octeon_dev);
-	if (ret) {
-		dev_err(&octeon_dev->pci_dev->dev, "Could not access board consoles\n");
-		return 1;
-	}
-	ret = octeon_add_console(octeon_dev, 0);
-	if (ret) {
-		dev_err(&octeon_dev->pci_dev->dev, "Could not access board console\n");
-		return 1;
-	}
+		dev_dbg(&octeon_dev->pci_dev->dev, "Initializing consoles\n");
+		ret = octeon_init_consoles(octeon_dev);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev, "Could not access board consoles\n");
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
+			return 1;
+		}
+		ret = octeon_add_console(octeon_dev, 0);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev, "Could not access board console\n");
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
+			return 1;
+		}
 
-	atomic_set(&octeon_dev->status, OCT_DEV_CONSOLE_INIT_DONE);
+		atomic_set(&octeon_dev->status, OCT_DEV_CONSOLE_INIT_DONE);
 
-	dev_dbg(&octeon_dev->pci_dev->dev, "Loading firmware\n");
-	ret = load_firmware(octeon_dev);
-	if (ret) {
-		dev_err(&octeon_dev->pci_dev->dev, "Could not load firmware to board\n");
-		return 1;
+		dev_dbg(&octeon_dev->pci_dev->dev, "Loading firmware\n");
+		ret = load_firmware(octeon_dev);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev, "Could not load firmware to board\n");
+			if (fw_locked)
+				cn23xx_fw_unlock(octeon_dev);
+			return 1;
+		}
+		/* set bit 1 of SLI_SCRATCH_1 to indicate that firmware is
+		 * loaded
+		 */
+		if (OCTEON_CN23XX_PF(octeon_dev))
+			octeon_write_csr64(octeon_dev, CN23XX_SLI_SCRATCH1,
+					   2ULL);
 	}
 
 	handshake[octeon_dev->octeon_id].init_ok = 1;
@@ -4011,6 +4077,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		       octeon_dev->droq[j]->pkts_credit_reg);
 
 	/* Packets can start arriving on the output queues from this point. */
+	if (fw_locked)
+		octeon_dev->fw_locked = 1;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 8e28ff4..e74973b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -473,6 +473,8 @@ struct octeon_device {
 
 	struct octeon_pf_vf_hs_word pfvf_hsword;
 
+	int fw_locked;
+
 	int msix_on;
 
 	/** IOq information of it's corresponding MSI-X interrupt. */
-- 
1.8.3.1
