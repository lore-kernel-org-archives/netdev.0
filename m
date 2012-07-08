From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [RFC PATCH] ppp: add support for L2 multihop / tunnel switching
Date: Sun, 8 Jul 2012 17:49:30 -0400
Message-ID: <20120708214930.GI19462@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

Below is a first cut at implementing multihop L2TP, also known as tunnel 
switching.  The feature is similar in scope to how PPPoE relaying works -- 
L2 packets that are received on one PPP interface are forwarded to another.  
This feature is typically used for traffic aggregation and backhaul for 
ISPs, with incoming sessions (often PPPoE) being partially authenticated 
by a LAC, and then forwarded over an L2TP session to an LNS (selected by the 
user's domain) which then provides network access to the client.

This is an RFC primarily to get some feedback on the implementation 
approach being used.  At present, this code is intercepting packets as soon 
as they are received on a PPP channel.  The packets are then modified to 
use a fake ETH_P_PPP protocol type and sent out over another PPP device 
via dev_queue_xmit().  In theory this enables forwarding of any type of PPP 
session, although I've only tested L2TPv2 so far.

The reasoning behind using dev_queue_xmit() rather than outputting directly 
to another PPP channel is to enable the use of the traffic shaping and 
queuing features of the kernel on multihop sessions.

Comments / thoughts?  A sample test program is available at 
http://www.kvack.org/~bcrl/pppol2tp/multihop.c .  I am in the process of 
updating the Babylon PPP implementation to use this functionality, and 
expect to be ready to make those changes available later this week.  I 
have not yet finished testing this code, so I'm sure that there are bugs 
lurking within.

		-ben

Not-signed-off-yet-by: Benjamin LaHaise <bcrl@kvack.org>
---
 drivers/net/ppp/ppp_generic.c |   53 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_ether.h      |    1 
 include/linux/ppp-ioctl.h     |    1 
 3 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c05572..9c12712 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -121,6 +121,7 @@ struct ppp {
 	unsigned long	last_xmit;	/* jiffies when last pkt sent 9c */
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
+	struct net_device *multihop_if;	/* if to forward incoming frames to */
 	int		closing;	/* is device closing down? a8 */
 #ifdef CONFIG_PPP_MULTILINK
 	int		nxchan;		/* next channel to send something on */
@@ -738,6 +739,30 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		err = 0;
 		break;
 
+	case PPPIOCSMULTIHOP_IF:
+	{
+		struct net_device *multihop_if;
+		if (get_user(val, p))
+			break;
+		err = 0;
+		if (ppp->multihop_if && (val == -1)) {
+			struct net_device *dev = ppp->multihop_if;
+			ppp->multihop_if = NULL;
+			dev_put(dev);
+			break;
+		}
+		err = -EBUSY;
+		if (ppp->multihop_if)
+			break;
+		multihop_if = dev_get_by_index(&init_net, val);
+		err = -ENOENT;
+		if (!multihop_if)
+			break;
+		ppp->multihop_if = multihop_if;
+		err = 0;
+		break;
+	}
+
 #ifdef CONFIG_PPP_FILTER
 	case PPPIOCSPASS:
 	{
@@ -942,6 +967,9 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int npi, proto;
 	unsigned char *pp;
 
+	if (skb->protocol == htons(ETH_P_PPP))
+		goto queue;
+
 	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
 		goto outf;
@@ -968,6 +996,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	proto = npindex_to_proto[npi];
 	put_unaligned_be16(proto, pp);
 
+queue:
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
 	return NETDEV_TX_OK;
@@ -1131,6 +1160,9 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	int len;
 	unsigned char *cp;
 
+	if (skb->protocol == htons(ETH_P_PPP))
+		goto xmit;
+
 	if (proto < 0x8000) {
 #ifdef CONFIG_PPP_FILTER
 		/* check if we should pass this packet */
@@ -1228,6 +1260,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		return;
 	}
 
+xmit:
 	ppp->xmit_pending = skb;
 	ppp_push(ppp);
 	return;
@@ -1259,7 +1292,8 @@ ppp_push(struct ppp *ppp)
 		return;
 	}
 
-	if ((ppp->flags & SC_MULTILINK) == 0) {
+	if (((ppp->flags & SC_MULTILINK) == 0) ||
+	    (skb->protocol == htons(ETH_P_PPP))) {
 		/* not doing multilink: send it down the first channel */
 		list = list->next;
 		pch = list_entry(list, struct channel, clist);
@@ -1599,6 +1633,14 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 		goto done;
 	}
 
+	if (pch->ppp && pch->ppp->multihop_if) {
+		skb->protocol = htons(ETH_P_PPP);
+		skb->dev = pch->ppp->multihop_if;
+		skb->ip_summed = CHECKSUM_NONE;
+		dev_queue_xmit(skb);
+		goto done;
+	}
+
 	proto = PPP_PROTO(skb);
 	if (!pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
 		/* put it on the channel queue */
@@ -2715,8 +2757,12 @@ static void ppp_shutdown_interface(struct ppp *ppp)
 	/* This will call dev_close() for us. */
 	ppp_lock(ppp);
 	if (!ppp->closing) {
+		struct net_device *multihop_if = ppp->multihop_if;
 		ppp->closing = 1;
+		ppp->multihop_if = NULL;
 		ppp_unlock(ppp);
+		if (multihop_if)
+			dev_put(multihop_if);
 		unregister_netdev(ppp->dev);
 		unit_put(&pn->units_idr, ppp->file.index);
 	} else
@@ -2764,6 +2810,11 @@ static void ppp_destroy_interface(struct ppp *ppp)
 #endif /* CONFIG_PPP_FILTER */
 
 	kfree_skb(ppp->xmit_pending);
+	printk("ppp_destroy_interface(%p): multihop_if = %p\n", ppp,
+		ppp->multihop_if);
+	if (ppp->multihop_if)
+		dev_put(ppp->multihop_if);
+	ppp->multihop_if = NULL;
 
 	free_netdev(ppp->dev);
 }
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 167ce5b..fe47a70 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -120,6 +120,7 @@
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
+#define ETH_P_PPP	0x00F8		/* Dummy type for PPP multihop	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/ppp-ioctl.h b/include/linux/ppp-ioctl.h
index 2d9a885..5571375 100644
--- a/include/linux/ppp-ioctl.h
+++ b/include/linux/ppp-ioctl.h
@@ -81,6 +81,7 @@ struct pppol2tp_ioc_stats {
  * Ioctl definitions.
  */
 
+#define	PPPIOCSMULTIHOP_IF	_IOWR('t', 91, int) /* set multihop if */
 #define	PPPIOCGFLAGS	_IOR('t', 90, int)	/* get configuration flags */
 #define	PPPIOCSFLAGS	_IOW('t', 89, int)	/* set configuration flags */
 #define	PPPIOCGASYNCMAP	_IOR('t', 88, int)	/* get async map */
-- 
"Thought is the essence of where you are now."
