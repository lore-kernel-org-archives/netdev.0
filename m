From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:08:11 +0200
Message-ID: <20060630130811.GE14627@postel.suug.ch>
References: <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2996 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932596AbWF3NHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 09:07:51 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151629890.8922.121.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-29 21:11
> Heres what it would look at ingress:
> 
> step 0: coming from wire via eth0,
> dev=eth0, input_dev=eth0
> 
> step 1: redirect to ifb0, leaving redirect
> dev=ifb0, input_dev=eth0
> 
> step 2: leaving ifb0, coming back to ingress side of stack
> 
> dev= eth0, input_dev=ifb0

That creates a nice loop on ingress. Upon reentering the
stack with skb->dev set to eth0 again we'll go through the
same ingress filters as the first time and we'll hit ifb0
again over and over. Are you suggesting everyone has to
insert a pass action matching input_dev in order to escape
the loop when using ifb?

> > When leaving ifb0 you want for...
> > ... egress:
> >    skb->dev=to (eth0) skb->iif=from (ifb0)
> > ... ingress:
> >    skb->dev=at (ifb0) skb->iif=from (eth0)
> > 
> 
> Yes, this is correct. I described the flow of the first one in the
> earlier email and the ingress side.

How can it be correct if it differs from your description
above? What I described is what the patch changes it to.
Looking closer at ifb it contains a race when updating
skb->dev. Preempt has to be disabled when updating skb->dev
before calling netif_rx() otherwise the device might disappear.

[NET]: Use interface index to keep input device information

Using the interface index instead of a direct reference
allows a safe usage beyond the scope where an interface
could disappear.

The old input_dev field was incorrectly made dependant
on CONFIG_NET_CLS_ACT in skb_copy().

The ifb device is fixed to set skb->dev in a manner that
the device can't disappear before calling netif_rx() and
the semantics are fixed so a packet reentering the stack
looks like it would have been received on the ifb device.

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
Index: net-2.6.git/drivers/net/ifb.c
===================================================================
--- net-2.6.git.orig/drivers/net/ifb.c
+++ net-2.6.git/drivers/net/ifb.c
@@ -98,13 +98,41 @@ static void ri_tasklet(unsigned long dev
 		stats->tx_packets++;
 		stats->tx_bytes +=skb->len;
 		if (from & AT_EGRESS) {
+			/*
+			 * Skb was given to us at egress, direct it back
+			 * to where it came from [iif] but update iif to
+			 * signal its new origin.
+			 */
+			struct net_device *iif;
+
+			iif = __dev_get_by_index(skb->iif);
+			if (!iif)
+				goto drop;
+
 			dp->st_rx_frm_egr++;
+
+			/* Already holding a reference on iif netdevice. */
+			skb->dev = iif;
+			skb->iif = _dev->ifindex;
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
-
+			/*
+			 * Skb was given to us at ingress, reinject into
+			 * stack as if it would have been received on
+			 * this device.
+			 */
 			dp->st_rx_frm_ing++;
+
+			/*
+			 * Disable preempt until holding new reference on
+			 * skb->dev in netif_rx().
+			 */
+			preempt_disable();
+			skb->dev = _dev;
 			netif_rx(skb);
+			preempt_enable();
 		} else {
+drop:
 			dev_kfree_skb(skb);
 			stats->tx_dropped++;
 		}
@@ -158,7 +186,7 @@ static int ifb_xmit(struct sk_buff *skb,
 	stats->tx_packets++;
 	stats->tx_bytes+=skb->len;
 
-	if (!from || !skb->input_dev) {
+	if (!from || !skb->iif) {
 dropped:
 		dev_kfree_skb(skb);
 		stats->rx_dropped++;
@@ -169,8 +197,6 @@ dropped:
 		 * ingress -> egress or
 		 * egress -> ingress
 		*/
-		skb->dev = skb->input_dev;
-		skb->input_dev = dev;
 		if (from & AT_INGRESS) {
 			skb_pull(skb, skb->dev->hard_header_len);
 		} else {
