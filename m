From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 08/12] gtp: Call function to update path mtu
Date: Tue, 26 Sep 2017 21:57:59 -0700
Message-ID: <20170927045803.2477-9-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:52652 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161072AbdI0E67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:59 -0400
Received: by mail-pg0-f48.google.com with SMTP id i195so7133341pgd.9
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:59 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace mtu handling with call to __iptunnel_update_pmtu.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 36 ++++++------------------------------
 1 file changed, 6 insertions(+), 30 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index a6e2e0a1f424..bbb08f8849d3 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -53,6 +53,7 @@ struct pdp_ctx {
 		} v1;
 	} u;
 	u8			gtp_version;
+	u8			hlen;
 	u16			af;
 
 	struct in_addr		ms_addr_ip4;
@@ -467,8 +468,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct iphdr *iph;
 	struct sock *sk;
 	__be32 saddr;
-	__be16 df;
-	int mtu;
 
 	/* Read the IP destination address and resolve the PDP context.
 	 * Prepend PDP header with TEI/TID from PDP ctx.
@@ -514,37 +513,12 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 
 	skb_dst_drop(skb);
 
-	/* This is similar to tnl_update_pmtu(). */
-	df = iph->frag_off;
-	if (df) {
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len -
-			sizeof(struct iphdr) - sizeof(struct udphdr);
-		switch (pctx->gtp_version) {
-		case GTP_V0:
-			mtu -= sizeof(struct gtp0_header);
-			break;
-		case GTP_V1:
-			mtu -= sizeof(struct gtp1_header);
-			break;
-		}
-	} else {
-		mtu = dst_mtu(&rt->dst);
-	}
-
-	rt->dst.ops->update_pmtu(&rt->dst, NULL, skb, mtu);
-
-	if (!skb_is_gso(skb) && (iph->frag_off & htons(IP_DF)) &&
-	    mtu < ntohs(iph->tot_len)) {
-		netdev_dbg(dev, "packet too big, fragmentation needed\n");
-		memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(mtu));
-		goto err_rt;
-	}
-
 	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
+	__iptunnel_update_pmtu(dev, skb, &rt->dst, !!iph->frag_off, iph,
+			       pctx->hlen, pctx->peer_addr_ip4.s_addr);
+
 	return 0;
 err_rt:
 	ip_rt_put(rt);
@@ -915,10 +889,12 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 		 */
 		pctx->u.v0.tid = nla_get_u64(info->attrs[GTPA_TID]);
 		pctx->u.v0.flow = nla_get_u16(info->attrs[GTPA_FLOW]);
+		pctx->hlen = sizeof(struct udphdr) + sizeof(struct gtp0_header);
 		break;
 	case GTP_V1:
 		pctx->u.v1.i_tei = nla_get_u32(info->attrs[GTPA_I_TEI]);
 		pctx->u.v1.o_tei = nla_get_u32(info->attrs[GTPA_O_TEI]);
+		pctx->hlen = sizeof(struct udphdr) + sizeof(struct gtp1_header);
 		break;
 	default:
 		break;
-- 
2.11.0
