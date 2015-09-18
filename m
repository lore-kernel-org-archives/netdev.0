From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 09/14] net: Pass net to nf_dup_ipv4 and nf_dup_ipv6
Date: Fri, 18 Sep 2015 11:05:55 -0500
Message-ID: <1442592360-2575-9-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/ipv4/nf_dup_ipv4.h |  2 +-
 include/net/netfilter/ipv6/nf_dup_ipv6.h |  2 +-
 net/ipv4/netfilter/nf_dup_ipv4.c         | 23 ++++-------------------
 net/ipv4/netfilter/nft_dup_ipv4.c        |  2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c         | 23 ++++-------------------
 net/ipv6/netfilter/nft_dup_ipv6.c        |  2 +-
 net/netfilter/xt_TEE.c                   |  4 ++--
 7 files changed, 14 insertions(+), 44 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_dup_ipv4.h b/include/net/netfilter/ipv4/nf_dup_ipv4.h
index 42008f10dfc4..0a14733e8b82 100644
--- a/include/net/netfilter/ipv4/nf_dup_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_dup_ipv4.h
@@ -1,7 +1,7 @@
 #ifndef _NF_DUP_IPV4_H_
 #define _NF_DUP_IPV4_H_
 
-void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
+void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in_addr *gw, int oif);
 
 #endif /* _NF_DUP_IPV4_H_ */
diff --git a/include/net/netfilter/ipv6/nf_dup_ipv6.h b/include/net/netfilter/ipv6/nf_dup_ipv6.h
index ed6bd66fa5a0..fa6237b382a3 100644
--- a/include/net/netfilter/ipv6/nf_dup_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_dup_ipv6.h
@@ -1,7 +1,7 @@
 #ifndef _NF_DUP_IPV6_H_
 #define _NF_DUP_IPV6_H_
 
-void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
+void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in6_addr *gw, int oif);
 
 #endif /* _NF_DUP_IPV6_H_ */
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index 2d79e6e8d934..ce2a59e5c665 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -23,25 +23,10 @@
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
-static struct net *pick_net(struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-	const struct dst_entry *dst;
-
-	if (skb->dev != NULL)
-		return dev_net(skb->dev);
-	dst = skb_dst(skb);
-	if (dst != NULL && dst->dev != NULL)
-		return dev_net(dst->dev);
-#endif
-	return &init_net;
-}
-
-static bool nf_dup_ipv4_route(struct sk_buff *skb, const struct in_addr *gw,
-			      int oif)
+static bool nf_dup_ipv4_route(struct net *net, struct sk_buff *skb,
+			      const struct in_addr *gw, int oif)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct net *net = pick_net(skb);
 	struct rtable *rt;
 	struct flowi4 fl4;
 
@@ -65,7 +50,7 @@ static bool nf_dup_ipv4_route(struct sk_buff *skb, const struct in_addr *gw,
 	return true;
 }
 
-void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
+void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in_addr *gw, int oif)
 {
 	struct iphdr *iph;
@@ -105,7 +90,7 @@ void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
 		--iph->ttl;
 	ip_send_check(iph);
 
-	if (nf_dup_ipv4_route(skb, gw, oif)) {
+	if (nf_dup_ipv4_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
 		ip_local_out(skb);
 		__this_cpu_write(nf_skb_duplicated, false);
diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index 30bcf820e8bd..bf855e64fc45 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -30,7 +30,7 @@ static void nft_dup_ipv4_eval(const struct nft_expr *expr,
 	};
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv4(pkt->skb, pkt->hook, &gw, oif);
+	nf_dup_ipv4(pkt->net, pkt->skb, pkt->hook, &gw, oif);
 }
 
 static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index c8ab626556a0..ee0d9a5b16c3 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -19,25 +19,10 @@
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
-static struct net *pick_net(struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-	const struct dst_entry *dst;
-
-	if (skb->dev != NULL)
-		return dev_net(skb->dev);
-	dst = skb_dst(skb);
-	if (dst != NULL && dst->dev != NULL)
-		return dev_net(dst->dev);
-#endif
-	return &init_net;
-}
-
-static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_addr *gw,
-			      int oif)
+static bool nf_dup_ipv6_route(struct net *net, struct sk_buff *skb,
+			      const struct in6_addr *gw, int oif)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct net *net = pick_net(skb);
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 
@@ -61,7 +46,7 @@ static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_addr *gw,
 	return true;
 }
 
-void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
+void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 		 const struct in6_addr *gw, int oif)
 {
 	if (this_cpu_read(nf_skb_duplicated))
@@ -81,7 +66,7 @@ void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 		--iph->hop_limit;
 	}
-	if (nf_dup_ipv6_route(skb, gw, oif)) {
+	if (nf_dup_ipv6_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
 		ip6_local_out(skb);
 		__this_cpu_write(nf_skb_duplicated, false);
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
index c81204faf15d..8bfd470cbe72 100644
--- a/net/ipv6/netfilter/nft_dup_ipv6.c
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -28,7 +28,7 @@ static void nft_dup_ipv6_eval(const struct nft_expr *expr,
 	struct in6_addr *gw = (struct in6_addr *)&regs->data[priv->sreg_addr];
 	int oif = regs->data[priv->sreg_dev];
 
-	nf_dup_ipv6(pkt->skb, pkt->hook, gw, oif);
+	nf_dup_ipv6(pkt->net, pkt->skb, pkt->hook, gw, oif);
 }
 
 static int nft_dup_ipv6_init(const struct nft_ctx *ctx,
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index fd980aa7715d..899b06115fc5 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -32,7 +32,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
 
-	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, info->priv->oif);
+	nf_dup_ipv4(par->net, skb, par->hooknum, &info->gw.in, info->priv->oif);
 
 	return XT_CONTINUE;
 }
@@ -43,7 +43,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
 
-	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, info->priv->oif);
+	nf_dup_ipv6(par->net, skb, par->hooknum, &info->gw.in6, info->priv->oif);
 
 	return XT_CONTINUE;
 }
-- 
2.2.1

