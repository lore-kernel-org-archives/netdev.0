From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Mon, 31 Jan 2005 11:29:20 +0100
Message-ID: <20050131102920.GC4170@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I'm just looking into a problem that may be related to the
new neighbor discovery code in core/neighbour.c.

The problem was originally reported against our SLES kernel, but the
code in 2.6.11-rc2 is almost identical; code and patches shown below
are relative to 2.6.11-rc2

The problem is that IBM testing was hitting the assertion in kfree_skb
that checks that the skb has been removed from any list it was on
("kfree_skb passed an skb still on a list").

It seems the problem is a bad interaction between neigh_event_send and
neigh_timer_handler:

In neigh_event_send:

		if (skb_queue_len(&neigh->arp_queue) >=
		    neigh->parms->queue_len) {
			struct sk_buff *buff;
			buff = neigh->arp_queue.next;
			__skb_unlink(buff, &neigh->arp_queue);
			kfree_skb(buff);
		}

If the ARP queue overflows, we're trying to remove the first skb
from the list. While we do this, the neighbor is locked.

The corresponding piece of code in neigh_timer_handler is this:

                struct sk_buff *skb = skb_peek(&neigh->arp_queue);
                /* keep skb alive even if arp_queue overflows */
                if (skb)
                        skb_get(skb);
                write_unlock(&neigh->lock);
                neigh->ops->solicit(neigh, skb);
                atomic_inc(&neigh->probes);
                if (skb)
                        kfree_skb(skb); /* <== this is where we BUG() */

The use of skb_get/kfree_skb makes sure the skb remains live while
we're calling solicit(). Note that the neighbor isn't locked when we
call kfree_skb.

Now what happens in the bug that was reported to us (this was on a
PPC SMP machine) is this, I think:

 -	On CPU 0, neigh_timer_handler grabs the first skb on the queue,
	incrementing is reference count to 2,
	unlocks the neighbor, calls solicit()
 -	On CPU 1, we enter neigh_event_send, find the ARP
	queue is full and remove the first skb. The call to kfree_skb
	will decrement the refcount to 1. This change is visible
	on all CPUs immediately, because it's an atomic_dec.
	The effects of __skb_unlink are not immediately visible
	on the other CPUs however.
 -	On the first CPU, we return from solicit, call kfree_skb.
 	Refcount goes to zero, but __kfree_skb still sees the
	skb->list pointer => barf.

One possible fix here would be to add an smp_wmb after the __skb_unlink
and a smp_rmb before the assertion in __kfree_skb, as in the attached
patch.

Does this make sense?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=arp-skb-unlink-serialize

Index: linux-2.6.10/net/core/neighbour.c
===================================================================
--- linux-2.6.10.orig/net/core/neighbour.c	2005-01-21 11:04:23.000000000 +0100
+++ linux-2.6.10/net/core/neighbour.c	2005-01-31 11:20:38.000000000 +0100
@@ -876,6 +876,9 @@ int __neigh_event_send(struct neighbour 
 				struct sk_buff *buff;
 				buff = neigh->arp_queue.next;
 				__skb_unlink(buff, &neigh->arp_queue);
+				/* Make sure the change of skb->head is
+				 * visible on all CPUs */
+				smp_wmb();
 				kfree_skb(buff);
 			}
 			__skb_queue_tail(&neigh->arp_queue, skb);
Index: linux-2.6.10/net/core/skbuff.c
===================================================================
--- linux-2.6.10.orig/net/core/skbuff.c	2005-01-21 11:04:15.000000000 +0100
+++ linux-2.6.10/net/core/skbuff.c	2005-01-31 11:20:52.000000000 +0100
@@ -275,6 +275,7 @@ void kfree_skbmem(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
+	smp_rmb();
 	if (skb->list) {
 	 	printk(KERN_WARNING "Warning: kfree_skb passed an skb still "
 		       "on a list (from %p).\n", NET_CALLER(skb));

--fUYQa+Pmc3FrFX/N--
