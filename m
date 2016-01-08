From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/17] netfilter: nf_tables: Add new attributes into nft_set to store user data.
Date: Fri,  8 Jan 2016 15:02:15 +0100
Message-ID: <1452261737-7475-16-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54191 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277AbcAHODc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:03:32 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A97DADA888
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9A7AAFAB4C
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9A97CEBAF2
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:25 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Carlos Falgueras Garc=C3=ADa <carlosfg@riseup.net>

User data is stored at after 'nft_set_ops' private data into 'data[]'
flexible array. The field 'udata' points to user data and 'udlen' store=
s
its length.

Add new flag NFTA_SET_USERDATA.

Signed-off-by: Carlos Falgueras Garc=C3=ADa <carlosfg@riseup.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  4 ++++
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nf_tables_api.c            | 21 ++++++++++++++++++++-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/=
nf_tables.h
index 0191fbb..f6b1daf 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -291,6 +291,8 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@timeout: default timeout value in msecs
  * 	@gc_int: garbage collection interval in msecs
  *	@policy: set parameterization (see enum nft_set_policies)
+ *	@udlen: user data length
+ *	@udata: user data
  * 	@ops: set ops
  * 	@pnet: network namespace
  * 	@flags: set flags
@@ -310,6 +312,8 @@ struct nft_set {
 	u64				timeout;
 	u32				gc_int;
 	u16				policy;
+	u16				udlen;
+	unsigned char			*udata;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
 	possible_net_t			pnet;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/li=
nux/netfilter/nf_tables.h
index 731288a..03c28a4 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -291,6 +291,7 @@ enum nft_set_desc_attributes {
  * @NFTA_SET_ID: uniquely identifies a set in a transaction (NLA_U32)
  * @NFTA_SET_TIMEOUT: default timeout value (NLA_U64)
  * @NFTA_SET_GC_INTERVAL: garbage collection interval (NLA_U32)
+ * @NFTA_SET_USERDATA: user data (NLA_BINARY)
  */
 enum nft_set_attributes {
 	NFTA_SET_UNSPEC,
@@ -306,6 +307,7 @@ enum nft_set_attributes {
 	NFTA_SET_ID,
 	NFTA_SET_TIMEOUT,
 	NFTA_SET_GC_INTERVAL,
+	NFTA_SET_USERDATA,
 	__NFTA_SET_MAX
 };
 #define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_ap=
i.c
index f5c3971..2011977 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2323,6 +2323,8 @@ static const struct nla_policy nft_set_policy[NFT=
A_SET_MAX + 1] =3D {
 	[NFTA_SET_ID]			=3D { .type =3D NLA_U32 },
 	[NFTA_SET_TIMEOUT]		=3D { .type =3D NLA_U64 },
 	[NFTA_SET_GC_INTERVAL]		=3D { .type =3D NLA_U32 },
+	[NFTA_SET_USERDATA]		=3D { .type =3D NLA_BINARY,
+					    .len  =3D NFT_USERDATA_MAXLEN },
 };
=20
 static const struct nla_policy nft_set_desc_policy[NFTA_SET_DESC_MAX +=
 1] =3D {
@@ -2482,6 +2484,9 @@ static int nf_tables_fill_set(struct sk_buff *skb=
, const struct nft_ctx *ctx,
 			goto nla_put_failure;
 	}
=20
+	if (nla_put(skb, NFTA_SET_USERDATA, set->udlen, set->udata))
+		goto nla_put_failure;
+
 	desc =3D nla_nest_start(skb, NFTA_SET_DESC);
 	if (desc =3D=3D NULL)
 		goto nla_put_failure;
@@ -2691,6 +2696,8 @@ static int nf_tables_newset(struct net *net, stru=
ct sock *nlsk,
 	u64 timeout;
 	u32 ktype, dtype, flags, policy, gc_int;
 	struct nft_set_desc desc;
+	unsigned char *udata;
+	u16 udlen;
 	int err;
=20
 	if (nla[NFTA_SET_TABLE] =3D=3D NULL ||
@@ -2803,12 +2810,16 @@ static int nf_tables_newset(struct net *net, st=
ruct sock *nlsk,
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
=20
+	udlen =3D 0;
+	if (nla[NFTA_SET_USERDATA])
+		udlen =3D nla_len(nla[NFTA_SET_USERDATA]);
+
 	size =3D 0;
 	if (ops->privsize !=3D NULL)
 		size =3D ops->privsize(nla);
=20
 	err =3D -ENOMEM;
-	set =3D kzalloc(sizeof(*set) + size, GFP_KERNEL);
+	set =3D kzalloc(sizeof(*set) + size + udlen, GFP_KERNEL);
 	if (set =3D=3D NULL)
 		goto err1;
=20
@@ -2817,6 +2828,12 @@ static int nf_tables_newset(struct net *net, str=
uct sock *nlsk,
 	if (err < 0)
 		goto err2;
=20
+	udata =3D NULL;
+	if (udlen) {
+		udata =3D set->data + size;
+		nla_memcpy(udata, nla[NFTA_SET_USERDATA], udlen);
+	}
+
 	INIT_LIST_HEAD(&set->bindings);
 	write_pnet(&set->pnet, net);
 	set->ops   =3D ops;
@@ -2827,6 +2844,8 @@ static int nf_tables_newset(struct net *net, stru=
ct sock *nlsk,
 	set->flags =3D flags;
 	set->size  =3D desc.size;
 	set->policy =3D policy;
+	set->udlen  =3D udlen;
+	set->udata  =3D udata;
 	set->timeout =3D timeout;
 	set->gc_int =3D gc_int;
=20
--=20
2.1.4
