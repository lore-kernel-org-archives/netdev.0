From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Sat, 18 Dec 2004 18:00:17 +0100
Message-ID: <20041218170017.GH17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Correctly handle shared and cloned skbs by copying them before writing
and dequeue unwriteable skbs unchanged. Assumes that IP/IPv6 header
is always linear so no pulling required.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc3-bk12.orig/net/sched/sch_dsmark.c	2004-12-18 15:16:29.000000000 +0100
+++ linux-2.6.10-rc3-bk12/net/sched/sch_dsmark.c	2004-12-18 16:24:58.000000000 +0100
@@ -195,7 +195,8 @@
 
 	D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
 	if (p->set_tc_index) {
-		/* FIXME: Safe with non-linear skbs? --RR */
+		/* Safe with non-linear skbs? --RR
+		   IP/IPv6 header is always linear --TGR */
 		switch (skb->protocol) {
 			case __constant_htons(ETH_P_IP):
 				skb->tc_index = ipv4_get_dsfield(skb->nh.iph);
@@ -250,6 +251,34 @@
 	return ret;
 }
 
+static inline int
+dsmark_make_writeable(struct sk_buff **pskb, int offset)
+{
+	struct sk_buff *nskb;
+
+	if ((offset + (*pskb)->mac_len) > (*pskb)->len)
+		return 0;
+
+	if (skb_shared(*pskb) || skb_cloned(*pskb))
+		goto copy_skb;
+
+	/* IP/IPv6 header is always linear, no need to pull */
+	return 1;
+
+copy_skb:
+	nskb = skb_copy(*pskb, GFP_ATOMIC);
+	if (!nskb)
+		return 0;
+	BUG_ON(skb_is_nonlinear(nskb));
+
+	/* Rest of kernel will get very unhappy if we pass it a
+	   suddenly-orphaned skbuff */
+	if ((*pskb)->sk)
+		skb_set_owner_w(nskb, (*pskb)->sk);
+	kfree_skb(*pskb);
+	*pskb = nskb;
+	return 1;
+}
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 {
@@ -266,10 +295,14 @@
 	D2PRINTK("index %d->%d\n",skb->tc_index,index);
 	switch (skb->protocol) {
 		case __constant_htons(ETH_P_IP):
+			if (!dsmark_make_writeable(&skb, sizeof(struct iphdr)))
+				goto unwriteable;
 			ipv4_change_dsfield(skb->nh.iph,
 			    p->mask[index],p->value[index]);
 			break;
 		case __constant_htons(ETH_P_IPV6):
+			if (!dsmark_make_writeable(&skb, sizeof(struct ipv6hdr)))
+				goto unwriteable;
 			ipv6_change_dsfield(skb->nh.ipv6h,
 			    p->mask[index],p->value[index]);
 			break;
@@ -280,12 +313,17 @@
 			 * and don't need yet another qdisc as a bypass.
 			 */
 			if (p->mask[index] != 0xff || p->value[index])
-				printk(KERN_WARNING "dsmark_dequeue: "
-				       "unsupported protocol %d\n",
-				       htons(skb->protocol));
+				if (net_ratelimit())
+					printk(KERN_WARNING "dsmark_dequeue: "
+					       "unsupported protocol %d\n",
+					       htons(skb->protocol));
 			break;
 	};
 	return skb;
+unwriteable:
+	if (net_ratelimit())
+		printk(KERN_WARNING "dsmark_dequeue: skb not writable\n");
+	return skb;
 }
 
 
