From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] r8169: non-NAPI netif_poll_disable removal
Date: Sun, 7 Nov 2004 00:38:00 +0100
Message-ID: <20041106233800.GB4895@electric-eye.fr.zoreil.com>
References: <200411021203.17013.jdmason@us.ibm.com> <20041106145618.GA4895@electric-eye.fr.zoreil.com> <200411060930.27106.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411060930.27106.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> There is an overall problem with the rtl8169_reset_task.  While the driver 
> continues to receive packets, can't allcate any new rx buffers, or the rx dma 
> engine is hung and no rx buffers are processed, the rtl8169_reset_task will 
> schedule itself and loop forever (as dirty_rx != cur_rx).

rtl8169_reset_task() is issued after a rtl8169_hw_reset() which should disable
the Rx/Tx DMA activity. dirty_rx == cur_rx means a complete Rx ring refill.

At first sight, I'd say that a partially refilled Rx ring is still usable if
it verifies 0 < dirty_rx % NUM_RX_DESC < cur_rx % NUM_RX_DESC or
cur_rx % NUM_RX_DESC == 0. I prefer to simply test for a complete refill.

Regarding the initial issue, what about the second patch below (against
2.6.10-rc1-bk15 + latest Jeff's netdev + first patch) ?

It is a bit paranoid but an user already reported a PCI error interruption
on x86 so it should be possible to have a PCI error close to a Tx watchdog
event. Despite what I claimed before, netif_queue_stopped() is not enough to
synchronize the tasks.


diff -puN drivers/net/r8169.c~r8169-250 drivers/net/r8169.c
--- linux-2.6.10-rc1/drivers/net/r8169.c~r8169-250	2004-11-06 21:49:00.000000000 +0100
+++ linux-2.6.10-rc1-fr/drivers/net/r8169.c	2004-11-06 21:49:00.000000000 +0100
@@ -1742,10 +1742,17 @@ static void rtl8169_schedule_work(struct
 
 static void rtl8169_wait_for_quiescence(struct net_device *dev)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
 	netif_poll_disable(dev);
+
+	RTL_W16(IntrMask, 0x0000);
+
+	netif_poll_enable(dev);
 }
 
 static void rtl8169_reinit_task(void *_data)

diff -puN drivers/net/r8169.c~r8169-260 drivers/net/r8169.c
--- linux-2.6.10-rc1/drivers/net/r8169.c~r8169-260	2004-11-06 23:50:59.000000000 +0100
+++ linux-2.6.10-rc1-fr/drivers/net/r8169.c	2004-11-07 00:19:02.000000000 +0100
@@ -150,6 +150,12 @@ enum phy_version {
 	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
 };
 
+enum drv_state {
+	R8169_STATE_NONE = 0,
+	R8169_STATE_UP,
+	R8169_STATE_DOWN,
+	R8169_STATE_TX_TIMEOUT,
+};
 
 #define _R(NAME,MAC,MASK) \
 	{ .name = NAME, .mac_version = MAC, .RxConfigMask = MASK }
@@ -403,6 +409,7 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct work_struct task;
+	unsigned int state;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -423,6 +430,7 @@ static void rtl8169_hw_start(struct net_
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
+static void rtl8169_work(void *);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
@@ -1480,13 +1488,15 @@ rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx;
 
-	INIT_WORK(&tp->task, NULL, dev);
+	INIT_WORK(&tp->task, rtl8169_work, dev);
 
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
 
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
+
+	netif_poll_enable(dev);
 out:
 	return retval;
 
@@ -1506,6 +1516,8 @@ static void rtl8169_hw_reset(void __iome
 	/* Disable interrupts */
 	RTL_W16(IntrMask, 0x0000);
 
+	RTL_W16(IntrStatus, 0x0000);
+
 	/* Reset the chipset */
 	RTL_W8(ChipCmd, CmdReset);
 
@@ -1732,11 +1744,8 @@ static void rtl8169_tx_clear(struct rtl8
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
-static void rtl8169_schedule_work(struct net_device *dev, void (*task)(void *))
+static void rtl8169_schedule_work(struct rtl8169_private *tp)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	PREPARE_WORK(&tp->task, task, dev);
 	schedule_delayed_work(&tp->task, 4);
 }
 
@@ -1750,38 +1759,30 @@ static void rtl8169_wait_for_quiescence(
 	/* Wait for any pending NAPI task to complete */
 	netif_poll_disable(dev);
 
-	RTL_W16(IntrMask, 0x0000);
+	RTL_W16(IntrMask, 0x00);
 
 	netif_poll_enable(dev);
 }
 
-static void rtl8169_reinit_task(void *_data)
+static int rtl8169_down_task(struct net_device *dev)
 {
-	struct net_device *dev = _data;
-	int ret;
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
 
-	if (netif_running(dev)) {
-		rtl8169_wait_for_quiescence(dev);
-		rtl8169_close(dev);
-	}
+	rtl8169_wait_for_quiescence(dev);
+	rtl8169_close(dev);
 
-	ret = rtl8169_open(dev);
-	if (unlikely(ret < 0)) {
-		if (net_ratelimit()) {
-			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
-			       " Rescheduling.\n", dev->name, ret);
-		}
-		rtl8169_schedule_work(dev, rtl8169_reinit_task);
-	}
+	spin_lock_irqsave(&tp->lock, flags);
+	tp->state = R8169_STATE_UP;
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	return 0;
 }
 
-static void rtl8169_reset_task(void *_data)
+static int rtl8169_reset_task(struct net_device *dev)
 {
-	struct net_device *dev = _data;
 	struct rtl8169_private *tp = netdev_priv(dev);
-
-	if (!netif_running(dev))
-		return;
+	int ret = 0;
 
 	rtl8169_wait_for_quiescence(dev);
 
@@ -1792,23 +1793,81 @@ static void rtl8169_reset_task(void *_da
 		rtl8169_init_ring_indexes(tp);
 		rtl8169_hw_start(dev);
 		netif_wake_queue(dev);
+	} else
+		ret = -EAGAIN;
+
+	return ret;
+}
+
+static void rtl8169_work(void *_data)
+{
+	struct net_device *dev = _data;
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
+	static struct {
+		int (*action)(struct net_device *);
+		unsigned int state;
+	} rtl8169_recovery_task[] = {
+		{ rtl8169_reset_task,	R8169_STATE_TX_TIMEOUT },
+		{ rtl8169_down_task,	R8169_STATE_DOWN },
+		{ rtl8169_open,		R8169_STATE_UP },
+		{ NULL,			R8169_STATE_NONE }
+	}, *p;
+
+	if (!netif_running(dev))
+		return;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	for (p = rtl8169_recovery_task; p->action; p++) {
+		if (p->state == tp->state)
+			break;
+	}
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	if (likely(p->action)) {
+		int ret;
+
+		ret = p->action(dev);
+
+		spin_lock_irqsave(&tp->lock, flags);
+
+		if ((ret < 0) || (p->state != tp->state)) {
+			if ((ret < 0) && net_ratelimit()) {
+				printk(PFX KERN_ERR
+				       "%s: task failed (%p). Rescheduling.\n",
+				       dev->name, p->action);
+			}
+			rtl8169_schedule_work(tp);
+		} else
+			tp->state = R8169_STATE_NONE;
+
+		spin_unlock_irqrestore(&tp->lock, flags);
 	} else {
-		if (net_ratelimit()) {
-			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
-			       dev->name);
-		}
-		rtl8169_schedule_work(dev, rtl8169_reset_task);
+		printk(PFX KERN_ERR "%s: nothing to do in delayed task.\n",
+		       dev->name);
 	}
 }
 
 static void rtl8169_tx_timeout(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
 
 	rtl8169_hw_reset(tp->mmio_addr);
 
-	/* Let's wait a bit while any (async) irq lands on */
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	spin_lock_irqsave(&tp->lock, flags);
+
+	/*
+	 * Let's wait a bit while any (async) irq lands on.
+	 * A racing pci error recovery task should be able to recover
+	 * from a TX timeout as well: no need to insist.
+	 */
+	if (likely(tp->state == R8169_STATE_NONE)) {
+		tp->state = R8169_STATE_TX_TIMEOUT;
+		rtl8169_schedule_work(tp);
+	}
+
+	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
@@ -1977,11 +2036,20 @@ static void rtl8169_pcierr_interrupt(str
 
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && (tp->dirty_rx == tp->cur_rx == 0)) {
+		unsigned long flags;
+
 		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
-		rtl8169_schedule_work(dev, rtl8169_reinit_task);
+
+		spin_lock_irqsave(&tp->lock, flags);
+
+		if (likely(tp->state == R8169_STATE_NONE))
+			rtl8169_schedule_work(tp);
+		tp->state = R8169_STATE_DOWN;
+
+		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
 	rtl8169_hw_reset(ioaddr);

_
