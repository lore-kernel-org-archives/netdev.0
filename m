From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Add netif_tx_lock
Date: Fri, 9 Jun 2006 15:48:16 +1000
Message-ID: <20060609054816.GA7612@gondor.apana.org.au>
References: <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net> <1149110429.3078.5.camel@rh4> <20060531.170908.46214247.davem@davemloft.net> <20060601002525.GA19220@gondor.apana.org.au> <20060601111503.GA16097@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:9744 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750930AbWFIFsq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 01:48:46 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060601111503.GA16097@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 01, 2006 at 09:15:03PM +1000, herbert wrote:
> 
> OK, here is a patch which does this.
> 
> [NET]: Add netif_tx_lock

Just noticed that I showed dyslexia in winbond.c :) Here is the corrected
version.

[NET]: Add netif_tx_lock

Various drivers use xmit_lock internally to synchronise with their
transmission routines.  They do so without setting xmit_lock_owner.
This is fine as long as netpoll is not in use.

With netpoll it is possible for deadlocks to occur if xmit_lock_owner
isn't set.  This is because if a printk occurs while xmit_lock is held
and xmit_lock_owner is not set can cause netpoll to attempt to take
xmit_lock recursively.

While it is possible to resolve this by getting netpoll to use trylock,
it is suboptimal because netpoll's sole objective is to maximise the
chance of getting the printk out on the wire.  So delaying or dropping
the message is to be avoided as much as possible.

So the only alternative is to always set xmit_lock_owner.  The following
patch does this by introducing the netif_tx_lock family of functions that 
take care of setting/unsetting xmit_lock_owner.

I renamed xmit_lock to _xmit_lock to indicate that it should not be used
directly.  I didn't provide irq versions of the netif_tx_lock functions
since xmit_lock is meant to be a BH-disabling lock.

This is pretty much a straight text substitution except for a small bug
fix in winbond.  It currently uses netif_stop_queue/spin_unlock_wait to
stop transmission.  This is unsafe as an IRQ can potentially wake up the
queue.  So it is safer to use netif_tx_disable.

The hamradio bits used spin_lock_irq but it is unnecessary as xmit_lock
must never be taken in an IRQ handler.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="netif-tx-lock-2.patch"

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 3c0a5ba..847cedb 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -42,9 +42,9 @@ dev->get_stats:
 	Context: nominally process, but don't sleep inside an rwlock
 
 dev->hard_start_xmit:
-	Synchronization: dev->xmit_lock spinlock.
+	Synchronization: netif_tx_lock spinlock.
 	When the driver sets NETIF_F_LLTX in dev->features this will be
-	called without holding xmit_lock. In this case the driver 
+	called without holding netif_tx_lock. In this case the driver
 	has to lock by itself when needed. It is recommended to use a try lock
 	for this and return -1 when the spin lock fails. 
 	The locking there should also properly protect against 
@@ -62,12 +62,12 @@ dev->hard_start_xmit:
 	  Only valid when NETIF_F_LLTX is set.
 
 dev->tx_timeout:
-	Synchronization: dev->xmit_lock spinlock.
+	Synchronization: netif_tx_lock spinlock.
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed true
 
 dev->set_multicast_list:
-	Synchronization: dev->xmit_lock spinlock.
+	Synchronization: netif_tx_lock spinlock.
 	Context: BHs disabled
 
 dev->poll:
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 1dae4b2..1d917ed 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -821,7 +821,8 @@ void ipoib_mcast_restart_task(void *dev_
 
 	ipoib_mcast_stop_thread(dev, 0);
 
-	spin_lock_irqsave(&dev->xmit_lock, flags);
+	local_irq_save(flags);
+	netif_tx_lock(dev);
 	spin_lock(&priv->lock);
 
 	/*
@@ -896,7 +897,8 @@ void ipoib_mcast_restart_task(void *dev_
 	}
 
 	spin_unlock(&priv->lock);
-	spin_unlock_irqrestore(&dev->xmit_lock, flags);
+	netif_tx_unlock(dev);
+	local_irq_restore(flags);
 
 	/* We have to cancel outside of the spinlock */
 	list_for_each_entry_safe(mcast, tmcast, &remove_list, list) {
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 2f0f358..9fd8752 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1052,7 +1052,7 @@ static void wq_set_multicast_list (void 
 
 	dvb_net_feed_stop(dev);
 	priv->rx_mode = RX_MODE_UNI;
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		dprintk("%s: promiscuous mode\n", dev->name);
@@ -1077,7 +1077,7 @@ static void wq_set_multicast_list (void 
 		}
 	}
 
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 	dvb_net_feed_start(dev);
 }
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 54161ae..9c5a884 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2009,7 +2009,7 @@ bnx2_poll(struct net_device *dev, int *b
 	return 1;
 }
 
-/* Called with rtnl_lock from vlan functions and also dev->xmit_lock
+/* Called with rtnl_lock from vlan functions and also netif_tx_lock
  * from set_multicast.
  */
 static void
@@ -4252,7 +4252,7 @@ bnx2_vlan_rx_kill_vid(struct net_device 
 }
 #endif
 
-/* Called with dev->xmit_lock.
+/* Called with netif_tx_lock.
  * hard_start_xmit is pseudo-lockless - a lock is only required when
  * the tx queue is full. This way, we get the benefit of lockless
  * operations most of the time without the complexities to handle
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 55d2367..46326cd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4191,7 +4191,7 @@ static int bond_init(struct net_device *
 	 */
 	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 
-	/* don't acquire bond device's xmit_lock when 
+	/* don't acquire bond device's netif_tx_lock when
 	 * transmitting */
 	bond_dev->features |= NETIF_F_LLTX;
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index feb5b22..5a8651b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -533,9 +533,9 @@ #define NV_MSI_X_VECTOR_OTHER 0x2
  * critical parts:
  * - rx is (pseudo-) lockless: it relies on the single-threading provided
  *	by the arch code for interrupts.
- * - tx setup is lockless: it relies on dev->xmit_lock. Actual submission
+ * - tx setup is lockless: it relies on netif_tx_lock. Actual submission
  *	needs dev->priv->lock :-(
- * - set_multicast_list: preparation lockless, relies on dev->xmit_lock.
+ * - set_multicast_list: preparation lockless, relies on netif_tx_lock.
  */
 
 /* in dev: base, irq */
@@ -1213,7 +1213,7 @@ static void drain_ring(struct net_device
 
 /*
  * nv_start_xmit: dev->hard_start_xmit function
- * Called with dev->xmit_lock held.
+ * Called with netif_tx_lock held.
  */
 static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1407,7 +1407,7 @@ static void nv_tx_done(struct net_device
 
 /*
  * nv_tx_timeout: dev->tx_timeout function
- * Called with dev->xmit_lock held.
+ * Called with netif_tx_lock held.
  */
 static void nv_tx_timeout(struct net_device *dev)
 {
@@ -1737,7 +1737,7 @@ static int nv_change_mtu(struct net_devi
 		 * Changing the MTU is a rare event, it shouldn't matter.
 		 */
 		nv_disable_irq(dev);
-		spin_lock_bh(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rx(dev);
@@ -1768,7 +1768,7 @@ static int nv_change_mtu(struct net_devi
 		nv_start_rx(dev);
 		nv_start_tx(dev);
 		spin_unlock(&np->lock);
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -1803,7 +1803,7 @@ static int nv_set_mac_address(struct net
 	memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
 
 	if (netif_running(dev)) {
-		spin_lock_bh(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		spin_lock_irq(&np->lock);
 
 		/* stop rx engine */
@@ -1815,7 +1815,7 @@ static int nv_set_mac_address(struct net
 		/* restart rx engine */
 		nv_start_rx(dev);
 		spin_unlock_irq(&np->lock);
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 	} else {
 		nv_copy_mac_to_hw(dev);
 	}
@@ -1824,7 +1824,7 @@ static int nv_set_mac_address(struct net
 
 /*
  * nv_set_multicast: dev->set_multicast function
- * Called with dev->xmit_lock held.
+ * Called with netif_tx_lock held.
  */
 static void nv_set_multicast(struct net_device *dev)
 {
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 102c1f0..d12605f 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -308,9 +308,9 @@ static int sp_set_mac_address(struct net
 {
 	struct sockaddr_ax25 *sa = addr;
 
-	spin_lock_irq(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	memcpy(dev->dev_addr, &sa->sax25_call, AX25_ADDR_LEN);
-	spin_unlock_irq(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 
 	return 0;
 }
@@ -767,9 +767,9 @@ static int sixpack_ioctl(struct tty_stru
 			break;
 		}
 
-		spin_lock_irq(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		memcpy(dev->dev_addr, &addr, AX25_ADDR_LEN);
-		spin_unlock_irq(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 
 		err = 0;
 		break;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index d81a8e1..3ebbbe5 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -357,9 +357,9 @@ static int ax_set_mac_address(struct net
 {
 	struct sockaddr_ax25 *sa = addr;
 
-	spin_lock_irq(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	memcpy(dev->dev_addr, &sa->sax25_call, AX25_ADDR_LEN);
-	spin_unlock_irq(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 
 	return 0;
 }
@@ -886,9 +886,9 @@ static int mkiss_ioctl(struct tty_struct
 			break;
 		}
 
-		spin_lock_irq(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		memcpy(dev->dev_addr, addr, AX25_ADDR_LEN);
-		spin_unlock_irq(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 
 		err = 0;
 		break;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 31fb2d7..2e222ef 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -76,13 +76,13 @@ static void ri_tasklet(unsigned long dev
 	dp->st_task_enter++;
 	if ((skb = skb_peek(&dp->tq)) == NULL) {
 		dp->st_txq_refl_try++;
-		if (spin_trylock(&_dev->xmit_lock)) {
+		if (netif_tx_trylock(_dev)) {
 			dp->st_rxq_enter++;
 			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
 				skb_queue_tail(&dp->tq, skb);
 				dp->st_rx2tx_tran++;
 			}
-			spin_unlock(&_dev->xmit_lock);
+			netif_tx_unlock(_dev);
 		} else {
 			/* reschedule */
 			dp->st_rxq_notenter++;
@@ -110,7 +110,7 @@ static void ri_tasklet(unsigned long dev
 		}
 	}
 
-	if (spin_trylock(&_dev->xmit_lock)) {
+	if (netif_tx_trylock(_dev)) {
 		dp->st_rxq_check++;
 		if ((skb = skb_peek(&dp->rq)) == NULL) {
 			dp->tasklet_pending = 0;
@@ -118,10 +118,10 @@ static void ri_tasklet(unsigned long dev
 				netif_wake_queue(_dev);
 		} else {
 			dp->st_rxq_rsch++;
-			spin_unlock(&_dev->xmit_lock);
+			netif_tx_unlock(_dev);
 			goto resched;
 		}
-		spin_unlock(&_dev->xmit_lock);
+		netif_tx_unlock(_dev);
 	} else {
 resched:
 		dp->tasklet_pending = 1;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 97a49e0..d70b9e8 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -959,7 +959,7 @@ static int vlsi_hard_start_xmit(struct s
 			    ||  (now.tv_sec==ready.tv_sec && now.tv_usec>=ready.tv_usec))
 			    	break;
 			udelay(100);
-			/* must not sleep here - we are called under xmit_lock! */
+			/* must not sleep here - called under netif_tx_lock! */
 		}
 	}
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9062775..2e4eced 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -318,12 +318,12 @@ performance critical codepaths:
 The rx process only runs in the interrupt handler. Access from outside
 the interrupt handler is only permitted after disable_irq().
 
-The rx process usually runs under the dev->xmit_lock. If np->intr_tx_reap
+The rx process usually runs under the netif_tx_lock. If np->intr_tx_reap
 is set, then access is permitted under spin_lock_irq(&np->lock).
 
 Thus configuration functions that want to access everything must call
 	disable_irq(dev->irq);
-	spin_lock_bh(dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	spin_lock_irq(&np->lock);
 
 IV. Notes
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 136a70c..56d86c7 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1605,11 +1605,11 @@ #ifdef CONFIG_PM
  * - get_stats:
  * 	spin_lock_irq(np->lock), doesn't touch hw if not present
  * - hard_start_xmit:
- * 	netif_stop_queue + spin_unlock_wait(&dev->xmit_lock);
+ * 	synchronize_irq + netif_tx_disable;
  * - tx_timeout:
- * 	netif_device_detach + spin_unlock_wait(&dev->xmit_lock);
+ * 	netif_device_detach + netif_tx_disable;
  * - set_multicast_list
- * 	netif_device_detach + spin_unlock_wait(&dev->xmit_lock);
+ * 	netif_device_detach + netif_tx_disable;
  * - interrupt handler
  * 	doesn't touch hw if not present, synchronize_irq waits for
  * 	running instances of the interrupt handler.
@@ -1635,11 +1635,10 @@ static int w840_suspend (struct pci_dev 
 		netif_device_detach(dev);
 		update_csr6(dev, 0);
 		iowrite32(0, ioaddr + IntrEnable);
-		netif_stop_queue(dev);
 		spin_unlock_irq(&np->lock);
 
-		spin_unlock_wait(&dev->xmit_lock);
 		synchronize_irq(dev->irq);
+		netif_tx_disable(dev);
 	
 		np->stats.rx_missed_errors += ioread32(ioaddr + RxMissed) & 0xffff;
 
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index c2d0b09..a5fcfcd 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1833,7 +1833,9 @@ static int __orinoco_program_rids(struct
 	/* Set promiscuity / multicast*/
 	priv->promiscuous = 0;
 	priv->mc_count = 0;
-	__orinoco_set_multicast_list(dev); /* FIXME: what about the xmit_lock */
+
+	/* FIXME: what about netif_tx_lock */
+	__orinoco_set_multicast_list(dev);
 
 	return 0;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f4169bb..01699eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -406,7 +406,7 @@ #define NETIF_F_UFO             8192    
  * One part is mostly used on xmit path (device)
  */
 	/* hard_start_xmit synchronizer */
-	spinlock_t		xmit_lock ____cacheline_aligned_in_smp;
+	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
 	/* cpu id of processor entered to hard_start_xmit or -1,
 	   if nobody entered there.
 	 */
@@ -889,11 +889,43 @@ static inline void __netif_rx_complete(s
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 }
 
+static inline void netif_tx_lock(struct net_device *dev)
+{
+	spin_lock(&dev->_xmit_lock);
+	dev->xmit_lock_owner = smp_processor_id();
+}
+
+static inline void netif_tx_lock_bh(struct net_device *dev)
+{
+	spin_lock_bh(&dev->_xmit_lock);
+	dev->xmit_lock_owner = smp_processor_id();
+}
+
+static inline int netif_tx_trylock(struct net_device *dev)
+{
+	int err = spin_trylock(&dev->_xmit_lock);
+	if (!err)
+		dev->xmit_lock_owner = smp_processor_id();
+	return err;
+}
+
+static inline void netif_tx_unlock(struct net_device *dev)
+{
+	dev->xmit_lock_owner = -1;
+	spin_unlock(&dev->_xmit_lock);
+}
+
+static inline void netif_tx_unlock_bh(struct net_device *dev)
+{
+	dev->xmit_lock_owner = -1;
+	spin_unlock_bh(&dev->_xmit_lock);
+}
+
 static inline void netif_tx_disable(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	netif_stop_queue(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 72d8529..f92f9c9 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -98,7 +98,7 @@ static void unlink_clip_vcc(struct clip_
 		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n", clip_vcc);
 		return;
 	}
-	spin_lock_bh(&entry->neigh->dev->xmit_lock);	/* block clip_start_xmit() */
+	netif_tx_lock_bh(entry->neigh->dev);	/* block clip_start_xmit() */
 	entry->neigh->used = jiffies;
 	for (walk = &entry->vccs; *walk; walk = &(*walk)->next)
 		if (*walk == clip_vcc) {
@@ -122,7 +122,7 @@ static void unlink_clip_vcc(struct clip_
 	printk(KERN_CRIT "ATMARP: unlink_clip_vcc failed (entry %p, vcc "
 	       "0x%p)\n", entry, clip_vcc);
       out:
-	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
+	netif_tx_unlock_bh(entry->neigh->dev);
 }
 
 /* The neighbour entry n->lock is held. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 4fba549..8906f59 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1275,15 +1275,13 @@ int __skb_linearize(struct sk_buff *skb,
 
 #define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		spin_lock(&dev->xmit_lock);		\
-		dev->xmit_lock_owner = cpu;		\
+		netif_tx_lock(dev);			\
 	}						\
 }
 
 #define HARD_TX_UNLOCK(dev) {				\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		dev->xmit_lock_owner = -1;		\
-		spin_unlock(&dev->xmit_lock);		\
+		netif_tx_unlock(dev);			\
 	}						\
 }
 
@@ -1382,8 +1380,8 @@ #endif
 	/* The device has no queue. Common case for software devices:
 	   loopback, all the sorts of tunnels...
 
-	   Really, it is unlikely that xmit_lock protection is necessary here.
-	   (f.e. loopback and IP tunnels are clean ignoring statistics
+	   Really, it is unlikely that netif_tx_lock protection is necessary
+	   here.  (f.e. loopback and IP tunnels are clean ignoring statistics
 	   counters.)
 	   However, it is possible, that they rely on protection
 	   made by us here.
@@ -2785,7 +2783,7 @@ int register_netdevice(struct net_device
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
 
 	spin_lock_init(&dev->queue_lock);
-	spin_lock_init(&dev->xmit_lock);
+	spin_lock_init(&dev->_xmit_lock);
 	dev->xmit_lock_owner = -1;
 #ifdef CONFIG_NET_CLS_ACT
 	spin_lock_init(&dev->ingress_lock);
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 05d6085..c57d887 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -62,7 +62,7 @@ #include <net/arp.h>
  *	Device mc lists are changed by bh at least if IPv6 is enabled,
  *	so that it must be bh protected.
  *
- *	We block accesses to device mc filters with dev->xmit_lock.
+ *	We block accesses to device mc filters with netif_tx_lock.
  */
 
 /*
@@ -93,9 +93,9 @@ static void __dev_mc_upload(struct net_d
 
 void dev_mc_upload(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	__dev_mc_upload(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 /*
@@ -107,7 +107,7 @@ int dev_mc_delete(struct net_device *dev
 	int err = 0;
 	struct dev_mc_list *dmi, **dmip;
 
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 
 	for (dmip = &dev->mc_list; (dmi = *dmip) != NULL; dmip = &dmi->next) {
 		/*
@@ -139,13 +139,13 @@ int dev_mc_delete(struct net_device *dev
 			 */
 			__dev_mc_upload(dev);
 			
-			spin_unlock_bh(&dev->xmit_lock);
+			netif_tx_unlock_bh(dev);
 			return 0;
 		}
 	}
 	err = -ENOENT;
 done:
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 	return err;
 }
 
@@ -160,7 +160,7 @@ int dev_mc_add(struct net_device *dev, v
 
 	dmi1 = kmalloc(sizeof(*dmi), GFP_ATOMIC);
 
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
 		if (memcmp(dmi->dmi_addr, addr, dmi->dmi_addrlen) == 0 &&
 		    dmi->dmi_addrlen == alen) {
@@ -176,7 +176,7 @@ int dev_mc_add(struct net_device *dev, v
 	}
 
 	if ((dmi = dmi1) == NULL) {
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 		return -ENOMEM;
 	}
 	memcpy(dmi->dmi_addr, addr, alen);
@@ -189,11 +189,11 @@ int dev_mc_add(struct net_device *dev, v
 
 	__dev_mc_upload(dev);
 	
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 	return 0;
 
 done:
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 	kfree(dmi1);
 	return err;
 }
@@ -204,7 +204,7 @@ done:
 
 void dev_mc_discard(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	
 	while (dev->mc_list != NULL) {
 		struct dev_mc_list *tmp = dev->mc_list;
@@ -215,7 +215,7 @@ void dev_mc_discard(struct net_device *d
 	}
 	dev->mc_count = 0;
 
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 #ifdef CONFIG_PROC_FS
@@ -250,7 +250,7 @@ static int dev_mc_seq_show(struct seq_fi
 	struct dev_mc_list *m;
 	struct net_device *dev = v;
 
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	for (m = dev->mc_list; m; m = m->next) {
 		int i;
 
@@ -262,7 +262,7 @@ static int dev_mc_seq_show(struct seq_fi
 
 		seq_putc(seq, '\n');
 	}
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 	return 0;
 }
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e8e05ce..9cb7818 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -273,24 +273,21 @@ static void netpoll_send_skb(struct netp
 
 	do {
 		npinfo->tries--;
-		spin_lock(&np->dev->xmit_lock);
-		np->dev->xmit_lock_owner = smp_processor_id();
+		netif_tx_lock(np->dev);
 
 		/*
 		 * network drivers do not expect to be called if the queue is
 		 * stopped.
 		 */
 		if (netif_queue_stopped(np->dev)) {
-			np->dev->xmit_lock_owner = -1;
-			spin_unlock(&np->dev->xmit_lock);
+			netif_tx_unlock(np->dev);
 			netpoll_poll(np);
 			udelay(50);
 			continue;
 		}
 
 		status = np->dev->hard_start_xmit(skb, np->dev);
-		np->dev->xmit_lock_owner = -1;
-		spin_unlock(&np->dev->xmit_lock);
+		netif_tx_unlock(np->dev);
 
 		/* success */
 		if(!status) {
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index c23e9c0..67ed14d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2897,7 +2897,7 @@ static __inline__ void pktgen_xmit(struc
 		}
 	}
 
-	spin_lock_bh(&odev->xmit_lock);
+	netif_tx_lock_bh(odev);
 	if (!netif_queue_stopped(odev)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
@@ -2942,7 +2942,7 @@ static __inline__ void pktgen_xmit(struc
 		pkt_dev->next_tx_ns = 0;
 	}
 
-	spin_unlock_bh(&odev->xmit_lock);
+	netif_tx_unlock_bh(odev);
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 138ea92..b1e4c5e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -72,9 +72,9 @@ void qdisc_unlock_tree(struct net_device
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
 
-   dev->xmit_lock serializes accesses to device driver.
+   netif_tx_lock serializes accesses to device driver.
 
-   dev->queue_lock and dev->xmit_lock are mutually exclusive,
+   dev->queue_lock and netif_tx_lock are mutually exclusive,
    if one is grabbed, another must be free.
  */
 
@@ -108,7 +108,7 @@ int qdisc_restart(struct net_device *dev
 		 * will be requeued.
 		 */
 		if (!nolock) {
-			if (!spin_trylock(&dev->xmit_lock)) {
+			if (!netif_tx_trylock(dev)) {
 			collision:
 				/* So, someone grabbed the driver. */
 				
@@ -126,8 +126,6 @@ int qdisc_restart(struct net_device *dev
 				__get_cpu_var(netdev_rx_stat).cpu_collision++;
 				goto requeue;
 			}
-			/* Remember that the driver is grabbed by us. */
-			dev->xmit_lock_owner = smp_processor_id();
 		}
 		
 		{
@@ -142,8 +140,7 @@ int qdisc_restart(struct net_device *dev
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
 					if (!nolock) {
-						dev->xmit_lock_owner = -1;
-						spin_unlock(&dev->xmit_lock);
+						netif_tx_unlock(dev);
 					}
 					spin_lock(&dev->queue_lock);
 					return -1;
@@ -157,8 +154,7 @@ int qdisc_restart(struct net_device *dev
 			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
 			if (!nolock) { 
-				dev->xmit_lock_owner = -1;
-				spin_unlock(&dev->xmit_lock);
+				netif_tx_unlock(dev);
 			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
@@ -187,7 +183,7 @@ static void dev_watchdog(unsigned long a
 {
 	struct net_device *dev = (struct net_device *)arg;
 
-	spin_lock(&dev->xmit_lock);
+	netif_tx_lock(dev);
 	if (dev->qdisc != &noop_qdisc) {
 		if (netif_device_present(dev) &&
 		    netif_running(dev) &&
@@ -203,7 +199,7 @@ static void dev_watchdog(unsigned long a
 				dev_hold(dev);
 		}
 	}
-	spin_unlock(&dev->xmit_lock);
+	netif_tx_unlock(dev);
 
 	dev_put(dev);
 }
@@ -227,17 +223,17 @@ void __netdev_watchdog_up(struct net_dev
 
 static void dev_watchdog_up(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	__netdev_watchdog_up(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 static void dev_watchdog_down(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	netif_tx_lock_bh(dev);
 	if (del_timer(&dev->watchdog_timer))
 		dev_put(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 void netif_carrier_on(struct net_device *dev)
@@ -582,7 +578,7 @@ void dev_deactivate(struct net_device *d
 	while (test_bit(__LINK_STATE_SCHED, &dev->state))
 		yield();
 
-	spin_unlock_wait(&dev->xmit_lock);
+	spin_unlock_wait(&dev->_xmit_lock);
 }
 
 void dev_init_scheduler(struct net_device *dev)
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 79b8ef3..4c16ad5 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -302,20 +302,17 @@ restart:
 
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
-			if (spin_trylock(&slave->xmit_lock)) {
-				slave->xmit_lock_owner = smp_processor_id();
+			if (netif_tx_trylock(slave)) {
 				if (!netif_queue_stopped(slave) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
-					slave->xmit_lock_owner = -1;
-					spin_unlock(&slave->xmit_lock);
+					netif_tx_unlock(slave);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
 					master->stats.tx_bytes += len;
 					return 0;
 				}
-				slave->xmit_lock_owner = -1;
-				spin_unlock(&slave->xmit_lock);
+				netif_tx_unlock(slave);
 			}
 			if (netif_queue_stopped(dev))
 				busy = 1;

--r5Pyd7+fXNt84Ff3--
