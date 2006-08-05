From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: nf_queue: handle GSO packets
Date: Sat, 05 Aug 2006 09:25:34 +0200
Message-ID: <44D447EE.2010203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405000104050304080701"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25236 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422683AbWHEHZe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:25:34 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010405000104050304080701
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------010405000104050304080701
Content-Type: text/plain;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

[NETFILTER]: nf_queue: handle GSO packets

Handle GSO packets in nf_queue by segmenting them before queueing to
avoid breaking GSO in case they get mangled.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 25b15e13491e9904b4fdf60b67a3c5d933e35fca
tree 68eab97a1634bebdd0d8431b5487df0b8f88bcf3
parent d4bf859dbf0158d8ac0dc7d9d88d68c6882233df
author Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:16:37 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:16:37 +0200

 net/netfilter/core.c         |    2 +
 net/netfilter/nf_internals.h |    2 +
 net/netfilter/nf_queue.c     |   80 ++++++++++++++++++++++++++++++++----------
 3 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 27f639f..d80b935 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -182,7 +182,7 @@ next_hook:
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
-		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn,
+		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 	}
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 86e392b..a981971 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -23,7 +23,7 @@ extern unsigned int nf_iterate(struct li
 				int hook_thresh);
 
 /* nf_queue.c */
-extern int nf_queue(struct sk_buff **skb, 
+extern int nf_queue(struct sk_buff *skb,
 		    struct list_head *elem, 
 		    int pf, unsigned int hook,
 		    struct net_device *indev,
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 662a869..4d8936e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -74,13 +74,13 @@ EXPORT_SYMBOL_GPL(nf_unregister_queue_ha
  * Any packet that leaves via this function must come back 
  * through nf_reinject().
  */
-int nf_queue(struct sk_buff **skb, 
-	     struct list_head *elem, 
-	     int pf, unsigned int hook,
-	     struct net_device *indev,
-	     struct net_device *outdev,
-	     int (*okfn)(struct sk_buff *),
-	     unsigned int queuenum)
+static int __nf_queue(struct sk_buff *skb,
+		      struct list_head *elem,
+		      int pf, unsigned int hook,
+		      struct net_device *indev,
+		      struct net_device *outdev,
+		      int (*okfn)(struct sk_buff *),
+		      unsigned int queuenum)
 {
 	int status;
 	struct nf_info *info;
@@ -94,14 +94,14 @@ #endif
 	read_lock(&queue_handler_lock);
 	if (!queue_handler[pf]) {
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
 	afinfo = nf_get_afinfo(pf);
 	if (!afinfo) {
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
@@ -109,9 +109,9 @@ #endif
 	if (!info) {
 		if (net_ratelimit())
 			printk(KERN_ERR "OOM queueing packet %p\n",
-			       *skb);
+			       skb);
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
@@ -130,15 +130,15 @@ #endif
 	if (outdev) dev_hold(outdev);
 
 #ifdef CONFIG_BRIDGE_NETFILTER
-	if ((*skb)->nf_bridge) {
-		physindev = (*skb)->nf_bridge->physindev;
+	if (skb->nf_bridge) {
+		physindev = skb->nf_bridge->physindev;
 		if (physindev) dev_hold(physindev);
-		physoutdev = (*skb)->nf_bridge->physoutdev;
+		physoutdev = skb->nf_bridge->physoutdev;
 		if (physoutdev) dev_hold(physoutdev);
 	}
 #endif
-	afinfo->saveroute(*skb, info);
-	status = queue_handler[pf]->outfn(*skb, info, queuenum,
+	afinfo->saveroute(skb, info);
+	status = queue_handler[pf]->outfn(skb, info, queuenum,
 					  queue_handler[pf]->data);
 
 	read_unlock(&queue_handler_lock);
@@ -153,7 +153,7 @@ #ifdef CONFIG_BRIDGE_NETFILTER
 #endif
 		module_put(info->elem->owner);
 		kfree(info);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 
 		return 1;
 	}
@@ -161,6 +161,46 @@ #endif
 	return 1;
 }
 
+int nf_queue(struct sk_buff *skb,
+	     struct list_head *elem,
+	     int pf, unsigned int hook,
+	     struct net_device *indev,
+	     struct net_device *outdev,
+	     int (*okfn)(struct sk_buff *),
+	     unsigned int queuenum)
+{
+	struct sk_buff *segs;
+
+	if (!skb_is_gso(skb))
+		return __nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
+				  queuenum);
+
+	switch (pf) {
+	case AF_INET:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case AF_INET6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	}
+
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+	if (unlikely(IS_ERR(segs)))
+		return 1;
+
+	do {
+		struct sk_buff *nskb = segs->next;
+
+		segs->next = NULL;
+		if (!__nf_queue(segs, elem, pf, hook, indev, outdev, okfn,
+				queuenum))
+			kfree_skb(segs);
+		segs = nskb;
+	} while (segs);
+	return 1;
+}
+
 void nf_reinject(struct sk_buff *skb, struct nf_info *info,
 		 unsigned int verdict)
 {
@@ -224,9 +264,9 @@ #endif
 	case NF_STOLEN:
 		break;
 	case NF_QUEUE:
-		if (!nf_queue(&skb, elem, info->pf, info->hook, 
-			      info->indev, info->outdev, info->okfn,
-			      verdict >> NF_VERDICT_BITS))
+		if (!__nf_queue(skb, elem, info->pf, info->hook,
+				info->indev, info->outdev, info->okfn,
+				verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 		break;
 	default:

--------------010405000104050304080701--
