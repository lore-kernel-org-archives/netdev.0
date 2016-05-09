From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/36] netfilter: nf_tables: parse element flags from nft_del_setelem()
Date: Mon,  9 May 2016 20:46:26 +0200
Message-ID: <1462819614-5402-9-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Parse flags and pass them to the set via ->deactivate() to check if we
remove the right element from the intervals.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 38 +++++++++++++++++++++++++++++++++-----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 1b3210b..73c8fad 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3592,9 +3592,13 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 			   const struct nlattr *attr)
 {
 	struct nlattr *nla[NFTA_SET_ELEM_MAX + 1];
+	struct nft_set_ext_tmpl tmpl;
 	struct nft_data_desc desc;
 	struct nft_set_elem elem;
+	struct nft_set_ext *ext;
 	struct nft_trans *trans;
+	u32 flags = 0;
+	void *priv;
 	int err;
 
 	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
@@ -3606,6 +3610,14 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (nla[NFTA_SET_ELEM_KEY] == NULL)
 		goto err1;
 
+	nft_set_ext_prepare(&tmpl);
+
+	err = nft_setelem_parse_flags(set, nla[NFTA_SET_ELEM_FLAGS], &flags);
+	if (err < 0)
+		return err;
+	if (flags != 0)
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_FLAGS);
+
 	err = nft_data_init(ctx, &elem.key.val, sizeof(elem.key), &desc,
 			    nla[NFTA_SET_ELEM_KEY]);
 	if (err < 0)
@@ -3615,24 +3627,40 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (desc.type != NFT_DATA_VALUE || desc.len != set->klen)
 		goto err2;
 
+	nft_set_ext_add_length(&tmpl, NFT_SET_EXT_KEY, desc.len);
+
+	err = -ENOMEM;
+	elem.priv = nft_set_elem_init(set, &tmpl, elem.key.val.data, NULL, 0,
+				      GFP_KERNEL);
+	if (elem.priv == NULL)
+		goto err2;
+
+	ext = nft_set_elem_ext(set, elem.priv);
+	if (flags)
+		*nft_set_ext_flags(ext) = flags;
+
 	trans = nft_trans_elem_alloc(ctx, NFT_MSG_DELSETELEM, set);
 	if (trans == NULL) {
 		err = -ENOMEM;
-		goto err2;
+		goto err3;
 	}
 
-	elem.priv = set->ops->deactivate(set, &elem);
-	if (elem.priv == NULL) {
+	priv = set->ops->deactivate(set, &elem);
+	if (priv == NULL) {
 		err = -ENOENT;
-		goto err3;
+		goto err4;
 	}
+	kfree(elem.priv);
+	elem.priv = priv;
 
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 	return 0;
 
-err3:
+err4:
 	kfree(trans);
+err3:
+	kfree(elem.priv);
 err2:
 	nft_data_uninit(&elem.key.val, desc.type);
 err1:
-- 
2.1.4

