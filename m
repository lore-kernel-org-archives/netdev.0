From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 06/10] liquidio: free resources during shutdown
Date: Tue, 28 Jun 2016 17:54:28 -0700
Message-ID: <1467161672-21063-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752553AbcF2AzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:15 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the issue of proper freeing of queue
memory resources during free device. It also has fix for
correct pcie error reporting.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c  |  4 ++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c       |  4 +++-
 drivers/net/ethernet/cavium/liquidio/octeon_console.c |  3 +++
 drivers/net/ethernet/cavium/liquidio/octeon_device.c  | 10 +++++-----
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index b923c7f..96a8802 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -74,9 +74,9 @@ void lio_cn6xxx_enable_error_reporting(struct octeon_device *oct)
 	u32 val;
 
 	pci_read_config_dword(oct->pci_dev, CN6XXX_PCIE_DEVCTL, &val);
-	if (val & 0x000f0000) {
+	if (val & 0x000c0000) {
 		dev_err(&oct->pci_dev->dev, "PCI-E Link error detected: 0x%08x\n",
-			val & 0x000f0000);
+			val & 0x000c0000);
 	}
 
 	val |= 0xf;          /* Enable Link error reporting */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 313ab32..0f39ad0 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3991,6 +3991,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		/* Release any previously allocated queues */
 		for (j = 0; j < octeon_dev->num_oqs; j++)
 			octeon_delete_droq(octeon_dev, j);
+		return 1;
 	}
 
 	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
@@ -4013,7 +4014,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	/* Setup the interrupt handler and record the INT SUM register address
 	 */
-	octeon_setup_interrupt(octeon_dev);
+	if (octeon_setup_interrupt(octeon_dev))
+		return 1;
 
 	/* Enable Octeon device interrupts */
 	octeon_dev->fn_list.enable_interrupt(octeon_dev->chip);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index f96a9d6..05313ac 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -323,6 +323,9 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 			if (name && named_size) {
 				char *name_tmp =
 					kmalloc(name_length + 1, GFP_KERNEL);
+				if (!name_tmp)
+					break;
+
 				CVMX_BOOTMEM_NAMED_GET_NAME(oct, named_addr,
 							    name_tmp,
 							    name_length);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 3372207..26cd494 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -652,16 +652,16 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 
 void octeon_free_device_mem(struct octeon_device *oct)
 {
-	u32 i;
+	int i;
 
 	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
-		/* could check  mask as well */
-		vfree(oct->droq[i]);
+		if (oct->io_qmask.oq & (1ULL << i))
+			vfree(oct->droq[i]);
 	}
 
 	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
-		/* could check mask as well */
-		vfree(oct->instr_queue[i]);
+		if (oct->io_qmask.iq & (1ULL << i))
+			vfree(oct->instr_queue[i]);
 	}
 
 	i = oct->octeon_id;
-- 
1.8.3.1
