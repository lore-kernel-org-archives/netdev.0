From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: [Patch] fix packet loss and massive ping spikes with PPP multi-link
Date: Fri, 26 Mar 2010 16:50:42 +0100
Message-ID: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

as you may be aware, it is recommended to switch of fragmentation when
doing PPP multi-link. Problems which will be seen if you don't do that
involve packet loss and massive spikes in the round-trip times.
An increase of 1.5 seconds(!) is what we usually see.

Every Cisco CPE offers to switch off fragmentation for multi-link, other
manufacturers are likely to offer it, as well.
We implemented a really ugly hack which allows us to do the same with
the Linux kernel. I can confirm that it gets rid of the problem 100%
of the time.

We are fully aware that this code is not nearly up for inclusion into
the kernel. What we hope to achieve is that someone with the skills to
do this properly will introduce an option to turn off fragmentation on
PPP multi-link or to just do away with it completely.

Some stats for a run of 4 hours each:

No patch:
    129 lost fragments, 575803 reordered
    127/3960 discarded fragments/bytes, 0 lost received

Patch:
    0 lost fragments, 0 reordered
    0/0 discarded fragments/bytes, 0 lost received

Unfortunately, I don't have paste-able stats for ping times available,
at the moment.


Any and all feedback on this is appreciated,
Richard

PS: Our image which is deployed in the field is using 2.6.32 which is
why we were forced to develop for and test with 2.6.32 instead of
linux-next; sorry for that.


--- /usr/src/linux-2.6.32.3/drivers/net/ppp_generic.c.orig	2010-03-25
16:56:05.000000000 +0100
+++ /usr/src/linux-2.6.32.3/drivers/net/ppp_generic.c	2010-03-26
14:42:42.000000000 +0100
@@ -123,6 +123,7 @@
 	struct net_device *dev;		/* network interface device a4 */
 	int		closing;	/* is device closing down? a8 */
 #ifdef CONFIG_PPP_MULTILINK
+	int		rrsched;	/* round robin scheduler for packet distribution */
 	int		nxchan;		/* next channel to send something on */
 	u32		nxseq;		/* next sequence number to send */
 	int		mrru;		/* MP: max reconst. receive unit */
@@ -1261,6 +1262,7 @@
 	struct list_head *list;
 	struct channel *pch;
 	struct sk_buff *skb = ppp->xmit_pending;
+	int i;

 	if (!skb)
 		return;
@@ -1292,10 +1294,40 @@
 	}

 #ifdef CONFIG_PPP_MULTILINK
-	/* Multilink: fragment the packet over as many links
-	   as can take the packet at the moment. */
-	if (!ppp_mp_explode(ppp, skb))
-		return;
+	ppp->rrsched++;
+//    printk(KERN_ERR "ppp: multi new packet, rrsched = %d\n", ppp->rrsched);
+
+	i = 0;
+	list_for_each_entry(pch, &ppp->channels, clist)      {
+//    	printk(KERN_ERR "ppp: channel %d ... \n", i);
+		if(pch->chan == NULL) continue;
+
+		if (ppp->rrsched % ppp->n_channels == i) {
+//    		printk(KERN_ERR "use channel %d\n", i);
+			spin_lock_bh(&pch->downl);
+			if (pch->chan) {
+//				++ppp->nxseq;
+				if (pch->chan->ops->start_xmit(pch->chan, skb)) {
+					ppp->xmit_pending = NULL;
+				}
+			} else {
+				/* channel got unregistered */
+				kfree_skb(skb);
+				ppp->xmit_pending = NULL;
+			}
+			spin_unlock_bh(&pch->downl);
+			return;
+		}
+		i++;
+	}
+//	printk(KERN_ERR "keep in queue\n");
+	return;
+
+
+//	/* Multilink: fragment the packet over as many links
+//	   as can take the packet at the moment. */
+//	if (!ppp_mp_explode(ppp, skb))
+//		return;
 #endif /* CONFIG_PPP_MULTILINK */

 	ppp->xmit_pending = NULL;
