From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Do less atomic count changes in dev_queue_xmit
Date: Tue, 7 Sep 2004 13:56:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907115655.GA25051@wotan.suse.de>
References: <20040904135439.GA23934@wotan.suse.de> <20040905220341.GA13217@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, netdev@oss.sgi.com,
        akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040905220341.GA13217@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 06, 2004 at 08:03:41AM +1000, Herbert Xu wrote:
> On Sat, Sep 04, 2004 at 01:54:39PM +0000, Andi Kleen wrote:
> > 
> > diff -u linux-2.6.8/net/core/dev.c-o linux-2.6.8/net/core/dev.c
> > --- linux-2.6.8/net/core/dev.c-o	2004-09-04 13:10:47.000000000 +0000
> > +++ linux-2.6.8/net/core/dev.c	2004-09-04 13:47:16.765722813 +0000
> > @@ -1249,14 +1249,14 @@
> >  	return 0;
> >  }
> >  
> > -#define HARD_TX_LOCK_BH(dev, cpu) {			\
> > +#define HARD_TX_LOCK(dev, cpu) {			\
> >  	if ((dev->features & NETIF_F_LLTX) == 0) {	\
> >  		spin_lock_bh(&dev->xmit_lock);		\
> 
> You can remove the _bh here as well.

Ok done. 

> 
> > @@ -1358,12 +1361,11 @@
> >  	   Either shot noqueue qdisc, it is even simpler 8)
> >  	 */
> >  	if (dev->flags & IFF_UP) {
> > -		int cpu = get_cpu();
> > +		int cpu = smp_processor_id(); /* ok because BHs are off */
> 
> Hmm this means that the loopback xmit function will now execute with
> BH/preempt turned off.  Is this what we want?

I think so yes.  It is not that costly. 

David, can you please consider this patch, thanks? 

-Andi

---------------------------------------------------------------

Streamline atomic count handling in queue xmit fast path.
Only do it once instead of multiple times.

diff -u linux-2.6.8/net/core/dev.c-o linux-2.6.8/net/core/dev.c
--- linux-2.6.8/net/core/dev.c-o	2004-09-04 13:10:47.000000000 +0000
+++ linux-2.6.8/net/core/dev.c	2004-09-07 08:09:52.000000000 +0000
@@ -1249,17 +1249,17 @@
 	return 0;
 }
 
-#define HARD_TX_LOCK_BH(dev, cpu) {			\
+#define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		spin_lock_bh(&dev->xmit_lock);		\
+		spin_lock(&dev->xmit_lock);		\
 		dev->xmit_lock_owner = cpu;		\
 	}						\
 }
 
-#define HARD_TX_UNLOCK_BH(dev) {			\
+#define HARD_TX_UNLOCK(dev) {				\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		dev->xmit_lock_owner = -1;		\
-		spin_unlock_bh(&dev->xmit_lock);	\
+		spin_unlock(&dev->xmit_lock);		\
 	}						\
 }
 
@@ -1313,7 +1313,12 @@
 	      	if (skb_checksum_help(&skb, 0))
 	      		goto out_kfree_skb;
 
-	rcu_read_lock();
+
+	/* Disable soft irqs for various locks below. Also 
+	 * stops preemption for RCU. 
+	 */
+	local_bh_disable(); 
+
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
 	 * rcu structure - it may be accessed without acquiring 
@@ -1332,18 +1337,16 @@
 #endif
 	if (q->enqueue) {
 		/* Grab device queue */
-		spin_lock_bh(&dev->queue_lock);
+		spin_lock(&dev->queue_lock);
 
 		rc = q->enqueue(skb, q);
 
 		qdisc_run(dev);
 
-		spin_unlock_bh(&dev->queue_lock);
-		rcu_read_unlock();
+		spin_unlock(&dev->queue_lock);
 		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
 		goto out;
 	}
-	rcu_read_unlock();
 
 	/* The device has no queue. Common case for software devices:
 	   loopback, all the sorts of tunnels...
@@ -1358,12 +1361,11 @@
 	   Either shot noqueue qdisc, it is even simpler 8)
 	 */
 	if (dev->flags & IFF_UP) {
-		int cpu = get_cpu();
+		int cpu = smp_processor_id(); /* ok because BHs are off */
 
 		if (dev->xmit_lock_owner != cpu) {
 
-			HARD_TX_LOCK_BH(dev, cpu);
-			put_cpu();
+			HARD_TX_LOCK(dev, cpu);
 
 			if (!netif_queue_stopped(dev)) {
 				if (netdev_nit)
@@ -1371,17 +1373,16 @@
 
 				rc = 0;
 				if (!dev->hard_start_xmit(skb, dev)) {
-					HARD_TX_UNLOCK_BH(dev);
+					HARD_TX_UNLOCK(dev);
 					goto out;
 				}
 			}
-			HARD_TX_UNLOCK_BH(dev);
+			HARD_TX_UNLOCK(dev);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
 			goto out_enetdown;
 		} else {
-			put_cpu();
 			/* Recursion is detected! It is possible,
 			 * unfortunately */
 			if (net_ratelimit())
@@ -1394,6 +1395,7 @@
 out_kfree_skb:
 	kfree_skb(skb);
 out:
+	local_bh_enable();
 	return rc;
 }
 
