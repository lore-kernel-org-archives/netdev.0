From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/13] netfilter: nf_tables: dump sets in all existing families
Date: Mon,  6 Jan 2014 14:46:42 +0100
Message-ID: <1389016002-9116-14-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59570 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762AbaAFNrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:47:03 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows you to dump all sets available in all of
the registered families. This allows you to use NFPROTO_UNSPEC
to dump all existing sets, similarly to other existing table,
chain and rule operations.

This patch is based on original patch from Arturo Borrero
Gonz=C3=A1lez.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   87 +++++++++++++++++++++++++++++++++=
+++-----
 1 file changed, 78 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_ap=
i.c
index 37f0e69..0d4b42d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1904,12 +1904,14 @@ static int nft_ctx_init_from_setattr(struct nft=
_ctx *ctx,
 {
 	struct net *net =3D sock_net(skb->sk);
 	const struct nfgenmsg *nfmsg =3D nlmsg_data(nlh);
-	const struct nft_af_info *afi;
+	const struct nft_af_info *afi =3D NULL;
 	const struct nft_table *table =3D NULL;
=20
-	afi =3D nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
-	if (IS_ERR(afi))
-		return PTR_ERR(afi);
+	if (nfmsg->nfgen_family !=3D NFPROTO_UNSPEC) {
+		afi =3D nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
+		if (IS_ERR(afi))
+			return PTR_ERR(afi);
+	}
=20
 	if (nla[NFTA_SET_TABLE] !=3D NULL) {
 		table =3D nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE]);
@@ -2078,8 +2080,8 @@ done:
 	return skb->len;
 }
=20
-static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff=
 *skb,
-				   struct netlink_callback *cb)
+static int nf_tables_dump_sets_family(struct nft_ctx *ctx, struct sk_b=
uff *skb,
+				      struct netlink_callback *cb)
 {
 	const struct nft_set *set;
 	unsigned int idx =3D 0, s_idx =3D cb->args[0];
@@ -2111,6 +2113,61 @@ done:
 	return skb->len;
 }
=20
+static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff=
 *skb,
+				   struct netlink_callback *cb)
+{
+	const struct nft_set *set;
+	unsigned int idx, s_idx =3D cb->args[0];
+	const struct nft_af_info *afi;
+	struct nft_table *table, *cur_table =3D (struct nft_table *)cb->args[=
2];
+	struct net *net =3D sock_net(skb->sk);
+	int cur_family =3D cb->args[3];
+
+	if (cb->args[1])
+		return skb->len;
+
+	list_for_each_entry(afi, &net->nft.af_info, list) {
+		if (cur_family) {
+			if (afi->family !=3D cur_family)
+				continue;
+
+			cur_family =3D 0;
+		}
+
+		list_for_each_entry(table, &afi->tables, list) {
+			if (cur_table) {
+				if (cur_table !=3D table)
+					continue;
+
+				cur_table =3D NULL;
+			}
+
+			ctx->table =3D table;
+			ctx->afi =3D afi;
+			idx =3D 0;
+			list_for_each_entry(set, &ctx->table->sets, list) {
+				if (idx < s_idx)
+					goto cont;
+				if (nf_tables_fill_set(skb, ctx, set,
+						       NFT_MSG_NEWSET,
+						       NLM_F_MULTI) < 0) {
+					cb->args[0] =3D idx;
+					cb->args[2] =3D (unsigned long) table;
+					cb->args[3] =3D afi->family;
+					goto done;
+				}
+cont:
+				idx++;
+			}
+			if (s_idx)
+				s_idx =3D 0;
+		}
+	}
+	cb->args[1] =3D 1;
+done:
+	return skb->len;
+}
+
 static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_cal=
lback *cb)
 {
 	const struct nfgenmsg *nfmsg =3D nlmsg_data(cb->nlh);
@@ -2127,9 +2184,12 @@ static int nf_tables_dump_sets(struct sk_buff *s=
kb, struct netlink_callback *cb)
 	if (err < 0)
 		return err;
=20
-	if (ctx.table =3D=3D NULL)
-		ret =3D nf_tables_dump_sets_all(&ctx, skb, cb);
-	else
+	if (ctx.table =3D=3D NULL) {
+		if (ctx.afi =3D=3D NULL)
+			ret =3D nf_tables_dump_sets_all(&ctx, skb, cb);
+		else
+			ret =3D nf_tables_dump_sets_family(&ctx, skb, cb);
+	} else
 		ret =3D nf_tables_dump_sets_table(&ctx, skb, cb);
=20
 	return ret;
@@ -2142,6 +2202,7 @@ static int nf_tables_getset(struct sock *nlsk, st=
ruct sk_buff *skb,
 	const struct nft_set *set;
 	struct nft_ctx ctx;
 	struct sk_buff *skb2;
+	const struct nfgenmsg *nfmsg =3D nlmsg_data(nlh);
 	int err;
=20
 	/* Verify existance before starting dump */
@@ -2156,6 +2217,10 @@ static int nf_tables_getset(struct sock *nlsk, s=
truct sk_buff *skb,
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
=20
+	/* Only accept unspec with dump */
+	if (nfmsg->nfgen_family =3D=3D NFPROTO_UNSPEC)
+		return -EAFNOSUPPORT;
+
 	set =3D nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
@@ -2325,6 +2390,7 @@ static int nf_tables_delset(struct sock *nlsk, st=
ruct sk_buff *skb,
 			    const struct nlmsghdr *nlh,
 			    const struct nlattr * const nla[])
 {
+	const struct nfgenmsg *nfmsg =3D nlmsg_data(nlh);
 	struct nft_set *set;
 	struct nft_ctx ctx;
 	int err;
@@ -2336,6 +2402,9 @@ static int nf_tables_delset(struct sock *nlsk, st=
ruct sk_buff *skb,
 	if (err < 0)
 		return err;
=20
+	if (nfmsg->nfgen_family =3D=3D NFPROTO_UNSPEC)
+		return -EAFNOSUPPORT;
+
 	set =3D nf_tables_set_lookup(ctx.table, nla[NFTA_SET_NAME]);
 	if (IS_ERR(set))
 		return PTR_ERR(set);
--=20
1.7.10.4
