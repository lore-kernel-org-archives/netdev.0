From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: nft_reject: restrict to INPUT/FORWARD/OUTPUT
Date: Tue, 30 Aug 2016 13:26:17 +0200
Message-ID: <1472556383-6787-2-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

After I add the nft rule "nft add rule filter prerouting reject
with tcp reset", kernel panic happened on my system:
  NULL pointer dereference at ...
  IP: [<ffffffff81b9db2f>] nf_send_reset+0xaf/0x400
  Call Trace:
  [<ffffffff81b9da80>] ? nf_reject_ip_tcphdr_get+0x160/0x160
  [<ffffffffa0928061>] nft_reject_ipv4_eval+0x61/0xb0 [nft_reject_ipv4]
  [<ffffffffa08e836a>] nft_do_chain+0x1fa/0x890 [nf_tables]
  [<ffffffffa08e8170>] ? __nft_trace_packet+0x170/0x170 [nf_tables]
  [<ffffffffa06e0900>] ? nf_ct_invert_tuple+0xb0/0xc0 [nf_conntrack]
  [<ffffffffa07224d4>] ? nf_nat_setup_info+0x5d4/0x650 [nf_nat]
  [...]

Because in the PREROUTING chain, routing information is not exist,
then we will dereference the NULL pointer and oops happen.

So we restrict reject expression to INPUT, FORWARD and OUTPUT chain.
This is consistent with iptables REJECT target.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_reject.h   |  4 ++++
 net/ipv4/netfilter/nft_reject_ipv4.c |  1 +
 net/ipv6/netfilter/nft_reject_ipv6.c |  1 +
 net/netfilter/nft_reject.c           | 16 ++++++++++++++++
 net/netfilter/nft_reject_inet.c      |  7 ++++++-
 5 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nft_reject.h b/include/net/netfilter/nft_reject.h
index 60fa153..02e28c5 100644
--- a/include/net/netfilter/nft_reject.h
+++ b/include/net/netfilter/nft_reject.h
@@ -8,6 +8,10 @@ struct nft_reject {
 
 extern const struct nla_policy nft_reject_policy[];
 
+int nft_reject_validate(const struct nft_ctx *ctx,
+			const struct nft_expr *expr,
+			const struct nft_data **data);
+
 int nft_reject_init(const struct nft_ctx *ctx,
 		    const struct nft_expr *expr,
 		    const struct nlattr * const tb[]);
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index c24f41c..2c2553b 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -46,6 +46,7 @@ static const struct nft_expr_ops nft_reject_ipv4_ops = {
 	.eval		= nft_reject_ipv4_eval,
 	.init		= nft_reject_init,
 	.dump		= nft_reject_dump,
+	.validate	= nft_reject_validate,
 };
 
 static struct nft_expr_type nft_reject_ipv4_type __read_mostly = {
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index 533cd57..92bda99 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -47,6 +47,7 @@ static const struct nft_expr_ops nft_reject_ipv6_ops = {
 	.eval		= nft_reject_ipv6_eval,
 	.init		= nft_reject_init,
 	.dump		= nft_reject_dump,
+	.validate	= nft_reject_validate,
 };
 
 static struct nft_expr_type nft_reject_ipv6_type __read_mostly = {
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index 0522fc9..c64de3f7 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -26,11 +26,27 @@ const struct nla_policy nft_reject_policy[NFTA_REJECT_MAX + 1] = {
 };
 EXPORT_SYMBOL_GPL(nft_reject_policy);
 
+int nft_reject_validate(const struct nft_ctx *ctx,
+			const struct nft_expr *expr,
+			const struct nft_data **data)
+{
+	return nft_chain_validate_hooks(ctx->chain,
+					(1 << NF_INET_LOCAL_IN) |
+					(1 << NF_INET_FORWARD) |
+					(1 << NF_INET_LOCAL_OUT));
+}
+EXPORT_SYMBOL_GPL(nft_reject_validate);
+
 int nft_reject_init(const struct nft_ctx *ctx,
 		    const struct nft_expr *expr,
 		    const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
+	int err;
+
+	err = nft_reject_validate(ctx, expr, NULL);
+	if (err < 0)
+		return err;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 759ca52..e79d9ca 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -66,7 +66,11 @@ static int nft_reject_inet_init(const struct nft_ctx *ctx,
 				const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	int icmp_code;
+	int icmp_code, err;
+
+	err = nft_reject_validate(ctx, expr, NULL);
+	if (err < 0)
+		return err;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
@@ -124,6 +128,7 @@ static const struct nft_expr_ops nft_reject_inet_ops = {
 	.eval		= nft_reject_inet_eval,
 	.init		= nft_reject_inet_init,
 	.dump		= nft_reject_inet_dump,
+	.validate	= nft_reject_validate,
 };
 
 static struct nft_expr_type nft_reject_inet_type __read_mostly = {
-- 
2.1.4

