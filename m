From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Wed, 09 Jan 2008 08:29:11 +0100
Message-ID: <478477C7.9030004@cosmosbay.com>
References: <E1JCUDY-000791-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020106010505090401010005"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40787 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbYAIH3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:29:32 -0500
In-Reply-To: <E1JCUDY-000791-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020106010505090401010005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Herbert Xu a écrit :
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
>> index 58dfa82..731f0a8 100644
>> --- a/include/net/xfrm.h
>> +++ b/include/net/xfrm.h
>> @@ -1188,10 +1188,15 @@ static inline int xfrm_aevent_is_on(void)
>>        return ret;
>> }
>>
>> +static inline int alg_len(struct xfrm_algo *alg)
> 
> Could you please add an xfrm prefix to this?

Sure, thanks for the suggestion :)

[XFRM]: xfrm_algo_clone() allocates too much memory

alg_key_len is the length in bits of the key, not in bytes.

Best way to fix this is to move alg_len() function from net/xfrm/xfrm_user.c 
to include/net/xfrm.h, and to use it in xfrm_algo_clone()

alg_len() is renamed to xfrm_alg_len() because of its global exposition.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

  include/net/xfrm.h   |    7 ++++++-
  net/xfrm/xfrm_user.c |   17 ++++++-----------
  2 files changed, 12 insertions(+), 12 deletions(-)

--------------020106010505090401010005
Content-Type: text/plain;
 name="xfrm_algo_clone.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_algo_clone.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 58dfa82..1dd20cf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1188,10 +1188,15 @@ static inline int xfrm_aevent_is_on(void)
 	return ret;
 }
 
+static inline int xfrm_alg_len(struct xfrm_algo *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 #ifdef CONFIG_XFRM_MIGRATE
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
-	return (struct xfrm_algo *)kmemdup(orig, sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
+	return kmemdup(orig, xfrm_alg_len(orig), GFP_KERNEL);
 }
 
 static inline void xfrm_states_put(struct xfrm_state **states, int n)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75dbdc..c4f6419 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,11 +31,6 @@
 #include <linux/in6.h>
 #endif
 
-static inline int alg_len(struct xfrm_algo *alg)
-{
-	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
-}
-
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
 	struct nlattr *rt = attrs[type];
@@ -45,7 +40,7 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 		return 0;
 
 	algp = nla_data(rt);
-	if (nla_len(rt) < alg_len(algp))
+	if (nla_len(rt) < xfrm_alg_len(algp))
 		return -EINVAL;
 
 	switch (type) {
@@ -204,7 +199,7 @@ static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 		return -ENOSYS;
 	*props = algo->desc.sadb_alg_id;
 
-	p = kmemdup(ualg, alg_len(ualg), GFP_KERNEL);
+	p = kmemdup(ualg, xfrm_alg_len(ualg), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
@@ -516,9 +511,9 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
 
 	if (x->aalg)
-		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
+		NLA_PUT(skb, XFRMA_ALG_AUTH, xfrm_alg_len(x->aalg), x->aalg);
 	if (x->ealg)
-		NLA_PUT(skb, XFRMA_ALG_CRYPT, alg_len(x->ealg), x->ealg);
+		NLA_PUT(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg);
 	if (x->calg)
 		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 
@@ -1978,9 +1973,9 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 {
 	size_t l = 0;
 	if (x->aalg)
-		l += nla_total_size(alg_len(x->aalg));
+		l += nla_total_size(xfrm_alg_len(x->aalg));
 	if (x->ealg)
-		l += nla_total_size(alg_len(x->ealg));
+		l += nla_total_size(xfrm_alg_len(x->ealg));
 	if (x->calg)
 		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)

--------------020106010505090401010005--
