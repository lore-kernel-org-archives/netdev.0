From: Ben McKeegan <ben@netservers.co.uk>
Subject: [PATCH] ppp: fix 'ppp_mp_reconstruct bad seq' errors
Date: Fri, 24 Feb 2012 16:33:56 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.1202241616590.5575@benxen>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulus@samba.org, netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch fixes a (mostly cosmetic) bug introduced by the patch
'ppp: Use SKB queue abstraction interfaces in fragment processing'
found here: http://www.spinics.net/lists/netdev/msg153312.html

The above patch rewrote and moved the code responsible for cleaning
up discarded fragments but the new code does not catch every case
where this is necessary.  This results in some discarded fragments
remaining in the queue, and triggering a 'bad seq' error on the
subsequent call to ppp_mp_reconstruct.  Fragments are discarded
whenever other fragments of the same frame have been lost.
This can generate a lot of unwanted and misleading log messages.

This patch also adds additional detail to the debug logging to
make it clearer which fragments were lost and which other fragments
were discarded as a result of losses. (Run pppd with 'kdebug 1'
option to enable debug logging.)

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>

diff -upr linux-3.2.7-orig/drivers/net/ppp/ppp_generic.c linux-3.2.7-fix-mp-reconstruct/drivers/net/ppp/ppp_generic.c
--- linux-3.2.7-orig/drivers/net/ppp/ppp_generic.c	2012-02-21 23:27:47.000000000 +0000
+++ linux-3.2.7-fix-mp-reconstruct/drivers/net/ppp/ppp_generic.c	2012-02-23 18:05:29.000000000 +0000
@@ -2162,14 +2162,22 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			continue;
 		}
 		if (PPP_MP_CB(p)->sequence != seq) {
+			u32 oldseq;
 			/* Fragment `seq' is missing.  If it is after
 			   minseq, it might arrive later, so stop here. */
 			if (seq_after(seq, minseq))
 				break;
 			/* Fragment `seq' is lost, keep going. */
 			lost = 1;
+			oldseq = seq;
 			seq = seq_before(minseq, PPP_MP_CB(p)->sequence)?
 				minseq + 1: PPP_MP_CB(p)->sequence;
+
+			if (ppp->debug & 1)
+				netdev_printk(KERN_DEBUG, ppp->dev,
+					      "lost frag %u..%u\n",
+					      oldseq, seq-1);
+
 			goto again;
 		}

@@ -2214,6 +2222,10 @@ ppp_mp_reconstruct(struct ppp *ppp)
 			struct sk_buff *tmp2;

 			skb_queue_reverse_walk_from_safe(list, p, tmp2) {
+				if (ppp->debug & 1)
+					netdev_printk(KERN_DEBUG, ppp->dev,
+						      "discarding frag %u\n",
+						      PPP_MP_CB(p)->sequence);
 				__skb_unlink(p, list);
 				kfree_skb(p);
 			}
@@ -2229,6 +2241,17 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		/* If we have discarded any fragments,
 		   signal a receive error. */
 		if (PPP_MP_CB(head)->sequence != ppp->nextseq) {
+			skb_queue_walk_safe(list, p, tmp) {
+				if (p == head)
+					break;
+				if (ppp->debug & 1)
+					netdev_printk(KERN_DEBUG, ppp->dev,
+						      "discarding frag %u\n",
+						      PPP_MP_CB(p)->sequence);
+				__skb_unlink(p, list);
+				kfree_skb(p);
+			}
+
 			if (ppp->debug & 1)
 				netdev_printk(KERN_DEBUG, ppp->dev,
 					      "  missed pkts %u..%u\n",
