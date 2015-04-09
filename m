From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH] e1000: Avoid that e1000_netpoll() triggers a kernel warning
Date: Thu, 9 Apr 2015 13:54:45 +0200
Message-ID: <55266885.6010905@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0085.outbound.protection.outlook.com ([65.55.169.85]:5629
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753694AbbDIM0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 08:26:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

console_cont_flush(), which is called by console_unlock(), calls
call_console_drivers() and hence also the netconsole function
write_msg() with local interrupts disabled. This means that it is
not allowed to call disable_irq() from inside a netpoll callback
function. Hence eliminate the disable_irq() / enable_irq() pair
from the e1000 netpoll function. This patch avoids that the e1000
networking driver triggers the following complaint:

BUG: sleeping function called from invalid context at kernel/irq/manage.c:104

Call Trace:
 [<ffffffff814d1ec5>] dump_stack+0x4c/0x65
 [<ffffffff8107bcc5>] ___might_sleep+0x175/0x230
 [<ffffffff8107bdba>] __might_sleep+0x3a/0xa0
 [<ffffffff810a78c8>] synchronize_irq+0x38/0xa0
 [<ffffffff810a7a20>] disable_irq+0x20/0x30
 [<ffffffffa04b4442>] e1000_netpoll+0x102/0x130 [e1000e]
 [<ffffffff813ffff2>] netpoll_poll_dev+0x72/0x350
 [<ffffffff81400489>] netpoll_send_skb_on_dev+0x1b9/0x2b0
 [<ffffffff81400842>] netpoll_send_udp+0x2c2/0x430
 [<ffffffffa058187f>] write_msg+0xcf/0x120 [netconsole]
 [<ffffffff810a4682>] call_console_drivers.constprop.25+0xc2/0x250
 [<ffffffff810a5588>] console_unlock+0x328/0x4c0
 [<ffffffff810a59f0>] vprintk_emit+0x2d0/0x570
 [<ffffffff810a5def>] vprintk_default+0x1f/0x30
 [<ffffffff814cf680>] printk+0x46/0x48

See also "[RFC PATCH net-next 00/11] net: remove disable_irq() from
->ndo_poll_controller" (http://thread.gmane.org/gmane.linux.network/342096).

See also patch "sched/wait: Add might_sleep() checks" (kernel v3.19-rc1;
commit e22b886a8a43).

Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Bart Van Assche <bvanassche@acm.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: <stable@vger.kernel.org>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |  5 +++++
 drivers/net/ethernet/intel/e1000/e1000_main.c | 27 ++++++++++++++++++++++-----
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 6970710..d85d19f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -323,6 +323,11 @@ struct e1000_adapter {
 	struct delayed_work watchdog_task;
 	struct delayed_work fifo_stall_task;
 	struct delayed_work phy_info_task;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	/* Used to serialize e1000 interrupts and the e1000 netpoll callback. */
+	spinlock_t netpoll_lock;
+#endif
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7f997d3..36870f8 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1313,6 +1313,9 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	spin_lock_init(&adapter->netpoll_lock);
+#endif
 
 	set_bit(__E1000_DOWN, &adapter->flags);
 
@@ -3751,10 +3754,8 @@ void e1000_update_stats(struct e1000_adapter *adapter)
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
 
@@ -3796,6 +3797,24 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t e1000_intr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	irqreturn_t ret;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->netpoll_lock, flags);
+	ret = __e1000_intr(irq, adapter);
+	spin_unlock_irqrestore(&adapter->netpoll_lock, flags);
+#else
+	ret = __e1000_intr(irq, adapter);
+#endif
+
+	return ret;
+}
+
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
@@ -5220,9 +5239,7 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	enable_irq(adapter->pdev->irq);
 }
 #endif
 
-- 
2.1.4
