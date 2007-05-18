From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Fri, 18 May 2007 14:34:12 +1000
Message-ID: <E1HouAO-0003i5-00@gondolin.me.apana.org.au>
References: <4643CD64.4090000@mvista.com>
Cc: netdev@vger.kernel.org
To: mhuth@mvista.com (Mark Huth), davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3680 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756037AbXEREe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 00:34:28 -0400
In-Reply-To: <4643CD64.4090000@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Huth <mhuth@mvista.com> wrote:
> 
> This patch provides a performance optimization in the pfkey_add path.
> Prior versions have a serious performance problem when adding a large
> number of SAs to a node.  For example, if a backup node needs to be
> loaded with the SAs previously held by a failed active node, thousands
> of SAs may need to be added as rapidly as possible.  Tests show that
> without this patch, such additions may take several minutes.  The
> cause is that the available algorithm modules are probed each time
> instead of only when needed.  This patch changes the unconditional
> call to xfrm_probe_algs() to only be done when it may be needed.

Thanks for the patch!
 
>  static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct 
> sadb_msg *hdr, void **ext_hdrs)
>  {
>        struct xfrm_state *x;
> -       int err;
> +       int err, probe_done = 0;
>        struct km_event c;
> 
> -       xfrm_probe_algs();
> -
>        x = pfkey_msg2xfrm_state(hdr, ext_hdrs);
>        if (IS_ERR(x))
>                return PTR_ERR(x);

I don't think it works when then algorithm isn't loaded though :)
If the algorithm isn't present pfkey_msg2xfrm_state will return
-ENOSYS so we need to do the probe here.

Actually, I think we should just probe for the specific algorithm
requested rather than everything.  See patch below.

[IPSEC] pfkey: Load specific algorithm in pfkey_add rather than all

This is a natural extension of the changeset

    [XFRM]: Probe selected algorithm only.

which only removed the probe call for xfrm_user.  This patch does exactly
the same thing for af_key.  In other words, we load the algorithm requested
by the user rather than everything when adding xfrm states in af_key.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 6249a94..8a72def 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -347,67 +347,44 @@ static inline int calg_entries(void)
 	return ARRAY_SIZE(calg_list);
 }
 
-/* Todo: generic iterators */
-struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id)
-{
-	int i;
-
-	for (i = 0; i < aalg_entries(); i++) {
-		if (aalg_list[i].desc.sadb_alg_id == alg_id) {
-			if (aalg_list[i].available)
-				return &aalg_list[i];
-			else
-				break;
-		}
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(xfrm_aalg_get_byid);
-
-struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id)
-{
-	int i;
+struct xfrm_algo_list {
+	struct xfrm_algo_desc *algs;
+	int entries;
+	u32 type;
+	u32 mask;
+};
 
-	for (i = 0; i < ealg_entries(); i++) {
-		if (ealg_list[i].desc.sadb_alg_id == alg_id) {
-			if (ealg_list[i].available)
-				return &ealg_list[i];
-			else
-				break;
-		}
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(xfrm_ealg_get_byid);
+static const struct xfrm_algo_list xfrm_aalg_list = {
+	.algs = aalg_list,
+	.entries = ARRAY_SIZE(aalg_list),
+	.type = CRYPTO_ALG_TYPE_HASH,
+	.mask = CRYPTO_ALG_TYPE_HASH_MASK | CRYPTO_ALG_ASYNC,
+};
 
-struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id)
-{
-	int i;
+static const struct xfrm_algo_list xfrm_ealg_list = {
+	.algs = ealg_list,
+	.entries = ARRAY_SIZE(ealg_list),
+	.type = CRYPTO_ALG_TYPE_BLKCIPHER,
+	.mask = CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC,
+};
 
-	for (i = 0; i < calg_entries(); i++) {
-		if (calg_list[i].desc.sadb_alg_id == alg_id) {
-			if (calg_list[i].available)
-				return &calg_list[i];
-			else
-				break;
-		}
-	}
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(xfrm_calg_get_byid);
+static const struct xfrm_algo_list xfrm_calg_list = {
+	.algs = calg_list,
+	.entries = ARRAY_SIZE(calg_list),
+	.type = CRYPTO_ALG_TYPE_COMPRESS,
+	.mask = CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC,
+};
 
-static struct xfrm_algo_desc *xfrm_get_byname(struct xfrm_algo_desc *list,
-					      int entries, u32 type, u32 mask,
-					      char *name, int probe)
+static struct xfrm_algo_desc *xfrm_find_algo(
+	const struct xfrm_algo_list *algo_list,
+	int match(const struct xfrm_algo_desc *entry, const void *data),
+	const void *data, int probe)
 {
+	struct xfrm_algo_desc *list = algo_list->algs;
 	int i, status;
 
-	if (!name)
-		return NULL;
-
-	for (i = 0; i < entries; i++) {
-		if (strcmp(name, list[i].name) &&
-		    (!list[i].compat || strcmp(name, list[i].compat)))
+	for (i = 0; i < algo_list->entries; i++) {
+		if (!match(list + i, data))
 			continue;
 
 		if (list[i].available)
@@ -416,8 +393,8 @@ static struct xfrm_algo_desc *xfrm_get_byname(struct xfrm_algo_desc *list,
 		if (!probe)
 			break;
 
-		status = crypto_has_alg(list[i].name, type,
-					mask | CRYPTO_ALG_ASYNC);
+		status = crypto_has_alg(list[i].name, algo_list->type,
+					algo_list->mask);
 		if (!status)
 			break;
 
@@ -427,27 +404,60 @@ static struct xfrm_algo_desc *xfrm_get_byname(struct xfrm_algo_desc *list,
 	return NULL;
 }
 
+static int xfrm_alg_id_match(const struct xfrm_algo_desc *entry,
+			     const void *data)
+{
+	return entry->desc.sadb_alg_id == (int)data;
+}
+
+struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id)
+{
+	return xfrm_find_algo(&xfrm_aalg_list, xfrm_alg_id_match,
+			      (void *)alg_id, 1);
+}
+EXPORT_SYMBOL_GPL(xfrm_aalg_get_byid);
+
+struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id)
+{
+	return xfrm_find_algo(&xfrm_ealg_list, xfrm_alg_id_match,
+			      (void *)alg_id, 1);
+}
+EXPORT_SYMBOL_GPL(xfrm_ealg_get_byid);
+
+struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id)
+{
+	return xfrm_find_algo(&xfrm_calg_list, xfrm_alg_id_match,
+			      (void *)alg_id, 1);
+}
+EXPORT_SYMBOL_GPL(xfrm_calg_get_byid);
+
+static int xfrm_alg_name_match(const struct xfrm_algo_desc *entry,
+			       const void *data)
+{
+	const char *name = data;
+
+	return name && (!strcmp(name, entry->name) ||
+			(entry->compat && !strcmp(name, entry->compat)));
+}
+
 struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name, int probe)
 {
-	return xfrm_get_byname(aalg_list, aalg_entries(),
-			       CRYPTO_ALG_TYPE_HASH, CRYPTO_ALG_TYPE_HASH_MASK,
-			       name, probe);
+	return xfrm_find_algo(&xfrm_aalg_list, xfrm_alg_name_match, name,
+			      probe);
 }
 EXPORT_SYMBOL_GPL(xfrm_aalg_get_byname);
 
 struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name, int probe)
 {
-	return xfrm_get_byname(ealg_list, ealg_entries(),
-			       CRYPTO_ALG_TYPE_BLKCIPHER, CRYPTO_ALG_TYPE_MASK,
-			       name, probe);
+	return xfrm_find_algo(&xfrm_ealg_list, xfrm_alg_name_match, name,
+			      probe);
 }
 EXPORT_SYMBOL_GPL(xfrm_ealg_get_byname);
 
 struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe)
 {
-	return xfrm_get_byname(calg_list, calg_entries(),
-			       CRYPTO_ALG_TYPE_COMPRESS, CRYPTO_ALG_TYPE_MASK,
-			       name, probe);
+	return xfrm_find_algo(&xfrm_calg_list, xfrm_alg_name_match, name,
+			      probe);
 }
 EXPORT_SYMBOL_GPL(xfrm_calg_get_byname);
 
