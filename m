From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 19/23] e1000e: set pm_qos DMA latency requirement
	per interface when needed
Date: Sat, 21 Nov 2009 01:27:40 -0800
Message-ID: <20091121092739.5715.56854.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:46261
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751990AbZKUJ1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:27:51 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

It was pointed out a pm_qos DMA latency requirement set when the driver is
loaded when parts that support early receive of jumbo frames are probed
could have that requirement overidden if another part supported by the
driver (one that does not support early receive of jumbo frames) is probed
later.  Change the DMA latency requirement to be per-interface if needed
instead of per driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   47 ++++++++++++++++++++++++++-----------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 25b0ef8..39f01d9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2472,21 +2472,23 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	 * packet size is equal or larger than the specified value (in 8 byte
 	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
 	 */
-	if ((adapter->flags & FLAG_HAS_ERT) &&
-	    (adapter->netdev->mtu > ETH_DATA_LEN)) {
-		u32 rxdctl = er32(RXDCTL(0));
-		ew32(RXDCTL(0), rxdctl | 0x3);
-		ew32(ERT, E1000_ERT_2048 | (1 << 13));
-		/*
-		 * With jumbo frames and early-receive enabled, excessive
-		 * C4->C2 latencies result in dropped transactions.
-		 */
-		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
-					  e1000e_driver_name, 55);
-	} else {
-		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
-					  e1000e_driver_name,
-					  PM_QOS_DEFAULT_VALUE);
+	if (adapter->flags & FLAG_HAS_ERT) {
+		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+			u32 rxdctl = er32(RXDCTL(0));
+			ew32(RXDCTL(0), rxdctl | 0x3);
+			ew32(ERT, E1000_ERT_2048 | (1 << 13));
+			/*
+			 * With jumbo frames and early-receive enabled,
+			 * excessive C-state transition latencies result in
+			 * dropped transactions.
+			 */
+			pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+						  adapter->netdev->name, 55);
+		} else {
+			pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+						  adapter->netdev->name,
+						  PM_QOS_DEFAULT_VALUE);
+		}
 	}
 
 	/* Enable Receives */
@@ -2804,6 +2806,12 @@ int e1000e_up(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
+	/* DMA latency requirement to workaround early-receive/jumbo issue */
+	if (adapter->flags & FLAG_HAS_ERT)
+		pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY,
+		                       adapter->netdev->name,
+				       PM_QOS_DEFAULT_VALUE);
+
 	/* hardware has been reset, we need to reload some things */
 	e1000_configure(adapter);
 
@@ -2864,6 +2872,10 @@ void e1000e_down(struct e1000_adapter *adapter)
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
 
+	if (adapter->flags & FLAG_HAS_ERT)
+		pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY,
+		                          adapter->netdev->name);
+
 	/*
 	 * TODO: for power management, we could drop the link and
 	 * pci_disable_device here.
@@ -5363,9 +5375,7 @@ static int __init e1000_init_module(void)
 	printk(KERN_INFO "%s: Copyright (c) 1999 - 2009 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
-	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name,
-			       PM_QOS_DEFAULT_VALUE);
-				
+
 	return ret;
 }
 module_init(e1000_init_module);
@@ -5379,7 +5389,6 @@ module_init(e1000_init_module);
 static void __exit e1000_exit_module(void)
 {
 	pci_unregister_driver(&e1000_driver);
-	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name);
 }
 module_exit(e1000_exit_module);
 

