From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/47] netfilter: rt: add support to fetch path mss
Date: Mon,  4 Sep 2017 00:40:18 +0200
Message-ID: <1504478435-13160-8-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52724 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753289AbdICWk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 81555190F61
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 702562DC84
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:30 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

to be used in combination with tcp option set support to mimic
iptables TCPMSS --clamp-mss-to-pmtu.

v2: Eric Dumazet points out dst must be initialized.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 +
 net/netfilter/nft_rt.c                   | 66 ++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 40fd199f7531..b49da72efa68 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -811,11 +811,13 @@ enum nft_meta_keys {
  * @NFT_RT_CLASSID: realm value of packet's route (skb->dst->tclassid)
  * @NFT_RT_NEXTHOP4: routing nexthop for IPv4
  * @NFT_RT_NEXTHOP6: routing nexthop for IPv6
+ * @NFT_RT_TCPMSS: fetch current path tcp mss
  */
 enum nft_rt_keys {
 	NFT_RT_CLASSID,
 	NFT_RT_NEXTHOP4,
 	NFT_RT_NEXTHOP6,
+	NFT_RT_TCPMSS,
 };
 
 /**
diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
index c7383d8f88d0..e142e65d3176 100644
--- a/net/netfilter/nft_rt.c
+++ b/net/netfilter/nft_rt.c
@@ -23,6 +23,42 @@ struct nft_rt {
 	enum nft_registers	dreg:8;
 };
 
+static u16 get_tcpmss(const struct nft_pktinfo *pkt, const struct dst_entry *skbdst)
+{
+	u32 minlen = sizeof(struct ipv6hdr), mtu = dst_mtu(skbdst);
+	const struct sk_buff *skb = pkt->skb;
+	const struct nf_afinfo *ai;
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+
+	switch (nft_pf(pkt)) {
+	case NFPROTO_IPV4:
+		fl.u.ip4.daddr = ip_hdr(skb)->saddr;
+		minlen = sizeof(struct iphdr);
+		break;
+	case NFPROTO_IPV6:
+		fl.u.ip6.daddr = ipv6_hdr(skb)->saddr;
+		break;
+	}
+
+	ai = nf_get_afinfo(nft_pf(pkt));
+	if (ai) {
+		struct dst_entry *dst = NULL;
+
+		ai->route(nft_net(pkt), &dst, &fl, false);
+		if (dst) {
+			mtu = min(mtu, dst_mtu(dst));
+			dst_release(dst);
+		}
+	}
+
+	if (mtu <= minlen || mtu > 0xffff)
+		return TCP_MSS_DEFAULT;
+
+	return mtu - minlen;
+}
+
 static void nft_rt_get_eval(const struct nft_expr *expr,
 			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
@@ -57,6 +93,9 @@ static void nft_rt_get_eval(const struct nft_expr *expr,
 					 &ipv6_hdr(skb)->daddr),
 		       sizeof(struct in6_addr));
 		break;
+	case NFT_RT_TCPMSS:
+		nft_reg_store16(dest, get_tcpmss(pkt, dst));
+		break;
 	default:
 		WARN_ON(1);
 		goto err;
@@ -94,6 +133,9 @@ static int nft_rt_get_init(const struct nft_ctx *ctx,
 	case NFT_RT_NEXTHOP6:
 		len = sizeof(struct in6_addr);
 		break;
+	case NFT_RT_TCPMSS:
+		len = sizeof(u16);
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -118,6 +160,29 @@ static int nft_rt_get_dump(struct sk_buff *skb,
 	return -1;
 }
 
+static int nft_rt_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
+			   const struct nft_data **data)
+{
+	const struct nft_rt *priv = nft_expr_priv(expr);
+	unsigned int hooks;
+
+	switch (priv->key) {
+	case NFT_RT_NEXTHOP4:
+	case NFT_RT_NEXTHOP6:
+	case NFT_RT_CLASSID:
+		return 0;
+	case NFT_RT_TCPMSS:
+		hooks = (1 << NF_INET_FORWARD) |
+			(1 << NF_INET_LOCAL_OUT) |
+			(1 << NF_INET_POST_ROUTING);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return nft_chain_validate_hooks(ctx->chain, hooks);
+}
+
 static struct nft_expr_type nft_rt_type;
 static const struct nft_expr_ops nft_rt_get_ops = {
 	.type		= &nft_rt_type,
@@ -125,6 +190,7 @@ static const struct nft_expr_ops nft_rt_get_ops = {
 	.eval		= nft_rt_get_eval,
 	.init		= nft_rt_get_init,
 	.dump		= nft_rt_get_dump,
+	.validate	= nft_rt_validate,
 };
 
 static struct nft_expr_type nft_rt_type __read_mostly = {
-- 
2.1.4
