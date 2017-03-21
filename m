From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH v2 1/2] gtp: rename SGSN netlink attribute
Date: Tue, 21 Mar 2017 16:04:29 +0100
Message-ID: <20170321150430.23314-1-jonas@southpole.se>
References: <20170203091231.10142-1-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: laforge@gnumonks.org, pablo@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:38527 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757180AbdCUPZs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:25:48 -0400
In-Reply-To: <20170203091231.10142-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a mostly cosmetic rename of the SGSN netlink attribute to
the GTP link.  The justification for this is that we will be making
the module support decapsulation of "downstream" SGSN packets, in
which case the netlink parameter actually refers to the upstream GGSN
peer.  Renaming the parameter makes the relationship clearer.

The legacy name is maintained as a define in the header file in order
to not break existing code.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/gtp.c        | 22 +++++++++++-----------
 include/uapi/linux/gtp.h |  3 ++-
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 50349a9..3806be6 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -56,7 +56,7 @@ struct pdp_ctx {
 	u16			af;
 
 	struct in_addr		ms_addr_ip4;
-	struct in_addr		sgsn_addr_ip4;
+	struct in_addr		peer_addr_ip4;
 
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
@@ -522,17 +522,17 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	rt = ip4_route_output_gtp(sock_net(sk), &fl4, gtp->sock0->sk,
-				  pctx->sgsn_addr_ip4.s_addr);
+				  pctx->peer_addr_ip4.s_addr);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to SSGN %pI4\n",
-			   &pctx->sgsn_addr_ip4.s_addr);
+			   &pctx->peer_addr_ip4.s_addr);
 		dev->stats.tx_carrier_errors++;
 		goto err;
 	}
 
 	if (rt->dst.dev == dev) {
 		netdev_dbg(dev, "circular route to SSGN %pI4\n",
-			   &pctx->sgsn_addr_ip4.s_addr);
+			   &pctx->peer_addr_ip4.s_addr);
 		dev->stats.collisions++;
 		goto err_rt;
 	}
@@ -894,8 +894,8 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 {
 	pctx->gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
 	pctx->af = AF_INET;
-	pctx->sgsn_addr_ip4.s_addr =
-		nla_get_be32(info->attrs[GTPA_SGSN_ADDRESS]);
+	pctx->peer_addr_ip4.s_addr =
+		nla_get_be32(info->attrs[GTPA_PEER_ADDRESS]);
 	pctx->ms_addr_ip4.s_addr =
 		nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 
@@ -981,13 +981,13 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 	switch (pctx->gtp_version) {
 	case GTP_V0:
 		netdev_dbg(dev, "GTPv0-U: new PDP ctx id=%llx ssgn=%pI4 ms=%pI4 (pdp=%p)\n",
-			   pctx->u.v0.tid, &pctx->sgsn_addr_ip4,
+			   pctx->u.v0.tid, &pctx->peer_addr_ip4,
 			   &pctx->ms_addr_ip4, pctx);
 		break;
 	case GTP_V1:
 		netdev_dbg(dev, "GTPv1-U: new PDP ctx id=%x/%x ssgn=%pI4 ms=%pI4 (pdp=%p)\n",
 			   pctx->u.v1.i_tei, pctx->u.v1.o_tei,
-			   &pctx->sgsn_addr_ip4, &pctx->ms_addr_ip4, pctx);
+			   &pctx->peer_addr_ip4, &pctx->ms_addr_ip4, pctx);
 		break;
 	}
 
@@ -1001,7 +1001,7 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	if (!info->attrs[GTPA_VERSION] ||
 	    !info->attrs[GTPA_LINK] ||
-	    !info->attrs[GTPA_SGSN_ADDRESS] ||
+	    !info->attrs[GTPA_PEER_ADDRESS] ||
 	    !info->attrs[GTPA_MS_ADDRESS])
 		return -EINVAL;
 
@@ -1114,7 +1114,7 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 		goto nlmsg_failure;
 
 	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version) ||
-	    nla_put_be32(skb, GTPA_SGSN_ADDRESS, pctx->sgsn_addr_ip4.s_addr) ||
+	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr) ||
 	    nla_put_be32(skb, GTPA_MS_ADDRESS, pctx->ms_addr_ip4.s_addr))
 		goto nla_put_failure;
 
@@ -1267,7 +1267,7 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_LINK]		= { .type = NLA_U32, },
 	[GTPA_VERSION]		= { .type = NLA_U32, },
 	[GTPA_TID]		= { .type = NLA_U64, },
-	[GTPA_SGSN_ADDRESS]	= { .type = NLA_U32, },
+	[GTPA_PEER_ADDRESS]	= { .type = NLA_U32, },
 	[GTPA_MS_ADDRESS]	= { .type = NLA_U32, },
 	[GTPA_FLOW]		= { .type = NLA_U16, },
 	[GTPA_NET_NS_FD]	= { .type = NLA_U32, },
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index 72a04a0..c51ebb0 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -19,7 +19,7 @@ enum gtp_attrs {
 	GTPA_LINK,
 	GTPA_VERSION,
 	GTPA_TID,	/* for GTPv0 only */
-	GTPA_SGSN_ADDRESS,
+	GTPA_PEER_ADDRESS,	/* Remote GSN peer, either SGSN or GGSN */
 	GTPA_MS_ADDRESS,
 	GTPA_FLOW,
 	GTPA_NET_NS_FD,
@@ -29,5 +29,6 @@ enum gtp_attrs {
 	__GTPA_MAX,
 };
 #define GTPA_MAX (__GTPA_MAX + 1)
+#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS /* maintain legacy attr name */
 
 #endif /* _UAPI_LINUX_GTP_H_ */
-- 
2.9.3
