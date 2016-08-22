From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 10/18] liquidio: CN23XX firmware download
Date: Sun, 21 Aug 2016 17:12:37 -0700
Message-ID: <1471824765-26473-11-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam03on0041.outbound.protection.outlook.com ([104.47.42.41]:52561
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753647AbcHVAOI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:14:08 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add firmware download support for cn23xx device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    |  40 +++++++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 115 ++++++++++++---------
 3 files changed, 111 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 0603218..335d0eb 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -214,6 +214,37 @@ void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct)
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
+	return 0;
+}
+
 static void cn23xx_enable_error_reporting(struct octeon_device *oct)
 {
 	u32 regval;
@@ -1053,6 +1084,7 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 	oct->fn_list.process_interrupt_regs = cn23xx_interrupt_handler;
 	oct->fn_list.msix_interrupt_handler = cn23xx_pf_msix_interrupt_handler;
 
+	oct->fn_list.soft_reset = cn23xx_pf_soft_reset;
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
 
@@ -1153,3 +1185,11 @@ void cn23xx_dump_iq_regs(struct octeon_device *oct)
 		CVM_CAST64(octeon_read_csr64(
 			oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
 }
+
+int cn23xx_fw_loaded(struct octeon_device *oct)
+{
+	u64 val;
+
+	val = octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1);
+	return (val >> 1) & 1ULL;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index 36252e7..33b7589 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -52,4 +52,6 @@ int validate_cn23xx_pf_config_info(struct octeon_device *oct,
 				   struct octeon_config *conf23xx);
 
 void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct);
+
+int cn23xx_fw_loaded(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 82b5ebd..c33c5a1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1312,9 +1312,9 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_PCI_MAP_DONE:
-
 		/* Soft reset the octeon device before exiting */
-		oct->fn_list.soft_reset(oct);
+		if ((!OCTEON_CN23XX_PF(oct)) || !oct->octeon_id)
+			oct->fn_list.soft_reset(oct);
 
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
@@ -3818,6 +3818,7 @@ static void nic_starter(struct work_struct *work)
 static int octeon_device_init(struct octeon_device *octeon_dev)
 {
 	int j, ret;
+	int fw_loaded = 0;
 	char bootcmd[] = "\n";
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)octeon_dev->priv;
@@ -3839,9 +3840,23 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	octeon_dev->app_mode = CVM_DRV_INVALID_APP;
 
-	/* Do a soft reset of the Octeon device. */
-	if (octeon_dev->fn_list.soft_reset(octeon_dev))
+	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		if (!cn23xx_fw_loaded(octeon_dev)) {
+			fw_loaded = 0;
+			/* Do a soft reset of the Octeon device. */
+			if (octeon_dev->fn_list.soft_reset(octeon_dev))
+				return 1;
+			/* things might have changed */
+			if (!cn23xx_fw_loaded(octeon_dev))
+				fw_loaded = 0;
+			else
+				fw_loaded = 1;
+		} else {
+			fw_loaded = 1;
+		}
+	} else if (octeon_dev->fn_list.soft_reset(octeon_dev)) {
 		return 1;
+	}
 
 	/* Initialize the dispatch mechanism used to push packets arriving on
 	 * Octeon Output queues.
@@ -3946,56 +3961,65 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_IO_QUEUES_DONE);
 
-	dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
-
-	if (ddr_timeout == 0)
-		dev_info(&octeon_dev->pci_dev->dev, "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
+	if ((!OCTEON_CN23XX_PF(octeon_dev)) || !fw_loaded) {
+		dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
+		if (!ddr_timeout) {
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
+		while (!ddr_timeout) {
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
+		if (octeon_wait_for_bootloader(octeon_dev, 1000)) {
+			dev_err(&octeon_dev->pci_dev->dev, "Board not responding\n");
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
+			return 1;
+		}
+		ret = octeon_add_console(octeon_dev, 0);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev, "Could not access board console\n");
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
@@ -4011,7 +4035,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		       octeon_dev->droq[j]->pkts_credit_reg);
 
 	/* Packets can start arriving on the output queues from this point. */
-
 	return 0;
 }
 
-- 
1.8.3.1
