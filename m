From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 7/7] gtp: add socket to pdp context
Date: Thu,  9 Mar 2017 17:43:02 +0100
Message-ID: <20170309164302.13550-8-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:51997 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932722AbdCIQne (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:34 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the socket present in context simplifies the sending logic.
It also fixes the invalid assumption that we have to use the same
sending socket for all client IP's on a specific gtp interface.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 94 +++++++++++++++++++++++++++----------------------------
 1 file changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index d58f46f..3e1854f 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -58,6 +58,7 @@ struct pdp_ctx {
 	struct in_addr		ms_addr_ip4;
 	struct in_addr		sgsn_addr_ip4;
 
+	struct sock		*sk;
 	struct net_device       *dev;
 
 	atomic_t		tx_seq;
@@ -179,8 +180,7 @@ static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 	return false;
 }
 
-static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen,
-		  bool xnet)
+static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen)
 {
 	struct pcpu_sw_netstats *stats;
 
@@ -190,7 +190,8 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen
 	}
 
 	/* Get rid of the GTP + UDP headers. */
-	if (iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet))
+	if (iptunnel_pull_header(skb, hdrlen, skb->protocol,
+				 !net_eq(sock_net(pctx->sk), dev_net(pctx->dev))))
 		return -1;
 
 	netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
@@ -214,8 +215,7 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen
 }
 
 /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
-static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
-			       bool xnet)
+static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp0_header);
@@ -239,11 +239,10 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, xnet);
+	return gtp_rx(pctx, skb, hdrlen);
 }
 
-static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
-				bool xnet)
+static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp1_header);
@@ -282,7 +281,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 		return 1;
 	}
 
-	return gtp_rx(pctx, skb, hdrlen, xnet);
+	return gtp_rx(pctx, skb, hdrlen);
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -318,7 +317,6 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct gtp_dev *gtp;
 	int ret = 0;
-	bool xnet;
 
 	gtp = rcu_dereference_sk_user_data(sk);
 	if (!gtp)
@@ -326,16 +324,14 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
 
-	xnet = !net_eq(sock_net(sk), dev_net(gtp->dev));
-
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
 		netdev_dbg(gtp->dev, "received GTP0 packet\n");
-		ret = gtp0_udp_encap_recv(gtp, skb, xnet);
+		ret = gtp0_udp_encap_recv(gtp, skb);
 		break;
 	case UDP_ENCAP_GTP1U:
 		netdev_dbg(gtp->dev, "received GTP1U packet\n");
-		ret = gtp1u_udp_encap_recv(gtp, skb, xnet);
+		ret = gtp1u_udp_encap_recv(gtp, skb);
 		break;
 	default:
 		ret = -1; /* Shouldn't happen. */
@@ -378,8 +374,9 @@ static void gtp_dev_uninit(struct net_device *dev)
 	free_percpu(dev->tstats);
 }
 
-static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
-					   const struct sock *sk, __be32 daddr)
+static struct rtable *ip4_route_output_gtp(struct flowi4 *fl4,
+					   const struct sock *sk,
+					   __be32 daddr)
 {
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_oif		= sk->sk_bound_dev_if;
@@ -388,7 +385,7 @@ static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
 	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
 	fl4->flowi4_proto	= sk->sk_protocol;
 
-	return ip_route_output_key(net, fl4);
+	return ip_route_output_key(sock_net(sk), fl4);
 }
 
 static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
@@ -477,7 +474,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	struct flowi4 fl4;
 	struct iphdr *iph;
-	struct sock *sk;
 	__be16 df;
 	int mtu;
 
@@ -493,30 +489,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	}
 	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
-	switch (pctx->gtp_version) {
-	case GTP_V0:
-		if (gtp->sk0)
-			sk = gtp->sk0;
-		else
-			sk = NULL;
-		break;
-	case GTP_V1:
-		if (gtp->sk1u)
-			sk = gtp->sk1u;
-		else
-			sk = NULL;
-		break;
-	default:
-		return -ENOENT;
-	}
-
-	if (!sk) {
-		netdev_dbg(dev, "no userspace socket is available, skip\n");
-		return -ENOENT;
-	}
-
-	rt = ip4_route_output_gtp(sock_net(sk), &fl4, gtp->sk0,
-				  pctx->sgsn_addr_ip4.s_addr);
+	rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->sgsn_addr_ip4.s_addr);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to SSGN %pI4\n",
 			   &pctx->sgsn_addr_ip4.s_addr);
@@ -561,7 +534,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		goto err_rt;
 	}
 
-	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
+	gtp_set_pktinfo_ipv4(pktinfo, pctx->sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
 	return 0;
@@ -916,7 +889,8 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	}
 }
 
-static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
+static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
+			struct genl_info *info)
 {
 	struct net_device *dev = gtp->dev;
 	u32 hash_ms, hash_tid = 0;
@@ -957,6 +931,8 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	if (pctx == NULL)
 		return -ENOMEM;
 
+	sock_hold(sk);
+	pctx->sk = sk;
 	pctx->dev = gtp->dev;
 	ipv4_pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
@@ -994,16 +970,26 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	return 0;
 }
 
+static void pdp_context_free(struct rcu_head *head)
+{
+	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
+
+	sock_put(pctx->sk);
+	kfree(pctx);
+}
+
 static void pdp_context_delete(struct pdp_ctx *pctx)
 {
 	hlist_del_rcu(&pctx->hlist_tid);
 	hlist_del_rcu(&pctx->hlist_addr);
-	kfree_rcu(pctx, rcu_head);
+	call_rcu(&pctx->rcu_head, pdp_context_free);
 }
 
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
+	unsigned int version;
 	struct gtp_dev *gtp;
+	struct sock *sk;
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
@@ -1012,7 +998,9 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	    !info->attrs[GTPA_MS_ADDRESS])
 		return -EINVAL;
 
-	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
+	version = nla_get_u32(info->attrs[GTPA_VERSION]);
+
+	switch (version) {
 	case GTP_V0:
 		if (!info->attrs[GTPA_TID] ||
 		    !info->attrs[GTPA_FLOW])
@@ -1036,7 +1024,19 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
-	err = ipv4_pdp_add(gtp, info);
+	if (version == GTP_V0)
+		sk = gtp->sk0;
+	else if (version == GTP_V1)
+		sk = gtp->sk1u;
+	else
+		sk = NULL;
+
+	if (!sk) {
+		err = -ENODEV;
+		goto out_unlock;
+	}
+
+	err = ipv4_pdp_add(gtp, sk, info);
 
 out_unlock:
 	rcu_read_unlock();
-- 
2.10.2
