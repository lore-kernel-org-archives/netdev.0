From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] tg3 locking update (with NAPI overtones)
Date: Tue, 26 Nov 2002 18:41:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE406AE.2000908@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060406020603000809040809"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060406020603000809040809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch is based on tg3.c as found in 2.4.20-rc3 or the 
latest Linus 2.5.x kernel, and originates from two motivations:

* When net drivers move TX completion from interrupt to dev->poll(), 
this allows the rethinking of some traditional locking, namely 
eliminating a lock in dev->start_xmit() that most drivers implement 
these days.

* Specific to the tg3 implementation, spin-lock-irq is held during NIC 
hardware halt and re-initialization (and a few other operations).  In 
general a goal is to change this; the driver may wind up holding 
interrupts disabled for longer than prudence dictates.  The attached 
patch does not address this issue directly, but it does begin to lay the 
groundwork for my upcoming solution :)

I mention "NAPI" in the subject because other NAPI drivers may wish to 
re-examine their locking as well, and this patch could serve as a basis 
for discussion.


Overall, I believe the attached patch (after testing/debugging/review) 
will make the tg3 driver faster due to less locking in dev->start_xmit, 
and more friendly system interaction because interrupts are being 
disabled->enabled less frequently by this driver.


Here is a function-by-function description of changes, which gives one a 
better idea of the locking changes that may be a found in a driver:

all functions:  s/spin_lock_irq/spin_lock_irqsave/ to be more 
conservative and "obviously safe"

all functions:  locking ordering now reversed:  dev->xmit_lock obtained 
before tp->lock.

tg3_set_power_state: Do not call tg3_halt(), the one case where this 
code path is hit, the caller has already called tg3_halt()

tg3_poll: hold dev->xmit_lock when checking for TX work, and running TX 
completion cycle.  tp->tx_lock GC'd.

tg3_tx_timeout: net stack already holds dev->xmit_lock.  tx_lock GC'd.

tg3_{4gbug}_start_xmit: net stack already holds dev->xmit_lock, no other 
locks needed (whee!), so:  tp->lock GC'd.

tg3_change_mtu: get dev->xmit_lock instead of tp->tx_lock. wrap locking 
in netif_start_queue ... netif_wake_queue.

tg3_timer: get xmit_lock instead of tx_lock.  wrap NIC reset in 
netif_start_queue ... netif_wake_queue.

tg3_open: no need for tx locking, just move netif_start_queue down to 
the bottom of the function.

tg3_close: s/tp->tx_lock/dev->xmit_lock/

tg3_get_regs: likewise

tg3_ethtool_ioctl: likewise, plus netif_{start,wake}_queue wrap around 
NIC reset

tg3_vlan_rx_register: remove TX lock

tg3_vlan_rx_kill_vid: remove TX lock

tg3_suspend: s/tp->tx_lock/dev->xmit_lock/, netif_{start,wake}_queue wrap

tg3_resume: likewise

Th-th-th-th-that's all, folks!

Questions/comments/flames requested.

--------------060406020603000809040809
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Tue Nov 26 18:05:17 2002
+++ b/drivers/net/tg3.c	Tue Nov 26 18:05:17 2002
@@ -63,7 +63,7 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.2"
+#define DRV_MODULE_VERSION	"1.2txlock"
 #define DRV_MODULE_RELDATE	"Nov 14, 2002"
 
 #define TG3_DEF_MAC_MODE	0
@@ -416,7 +416,6 @@
 }
 
 static int tg3_setup_phy(struct tg3 *);
-static int tg3_halt(struct tg3 *);
 
 static int tg3_set_power_state(struct tg3 *tp, int state)
 {
@@ -487,8 +486,6 @@
 		tg3_setup_phy(tp);
 	}
 
-	tg3_halt(tp);
-
 	pci_read_config_word(tp->pdev, pm + PCI_PM_PMC, &power_caps);
 
 	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE) {
@@ -2073,8 +2070,14 @@
 	struct tg3 *tp = netdev->priv;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	int done;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
+	spin_lock(&tp->dev->xmit_lock);
+	if (sblk->idx[0].tx_consumer != tp->tx_cons)
+		tg3_tx(tp);
+	spin_unlock(&tp->dev->xmit_lock);
+
+	spin_lock_irqsave(&tp->lock, flags);
 
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -2086,12 +2089,6 @@
 		}
 	}
 
-	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
-		spin_lock(&tp->tx_lock);
-		tg3_tx(tp);
-		spin_unlock(&tp->tx_lock);
-	}
-
 	done = 1;
 	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
 		int orig_budget = *budget;
@@ -2114,7 +2111,7 @@
 		tg3_unmask_ints(tp);
 	}
 
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return (done ? 0 : 1);
 }
@@ -2175,23 +2172,23 @@
 
 static void tg3_init_rings(struct tg3 *);
 static int tg3_init_hw(struct tg3 *);
+static int tg3_halt(struct tg3 *tp);
 
 static void tg3_tx_timeout(struct net_device *dev)
 {
 	struct tg3 *tp = dev->priv;
+	unsigned long flags;
 
 	printk(KERN_ERR PFX "%s: transmit timed out, resetting\n",
 	       dev->name);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_halt(tp);
 	tg3_init_rings(tp);
 	tg3_init_hw(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	netif_wake_queue(dev);
 }
@@ -2371,35 +2368,12 @@
 	unsigned int i;
 	u32 len, entry, base_flags, mss;
 	int would_hit_hwbug;
-	unsigned long flags;
 
 	len = (skb->len - skb->data_len);
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via tp->poll inside of a software
-	 * interrupt.  Rejoice!
-	 *
-	 * Actually, things are not so simple.  If we are to take a hw
-	 * IRQ here, we can deadlock, consider:
-	 *
-	 *       CPU1		CPU2
-	 *   tg3_start_xmit
-	 *   take tp->tx_lock
-	 *			tg3_timer
-	 *			take tp->lock
-	 *   tg3_interrupt
-	 *   spin on tp->lock
-	 *			spin on tp->tx_lock
-	 *
-	 * So we really do need to disable interrupts when taking
-	 * tx_lock here.
-	 */
-	spin_lock_irqsave(&tp->tx_lock, flags);
-
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&tp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -2551,8 +2525,6 @@
 		netif_stop_queue(dev);
 
 out_unlock:
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
-
 	dev->trans_start = jiffies;
 
 	return 0;
@@ -2563,35 +2535,12 @@
 	struct tg3 *tp = dev->priv;
 	dma_addr_t mapping;
 	u32 len, entry, base_flags, mss;
-	unsigned long flags;
 
 	len = (skb->len - skb->data_len);
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via tp->poll inside of a software
-	 * interrupt.  Rejoice!
-	 *
-	 * Actually, things are not so simple.  If we are to take a hw
-	 * IRQ here, we can deadlock, consider:
-	 *
-	 *       CPU1		CPU2
-	 *   tg3_start_xmit
-	 *   take tp->tx_lock
-	 *			tg3_timer
-	 *			take tp->lock
-	 *   tg3_interrupt
-	 *   spin on tp->lock
-	 *			spin on tp->tx_lock
-	 *
-	 * So we really do need to disable interrupts when taking
-	 * tx_lock here.
-	 */
-	spin_lock_irqsave(&tp->tx_lock, flags);
-
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&tp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -2697,8 +2646,6 @@
 	if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
-
 	dev->trans_start = jiffies;
 
 	return 0;
@@ -2707,6 +2654,7 @@
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct tg3 *tp = dev->priv;
+	unsigned long flags;
 
 	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU)
 		return -EINVAL;
@@ -2719,8 +2667,9 @@
 		return 0;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	netif_stop_queue(tp->dev);
+	spin_lock_bh(&tp->dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_halt(tp);
 
@@ -2734,8 +2683,10 @@
 	tg3_init_rings(tp);
 	tg3_init_hw(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->dev->xmit_lock);
+
+	netif_wake_queue(tp->dev);
 
 	return 0;
 }
@@ -4500,9 +4451,10 @@
 static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&tp->dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* All of this garbage is because when using non-tagged
 	 * IRQ status the mailbox/status_block protocol the chip
@@ -4517,9 +4469,11 @@
 	}
 
 	if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
+		netif_stop_queue(tp->dev);
 		tg3_halt(tp);
 		tg3_init_rings(tp);
 		tg3_init_hw(tp);
+		netif_wake_queue(tp->dev);
 	}
 
 	/* This part only runs once per second. */
@@ -4582,8 +4536,8 @@
 		tp->asf_counter = tp->asf_multiplier;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock(&tp->dev->xmit_lock);
 
 	tp->timer.expires = jiffies + tp->timer_offset;
 	add_timer(&tp->timer);
@@ -4593,15 +4547,14 @@
 {
 	struct tg3 *tp = dev->priv;
 	int err;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_disable_ints(tp);
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	/* If you move this call, make sure TG3_FLAG_HOST_TXDS in
 	 * tp->tg3_flags is accurate at that new place.
@@ -4618,8 +4571,7 @@
 		return err;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_init_rings(tp);
 
@@ -4641,8 +4593,7 @@
 		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	if (err) {
 		free_irq(dev->irq, dev);
@@ -4650,15 +4601,13 @@
 		return err;
 	}
 
-	netif_start_queue(dev);
-
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_enable_ints(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	netif_start_queue(dev);
 
 	return 0;
 }
@@ -4913,13 +4862,14 @@
 static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = dev->priv;
+	unsigned long flags;
 
 	netif_stop_queue(dev);
 
 	del_timer_sync(&tp->timer);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_bh(&tp->dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 #if 0
 	tg3_dump_state(tp);
 #endif
@@ -4933,8 +4883,8 @@
 		  TG3_FLAG_GOT_SERDES_FLOWCTL);
 	netif_carrier_off(tp->dev);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->dev->xmit_lock);
 
 	free_irq(dev->irq, dev);
 
@@ -5143,6 +5093,7 @@
 
 static u8 *tg3_get_regs(struct tg3 *tp)
 {
+	unsigned long flags;
 	u8 *orig_p = kmalloc(TG3_REGDUMP_LEN, GFP_KERNEL);
 	u8 *p;
 	int i;
@@ -5152,8 +5103,8 @@
 
 	memset(orig_p, 0, TG3_REGDUMP_LEN);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_bh(&tp->dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 #define __GET_REG32(reg)	(*((u32 *)(p))++ = tr32(reg))
 #define GET_REG32_LOOP(base,len)		\
@@ -5202,8 +5153,8 @@
 #undef GET_REG32_LOOP
 #undef GET_REG32_1
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->dev->xmit_lock);
 
 	return orig_p;
 }
@@ -5213,6 +5164,7 @@
 	struct tg3 *tp = dev->priv;
 	struct pci_dev *pci_dev = tp->pdev;
 	u32 ethcmd;
+	unsigned long flags;
 
 	if (copy_from_user (&ethcmd, useraddr, sizeof (ethcmd)))
 		return -EFAULT;
@@ -5300,8 +5252,7 @@
 				return -EINVAL;
 		}
 
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		spin_lock_irqsave(&tp->lock, flags);
 
 		tp->link_config.autoneg = cmd.autoneg;
 		if (cmd.autoneg == AUTONEG_ENABLE) {
@@ -5314,8 +5265,7 @@
 		}
 
 		tg3_setup_phy(tp);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_irqrestore(&tp->lock, flags);
 
 		return 0;
 	}
@@ -5453,8 +5403,9 @@
 		    (ering.tx_pending > TG3_TX_RING_SIZE - 1))
 			return -EINVAL;
 
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		netif_stop_queue(tp->dev);
+		spin_lock_bh(&tp->dev->xmit_lock);
+		spin_lock_irqsave(&tp->lock, flags);
 
 		tp->rx_pending = ering.rx_pending;
 #if TG3_MINI_RING_WORKS
@@ -5466,9 +5417,9 @@
 		tg3_halt(tp);
 		tg3_init_rings(tp);
 		tg3_init_hw(tp);
+		spin_unlock_irqrestore(&tp->lock, flags);
+		spin_unlock_bh(&tp->dev->xmit_lock);
 		netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
 
 		return 0;
 	}
@@ -5491,8 +5442,9 @@
 		if (copy_from_user(&epause, useraddr, sizeof(epause)))
 			return -EFAULT;
 
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		netif_stop_queue(tp->dev);
+		spin_lock_bh(&tp->dev->xmit_lock);
+		spin_lock_irqsave(&tp->lock, flags);
 		if (epause.autoneg)
 			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 		else
@@ -5508,8 +5460,9 @@
 		tg3_halt(tp);
 		tg3_init_rings(tp);
 		tg3_init_hw(tp);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_irqrestore(&tp->lock, flags);
+		spin_unlock_bh(&tp->dev->xmit_lock);
+		netif_wake_queue(tp->dev);
 
 		return 0;
 	}
@@ -5644,29 +5597,27 @@
 static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
 	struct tg3 *tp = dev->priv;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tp->vlgrp = grp;
 
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
 static void tg3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct tg3 *tp = dev->priv;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 }
 #endif
 
@@ -6852,7 +6803,6 @@
 	tp->grc_mode |= GRC_MODE_BSWAP_NONFRM_DATA;
 #endif
 	spin_lock_init(&tp->lock);
-	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
 
 	tp->regs = (unsigned long) ioremap(tg3reg_base, tg3reg_len);
@@ -6994,36 +6944,37 @@
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = dev->priv;
 	int err;
+	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 	tg3_disable_ints(tp);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	netif_device_detach(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 	tg3_halt(tp);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&dev->xmit_lock);
 
 	err = tg3_set_power_state(tp, state);
 	if (err) {
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		spin_lock_bh(&dev->xmit_lock);
+		spin_lock_irqsave(&tp->lock, flags);
 
 		tg3_init_rings(tp);
 		tg3_init_hw(tp);
+		tg3_enable_ints(tp);
 
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_irqrestore(&tp->lock, flags);
+		spin_unlock_bh(&dev->xmit_lock);
 
 		netif_device_attach(dev);
+		netif_wake_queue(dev);
 	}
 
 	return err;
@@ -7034,6 +6985,7 @@
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = dev->priv;
 	int err;
+	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
@@ -7042,17 +6994,18 @@
 	if (err)
 		return err;
 
-	netif_device_attach(dev);
-
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock_bh(&tp->dev->xmit_lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	tg3_init_rings(tp);
 	tg3_init_hw(tp);
 	tg3_enable_ints(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_bh(&tp->dev->xmit_lock);
+
+	netif_device_attach(dev);
+	netif_wake_queue(dev);
 
 	return 0;
 }
diff -Nru a/drivers/net/tg3.h b/drivers/net/tg3.h
--- a/drivers/net/tg3.h	Tue Nov 26 18:05:17 2002
+++ b/drivers/net/tg3.h	Tue Nov 26 18:05:17 2002
@@ -1733,15 +1733,17 @@
 	 * lock: Held during all operations except TX packet
 	 *       processing.
 	 *
-	 * tx_lock: Held during tg3_start_xmit{,_4gbug} and tg3_tx
+	 * dev->xmit_lock: Held in tg3_tx, and by upper layer during
+	 * tg3_start_xmit{,_4gbug}, plus assorted driver areas
+	 * that happen to relate to the TX engine.
 	 *
 	 * If you want to shut up all asynchronous processing you must
-	 * acquire both locks, 'lock' taken before 'tx_lock'.  IRQs must
-	 * be disabled to take 'lock' but only softirq disabling is
-	 * necessary for acquisition of 'tx_lock'.
+	 * acquire both locks, 'xmit_lock' taken before 'lock'.  xmit_lock
+	 * is often acquired by the upper layers, so pay attention.  IRQs must
+	 * be disabled to take 'lock' but only softirq/BH disabling is
+	 * necessary for acquisition of 'xmit_lock'.
 	 */
 	spinlock_t			lock;
-	spinlock_t			tx_lock;
 
 	u32				tx_prod;
 	u32				tx_cons;

--------------060406020603000809040809--
