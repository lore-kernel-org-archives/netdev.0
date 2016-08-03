From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next  16/18] liquidio support for new device cn23xx
Date: Wed, 3 Aug 2016 11:55:47 -0700
Message-ID: <1470250549-10993-17-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bn3nam01on0083.outbound.protection.outlook.com ([104.47.33.83]:30448
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758330AbcHCUb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 16:31:26 -0400
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for watchdog based health
monitoring of octeon cores.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 124 ++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 2 files changed, 124 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 3ae7e76..14b8dda 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -24,6 +24,7 @@
 #include <linux/firmware.h>
 #include <linux/ptp_clock_kernel.h>
 #include <net/vxlan.h>
+#include <linux/kthread.h>
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -946,8 +947,6 @@ static void update_txq_status(struct octeon_device *oct, int iq_num)
 	struct lio *lio;
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
 
-	/*octeon_update_iq_read_idx(oct, iq);*/
-
 	netdev = oct->props[iq->ifidx].netdev;
 
 	/* This is needed because the first IQ does not have
@@ -1183,6 +1182,100 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 	return 0;
 }
 
+static int liquidio_watchdog(void *param)
+{
+#define CIU3_WDOG(c) (0x1010000020000ULL + (c << 3))
+	u64 wdog;
+	u16 mask_of_stuck_cores = 0;
+	u16 mask_of_crashed_cores = 0;
+	int core_num;
+	u8 core_is_stuck[12];
+	u8 core_crashed[12];
+	struct octeon_device *oct = param;
+
+	memset(core_is_stuck, 0, sizeof(core_is_stuck));
+	memset(core_crashed, 0, sizeof(core_crashed));
+
+	while (!kthread_should_stop()) {
+		mask_of_crashed_cores =
+		    (u16)octeon_read_csr64(oct, CN23XX_SLI_SCRATCH2);
+
+		for (core_num = 0; core_num < 12; core_num++) {
+			if (!core_is_stuck[core_num]) {
+				wdog = lio_pci_readq(oct, CIU3_WDOG(core_num));
+
+				/* look at watchdog state field */
+				wdog &= 12ULL;
+				if (wdog) {
+					/* this watchdog timer has expired */
+					core_is_stuck[core_num] = 1;
+					mask_of_stuck_cores |= (1 << core_num);
+				}
+			}
+
+			if (!core_crashed[core_num])
+				core_crashed[core_num] =
+				    (mask_of_crashed_cores >> core_num) & 1;
+		}
+
+		if (mask_of_stuck_cores) {
+			for (core_num = 0; core_num < 12; core_num++) {
+				if (core_is_stuck[core_num] == 1) {
+					dev_err(&oct->pci_dev->dev,
+						"ERROR: Octeon core %d is stuck!\n",
+						core_num);
+					core_is_stuck[core_num] =
+						2; /* 2 means we have printk'd
+						    * an error; so no need to
+						    * repeat the same printk
+						    */
+				}
+			}
+		}
+
+		if (mask_of_crashed_cores) {
+			for (core_num = 0; core_num < 12; core_num++) {
+				if (core_crashed[core_num] == 1) {
+					dev_err(&oct->pci_dev->dev,
+						"ERROR: Octeon core %d crashed!  See oct-fwdump for details.\n",
+						core_num);
+					core_crashed[core_num] =
+						2; /* 2 means we have printk'd
+						    * an error; so no need to
+						    * repeat the same printk
+						    */
+				}
+			}
+		}
+
+		if (mask_of_stuck_cores || mask_of_crashed_cores) {
+			/* make module refcount=0 so that rmmod will work */
+			long refcount;
+
+			refcount = module_refcount(THIS_MODULE);
+
+			while (refcount > 0) {
+				module_put(THIS_MODULE);
+				refcount = module_refcount(THIS_MODULE);
+			}
+
+			/* compensate for and withstand an unlikely (but still
+			 * possible) race condition
+			 */
+			while (refcount < 0) {
+				try_module_get(THIS_MODULE);
+				refcount = module_refcount(THIS_MODULE);
+			}
+		}
+
+		/* sleep for two seconds */
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(2 * HZ);
+	}
+
+	return 0;
+}
+
 /**
  * \brief PCI probe handler
  * @param pdev PCI device structure
@@ -1228,6 +1321,30 @@ liquidio_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
+	if (OCTEON_CN23XX_PF(oct_dev)) {
+		u64 scratch1;
+		u8 bus, device, function;
+
+		scratch1 = octeon_read_csr64(oct_dev, CN23XX_SLI_SCRATCH1);
+		if (!(scratch1 & 4ULL)) {
+			/* Bit 2 of SLI_SCRATCH_1 is a flag that indicates that
+			 * the lio watchdog kernel thread is running for this
+			 * NIC.  Each NIC gets one watchdog kernel thread.
+			 */
+			scratch1 |= 4ULL;
+			octeon_write_csr64(oct_dev, CN23XX_SLI_SCRATCH1,
+					   scratch1);
+
+			bus = pdev->bus->number;
+			device = PCI_SLOT(pdev->devfn);
+			function = PCI_FUNC(pdev->devfn);
+			oct_dev->watchdog_task = kthread_create(
+			    liquidio_watchdog, oct_dev,
+			    "liowd/%02hhx:%02hhx.%hhx", bus, device, function);
+			wake_up_process(oct_dev->watchdog_task);
+		}
+	}
+
 	oct_dev->rx_pause = 1;
 	oct_dev->tx_pause = 1;
 
@@ -1562,6 +1679,9 @@ static void liquidio_remove(struct pci_dev *pdev)
 
 	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
 
+	if (oct_dev->watchdog_task)
+		kthread_stop(oct_dev->watchdog_task);
+
 	if (oct_dev->app_mode && (oct_dev->app_mode == CVM_DRV_NIC_APP))
 		liquidio_stop_nic_module(oct_dev);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 911bfde..7a965c1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -488,6 +488,8 @@ struct octeon_device {
 
 	/* private flags to control driver-specific features through ethtool */
 	u32 priv_flags;
+
+	void *watchdog_task;
 };
 
 #define  OCT_DRV_ONLINE 1
-- 
1.8.3.1
