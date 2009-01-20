From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] ixgbe: Fix usage of netif_*_all_queues() with
	netif_carrier_{off|on}()
Date: Mon, 19 Jan 2009 16:11:47 -0800
Message-ID: <20090120001147.22544.97470.stgit@lost.foo-projects.org>
References: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:46521
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761684AbZATAMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:12:06 -0500
In-Reply-To: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

netif_carrier_off() is sufficient to stop Tx into the driver.  Stopping the Tx
queues is redundant and unnecessary.  By the same token, netif_carrier_on()
will be sufficient to re-enable Tx, so waking the queues is unnecessary.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bf36737..d2f4d5f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2078,6 +2078,9 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	ixgbe_irq_enable(adapter);
 
+	/* enable transmits */
+	netif_tx_start_all_queues(netdev);
+
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
@@ -3479,7 +3482,6 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			        (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
-			netif_tx_wake_all_queues(netdev);
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -3491,7 +3493,6 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			printk(KERN_INFO "ixgbe: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
 		}
 	}
 
@@ -4222,7 +4223,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);

