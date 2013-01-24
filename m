From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Thu, 24 Jan 2013 13:25:46 +0200
Message-ID: <20130124112410.8535.75598.stgit@localhost6.localdomain6>
References: <20130124094337.GJ9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	Tom St Denis <tstdenis@elliptictech.com>,
	David Miller <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130124094337.GJ9147@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Steffen Klassert <steffen.klassert@secunet.com>:

> On Wed, Jan 23, 2013 at 05:35:10PM +0200, Jussi Kivilinna wrote:
>>
>> Problem seems to be that PFKEYv2 does not quite work with IKEv2, and
>> XFRM API should be used instead. There is new numbers assigned for
>> IKEv2: 
>> https://www.iana.org/assignments/ikev2-parameters/ikev2-parameters.xml#ikev2-parameters-7
>>
>> For new SADB_X_AALG_*, I'd think you should use value from "Reserved
>> for private use" range. Maybe 250?
>
> This would be an option, but we have just a few slots for private
> algorithms.
>
>>
>> But maybe better solution might be to not make AES-CMAC (or other
>> new algorithms) available throught PFKEY API at all, just XFRM?
>>
>
> It is probably the best to make new algorithms unavailable for pfkey
> as long as they have no official ikev1 iana transform identifier.
>
> But how to do that? Perhaps we can assign SADB_X_AALG_NOPFKEY to
> the private value 255 and return -EINVAL if pfkey tries to register
> such an algorithm. The netlink interface does not use these
> identifiers, everything should work as expected. So it should be
> possible to use these algoritms with iproute2 and the most modern
> ike deamons.

Maybe it would be cleaner to not mess with pfkeyv2.h at all, but instead mark algorithms that do not support pfkey with flag. See patch below.

Then I started looking up if sadb_alg_id is being used somewhere outside pfkey. Seems that its value is just being copied around.. but at "http://lxr.linux.no/linux+v3.7/net/xfrm/xfrm_policy.c#L1991" it's used as bit-index. So do larger values than 31 break some stuff? Can multiple algorithms have same sadb_alg_id value? Also in af_key.c, sadb_alg_id being used as bit-index.

-Jussi

---
ONLY COMPILE TESTED!
---
 include/net/xfrm.h   |    5 +++--
 net/key/af_key.c     |   39 +++++++++++++++++++++++++++++++--------
 net/xfrm/xfrm_algo.c |   12 ++++++------
 3 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 421f764..5d5eec2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1320,6 +1320,7 @@ struct xfrm_algo_desc {
 	char *name;
 	char *compat;
 	u8 available:1;
+	u8 sadb_disabled:1;
 	union {
 		struct xfrm_algo_aead_info aead;
 		struct xfrm_algo_auth_info auth;
@@ -1561,8 +1562,8 @@ extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
 
 extern void xfrm_probe_algs(void);
-extern int xfrm_count_auth_supported(void);
-extern int xfrm_count_enc_supported(void);
+extern int xfrm_count_sadb_auth_supported(void);
+extern int xfrm_count_sadb_enc_supported(void);
 extern struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx);
 extern struct xfrm_algo_desc *xfrm_ealg_get_byidx(unsigned int idx);
 extern struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b426a6..307cf1d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -816,18 +816,21 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	sa->sadb_sa_auth = 0;
 	if (x->aalg) {
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
-		sa->sadb_sa_auth = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_auth = (a && !a->sadb_disabled) ?
+					a->desc.sadb_alg_id : 0;
 	}
 	sa->sadb_sa_encrypt = 0;
 	BUG_ON(x->ealg && x->calg);
 	if (x->ealg) {
 		struct xfrm_algo_desc *a = xfrm_ealg_get_byname(x->ealg->alg_name, 0);
-		sa->sadb_sa_encrypt = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_encrypt = (a && !a->sadb_disabled) ?
+					a->desc.sadb_alg_id : 0;
 	}
 	/* KAME compatible: sadb_sa_encrypt is overloaded with calg id */
 	if (x->calg) {
 		struct xfrm_algo_desc *a = xfrm_calg_get_byname(x->calg->alg_name, 0);
-		sa->sadb_sa_encrypt = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_encrypt = (a && !a->sadb_disabled) ?
+					a->desc.sadb_alg_id : 0;
 	}
 
 	sa->sadb_sa_flags = 0;
@@ -1138,7 +1141,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sa->sadb_sa_auth) {
 		int keysize = 0;
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byid(sa->sadb_sa_auth);
-		if (!a) {
+		if (!a || a->sadb_disabled) {
 			err = -ENOSYS;
 			goto out;
 		}
@@ -1160,7 +1163,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sa->sadb_sa_encrypt) {
 		if (hdr->sadb_msg_satype == SADB_X_SATYPE_IPCOMP) {
 			struct xfrm_algo_desc *a = xfrm_calg_get_byid(sa->sadb_sa_encrypt);
-			if (!a) {
+			if (!a || a->sadb_disabled) {
 				err = -ENOSYS;
 				goto out;
 			}
@@ -1172,7 +1175,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 		} else {
 			int keysize = 0;
 			struct xfrm_algo_desc *a = xfrm_ealg_get_byid(sa->sadb_sa_encrypt);
-			if (!a) {
+			if (!a || a->sadb_disabled) {
 				err = -ENOSYS;
 				goto out;
 			}
@@ -1578,13 +1581,13 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 	struct sadb_msg *hdr;
 	int len, auth_len, enc_len, i;
 
-	auth_len = xfrm_count_auth_supported();
+	auth_len = xfrm_count_sadb_auth_supported();
 	if (auth_len) {
 		auth_len *= sizeof(struct sadb_alg);
 		auth_len += sizeof(struct sadb_supported);
 	}
 
-	enc_len = xfrm_count_enc_supported();
+	enc_len = xfrm_count_sadb_enc_supported();
 	if (enc_len) {
 		enc_len *= sizeof(struct sadb_alg);
 		enc_len += sizeof(struct sadb_supported);
@@ -1615,6 +1618,8 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 			struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(i);
 			if (!aalg)
 				break;
+			if (aalg->sadb_disabled)
+				continue;
 			if (aalg->available)
 				*ap++ = aalg->desc;
 		}
@@ -1634,6 +1639,8 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 			struct xfrm_algo_desc *ealg = xfrm_ealg_get_byidx(i);
 			if (!ealg)
 				break;
+			if (ealg->sadb_disabled)
+				continue;
 			if (ealg->available)
 				*ap++ = ealg->desc;
 		}
@@ -2825,6 +2832,8 @@ static int count_ah_combs(const struct xfrm_tmpl *t)
 		const struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(i);
 		if (!aalg)
 			break;
+		if (aalg->sadb_disabled)
+			continue;
 		if (aalg_tmpl_set(t, aalg) && aalg->available)
 			sz += sizeof(struct sadb_comb);
 	}
@@ -2840,6 +2849,9 @@ static int count_esp_combs(const struct xfrm_tmpl *t)
 		if (!ealg)
 			break;
 
+		if (ealg->sadb_disabled)
+			continue;
+
 		if (!(ealg_tmpl_set(t, ealg) && ealg->available))
 			continue;
 
@@ -2848,6 +2860,9 @@ static int count_esp_combs(const struct xfrm_tmpl *t)
 			if (!aalg)
 				break;
 
+			if (aalg->sadb_disabled)
+				continue;
+
 			if (aalg_tmpl_set(t, aalg) && aalg->available)
 				sz += sizeof(struct sadb_comb);
 		}
@@ -2871,6 +2886,9 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 		if (!aalg)
 			break;
 
+		if (aalg->sadb_disabled)
+			continue;
+
 		if (aalg_tmpl_set(t, aalg) && aalg->available) {
 			struct sadb_comb *c;
 			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
@@ -2903,6 +2921,9 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 		if (!ealg)
 			break;
 
+		if (ealg->sadb_disabled)
+			continue;
+
 		if (!(ealg_tmpl_set(t, ealg) && ealg->available))
 			continue;
 
@@ -2911,6 +2932,8 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 			const struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(k);
 			if (!aalg)
 				break;
+			if (aalg->sadb_disabled)
+				continue;
 			if (!(aalg_tmpl_set(t, aalg) && aalg->available))
 				continue;
 			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 4694cca..dab881c 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -713,27 +713,27 @@ void xfrm_probe_algs(void)
 }
 EXPORT_SYMBOL_GPL(xfrm_probe_algs);
 
-int xfrm_count_auth_supported(void)
+int xfrm_count_sadb_auth_supported(void)
 {
 	int i, n;
 
 	for (i = 0, n = 0; i < aalg_entries(); i++)
-		if (aalg_list[i].available)
+		if (aalg_list[i].available && !aalg_list[i].sadb_disabled)
 			n++;
 	return n;
 }
-EXPORT_SYMBOL_GPL(xfrm_count_auth_supported);
+EXPORT_SYMBOL_GPL(xfrm_count_sadb_auth_supported);
 
-int xfrm_count_enc_supported(void)
+int xfrm_count_sadb_enc_supported(void)
 {
 	int i, n;
 
 	for (i = 0, n = 0; i < ealg_entries(); i++)
-		if (ealg_list[i].available)
+		if (ealg_list[i].available && !ealg_list[i].sadb_disabled)
 			n++;
 	return n;
 }
-EXPORT_SYMBOL_GPL(xfrm_count_enc_supported);
+EXPORT_SYMBOL_GPL(xfrm_count_sadb_enc_supported);
 
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 
