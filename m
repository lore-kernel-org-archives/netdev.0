From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [NET]: Use interface index to keep input device information
Date: Mon, 26 Jun 2006 00:00:01 +0200
Message-ID: <20060626145515.150014000@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:23466 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932346AbWFZO6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 10:58:36 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=input_dev
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the interface index instead of a direct reference
allows a safe usage beyond the scope where an interface
could disappear.

The old input_dev field was incorrectly made dependant
on CONFIG_NET_CLS_ACT in skb_copy().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/include/linux/skbuff.h
===================================================================
--- net-2.6.git.orig/include/linux/skbuff.h
+++ net-2.6.git/include/linux/skbuff.h
@@ -181,7 +181,6 @@ enum {
  *	@sk: Socket we are owned by
  *	@tstamp: Time we arrived
  *	@dev: Device we arrived on/are leaving by
- *	@input_dev: Device we arrived on
  *	@h: Transport layer header
  *	@nh: Network layer header
  *	@mac: Link layer header
@@ -192,6 +191,7 @@ enum {
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
  *	@csum: Checksum
+ *	@iif: Device we arrived on
  *	@local_df: allow local fragmentation
  *	@cloned: Head may be cloned (check refcnt to be sure)
  *	@nohdr: Payload reference only, must not modify header
@@ -228,7 +228,6 @@ struct sk_buff {
 	struct sock		*sk;
 	struct skb_timeval	tstamp;
 	struct net_device	*dev;
-	struct net_device	*input_dev;
 
 	union {
 		struct tcphdr	*th;
@@ -266,6 +265,7 @@ struct sk_buff {
 				data_len,
 				mac_len,
 				csum;
+	int			iif;
 	__u32			priority;
 	__u8			local_df:1,
 				cloned:1,
Index: net-2.6.git/include/net/pkt_cls.h
===================================================================
--- net-2.6.git.orig/include/net/pkt_cls.h
+++ net-2.6.git/include/net/pkt_cls.h
@@ -352,14 +352,19 @@ tcf_change_indev(struct tcf_proto *tp, c
 static inline int
 tcf_match_indev(struct sk_buff *skb, char *indev)
 {
+	int ret = 1;
+
 	if (indev[0]) {
-		if  (!skb->input_dev)
-			return 0;
-		if (strcmp(indev, skb->input_dev->name))
+		struct net_device *dev;
+
+		dev = dev_get_by_index(skb->iif);
+		if  (!dev)
 			return 0;
+		ret = !strcmp(indev, dev->name);
+		dev_put(dev);
 	}
 
-	return 1;
+	return ret;
 }
 #endif /* CONFIG_NET_CLS_IND */
 
Index: net-2.6.git/net/core/dev.c
===================================================================
--- net-2.6.git.orig/net/core/dev.c
+++ net-2.6.git/net/core/dev.c
@@ -1715,8 +1715,8 @@ static int ing_filter(struct sk_buff *sk
 	if (dev->qdisc_ingress) {
 		__u32 ttl = (__u32) G_TC_RTTL(skb->tc_verd);
 		if (MAX_RED_LOOP < ttl++) {
-			printk("Redir loop detected Dropping packet (%s->%s)\n",
-				skb->input_dev->name, skb->dev->name);
+			printk("Redir loop detected Dropping packet (%d->%s)\n",
+				skb->iif, skb->dev->name);
 			return TC_ACT_SHOT;
 		}
 
@@ -1749,8 +1749,8 @@ int netif_receive_skb(struct sk_buff *sk
 	if (!skb->tstamp.off_sec)
 		net_timestamp(skb);
 
-	if (!skb->input_dev)
-		skb->input_dev = skb->dev;
+	if (!skb->iif)
+		skb->iif = skb->dev->ifindex;
 
 	orig_dev = skb_bond(skb);
 
Index: net-2.6.git/net/core/skbuff.c
===================================================================
--- net-2.6.git.orig/net/core/skbuff.c
+++ net-2.6.git/net/core/skbuff.c
@@ -463,10 +463,10 @@ struct sk_buff *skb_clone(struct sk_buff
 	n->tc_verd = SET_TC_VERD(skb->tc_verd,0);
 	n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
 	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
-	C(input_dev);
 #endif
 	skb_copy_secmark(n, skb);
 #endif
+	C(iif);
 	C(truesize);
 	atomic_set(&n->users, 1);
 	C(head);
Index: net-2.6.git/net/sched/act_api.c
===================================================================
--- net-2.6.git.orig/net/sched/act_api.c
+++ net-2.6.git/net/sched/act_api.c
@@ -156,9 +156,8 @@ int tcf_action_exec(struct sk_buff *skb,
 
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %s out %s\n",
-		         skb, skb->input_dev ? skb->input_dev->name : "xxx",
-		         skb->dev->name);
+		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %d out %s\n",
+		         skb, skb->iif, skb->dev->name);
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
Index: net-2.6.git/net/sched/act_mirred.c
===================================================================
--- net-2.6.git.orig/net/sched/act_mirred.c
+++ net-2.6.git/net/sched/act_mirred.c
@@ -207,7 +207,7 @@ bad_mirred:
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->dev = dev;
-	skb2->input_dev = skb->dev;
+	skb2->iif = skb->dev->ifindex;
 	dev_queue_xmit(skb2);
 	spin_unlock(&p->lock);
 	return p->action;

--

