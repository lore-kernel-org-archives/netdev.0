From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v5 net-next 09/12] gtp: Eliminate pktinfo and add port configuration
Date: Wed, 18 Oct 2017 13:10:15 -0700
Message-ID: <20171018201018.5692-10-tom@quantonium.net>
References: <20171018201018.5692-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:49723 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdJRULS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:11:18 -0400
Received: by mail-pg0-f66.google.com with SMTP id g6so5163073pgn.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:11:18 -0700 (PDT)
In-Reply-To: <20171018201018.5692-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gtp pktinfo structure is unnecessary and needs a lot of code to
manage it. Remove it. Also, add per pdp port configuration for transmit.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c        | 177 +++++++++++++++++++++--------------------------
 include/uapi/linux/gtp.h |   1 +
 2 files changed, 80 insertions(+), 98 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index bbb08f8849d3..44844eba8df2 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -54,6 +54,7 @@ struct pdp_ctx {
 	} u;
 	u8			gtp_version;
 	u8			hlen;
+	__be16			gtp_port;
 	u16			af;
 
 	struct in_addr		ms_addr_ip4;
@@ -420,73 +421,36 @@ static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	 */
 }
 
-struct gtp_pktinfo {
-	struct sock		*sk;
-	struct iphdr		*iph;
-	struct flowi4		fl4;
-	struct rtable		*rt;
-	struct pdp_ctx		*pctx;
-	struct net_device	*dev;
-	__be16			gtph_port;
-};
-
-static void gtp_push_header(struct sk_buff *skb, struct gtp_pktinfo *pktinfo)
+static void gtp_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 {
-	switch (pktinfo->pctx->gtp_version) {
+	switch (pctx->gtp_version) {
 	case GTP_V0:
-		pktinfo->gtph_port = htons(GTP0_PORT);
-		gtp0_push_header(skb, pktinfo->pctx);
+		gtp0_push_header(skb, pctx);
 		break;
 	case GTP_V1:
-		pktinfo->gtph_port = htons(GTP1U_PORT);
-		gtp1_push_header(skb, pktinfo->pctx);
+		gtp1_push_header(skb, pctx);
 		break;
 	}
 }
 
-static inline void gtp_set_pktinfo_ipv4(struct gtp_pktinfo *pktinfo,
-					struct sock *sk, struct iphdr *iph,
-					struct pdp_ctx *pctx, struct rtable *rt,
-					struct flowi4 *fl4,
-					struct net_device *dev)
-{
-	pktinfo->sk	= sk;
-	pktinfo->iph	= iph;
-	pktinfo->pctx	= pctx;
-	pktinfo->rt	= rt;
-	pktinfo->fl4	= *fl4;
-	pktinfo->dev	= dev;
-}
-
-static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
-			     struct gtp_pktinfo *pktinfo)
+static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
+		    struct pdp_ctx *pctx)
 {
-	struct gtp_dev *gtp = netdev_priv(dev);
-	struct pdp_ctx *pctx;
+	struct iphdr *inner_iph = NULL;
+	struct sock *sk = pctx->sk;
+	__be32 saddr = inet_sk(sk)->inet_saddr;
 	struct rtable *rt;
-	struct flowi4 fl4;
-	struct iphdr *iph;
-	struct sock *sk;
-	__be32 saddr;
+	int err = 0;
 
-	/* Read the IP destination address and resolve the PDP context.
-	 * Prepend PDP header with TEI/TID from PDP ctx.
-	 */
-	iph = ip_hdr(skb);
-	if (gtp->role == GTP_ROLE_SGSN)
-		pctx = ipv4_pdp_find(gtp, iph->saddr);
-	else
-		pctx = ipv4_pdp_find(gtp, iph->daddr);
+	if (skb->protocol == ETH_P_IP)
+		inner_iph = ip_hdr(skb);
 
-	if (!pctx) {
-		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
-			   &iph->daddr);
-		return -ENOENT;
-	}
-	netdev_dbg(dev, "found PDP context %p\n", pctx);
+	/* Ensure there is sufficient headroom. */
+	err = skb_cow_head(skb, dev->needed_headroom);
+	if (unlikely(err))
+		goto out_err;
 
-	sk = pctx->sk;
-	saddr = inet_sk(sk)->inet_saddr;
+	skb_reset_inner_headers(skb);
 
 	/* Source address returned by route lookup is ignored since
 	 * we get the address from a socket.
@@ -494,81 +458,89 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	rt = ip_tunnel_get_route(dev, skb, sk->sk_protocol,
 				 sk->sk_bound_dev_if, RT_CONN_FLAGS(sk),
 				 pctx->peer_addr_ip4.s_addr, &saddr,
-				 pktinfo->gtph_port, pktinfo->gtph_port,
+				 pctx->gtp_port, pctx->gtp_port,
 				 &pctx->dst_cache, NULL);
 
 	if (IS_ERR(rt)) {
-		if (rt == ERR_PTR(-ELOOP)) {
-			netdev_dbg(dev, "circular route to SSGN %pI4\n",
-				   &pctx->peer_addr_ip4.s_addr);
-			dev->stats.collisions++;
-			goto err_rt;
-		} else {
-			netdev_dbg(dev, "no route to SSGN %pI4\n",
-				   &pctx->peer_addr_ip4.s_addr);
-			dev->stats.tx_carrier_errors++;
-			goto err;
-		}
+		err = PTR_ERR(rt);
+		goto out_err;
 	}
 
 	skb_dst_drop(skb);
 
-	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
-	gtp_push_header(skb, pktinfo);
+	gtp_push_header(skb, pctx);
+
+	if (inner_iph)
+		__iptunnel_update_pmtu(dev, skb, &rt->dst,
+				       !!inner_iph->frag_off,
+				       inner_iph, pctx->hlen,
+				       pctx->peer_addr_ip4.s_addr);
 
-	__iptunnel_update_pmtu(dev, skb, &rt->dst, !!iph->frag_off, iph,
-			       pctx->hlen, pctx->peer_addr_ip4.s_addr);
+	udp_tunnel_xmit_skb(rt, sk, skb, saddr,
+			    pctx->peer_addr_ip4.s_addr,
+			    0, ip4_dst_hoplimit(&rt->dst), 0,
+			    pctx->gtp_port, pctx->gtp_port,
+			    false, false);
+
+	netdev_dbg(dev, "gtp -> IP src: %pI4 dst: %pI4\n",
+		   &saddr, &pctx->peer_addr_ip4.s_addr);
 
 	return 0;
-err_rt:
-	ip_rt_put(rt);
-err:
-	return -EBADMSG;
+
+out_err:
+	if (err == -ELOOP)
+		dev->stats.collisions++;
+	else
+		dev->stats.tx_carrier_errors++;
+
+	return err;
 }
 
 static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int proto = ntohs(skb->protocol);
-	struct gtp_pktinfo pktinfo;
+	struct gtp_dev *gtp = netdev_priv(dev);
+	struct pdp_ctx *pctx;
 	int err;
 
-	/* Ensure there is sufficient headroom. */
-	if (skb_cow_head(skb, dev->needed_headroom))
-		goto tx_err;
-
-	skb_reset_inner_headers(skb);
-
 	/* PDP context lookups in gtp_build_skb_*() need rcu read-side lock. */
 	rcu_read_lock();
 	switch (proto) {
-	case ETH_P_IP:
-		err = gtp_build_skb_ip4(skb, dev, &pktinfo);
+	case ETH_P_IP: {
+		struct iphdr *iph = ip_hdr(skb);
+
+		if (gtp->role == GTP_ROLE_SGSN)
+			pctx = ipv4_pdp_find(gtp, iph->saddr);
+		else
+			pctx = ipv4_pdp_find(gtp, iph->daddr);
+
+		if (!pctx) {
+			netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
+				   &iph->daddr);
+			err = -ENOENT;
+			goto tx_err;
+		}
+
 		break;
+	}
 	default:
 		err = -EOPNOTSUPP;
-		break;
+		goto tx_err;
 	}
-	rcu_read_unlock();
+
+	netdev_dbg(dev, "found PDP context %p\n", pctx);
+
+	err = gtp_xmit(skb, dev, pctx);
 
 	if (err < 0)
 		goto tx_err;
 
-	switch (proto) {
-	case ETH_P_IP:
-		netdev_dbg(pktinfo.dev, "gtp -> IP src: %pI4 dst: %pI4\n",
-			   &pktinfo.iph->saddr, &pktinfo.iph->daddr);
-		udp_tunnel_xmit_skb(pktinfo.rt, pktinfo.sk, skb,
-				    pktinfo.fl4.saddr, pktinfo.fl4.daddr,
-				    pktinfo.iph->tos,
-				    ip4_dst_hoplimit(&pktinfo.rt->dst),
-				    0,
-				    pktinfo.gtph_port, pktinfo.gtph_port,
-				    true, false);
-		break;
-	}
+	rcu_read_unlock();
 
 	return NETDEV_TX_OK;
+
 tx_err:
+	rcu_read_unlock();
 	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -874,6 +846,8 @@ static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
 
 static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 {
+	__be16 default_port = 0;
+
 	pctx->gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
 	pctx->af = AF_INET;
 	pctx->peer_addr_ip4.s_addr =
@@ -890,15 +864,22 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 		pctx->u.v0.tid = nla_get_u64(info->attrs[GTPA_TID]);
 		pctx->u.v0.flow = nla_get_u16(info->attrs[GTPA_FLOW]);
 		pctx->hlen = sizeof(struct udphdr) + sizeof(struct gtp0_header);
+		default_port = htons(GTP0_PORT);
 		break;
 	case GTP_V1:
 		pctx->u.v1.i_tei = nla_get_u32(info->attrs[GTPA_I_TEI]);
 		pctx->u.v1.o_tei = nla_get_u32(info->attrs[GTPA_O_TEI]);
 		pctx->hlen = sizeof(struct udphdr) + sizeof(struct gtp1_header);
+		default_port = htons(GTP1U_PORT);
 		break;
 	default:
 		break;
 	}
+
+	if (info->attrs[GTPA_PORT])
+		pctx->gtp_port = nla_get_u16(info->attrs[GTPA_PORT]);
+	else
+		pctx->gtp_port = default_port;
 }
 
 static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index 57d1edb8efd9..b2283a5c6d7f 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -27,6 +27,7 @@ enum gtp_attrs {
 	GTPA_I_TEI,	/* for GTPv1 only */
 	GTPA_O_TEI,	/* for GTPv1 only */
 	GTPA_PAD,
+	GTPA_PORT,
 	__GTPA_MAX,
 };
 #define GTPA_MAX (__GTPA_MAX + 1)
-- 
2.11.0
