From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Avoid undefined shift operation when testing algorithm ID
Date: Thu, 20 Dec 2007 12:29:37 +0800
Message-ID: <20071220042937.GA18679@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1562 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751339AbXLTE3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 23:29:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

I had wanted to fix this for ages but kept putting it off and then
forgetting about it :) So before I forget again,

[IPSEC]: Avoid undefined shift operation when testing algorithm ID

The aalgos/ealgos fields are only 32 bits wide.  However, af_key tries
to test them with the expression 1 << id where id can be as large as
253.  This produces different behaviour on different architectures.

The following patch explicitly checks whether ID is greater than 31
and fails the check if that's the case.

We cannot easily extend the mask to be longer than 32 bits due to
exposure to user-space.  Besides, this whole interface is obsolete
anyway in favour of the xfrm_user interface which doesn't use this
bit mask in templates (well not within the kernel anyway).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 878039b..26d5e63 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2784,12 +2784,22 @@ static struct sadb_msg *pfkey_get_base_msg(struct sk_buff *skb, int *errp)
 
 static inline int aalg_tmpl_set(struct xfrm_tmpl *t, struct xfrm_algo_desc *d)
 {
-	return t->aalgos & (1 << d->desc.sadb_alg_id);
+	unsigned int id = d->desc.sadb_alg_id;
+
+	if (id >= sizeof(t->aalgos) * 8)
+		return 0;
+
+	return (t->aalgos >> id) & 1;
 }
 
 static inline int ealg_tmpl_set(struct xfrm_tmpl *t, struct xfrm_algo_desc *d)
 {
-	return t->ealgos & (1 << d->desc.sadb_alg_id);
+	unsigned int id = d->desc.sadb_alg_id;
+
+	if (id >= sizeof(t->ealgos) * 8)
+		return 0;
+
+	return (t->ealgos >> id) & 1;
 }
 
 static int count_ah_combs(struct xfrm_tmpl *t)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
