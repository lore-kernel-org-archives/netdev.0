From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 02/11] e1000: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:13 +0100
Message-ID: <1418135842-21389-3-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Linux NICS <linux.nics@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:51951 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbaLIOiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:38:51 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt handler.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Linux NICS <linux.nics@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |  3 +++
 drivers/net/ethernet/intel/e1000/e1000_main.c | 21 ++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 69707108d23c..79444125b9bd 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -68,6 +68,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 
 #define BAR_0		0
 #define BAR_1		1
@@ -323,6 +324,8 @@ struct e1000_adapter {
 	struct delayed_work watchdog_task;
 	struct delayed_work fifo_stall_task;
 	struct delayed_work phy_info_task;
+
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 24f3986cfae2..5749a27e5c5e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -32,6 +32,7 @@
 #include <linux/prefetch.h>
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -1313,6 +1314,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
+	netpoll_irq_lock_init(&adapter->netpoll_lock);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
 
@@ -3751,10 +3753,8 @@ void e1000_update_stats(struct e1000_adapter *adapter)
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
-static irqreturn_t e1000_intr(int irq, void *data)
+static irqreturn_t __e1000_intr(int irq, struct e1000_adapter *adapter)
 {
-	struct net_device *netdev = data;
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
@@ -3796,6 +3796,19 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t e1000_intr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	irqreturn_t ret;
+
+	netpoll_irq_lock(&adapter->netpoll_lock);
+	ret = __e1000_intr(irq, adapter);
+	netpoll_irq_unlock(&adapter->netpoll_lock);
+
+	return ret;
+}
+
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
@@ -5220,9 +5233,7 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	enable_irq(adapter->pdev->irq);
 }
 #endif
 
-- 
2.1.3
