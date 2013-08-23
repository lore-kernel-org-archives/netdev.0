From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode callback
Date: Fri, 23 Aug 2013 14:47:04 +0800
Message-ID: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <saurabh.mohan@vyatta.com>,
	<herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:57710 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672Ab3HWGrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 02:47:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some thoughts on IPv4 VTI implementation:

The connection between VTI receiving part and xfrm tunnel mode input process
is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g ipip/sit
and xfrm4_tunnel, acts like a true "tunnel" device.

In addition, IMHO, VTI doesn't need vti_err to do something meaningful, as all
VTI needs is just a notifier to be called whenever xfrm_input ingress a packet
to update statistics.

So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out vti_erri
code.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h           |   10 +++++--
 net/ipv4/ip_vti.c            |   67 +-----------------------------------------
 net/ipv4/xfrm4_mode_tunnel.c |   16 +++++-----
 3 files changed, 17 insertions(+), 76 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..5451c68 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1352,6 +1352,12 @@ struct xfrm_tunnel {
 	int priority;
 };
 
+struct xfrm_tunnel_notifier {
+	int (*handler)(struct sk_buff *skb);
+	struct xfrm_tunnel_notifier __rcu *next;
+	int priority;
+};
+
 struct xfrm6_tunnel {
 	int (*handler)(struct sk_buff *skb);
 	int (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -1495,8 +1501,8 @@ extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_output_finish(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
-extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
-extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
+extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
+extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
 extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e805e7b..91f69bc 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -49,70 +49,6 @@ static struct rtnl_link_ops vti_link_ops __read_mostly;
 static int vti_net_id __read_mostly;
 static int vti_tunnel_init(struct net_device *dev);
 
-static int vti_err(struct sk_buff *skb, u32 info)
-{
-
-	/* All the routers (except for Linux) return only
-	 * 8 bytes of packet payload. It means, that precise relaying of
-	 * ICMP in the real Internet is absolutely infeasible.
-	 */
-	struct net *net = dev_net(skb->dev);
-	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
-	struct iphdr *iph = (struct iphdr *)skb->data;
-	const int type = icmp_hdr(skb)->type;
-	const int code = icmp_hdr(skb)->code;
-	struct ip_tunnel *t;
-	int err;
-
-	switch (type) {
-	default:
-	case ICMP_PARAMETERPROB:
-		return 0;
-
-	case ICMP_DEST_UNREACH:
-		switch (code) {
-		case ICMP_SR_FAILED:
-		case ICMP_PORT_UNREACH:
-			/* Impossible event. */
-			return 0;
-		default:
-			/* All others are translated to HOST_UNREACH. */
-			break;
-		}
-		break;
-	case ICMP_TIME_EXCEEDED:
-		if (code != ICMP_EXC_TTL)
-			return 0;
-		break;
-	}
-
-	err = -ENOENT;
-
-	t = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
-			     iph->daddr, iph->saddr, 0);
-	if (t == NULL)
-		goto out;
-
-	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_IPIP, 0);
-		err = 0;
-		goto out;
-	}
-
-	err = 0;
-	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		goto out;
-
-	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
-		t->err_count++;
-	else
-		t->err_count = 1;
-	t->err_time = jiffies;
-out:
-	return err;
-}
-
 /* We dont digest the packet therefore let the packet pass */
 static int vti_rcv(struct sk_buff *skb)
 {
@@ -296,9 +232,8 @@ static void __net_init vti_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 }
 
-static struct xfrm_tunnel vti_handler __read_mostly = {
+static struct xfrm_tunnel_notifier vti_handler __read_mostly = {
 	.handler	=	vti_rcv,
-	.err_handler	=	vti_err,
 	.priority	=	1,
 };
 
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index eb1dd4d..b82cde1 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -16,13 +16,13 @@
 #include <net/xfrm.h>
 
 /* Informational hook. The decap is still done here. */
-static struct xfrm_tunnel __rcu *rcv_notify_handlers __read_mostly;
+static struct xfrm_tunnel_notifier __rcu *rcv_notify_handlers __read_mostly;
 static DEFINE_MUTEX(xfrm4_mode_tunnel_input_mutex);
 
-int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler)
+int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler)
 {
-	struct xfrm_tunnel __rcu **pprev;
-	struct xfrm_tunnel *t;
+	struct xfrm_tunnel_notifier __rcu **pprev;
+	struct xfrm_tunnel_notifier *t;
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
@@ -50,10 +50,10 @@ err:
 }
 EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_register);
 
-int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler)
+int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler)
 {
-	struct xfrm_tunnel __rcu **pprev;
-	struct xfrm_tunnel *t;
+	struct xfrm_tunnel_notifier __rcu **pprev;
+	struct xfrm_tunnel_notifier *t;
 	int ret = -ENOENT;
 
 	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
@@ -134,7 +134,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_tunnel *handler;
+	struct xfrm_tunnel_notifier *handler;
 	int err = -EINVAL;
 
 	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPIP)
-- 
1.7.9.5
