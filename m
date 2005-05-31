From: "David S. Miller" <davem@davemloft.net>
Subject: Locking model for NAPI drivers
Date: Tue, 31 May 2005 15:48:47 -0700 (PDT)
Message-ID: <20050531.154847.63995530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I was doing some brainstorming to try and fix a nagging problem in
the tg3 driver which suggested that doing the SMP locking differently
might be the best and cleanest solution.

The tg3 problem is that it can do an skb_copy() in HW IRQ disabled
context which is illegal.

But then I noticed that the spinlocks really don't need IRQ disabling.
Only the tinyest sliver of code, the interrupt handler, actually runs
in HW interrupt context.  The bulk of the driver runs in SW interrupt
context.

So the idea is, if we can make all of the spinlocks BH locks we'll
solve a whole bunch of problems:

1) skb_copy() will run in BH context, fixing that bug
2) the driver will actually produce useful profiling data
   via oprofile and friends since timer interrupts will run
   even while holding the locks
3) moving long delays (particually when doing link settings)
   into work queues becomes much easier, at least in theory

Once we make this transformation, we need some way to synchronize
with the IRQ handler when shutting down the device or making major
configuration changes to the chip.

The idea I came up with is a two-bit atomic bitmask.  When base
level code wants to quiesce interrupt processing, it takes the
necessary driver spinlocks, sets the "SYNC" bit in the bitmask,
forces and IRQ to be asserted by the tg3 card, then waits for the
COMPLETE bit to get set by the interrupt handler.

The total cost of this scheme under normal operation is a single
shared memory location read at hw IRQ time.

If e1000, ixgb, s2io, the infiniband drivers, and friends can force
the chip to signal an interrupt they can do this kind of locking
enhancement as well.

Here is the full implementation I'm testing currently with Michael
Chan for tg3.  Note how tg3_tx() can now directly call dev_kfree_skb()
directly (instead of dev_kfree_skb_irq()) and most of tg3_poll() can
now run totally lockless.

[TG3]: Eliminate all hw IRQ handler spinlocks.

Move all driver spinlocks to be taken at sw IRQ
context only.

This fixes the skb_copy() we were doing with hw
IRQs disabled (which is illegal and triggers a
BUG() with HIGHMEM enabled).  It also simplifies
the locking all over the driver tremendously.

We accomplish this feat by creating a special
sequence to synchronize with the hw IRQ handler
using a 2-bit atomic state.

Signed-off-by: David S. Miller <davem@davemloft.net>

--- 1/drivers/net/tg3.c.~1~	2005-05-30 15:29:23.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-05-31 14:20:08.000000000 -0700
@@ -332,12 +332,10 @@ static struct {
 static void tg3_write_indirect_reg32(struct tg3 *tp, u32 off, u32 val)
 {
 	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) != 0) {
-		unsigned long flags;
-
-		spin_lock_irqsave(&tp->indirect_lock, flags);
+		spin_lock_bh(&tp->indirect_lock);
 		pci_write_config_dword(tp->pdev, TG3PCI_REG_BASE_ADDR, off);
 		pci_write_config_dword(tp->pdev, TG3PCI_REG_DATA, val);
-		spin_unlock_irqrestore(&tp->indirect_lock, flags);
+		spin_unlock_bh(&tp->indirect_lock);
 	} else {
 		writel(val, tp->regs + off);
 		if ((tp->tg3_flags & TG3_FLAG_5701_REG_WRITE_BUG) != 0)
@@ -348,12 +346,10 @@ static void tg3_write_indirect_reg32(str
 static void _tw32_flush(struct tg3 *tp, u32 off, u32 val)
 {
 	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) != 0) {
-		unsigned long flags;
-
-		spin_lock_irqsave(&tp->indirect_lock, flags);
+		spin_lock_bh(&tp->indirect_lock);
 		pci_write_config_dword(tp->pdev, TG3PCI_REG_BASE_ADDR, off);
 		pci_write_config_dword(tp->pdev, TG3PCI_REG_DATA, val);
-		spin_unlock_irqrestore(&tp->indirect_lock, flags);
+		spin_unlock_bh(&tp->indirect_lock);
 	} else {
 		void __iomem *dest = tp->regs + off;
 		writel(val, dest);
@@ -393,28 +389,24 @@ static inline void _tw32_tx_mbox(struct 
 
 static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->indirect_lock, flags);
+	spin_lock_bh(&tp->indirect_lock);
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_DATA, val);
 
 	/* Always leave this as zero. */
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, 0);
-	spin_unlock_irqrestore(&tp->indirect_lock, flags);
+	spin_unlock_bh(&tp->indirect_lock);
 }
 
 static void tg3_read_mem(struct tg3 *tp, u32 off, u32 *val)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->indirect_lock, flags);
+	spin_lock_bh(&tp->indirect_lock);
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
 	pci_read_config_dword(tp->pdev, TG3PCI_MEM_WIN_DATA, val);
 
 	/* Always leave this as zero. */
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, 0);
-	spin_unlock_irqrestore(&tp->indirect_lock, flags);
+	spin_unlock_bh(&tp->indirect_lock);
 }
 
 static void tg3_disable_ints(struct tg3 *tp)
@@ -438,7 +430,7 @@ static void tg3_enable_ints(struct tg3 *
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 		     (tp->last_tag << 24));
 	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
-
+	tp->irq_state = 0;
 	tg3_cond_int(tp);
 }
 
@@ -475,6 +467,8 @@ static void tg3_restart_ints(struct tg3 
 		     tp->last_tag << 24);
 	mmiowb();
 
+	BUG_ON(tp->irq_state);
+
 	/* When doing tagged status, this work check is unnecessary.
 	 * The last_tag we write above tells the chip which piece of
 	 * work we've completed.
@@ -2573,7 +2567,7 @@ static void tg3_tx(struct tg3 *tp)
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb(skb);
 	}
 
 	tp->tx_cons = sw_idx;
@@ -2879,11 +2873,8 @@ static int tg3_poll(struct net_device *n
 {
 	struct tg3 *tp = netdev_priv(netdev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned long flags;
 	int done;
 
-	spin_lock_irqsave(&tp->lock, flags);
-
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -2891,7 +2882,9 @@ static int tg3_poll(struct net_device *n
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
 				(sblk->status & ~SD_STATUS_LINK_CHG);
+			spin_lock(&tp->lock);
 			tg3_setup_phy(tp, 0);
+			spin_unlock(&tp->lock);
 		}
 	}
 
@@ -2902,8 +2895,6 @@ static int tg3_poll(struct net_device *n
 		spin_unlock(&tp->tx_lock);
 	}
 
-	spin_unlock_irqrestore(&tp->lock, flags);
-
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with dev->poll()
@@ -2928,15 +2919,56 @@ static int tg3_poll(struct net_device *n
 	/* if no more work, tell net stack and NIC we're done */
 	done = !tg3_has_work(tp);
 	if (done) {
-		spin_lock_irqsave(&tp->lock, flags);
+		spin_lock(&tp->lock);
 		__netif_rx_complete(netdev);
 		tg3_restart_ints(tp);
-		spin_unlock_irqrestore(&tp->lock, flags);
+		spin_unlock(&tp->lock);
 	}
 
 	return (done ? 0 : 1);
 }
 
+static void tg3_irq_quiesce(struct tg3 *tp)
+{
+	BUG_ON(test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state));
+
+	set_bit(TG3_IRQSTATE_SYNC, &tp->irq_state);
+	smp_mb();
+	tw32(GRC_LOCAL_CTRL,
+	     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
+
+	while (!test_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state))
+		cpu_relax();
+}
+
+static inline int tg3_irq_sync(struct tg3 *tp)
+{
+	if (test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state)) {
+		set_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state);
+		return 1;
+	}
+	return 0;
+}
+
+/* Fully shutdown all tg3 driver activity elsewhere in the system.
+ * If irq_sync is non-zero, then the IRQ handler must be synchronized
+ * with as well.  Most of the time, this is not necessary except when
+ * shutting down the device.
+ */
+static inline void tg3_full_lock(struct tg3 *tp, int irq_sync)
+{
+	if (irq_sync)
+		tg3_irq_quiesce(tp);
+	spin_lock_bh(&tp->lock);
+	spin_lock(&tp->tx_lock);
+}
+
+static inline void tg3_full_unlock(struct tg3 *tp)
+{
+	spin_unlock(&tp->tx_lock);
+	spin_unlock_bh(&tp->lock);
+}
+
 /* MSI ISR - No need to check for interrupt sharing and no need to
  * flush status block and interrupt mailbox. PCI ordering rules
  * guarantee that MSI will arrive after the status block.
@@ -2946,9 +2978,6 @@ static irqreturn_t tg3_msi(int irq, void
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
 
 	/*
 	 * Writing any value to intr-mbox-0 clears PCI INTA# and
@@ -2959,6 +2988,8 @@ static irqreturn_t tg3_msi(int irq, void
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	tp->last_tag = sblk->status_tag;
+	if (tg3_irq_sync(tp))
+		goto out;
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -2967,9 +2998,7 @@ static irqreturn_t tg3_msi(int irq, void
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     tp->last_tag << 24);
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(1);
 }
 
@@ -2978,11 +3007,8 @@ static irqreturn_t tg3_interrupt(int irq
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned long flags;
 	unsigned int handled = 1;
 
-	spin_lock_irqsave(&tp->lock, flags);
-
 	/* In INTx mode, it is possible for the interrupt to arrive at
 	 * the CPU before the status block posted prior to the interrupt.
 	 * Reading the PCI State register will confirm whether the
@@ -2999,6 +3025,8 @@ static irqreturn_t tg3_interrupt(int irq
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
+		if (tg3_irq_sync(tp))
+			goto out;
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3013,9 +3041,7 @@ static irqreturn_t tg3_interrupt(int irq
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3024,11 +3050,8 @@ static irqreturn_t tg3_interrupt_tagged(
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned long flags;
 	unsigned int handled = 1;
 
-	spin_lock_irqsave(&tp->lock, flags);
-
 	/* In INTx mode, it is possible for the interrupt to arrive at
 	 * the CPU before the status block posted prior to the interrupt.
 	 * Reading the PCI State register will confirm whether the
@@ -3046,6 +3069,8 @@ static irqreturn_t tg3_interrupt_tagged(
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
 		tp->last_tag = sblk->status_tag;
+		if (tg3_irq_sync(tp))
+			goto out;
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3060,9 +3085,7 @@ static irqreturn_t tg3_interrupt_tagged(
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3101,8 +3124,7 @@ static void tg3_reset_task(void *_data)
 
 	tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 
 	restart_timer = tp->tg3_flags2 & TG3_FLG2_RESTART_TIMER;
 	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
@@ -3112,8 +3134,7 @@ static void tg3_reset_task(void *_data)
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	if (restart_timer)
 		mod_timer(&tp->timer, jiffies + 1);
@@ -3219,39 +3240,21 @@ static int tg3_start_xmit(struct sk_buff
 	unsigned int i;
 	u32 len, entry, base_flags, mss;
 	int would_hit_hwbug;
-	unsigned long flags;
 
 	len = skb_headlen(skb);
 
 	/* No BH disabling for tx_lock here.  We are running in BH disabled
 	 * context and TX reclaim runs via tp->poll inside of a software
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
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	local_irq_save(flags);
-	if (!spin_trylock(&tp->tx_lock)) { 
-		local_irq_restore(flags);
+	if (!spin_trylock(&tp->tx_lock))
 		return NETDEV_TX_LOCKED; 
-	} 
 
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&tp->tx_lock, flags);
+		spin_unlock(&tp->tx_lock);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return NETDEV_TX_BUSY;
@@ -3416,7 +3419,7 @@ static int tg3_start_xmit(struct sk_buff
 
 out_unlock:
     	mmiowb();
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
+	spin_unlock(&tp->tx_lock);
 
 	dev->trans_start = jiffies;
 
@@ -3450,8 +3453,8 @@ static int tg3_change_mtu(struct net_dev
 	}
 
 	tg3_netif_stop(tp);
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+
+	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 
@@ -3461,8 +3464,7 @@ static int tg3_change_mtu(struct net_dev
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	return 0;
 }
@@ -5083,9 +5085,9 @@ static int tg3_set_mac_addr(struct net_d
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	__tg3_set_mac_addr(tp);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
 
 	return 0;
 }
@@ -5797,10 +5799,8 @@ static void tg3_periodic_fetch_stats(str
 static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
-	unsigned long flags;
 
-	spin_lock_irqsave(&tp->lock, flags);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&tp->lock);
 
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
 		/* All of this garbage is because when using non-tagged
@@ -5817,8 +5817,7 @@ static void tg3_timer(unsigned long __op
 
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
 			tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
-			spin_unlock(&tp->tx_lock);
-			spin_unlock_irqrestore(&tp->lock, flags);
+			spin_unlock(&tp->lock);
 			schedule_work(&tp->reset_task);
 			return;
 		}
@@ -5886,8 +5885,7 @@ static void tg3_timer(unsigned long __op
 		tp->asf_counter = tp->asf_multiplier;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock(&tp->lock);
 
 	tp->timer.expires = jiffies + tp->timer_offset;
 	add_timer(&tp->timer);
@@ -6002,14 +6000,12 @@ static int tg3_test_msi(struct tg3 *tp)
 	/* Need to reset the chip because the MSI cycle may have terminated
 	 * with Master Abort.
 	 */
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 	err = tg3_init_hw(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	if (err)
 		free_irq(tp->pdev->irq, dev);
@@ -6022,14 +6018,12 @@ static int tg3_open(struct net_device *d
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tg3_disable_ints(tp);
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	/* The placement of this call is tied
 	 * to the setup and use of Host TX descriptors.
@@ -6076,8 +6070,7 @@ static int tg3_open(struct net_device *d
 		return err;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	err = tg3_init_hw(tp);
 	if (err) {
@@ -6101,8 +6094,7 @@ static int tg3_open(struct net_device *d
 		tp->timer.function = tg3_timer;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	if (err) {
 		free_irq(tp->pdev->irq, dev);
@@ -6118,8 +6110,7 @@ static int tg3_open(struct net_device *d
 		err = tg3_test_msi(tp);
 
 		if (err) {
-			spin_lock_irq(&tp->lock);
-			spin_lock(&tp->tx_lock);
+			tg3_full_lock(tp, 0);
 
 			if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 				pci_disable_msi(tp->pdev);
@@ -6129,22 +6120,19 @@ static int tg3_open(struct net_device *d
 			tg3_free_rings(tp);
 			tg3_free_consistent(tp);
 
-			spin_unlock(&tp->tx_lock);
-			spin_unlock_irq(&tp->lock);
+			tg3_full_unlock(tp);
 
 			return err;
 		}
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	add_timer(&tp->timer);
 	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
 	tg3_enable_ints(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	netif_start_queue(dev);
 
@@ -6390,8 +6378,7 @@ static int tg3_close(struct net_device *
 
 	del_timer_sync(&tp->timer);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 #if 0
 	tg3_dump_state(tp);
 #endif
@@ -6405,8 +6392,7 @@ static int tg3_close(struct net_device *
 		  TG3_FLAG_GOT_SERDES_FLOWCTL);
 	netif_carrier_off(tp->dev);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	free_irq(tp->pdev->irq, dev);
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
@@ -6443,16 +6429,15 @@ static unsigned long calc_crc_errors(str
 	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
-		unsigned long flags;
 		u32 val;
 
-		spin_lock_irqsave(&tp->lock, flags);
+		spin_lock_bh(&tp->lock);
 		if (!tg3_readphy(tp, 0x1e, &val)) {
 			tg3_writephy(tp, 0x1e, val | 0x8000);
 			tg3_readphy(tp, 0x14, &val);
 		} else
 			val = 0;
-		spin_unlock_irqrestore(&tp->lock, flags);
+		spin_unlock_bh(&tp->lock);
 
 		tp->phy_crc_errors += val;
 
@@ -6714,11 +6699,9 @@ static void tg3_set_rx_mode(struct net_d
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 	__tg3_set_rx_mode(dev);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 }
 
 #define TG3_REGDUMP_LEN		(32 * 1024)
@@ -6740,8 +6723,7 @@ static void tg3_get_regs(struct net_devi
 
 	memset(p, 0, TG3_REGDUMP_LEN);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 #define __GET_REG32(reg)	(*(p)++ = tr32(reg))
 #define GET_REG32_LOOP(base,len)		\
@@ -6791,8 +6773,7 @@ do {	p = (u32 *)(orig_p + (reg));		\
 #undef GET_REG32_LOOP
 #undef GET_REG32_1
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 }
 
 static int tg3_get_eeprom_len(struct net_device *dev)
@@ -6968,8 +6949,7 @@ static int tg3_set_settings(struct net_d
 			return -EINVAL;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tp->link_config.autoneg = cmd->autoneg;
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -6985,8 +6965,7 @@ static int tg3_set_settings(struct net_d
 	if (netif_running(dev))
 		tg3_setup_phy(tp, 1);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7022,12 +7001,12 @@ static int tg3_set_wol(struct net_device
 	    !(tp->tg3_flags & TG3_FLAG_SERDES_WOL_CAP))
 		return -EINVAL;
   
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	if (wol->wolopts & WAKE_MAGIC)
 		tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 	else
 		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
   
 	return 0;
 }
@@ -7067,7 +7046,7 @@ static int tg3_nway_reset(struct net_dev
 	if (!netif_running(dev))
 		return -EAGAIN;
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	r = -EINVAL;
 	tg3_readphy(tp, MII_BMCR, &bmcr);
 	if (!tg3_readphy(tp, MII_BMCR, &bmcr) &&
@@ -7075,7 +7054,7 @@ static int tg3_nway_reset(struct net_dev
 		tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART);
 		r = 0;
 	}
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
   
 	return r;
 }
@@ -7106,8 +7085,7 @@ static int tg3_set_ringparam(struct net_
 	if (netif_running(dev))
 		tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
   
 	tp->rx_pending = ering->rx_pending;
 
@@ -7123,8 +7101,7 @@ static int tg3_set_ringparam(struct net_
 		tg3_netif_start(tp);
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7145,8 +7122,8 @@ static int tg3_set_pauseparam(struct net
 	if (netif_running(dev))
 		tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
+
 	if (epause->autoneg)
 		tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	else
@@ -7165,8 +7142,8 @@ static int tg3_set_pauseparam(struct net
 		tg3_init_hw(tp);
 		tg3_netif_start(tp);
 	}
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7187,12 +7164,12 @@ static int tg3_set_rx_csum(struct net_de
   		return 0;
   	}
   
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	if (data)
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
 	else
 		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
   
 	return 0;
 }
@@ -7714,8 +7691,7 @@ static void tg3_self_test(struct net_dev
 		if (netif_running(dev))
 			tg3_netif_stop(tp);
 
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		tg3_full_lock(tp, 1);
 
 		tg3_halt(tp, RESET_KIND_SUSPEND, 1);
 		tg3_nvram_lock(tp);
@@ -7737,14 +7713,14 @@ static void tg3_self_test(struct net_dev
 			data[4] = 1;
 		}
 
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		tg3_full_unlock(tp);
+
 		if (tg3_test_interrupt(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
 			data[5] = 1;
 		}
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+
+		tg3_full_lock(tp, 0);
 
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
@@ -7752,8 +7728,8 @@ static void tg3_self_test(struct net_dev
 			tg3_init_hw(tp);
 			tg3_netif_start(tp);
 		}
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+
+		tg3_full_unlock(tp);
 	}
 }
 
@@ -7774,9 +7750,9 @@ static int tg3_ioctl(struct net_device *
 		if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		spin_lock_irq(&tp->lock);
+		spin_lock_bh(&tp->lock);
 		err = tg3_readphy(tp, data->reg_num & 0x1f, &mii_regval);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_bh(&tp->lock);
 
 		data->val_out = mii_regval;
 
@@ -7790,9 +7766,9 @@ static int tg3_ioctl(struct net_device *
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_irq(&tp->lock);
+		spin_lock_bh(&tp->lock);
 		err = tg3_writephy(tp, data->reg_num & 0x1f, data->val_in);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_bh(&tp->lock);
 
 		return err;
 
@@ -7808,28 +7784,24 @@ static void tg3_vlan_rx_register(struct 
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tp->vlgrp = grp;
 
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 }
 
 static void tg3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 	if (tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 }
 #endif
 
@@ -10136,24 +10108,19 @@ static int tg3_suspend(struct pci_dev *p
 
 	del_timer_sync(&tp->timer);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 	tg3_disable_ints(tp);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	netif_device_detach(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
 	if (err) {
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		tg3_full_lock(tp, 0);
 
 		tg3_init_hw(tp);
 
@@ -10163,8 +10130,7 @@ static int tg3_suspend(struct pci_dev *p
 		netif_device_attach(dev);
 		tg3_netif_start(tp);
 
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		tg3_full_unlock(tp);
 	}
 
 	return err;
@@ -10187,8 +10153,7 @@ static int tg3_resume(struct pci_dev *pd
 
 	netif_device_attach(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tg3_init_hw(tp);
 
@@ -10199,8 +10164,7 @@ static int tg3_resume(struct pci_dev *pd
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	return 0;
 }
--- 1/drivers/net/tg3.h.~1~	2005-05-30 15:29:23.000000000 -0700
+++ 2/drivers/net/tg3.h	2005-05-30 18:55:43.000000000 -0700
@@ -2006,17 +2006,33 @@ struct tg3_ethtool_stats {
 struct tg3 {
 	/* begin "general, frequently-used members" cacheline section */
 
+	/* If the IRQ handler (which runs lockless) needs to be
+	 * quiesced, the following bitmask state is used.  The
+	 * SYNC bit is set by non-IRQ context code to initiate
+	 * the quiescence.  The setter of this bit also forces
+	 * an interrupt to run via the GRC misc host control
+	 * register.
+	 *
+	 * The IRQ handler notes this, disables interrupts, and
+	 * sets the COMPLETE bit.  At this point the SYNC bit
+	 * setter can be assured that interrupts will no longer
+	 * get run.
+	 *
+	 * In this way all SMP driver locks are never acquired
+	 * in hw IRQ context, only sw IRQ context or lower.
+	 */
+	unsigned long			irq_state;
+#define TG3_IRQSTATE_SYNC		0
+#define TG3_IRQSTATE_COMPLETE		1
+
 	/* SMP locking strategy:
 	 *
 	 * lock: Held during all operations except TX packet
 	 *       processing.
 	 *
-	 * tx_lock: Held during tg3_start_xmit{,_4gbug} and tg3_tx
+	 * tx_lock: Held during tg3_start_xmit and tg3_tx
 	 *
-	 * If you want to shut up all asynchronous processing you must
-	 * acquire both locks, 'lock' taken before 'tx_lock'.  IRQs must
-	 * be disabled to take 'lock' but only softirq disabling is
-	 * necessary for acquisition of 'tx_lock'.
+	 * Both of these locks are to be held with BH safety.
 	 */
 	spinlock_t			lock;
 	spinlock_t			indirect_lock;
