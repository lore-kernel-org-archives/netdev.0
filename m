From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/21] netfilter: nf_tables: add flush field to struct nft_set_iter
Date: Sun, 12 Feb 2017 20:42:37 +0100
Message-ID: <1486928573-24773-6-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This provides context to walk callback iterator, thus, we know if the
walk happens from the set flush path. This is required by the new bitmap
set type coming in a follow up patch which has no real struct
nft_set_ext, so it has to allocate it based on the two bit compact
element representation.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 1 +
 net/netfilter/nf_tables_api.c     | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index ab155644d489..5830f594842e 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -203,6 +203,7 @@ struct nft_set_elem {
 struct nft_set;
 struct nft_set_iter {
 	u8		genmask;
+	bool		flush;
 	unsigned int	count;
 	unsigned int	skip;
 	int		err;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c09b11eb36fc..7ae810b03462 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3121,6 +3121,7 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 		iter.count	= 0;
 		iter.err	= 0;
 		iter.fn		= nf_tables_bind_check_setelem;
+		iter.flush	= false;
 
 		set->ops->walk(ctx, set, &iter);
 		if (iter.err < 0)
@@ -3374,6 +3375,7 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	args.iter.count		= 0;
 	args.iter.err		= 0;
 	args.iter.fn		= nf_tables_dump_setelem;
+	args.iter.flush		= false;
 	set->ops->walk(&ctx, set, &args.iter);
 
 	nla_nest_end(skb, nest);
@@ -3939,6 +3941,7 @@ static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 		struct nft_set_iter iter = {
 			.genmask	= genmask,
 			.fn		= nft_flush_set,
+			.flush		= true,
 		};
 		set->ops->walk(&ctx, set, &iter);
 
@@ -5089,6 +5092,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			iter.count	= 0;
 			iter.err	= 0;
 			iter.fn		= nf_tables_loop_check_setelem;
+			iter.flush	= false;
 
 			set->ops->walk(ctx, set, &iter);
 			if (iter.err < 0)
-- 
2.1.4

