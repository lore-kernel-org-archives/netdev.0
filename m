From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH]: Tigon3 new NAPI locking v2
Date: Fri, 03 Jun 2005 12:25:58 -0700 (PDT)
Message-ID: <20050603.122558.88474819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This version incorporates two bug fixes from Michael.

1) Check the mailbox register for 0x1 while polling on the COMPLETE
   state bit.

2) Remove the BUG_ON() check in tg3_restart_ints(), it can legally and
   harmlessly occur.

Point #2 may want some refinements, but this patch below is good
enough for testing.

If someone (please please, pretty please) could be adventurous enough
to attempt this kind of change for e1000, that would be great.

Thanks.

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

--- 1/drivers/net/tg3.c.~1~	2005-06-03 12:11:40.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-06-03 12:15:34.000000000 -0700
@@ -337,12 +337,10 @@ static struct {
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
@@ -353,12 +351,10 @@ static void tg3_write_indirect_reg32(str
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
@@ -398,28 +394,24 @@ static inline void _tw32_tx_mbox(struct 
 
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
@@ -443,7 +435,7 @@ static void tg3_enable_ints(struct tg3 *
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 		     (tp->last_tag << 24));
 	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
-
+	tp->irq_state = 0;
 	tg3_cond_int(tp);
 }
 
@@ -2578,7 +2570,7 @@ static void tg3_tx(struct tg3 *tp)
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb(skb);
 	}
 
 	tp->tx_cons = sw_idx;
@@ -2884,11 +2876,8 @@ static int tg3_poll(struct net_device *n
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
@@ -2896,7 +2885,9 @@ static int tg3_poll(struct net_device *n
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
 				(sblk->status & ~SD_STATUS_LINK_CHG);
+			spin_lock(&tp->lock);
 			tg3_setup_phy(tp, 0);
+			spin_unlock(&tp->lock);
 		}
 	}
 
@@ -2907,8 +2898,6 @@ static int tg3_poll(struct net_device *n
 		spin_unlock(&tp->tx_lock);
 	}
 
-	spin_unlock_irqrestore(&tp->lock, flags);
-
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with dev->poll()
@@ -2933,15 +2922,62 @@ static int tg3_poll(struct net_device *n
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
+	while (!test_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state)) {
+		u32 val = tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+
+		if (val == 0x00000001)
+			break;
+
+		cpu_relax();
+	}
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
@@ -2951,9 +2987,6 @@ static irqreturn_t tg3_msi(int irq, void
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
 
 	/*
 	 * Writing any value to intr-mbox-0 clears PCI INTA# and
@@ -2964,6 +2997,8 @@ static irqreturn_t tg3_msi(int irq, void
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	tp->last_tag = sblk->status_tag;
+	if (tg3_irq_sync(tp))
+		goto out;
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -2972,9 +3007,7 @@ static irqreturn_t tg3_msi(int irq, void
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     tp->last_tag << 24);
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(1);
 }
 
@@ -2983,11 +3016,8 @@ static irqreturn_t tg3_interrupt(int irq
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
@@ -3004,6 +3034,8 @@ static irqreturn_t tg3_interrupt(int irq
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
+		if (tg3_irq_sync(tp))
+			goto out;
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3018,9 +3050,7 @@ static irqreturn_t tg3_interrupt(int irq
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3029,11 +3059,8 @@ static irqreturn_t tg3_interrupt_tagged(
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
@@ -3051,6 +3078,8 @@ static irqreturn_t tg3_interrupt_tagged(
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
 		tp->last_tag = sblk->status_tag;
+		if (tg3_irq_sync(tp))
+			goto out;
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3065,9 +3094,7 @@ static irqreturn_t tg3_interrupt_tagged(
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-
-	spin_unlock_irqrestore(&tp->lock, flags);
-
+out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3106,8 +3133,7 @@ static void tg3_reset_task(void *_data)
 
 	tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 
 	restart_timer = tp->tg3_flags2 & TG3_FLG2_RESTART_TIMER;
 	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
@@ -3117,8 +3143,7 @@ static void tg3_reset_task(void *_data)
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	if (restart_timer)
 		mod_timer(&tp->timer, jiffies + 1);
@@ -3224,39 +3249,21 @@ static int tg3_start_xmit(struct sk_buff
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
@@ -3421,7 +3428,7 @@ static int tg3_start_xmit(struct sk_buff
 
 out_unlock:
     	mmiowb();
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
+	spin_unlock(&tp->tx_lock);
 
 	dev->trans_start = jiffies;
 
@@ -3455,8 +3462,8 @@ static int tg3_change_mtu(struct net_dev
 	}
 
 	tg3_netif_stop(tp);
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+
+	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 
@@ -3466,8 +3473,7 @@ static int tg3_change_mtu(struct net_dev
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	return 0;
 }
@@ -5088,9 +5094,9 @@ static int tg3_set_mac_addr(struct net_d
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	__tg3_set_mac_addr(tp);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
 
 	return 0;
 }
@@ -5802,10 +5808,8 @@ static void tg3_periodic_fetch_stats(str
 static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
-	unsigned long flags;
 
-	spin_lock_irqsave(&tp->lock, flags);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&tp->lock);
 
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
 		/* All of this garbage is because when using non-tagged
@@ -5822,8 +5826,7 @@ static void tg3_timer(unsigned long __op
 
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
 			tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
-			spin_unlock(&tp->tx_lock);
-			spin_unlock_irqrestore(&tp->lock, flags);
+			spin_unlock(&tp->lock);
 			schedule_work(&tp->reset_task);
 			return;
 		}
@@ -5891,8 +5894,7 @@ static void tg3_timer(unsigned long __op
 		tp->asf_counter = tp->asf_multiplier;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock(&tp->lock);
 
 	tp->timer.expires = jiffies + tp->timer_offset;
 	add_timer(&tp->timer);
@@ -6007,14 +6009,12 @@ static int tg3_test_msi(struct tg3 *tp)
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
@@ -6027,14 +6027,12 @@ static int tg3_open(struct net_device *d
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
@@ -6081,8 +6079,7 @@ static int tg3_open(struct net_device *d
 		return err;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	err = tg3_init_hw(tp);
 	if (err) {
@@ -6106,8 +6103,7 @@ static int tg3_open(struct net_device *d
 		tp->timer.function = tg3_timer;
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	if (err) {
 		free_irq(tp->pdev->irq, dev);
@@ -6123,8 +6119,7 @@ static int tg3_open(struct net_device *d
 		err = tg3_test_msi(tp);
 
 		if (err) {
-			spin_lock_irq(&tp->lock);
-			spin_lock(&tp->tx_lock);
+			tg3_full_lock(tp, 0);
 
 			if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 				pci_disable_msi(tp->pdev);
@@ -6134,22 +6129,19 @@ static int tg3_open(struct net_device *d
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
 
@@ -6395,8 +6387,7 @@ static int tg3_close(struct net_device *
 
 	del_timer_sync(&tp->timer);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
 #if 0
 	tg3_dump_state(tp);
 #endif
@@ -6410,8 +6401,7 @@ static int tg3_close(struct net_device *
 		  TG3_FLAG_GOT_SERDES_FLOWCTL);
 	netif_carrier_off(tp->dev);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	free_irq(tp->pdev->irq, dev);
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
@@ -6448,16 +6438,15 @@ static unsigned long calc_crc_errors(str
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
 
@@ -6719,11 +6708,9 @@ static void tg3_set_rx_mode(struct net_d
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
@@ -6745,8 +6732,7 @@ static void tg3_get_regs(struct net_devi
 
 	memset(p, 0, TG3_REGDUMP_LEN);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 #define __GET_REG32(reg)	(*(p)++ = tr32(reg))
 #define GET_REG32_LOOP(base,len)		\
@@ -6796,8 +6782,7 @@ do {	p = (u32 *)(orig_p + (reg));		\
 #undef GET_REG32_LOOP
 #undef GET_REG32_1
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 }
 
 static int tg3_get_eeprom_len(struct net_device *dev)
@@ -6973,8 +6958,7 @@ static int tg3_set_settings(struct net_d
 			return -EINVAL;
 	}
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tp->link_config.autoneg = cmd->autoneg;
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -6990,8 +6974,7 @@ static int tg3_set_settings(struct net_d
 	if (netif_running(dev))
 		tg3_setup_phy(tp, 1);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7027,12 +7010,12 @@ static int tg3_set_wol(struct net_device
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
@@ -7072,7 +7055,7 @@ static int tg3_nway_reset(struct net_dev
 	if (!netif_running(dev))
 		return -EAGAIN;
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_bh(&tp->lock);
 	r = -EINVAL;
 	tg3_readphy(tp, MII_BMCR, &bmcr);
 	if (!tg3_readphy(tp, MII_BMCR, &bmcr) &&
@@ -7080,7 +7063,7 @@ static int tg3_nway_reset(struct net_dev
 		tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART);
 		r = 0;
 	}
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_bh(&tp->lock);
   
 	return r;
 }
@@ -7111,8 +7094,7 @@ static int tg3_set_ringparam(struct net_
 	if (netif_running(dev))
 		tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
   
 	tp->rx_pending = ering->rx_pending;
 
@@ -7128,8 +7110,7 @@ static int tg3_set_ringparam(struct net_
 		tg3_netif_start(tp);
 	}
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7150,8 +7131,8 @@ static int tg3_set_pauseparam(struct net
 	if (netif_running(dev))
 		tg3_netif_stop(tp);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 1);
+
 	if (epause->autoneg)
 		tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	else
@@ -7170,8 +7151,8 @@ static int tg3_set_pauseparam(struct net
 		tg3_init_hw(tp);
 		tg3_netif_start(tp);
 	}
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+
+	tg3_full_unlock(tp);
   
 	return 0;
 }
@@ -7192,12 +7173,12 @@ static int tg3_set_rx_csum(struct net_de
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
@@ -7719,8 +7700,7 @@ static void tg3_self_test(struct net_dev
 		if (netif_running(dev))
 			tg3_netif_stop(tp);
 
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		tg3_full_lock(tp, 1);
 
 		tg3_halt(tp, RESET_KIND_SUSPEND, 1);
 		tg3_nvram_lock(tp);
@@ -7742,14 +7722,14 @@ static void tg3_self_test(struct net_dev
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
@@ -7757,8 +7737,8 @@ static void tg3_self_test(struct net_dev
 			tg3_init_hw(tp);
 			tg3_netif_start(tp);
 		}
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+
+		tg3_full_unlock(tp);
 	}
 }
 
@@ -7779,9 +7759,9 @@ static int tg3_ioctl(struct net_device *
 		if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		spin_lock_irq(&tp->lock);
+		spin_lock_bh(&tp->lock);
 		err = tg3_readphy(tp, data->reg_num & 0x1f, &mii_regval);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_bh(&tp->lock);
 
 		data->val_out = mii_regval;
 
@@ -7795,9 +7775,9 @@ static int tg3_ioctl(struct net_device *
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_irq(&tp->lock);
+		spin_lock_bh(&tp->lock);
 		err = tg3_writephy(tp, data->reg_num & 0x1f, data->val_in);
-		spin_unlock_irq(&tp->lock);
+		spin_unlock_bh(&tp->lock);
 
 		return err;
 
@@ -7813,28 +7793,24 @@ static void tg3_vlan_rx_register(struct 
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
 
@@ -10141,24 +10117,19 @@ static int tg3_suspend(struct pci_dev *p
 
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
 
@@ -10168,8 +10139,7 @@ static int tg3_suspend(struct pci_dev *p
 		netif_device_attach(dev);
 		tg3_netif_start(tp);
 
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+		tg3_full_unlock(tp);
 	}
 
 	return err;
@@ -10192,8 +10162,7 @@ static int tg3_resume(struct pci_dev *pd
 
 	netif_device_attach(dev);
 
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	tg3_full_lock(tp, 0);
 
 	tg3_init_hw(tp);
 
@@ -10204,8 +10173,7 @@ static int tg3_resume(struct pci_dev *pd
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
+	tg3_full_unlock(tp);
 
 	return 0;
 }
--- 1/drivers/net/tg3.h.~1~	2005-06-03 12:11:44.000000000 -0700
+++ 2/drivers/net/tg3.h	2005-06-03 12:12:03.000000000 -0700
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
