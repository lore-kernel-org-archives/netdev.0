From: Mark Broadbent <markb@wetlettuce.com>
Subject: Re: Followup to netpoll issues
Date: Fri, 07 Jan 2005 20:14:47 +0000
Message-ID: <1105128887.3814.20.camel@localhost>
References: <1105045914.7687.3.camel@tigger>
	 <20050107002053.GD27896@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-siOvjmewd9qVZIRl+1iS"
Cc: Matt Mackall <mpm@selenic.com>,
        "Network Development (Linux)" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050107002053.GD27896@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-siOvjmewd9qVZIRl+1iS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

[cc'ing netdev]

On Fri, 2005-01-07 at 01:20 +0100, Francois Romieu wrote:
> Mark Broadbent <markb@wetlettuce.com> :
> [...]
> > I had a think about the netpoll deadlock following the initial detective
> > work by you and Francois did.  I came up with a sample fix given below
> > that defers the packet transmission within netpoll until the xmit_lock
> > can be grabbed.  An advantage of this is that is maintains the packet
> > ordering.  I have attached the patch.
> 
> Nice.
> 
> Comments below. Off to bed now.
> 
> > It is possible for netpoll to deadlock by attempting to take the network
> > device xmit_lock twice on different processors.  This patch resolves this
> > by deferring to transmission of the second and subsequent skbs.
> > 
> > Signed-Off-By: Mark Broadbent <markb@wetlettuce.com>
> > 
> > --- linux-2.6.10-org/net/core/netpoll.c	2005-01-05 22:30:53.000000000 +0000
> > +++ linux-2.6.10/net/core/netpoll.c	2005-01-06 21:00:24.000000000 +0000
> [...]
> > @@ -178,17 +201,14 @@ repeat:
> >  	return skb;
> >  }
> >  
> > -void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
> > +/* This must be called with np->dev->xmit_lock spinlock held - this function 
> > + * function will drop the lock before returning indicating if it needs to be 
> > + * retried
> > + */
> > +static int transmit_skb(struct netpoll *np, struct sk_buff *skb)
> 
> It may seem like cosmetic but I do not like functions which unlock a lock
> they have not acquired themselves (and I am probably not alone). Would you
> consider pushing the trylock() in transmit_skb() itself ?
> 
> All the callers of this functions have to issue the trylock anyway so it
> should not matter from a performance POV.

Good point, I was having doubts about that.

> [...]
> > +	
> > +	spin_lock(&tx_list_lock);
>         ^^^^^^^^^
> kernel/workqueue.c::run_workqueue() could reenable interrupts before
> it calls tx_retry_wq(). An irq safe version of the underlined lock
> seems required to avoid deadlocking with printks potentially issued
> from interrupt context.

Fixed.

> > +	
> > +	list_for_each_safe(tx_ctr, tx_tmp, &tx_queue.link) {
> > +		tx_el = list_entry(tx_ctr, struct tx_queue_list, link);
> > +		
> > +		while (tx_el->np && tx_el->np->dev && 
> > +				netif_running(tx_el->np->dev)) {
> 
> netif_running() without xmit_lock held ? Uh oh...

This is done in the original code (and still is in other parts of the code).

> Imho you should try to keep transmit_skb() closer to the former
> netpoll_send_skb() (modulo the try_lock change of course).
> Btw I do not see what will prevent cleanup_netconsole() to succeed
> when tx_retry_wq() is scheduled for later execution. Add some module
> refcounting ?

No need, if netpoll_cleanup is called whilst a retry is pending the tx
list lock is taken.  All the references to the netpoll pointer are
deleted from the pending list before the lock is released.

> > +void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
> > +{
> > +repeat:
> > +	if(!np || !np->dev || !netif_running(np->dev))
> > +		goto out_free;
> 
> I am not sure that the first two tests above really made sense in
> the former version of the code:
> -> kernel/printk.c::vprintk() (downs console_sem)
>    -> kernel/printk.c::release_console_sem 
>       -> kernel/printk.c::call_console_drivers
>          [blah blah]
>          -> drivers/net/netconsole.c::netconsole.write_msg
>             -> drivers/net/netconsole.c::netpoll_send_udp
>                -> drivers/net/netconsole.c::netpoll_send_skb
> 
> -> drivers/net/netconsole.c::cleanup_netconsole
>    -> kernel/printk.c::unregister_console
>       -> kernel/printk.c::acquire_console_sem
>          -> try to down(&console_sem)
> 
> dev_put() has not been issued, np->dev is still among us and != NULL.
> So far, so good.
> 
> However netpoll_send_skb can be called through:
> netpoll_rx -> arp_reply -> netpoll_send_skb
> Here I fail to see why netpoll_cleanup could not happen at the same time
> and issue np->dev = NULL;

Could this solved by having a per netpoll structure rw_lock to protect
against changing elements in the structure?

e.g. 
struct netpoll {
	...
	rwlock_t netpoll_lock;
};

write_lock_irqsave(&np->netpoll_lock, flags);
np->dev = NULL;
write_unlock_irqsave(&np->netpoll_lock, flags);

> > +
> > +	/* If the list is non-empty then pkts are pending tx,
> > +	 * append to the end of list to stop reordering of the pkts
> > +	 */
> > +	if (!list_empty(&tx_queue.link) || !spin_trylock(&np->dev->xmit_lock)) {
> > +		struct tx_queue_list *txel;
> > +		
> > +		/* If we failed to get the xmit_lock then netpoll probably 
> > +		 * already holds this lock but will deadlock here if we relock,
> 
> Ok ("probably" ?).

:) Fixed

> > +		 * queue the skb for transmission later
> > +		 */
> > +		spin_lock(&tx_list_lock);
> 
> No spin_lock_irqsave ? Hmmm...
> The only use of netpoll_send_skb() goes through netpoll_send_udp() which is
> issued in drivers/net/netconsole.c::write_msg() with local_irq disabled.
> You are right but an extra comment would not hurt imho.

Is it safe to issue spin_lock_irqsave/spin_unlock_restore in this
context?  Reason: What if it wasn't netconsole calling netpoll_send_udp
and not with local interrupts disabled?

> > +		
> > +		txel = kmalloc(sizeof(struct tx_queue_list), GFP_ATOMIC);
> > +		if (!txel)
> > +			goto out_free;
> > +		
> > +		txel->skb = skb_get(skb);
> > +		txel->np  = np;
> > +		
> > +		list_add_tail(&txel->link, &tx_queue.link);
> > +		
> > +		queue_delayed_work(tx_wq, &tx_wq_obj, HZ/100);
> > +		
> > +		spin_unlock(&tx_list_lock);
> > +	} else if (transmit_skb(np, skb))
> > +		goto repeat;
> 
> As I read it, the previous code could loop as long as netif_queue_stopped()
> is true and it can acquire the lock. Any reason to not defer the skb for
> transmission in tx_retry_wq() ?

Nope, no good reason.  If transmit_skb fails it'll now defer.

> 
> > +	
> > +	return;
> > +	
> > +out_free:
> > +	__kfree_skb(skb);
> >  }
> >  
> >  void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
> > @@ -636,6 +729,15 @@ int netpoll_setup(struct netpoll *np)
> >  		spin_unlock_irqrestore(&rx_list_lock, flags);
> >  	}
> >  
> > +	/* Workqueue to schedule the tx retries */
> > +	if (!tx_wq)
> > +		tx_wq = create_workqueue("netpoll");
> > +	
> > +	if (!tx_wq) {
> > +		printk(KERN_ERR "Failed to create netpoll workqueue\n");
> > +		goto release;
> > +	}
> > +	
> 
> This queue is created but never removed. May be it could/should go in a
> separate function and be anchored to net_dev_init(). The network maintainers
> will tell if they care or not.
> 
> Pure curiosity: why a specific queue instead of schedule_delayed_work() ?

Pure ignorance I'm afraid ;).  That'll more what I was looking for
originally so I've changed it.

I've attached a revised version.

Thanks for you comments (and Matts)

Mark

-- 
Mark Broadbent <markb@wetlettuce.com>

--=-siOvjmewd9qVZIRl+1iS
Content-Disposition: attachment; filename=netpoll-fix-tx-deadlock-2.patch
Content-Type: text/x-patch; name=netpoll-fix-tx-deadlock-2.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

It is possible for netpoll to deadlock by attempting to take the network
device xmit_lock twice on different processors.  This patch resolves this
by deferring to transmission of the second and subsequent skbs.

Signed-Off-By: Mark Broadbent <markb@wetlettuce.com>

--- linux-2.6.10-org/net/core/netpoll.c	2005-01-05 22:30:53.000000000 +0000
+++ linux-2.6.10/net/core/netpoll.c	2005-01-07 20:10:20.000000000 +0000
@@ -1,6 +1,9 @@
 /*
  * Common framework for low-level network console, dump, and debugger code
  *
+ * Jan 5 2005 Mark Broadbent <markb@wetlettuce.com>
+ * avoid deadlock on transmission
+ *
  * Sep 8 2003  Matt Mackall <mpm@selenic.com>
  *
  * based on the netconsole code from:
@@ -19,6 +22,8 @@
 #include <linux/netpoll.h>
 #include <linux/sched.h>
 #include <linux/rcupdate.h>
+#include <linux/workqueue.h>
+#include <linux/list.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <asm/unaligned.h>
@@ -31,6 +36,22 @@
 #define MAX_SKBS 32
 #define MAX_UDP_CHUNK 1460
 
+static void tx_retry_wq(void *p);
+
+struct tx_queue_list {
+	struct list_head link;
+	struct sk_buff *skb;
+	struct netpoll *np;
+};
+
+static spinlock_t tx_list_lock = SPIN_LOCK_UNLOCKED;
+static struct tx_queue_list tx_queue = {
+	.link = LIST_HEAD_INIT(tx_queue.link)
+};
+
+static DECLARE_WORK(tx_wq_obj, tx_retry_wq, NULL);
+
+
 static spinlock_t skb_list_lock = SPIN_LOCK_UNLOCKED;
 static int nr_skbs;
 static struct sk_buff *skbs;
@@ -178,17 +199,21 @@ repeat:
 	return skb;
 }
 
-void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+/* This must be called with np->dev->xmit_lock spinlock held - this function 
+ * function will drop the lock before returning indicating if it needs to be 
+ * retried
+ */
+static int transmit_skb(struct netpoll *np, struct sk_buff *skb)
 {
 	int status;
 
-repeat:
-	if(!np || !np->dev || !netif_running(np->dev)) {
-		__kfree_skb(skb);
-		return;
-	}
-
-	spin_lock(&np->dev->xmit_lock);
+	if (np && np->dev && netif_running(np->dev))
+		 return -1;
+	
+	/* Attempt the xmit lock as we may already hold it */
+	if (!spin_trylock(&np->dev->xmit_lock))
+		return -1;
+	
 	np->dev->xmit_lock_owner = smp_processor_id();
 
 	/*
@@ -200,7 +225,7 @@ repeat:
 		spin_unlock(&np->dev->xmit_lock);
 
 		netpoll_poll(np);
-		goto repeat;
+		return -1;
 	}
 
 	status = np->dev->hard_start_xmit(skb, np->dev);
@@ -210,8 +235,73 @@ repeat:
 	/* transmit busy */
 	if(status) {
 		netpoll_poll(np);
-		goto repeat;
+		return -1;
 	}
+	
+	return 0;
+}
+
+static void tx_retry_wq(void *p)
+{
+	struct list_head *tx_ctr, *tx_tmp;
+	struct tx_queue_list *tx_el;
+	unsigned long flags;
+	
+	spin_lock_irqsave(&tx_list_lock, flags);
+	
+	list_for_each_safe(tx_ctr, tx_tmp, &tx_queue.link) {
+		tx_el = list_entry(tx_ctr, struct tx_queue_list, link);
+		
+		if (transmit_skb(tx_el->np, tx_el->skb)) {
+			// Transmit failed - reschedule
+			schedule_delayed_work(&tx_wq_obj, HZ/100);
+			goto out_unlock;
+		}
+
+		list_del(tx_ctr);
+		__kfree_skb(tx_el->skb);
+		kfree(tx_el);
+	}
+	
+out_unlock:
+	spin_unlock_irqrestore(&tx_list_lock, flags);
+}
+
+void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+{
+	/* If the list is non-empty (packets pending tx) or the skb transmit
+	 * failed then pkts are pending tx, append to the end of list to stop
+	 * reordering of the pkts
+	 */
+	if (!list_empty(&tx_queue.link) || transmit_skb(np, skb)) {
+		struct tx_queue_list *txel;
+		
+		/* If we failed to get the xmit_lock then netpoll already holds
+		 * this lock but will deadlock here if we relock, queue the skb
+		 * for transmission later.
+		 * This function is always called with local irqs disabled, hence
+		 * the lack of spin_lock_irqsave
+		 */
+		spin_lock(&tx_list_lock);
+		
+		txel = kmalloc(sizeof(struct tx_queue_list), GFP_ATOMIC);
+		if (!txel)
+			goto out_free;
+		
+		txel->skb = skb_get(skb);
+		txel->np  = np;
+		
+		list_add_tail(&txel->link, &tx_queue.link);
+		
+		schedule_delayed_work(&tx_wq_obj, HZ/100);
+		
+		spin_unlock(&tx_list_lock);
+	}
+	
+	return;
+	
+out_free:
+	__kfree_skb(skb);
 }
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
@@ -644,6 +734,23 @@ int netpoll_setup(struct netpoll *np)
 
 void netpoll_cleanup(struct netpoll *np)
 {
+	struct list_head *tx_ctr, *tx_tmp;
+	struct tx_queue_list *tx_el;
+	unsigned long flags;
+	
+	spin_lock_irqsave(&tx_list_lock, flags);
+	list_for_each_safe(tx_ctr, tx_tmp, &tx_queue.link) {
+		tx_el = list_entry(tx_ctr, struct tx_queue_list, link);
+		
+		// This netpoll is going away - remove just these elements
+		if (tx_el->np == np) {
+			list_del(tx_ctr);
+			__kfree_skb(tx_el->skb);
+			kfree(tx_el);
+		}
+	}
+	spin_unlock_irqrestore(&tx_list_lock, flags);
+	
 	if (np->rx_hook) {
 		unsigned long flags;
 

--=-siOvjmewd9qVZIRl+1iS--
