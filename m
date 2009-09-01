From: Alex Badea <abadea@ixiacom.com>
Subject: Re: Does ESP support 64 bit sequence numbering for authentication
 hash ?
Date: Tue, 01 Sep 2009 15:23:21 +0300
Message-ID: <4A9D1239.8000900@ixiacom.com>
References: <1231943033.7937.120.camel@libdev3.mvista.co.uk> <20090115055644.GA30626@gondor.apana.org.au> <20090901120915.GA12646@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040909010204040103060806"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, djenkins@mvista.com,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20090901120915.GA12646@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040909010204040103060806
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 09/01/2009 03:09 PM, Steffen Klassert wrote:
> On Thu, Jan 15, 2009 at 04:56:44PM +1100, Herbert Xu wrote:
>> Dean Jenkins <djenkins@mvista.com> wrote:
>>> Does ESP support 64 bit sequence numbering for use with the
>>> authentication HMAC ?
>> We don't support 64-bit sequence numbers yet.  If you look at
>> struct xfrm_replay_state which is where we store the sequence
>> number internally you'll find that it uses u32s.
>>
>> Patches for 64-bit support are welcome of course.
>>
> 
> Is there actually anybody working on 64-bit sequence number support?
> If not, I'd start to look at it.

A while ago I implemented a rough version of ESN support. It's against
an ancient 2.6.7 kernel though, and is only superficially tested.

I suppose there's no reason not to publish them here, if only for
historical reasons. My apologies to anyone not interested :)


Alex Badea (6):
      xfrm: move xfrm_replay_{check,advance} to their own source file
      xfrm: introduce XFRM_STATE_ESN flag, and extended replay structure
      xfrm: add generic support for replay protection with Extended
Sequence Numbers
      ipsec: Extended Sequence Numbers support for ESP
      ipsec: Extended Sequence Numbers support for AH
      xfrm: add test harness for Extended Sequence Numbers replay
protection algorithm


Best regards,
Alex

--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0001-xfrm-move-xfrm_replay_-check-advance-to-their-own.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-xfrm-move-xfrm_replay_-check-advance-to-their-own.patch"

>From 2831af26b9783da9b311e8442b0cd19df3f4b422 Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Thu, 18 Jun 2009 16:41:06 +0300
Subject: [PATCH] xfrm: move xfrm_replay_{check,advance} to their own source file

---
 src/net/xfrm/Makefile      |    2 +-
 src/net/xfrm/xfrm_replay.c |   46 ++++++++++++++++++++++++++++++++++++++++++++
 src/net/xfrm/xfrm_state.c  |   44 ------------------------------------------
 3 files changed, 47 insertions(+), 45 deletions(-)
 create mode 100644 src/net/xfrm/xfrm_replay.c

diff --git a/src/net/xfrm/Makefile b/src/net/xfrm/Makefile
index 3d076b5..5540fc5 100644
--- a/src/net/xfrm/Makefile
+++ b/src/net/xfrm/Makefile
@@ -3,6 +3,6 @@
 #
 obj-$(CONFIG_CAVIUM) += xfrm_cavium_stub.o
 obj-$(CONFIG_XFRM) += xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o xfrm_output.o \
-	xfrm_export.o
+	xfrm_replay.o xfrm_export.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff --git a/src/net/xfrm/xfrm_replay.c b/src/net/xfrm/xfrm_replay.c
new file mode 100644
index 0000000..6a7350d
--- /dev/null
+++ b/src/net/xfrm/xfrm_replay.c
@@ -0,0 +1,46 @@
+#include <net/xfrm.h>
+
+int xfrm_replay_check(struct xfrm_state *x, u32 seq)
+{
+	u32 diff;
+
+	seq = ntohl(seq);
+
+	if (unlikely(seq == 0))
+		return -EINVAL;
+
+	if (likely(seq > x->replay.seq))
+		return 0;
+
+	diff = x->replay.seq - seq;
+	if (diff >= x->props.replay_window) {
+		x->stats.replay_window++;
+		return -EINVAL;
+	}
+
+	if (x->replay.bitmap & (1U << diff)) {
+		x->stats.replay++;
+		return -EINVAL;
+	}
+	return 0;
+}
+
+void xfrm_replay_advance(struct xfrm_state *x, u32 seq)
+{
+	u32 diff;
+
+	seq = ntohl(seq);
+
+	if (seq > x->replay.seq) {
+		diff = seq - x->replay.seq;
+		if (diff < x->props.replay_window)
+			x->replay.bitmap = ((x->replay.bitmap) << diff) | 1;
+		else
+			x->replay.bitmap = 1;
+		x->replay.seq = seq;
+	} else {
+		diff = x->replay.seq - seq;
+		x->replay.bitmap |= (1U << diff);
+	}
+}
+
diff --git a/src/net/xfrm/xfrm_state.c b/src/net/xfrm/xfrm_state.c
index e43c5e3..3afa72a 100644
--- a/src/net/xfrm/xfrm_state.c
+++ b/src/net/xfrm/xfrm_state.c
@@ -671,50 +671,6 @@ out:
 }
 
 
-int xfrm_replay_check(struct xfrm_state *x, u32 seq)
-{
-	u32 diff;
-
-	seq = ntohl(seq);
-
-	if (unlikely(seq == 0))
-		return -EINVAL;
-
-	if (likely(seq > x->replay.seq))
-		return 0;
-
-	diff = x->replay.seq - seq;
-	if (diff >= x->props.replay_window) {
-		x->stats.replay_window++;
-		return -EINVAL;
-	}
-
-	if (x->replay.bitmap & (1U << diff)) {
-		x->stats.replay++;
-		return -EINVAL;
-	}
-	return 0;
-}
-
-void xfrm_replay_advance(struct xfrm_state *x, u32 seq)
-{
-	u32 diff;
-
-	seq = ntohl(seq);
-
-	if (seq > x->replay.seq) {
-		diff = seq - x->replay.seq;
-		if (diff < x->props.replay_window)
-			x->replay.bitmap = ((x->replay.bitmap) << diff) | 1;
-		else
-			x->replay.bitmap = 1;
-		x->replay.seq = seq;
-	} else {
-		diff = x->replay.seq - seq;
-		x->replay.bitmap |= (1U << diff);
-	}
-}
-
 int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl)
 {
 	int i;
-- 
1.5.4.3


--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0002-xfrm-introduce-XFRM_STATE_ESN-flag-and-extended-re.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-xfrm-introduce-XFRM_STATE_ESN-flag-and-extended-re.patc";
 filename*1="h"

>From dcfe6e052d43cac53d40e031b857b5f1ce06a26b Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Thu, 18 Jun 2009 16:46:44 +0300
Subject: [PATCH] xfrm: introduce XFRM_STATE_ESN flag, and extended replay structure

---
 src/include/linux/xfrm.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/src/include/linux/xfrm.h b/src/include/linux/xfrm.h
index 5bd2274..00b1f57 100644
--- a/src/include/linux/xfrm.h
+++ b/src/include/linux/xfrm.h
@@ -74,6 +74,12 @@ struct xfrm_replay_state
 	__u32	bitmap;
 };
 
+struct xfrm_replay_state_ext
+{
+	__u32	oseq_hi;
+	__u32	seq_hi;
+};
+
 struct xfrm_algo {
 	char	alg_name[64];
 	int	alg_key_len;    /* in bits */
@@ -171,6 +177,7 @@ struct xfrm_usersa_info {
 	__u8				replay_window;
 	__u8				flags;
 #define XFRM_STATE_NOECN	1
+#define XFRM_STATE_ESN		64	/* Extended Sequence Numbers */
 };
 
 struct xfrm_usersa_id {
-- 
1.5.4.3


--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0003-xfrm-add-generic-support-for-replay-protection-with.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0003-xfrm-add-generic-support-for-replay-protection-with.pat";
 filename*1="ch"

>From 7aa47cdff60f5a1a7b48bc6100daea710f0ffa37 Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Thu, 18 Jun 2009 17:03:39 +0300
Subject: [PATCH] xfrm: add generic support for replay protection with Extended Sequence Numbers

---
 src/include/net/xfrm.h     |    2 +
 src/net/ipv4/xfrm4_input.c |    2 +-
 src/net/ipv6/xfrm6_input.c |    2 +-
 src/net/xfrm/xfrm_export.c |    1 +
 src/net/xfrm/xfrm_replay.c |   77 +++++++++++++++++++++++++++++++++++++++----
 5 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/src/include/net/xfrm.h b/src/include/net/xfrm.h
index bf0daff..1f9feb5 100644
--- a/src/include/net/xfrm.h
+++ b/src/include/net/xfrm.h
@@ -132,6 +132,7 @@ struct xfrm_state
 
 	/* State for replay detection */
 	struct xfrm_replay_state replay;
+	struct xfrm_replay_state_ext replay_ext;
 
 	/* Statistics */
 	struct xfrm_stats	stats;
@@ -819,6 +820,7 @@ extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern void xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
+extern u32 xfrm_replay_seqhi(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_check_output(struct xfrm_state *x, struct sk_buff *skb, unsigned short family);
diff --git a/src/net/ipv4/xfrm4_input.c b/src/net/ipv4/xfrm4_input.c
index d3284b1..d2d58df 100644
--- a/src/net/ipv4/xfrm4_input.c
+++ b/src/net/ipv4/xfrm4_input.c
@@ -91,7 +91,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
-		if (x->props.replay_window)
+		if (x->props.replay_window || (x->props.flags & XFRM_STATE_ESN))
 			xfrm_replay_advance(x, seq);
 
 		x->curlft.bytes += skb->len;
diff --git a/src/net/ipv6/xfrm6_input.c b/src/net/ipv6/xfrm6_input.c
index 075f8b4..be7f4d7 100644
--- a/src/net/ipv6/xfrm6_input.c
+++ b/src/net/ipv6/xfrm6_input.c
@@ -75,7 +75,7 @@ int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
 		if (nexthdr <= 0)
 			goto drop_unlock;
 
-		if (x->props.replay_window)
+		if (x->props.replay_window || (x->props.flags & XFRM_STATE_ESN))
 			xfrm_replay_advance(x, seq);
 
 		x->curlft.bytes += skb->len;
diff --git a/src/net/xfrm/xfrm_export.c b/src/net/xfrm/xfrm_export.c
index fdd4d0e..25cb97e 100644
--- a/src/net/xfrm/xfrm_export.c
+++ b/src/net/xfrm/xfrm_export.c
@@ -25,6 +25,7 @@ EXPORT_SYMBOL(xfrm_state_get_afinfo);
 EXPORT_SYMBOL(xfrm_state_put_afinfo);
 EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 EXPORT_SYMBOL(xfrm_replay_check);
+EXPORT_SYMBOL(xfrm_replay_seqhi);
 EXPORT_SYMBOL(xfrm_replay_advance);
 EXPORT_SYMBOL(xfrm_check_selectors);
 EXPORT_SYMBOL(xfrm_check_output);
diff --git a/src/net/xfrm/xfrm_replay.c b/src/net/xfrm/xfrm_replay.c
index 6a7350d..96ccdb3 100644
--- a/src/net/xfrm/xfrm_replay.c
+++ b/src/net/xfrm/xfrm_replay.c
@@ -1,18 +1,67 @@
 #include <net/xfrm.h>
 
+/** Given a state and a Seql, figure out Seqh (for ESN) */
+u32 xfrm_replay_seqhi(struct xfrm_state *x, u32 seq)
+{
+	if (unlikely(!(x->props.flags & XFRM_STATE_ESN))) {
+		BUG();
+		return 0;
+	}
+
+	seq = ntohl(seq);
+	
+	const u32 bottom = x->replay.seq - x->props.replay_window + 1;
+	u32 seq_hi = x->replay_ext.seq_hi;
+
+	if (likely(x->replay.seq >= x->props.replay_window - 1)) {
+		/* A. same subspace */
+		if (unlikely(seq < bottom))
+			seq_hi++;
+	} else {
+		/* B. window spans two subspaces */
+		if (unlikely(seq >= bottom))
+			seq_hi--;
+	}
+	return seq_hi;
+}
+
+
 int xfrm_replay_check(struct xfrm_state *x, u32 seq)
 {
 	u32 diff;
 
 	seq = ntohl(seq);
 
-	if (unlikely(seq == 0))
-		return -EINVAL;
+	if (unlikely(seq == 0)) {
+		if (!(x->props.flags & XFRM_STATE_ESN))
+			return -EINVAL;
+		if (x->replay_ext.seq_hi == 0 && (x->replay.seq < x->props.replay_window - 1))
+			return -EINVAL;
+	}
 
-	if (likely(seq > x->replay.seq))
-		return 0;
+	if (x->props.flags & XFRM_STATE_ESN) {
+		const u32 wsize = x->props.replay_window;
+		const u32 top = x->replay.seq;
+		const u32 bottom = top - wsize + 1;
+
+		diff = top - seq;
+		if (likely(top >= wsize - 1)) {
+			/* A. same subspace */
+			if (likely(seq > top) || seq < bottom)
+				return 0;
+		} else {
+			/* B. window spans two subspaces */
+			if (likely(seq > top && seq < bottom))
+				return 0;
+			if (seq >= bottom)
+				diff = ~seq + top + 1;
+		}
+	} else {
+		if (likely(seq > x->replay.seq))
+			return 0;
+		diff = x->replay.seq - seq;
+	}
 
-	diff = x->replay.seq - seq;
 	if (diff >= x->props.replay_window) {
 		x->stats.replay_window++;
 		return -EINVAL;
@@ -28,19 +77,31 @@ int xfrm_replay_check(struct xfrm_state *x, u32 seq)
 void xfrm_replay_advance(struct xfrm_state *x, u32 seq)
 {
 	u32 diff;
+	int wrap = 0;
+	
+	if (x->props.flags & XFRM_STATE_ESN) {
+		u32 seq_hi = xfrm_replay_seqhi(x, seq);
+		wrap = seq_hi - x->replay_ext.seq_hi;
+	}
 
 	seq = ntohl(seq);
 
-	if (seq > x->replay.seq) {
-		diff = seq - x->replay.seq;
+	if ((!wrap && seq > x->replay.seq) || wrap > 0) {
+		if (likely(!wrap))
+			diff = seq - x->replay.seq;
+		else
+			diff = ~x->replay.seq + seq + 1;
+
 		if (diff < x->props.replay_window)
 			x->replay.bitmap = ((x->replay.bitmap) << diff) | 1;
 		else
 			x->replay.bitmap = 1;
 		x->replay.seq = seq;
+
+		if (unlikely(wrap > 0))
+			x->replay_ext.seq_hi++;
 	} else {
 		diff = x->replay.seq - seq;
 		x->replay.bitmap |= (1U << diff);
 	}
 }
-
-- 
1.5.4.3


--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0004-ipsec-Extended-Sequence-Numbers-support-for-ESP.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0004-ipsec-Extended-Sequence-Numbers-support-for-ESP.patch"

>From d503604d592dac8232780d9442b67c4b051cf602 Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Thu, 18 Jun 2009 17:07:45 +0300
Subject: [PATCH] ipsec: Extended Sequence Numbers support for ESP

---
 src/include/net/esp.h |   14 ++++++++++++--
 src/net/ipv4/esp4.c   |   18 +++++++++++++++---
 src/net/ipv6/esp6.c   |   15 +++++++++++++--
 3 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/src/include/net/esp.h b/src/include/net/esp.h
index a513d14..d39711c 100644
--- a/src/include/net/esp.h
+++ b/src/include/net/esp.h
@@ -2,6 +2,7 @@
 #define _NET_ESP_H
 
 #include <net/xfrm.h>
+#include <asm/scatterlist.h>
 
 struct esp_data
 {
@@ -28,8 +29,10 @@ struct esp_data
 		int			icv_trunc_len;
 		void			(*icv)(struct esp_data*,
 		                               struct sk_buff *skb,
-		                               int offset, int len, u8 *icv);
+		                               int offset, int len,
+					       u32 seq_hi, u8 *icv);
 		struct crypto_tfm	*tfm;
+		unsigned		esn:1;		/* Extended Sequence Number enabled */
 	} auth;
 };
 
@@ -39,7 +42,7 @@ extern void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 
 static inline void
 esp_hmac_digest(struct esp_data *esp, struct sk_buff *skb, int offset,
-                int len, u8 *auth_data)
+                int len, u32 seq_hi, u8 *auth_data)
 {
 	struct crypto_tfm *tfm = esp->auth.tfm;
 	char *icv = esp->auth.work_icv;
@@ -47,6 +50,13 @@ esp_hmac_digest(struct esp_data *esp, struct sk_buff *skb, int offset,
 	memset(auth_data, 0, esp->auth.icv_trunc_len);
 	crypto_hmac_init(tfm, esp->auth.key, &esp->auth.key_len);
 	skb_icv_walk(skb, tfm, offset, len, crypto_hmac_update);
+	if (unlikely(esp->auth.esn)) {
+		struct scatterlist sg;
+		sg.page = virt_to_page(&seq_hi);
+		sg.offset = offset_in_page(&seq_hi);
+		sg.length = sizeof(u32);
+		crypto_hmac_update(tfm, &sg, 1);
+	}
 	crypto_hmac_final(tfm, esp->auth.key, &esp->auth.key_len, icv);
 	memcpy(auth_data, icv, esp->auth.icv_trunc_len);
 }
diff --git a/src/net/ipv4/esp4.c b/src/net/ipv4/esp4.c
index 014dd87..6b73373 100644
--- a/src/net/ipv4/esp4.c
+++ b/src/net/ipv4/esp4.c
@@ -209,6 +209,8 @@ int esp_output(struct sk_buff **pskb)
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
+	if (unlikely(!x->replay.oseq))
+		x->replay_ext.oseq_hi++;
 
 	if (esp->conf.ivlen)
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
@@ -234,8 +236,11 @@ int esp_output(struct sk_buff **pskb)
 	}
 
 	if (esp->auth.icv_full_len) {
+		printk("%s: oseq=%u oseq_hi=%d\n", __FUNCTION__, x->replay.oseq, x->replay_ext.oseq_hi);
 		esp->auth.icv(esp, *pskb, (u8*)esph-(*pskb)->data,
-		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
+		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen,
+			      x->replay_ext.oseq_hi,
+			      trailer->tail);
 		pskb_put(*pskb, trailer, alen);
 	}
 
@@ -286,8 +291,13 @@ int esp_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_bu
 	if (esp->auth.icv_full_len) {
 		u8 sum[esp->auth.icv_full_len];
 		u8 sum1[alen];
-		
-		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
+
+		u32 seq_hi = 0;
+		if (x->props.flags & XFRM_STATE_ESN) {
+			u32 seq = ((struct ip_esp_hdr *) skb->data)->seq_no;
+			seq_hi = xfrm_replay_seqhi(x, seq);
+		}
+		esp->auth.icv(esp, skb, 0, skb->len-alen, seq_hi, sum);
 
 		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
 			BUG();
@@ -539,6 +549,8 @@ int esp_init_state(struct xfrm_state *x, void *args)
 		if (esp->auth.tfm == NULL)
 			goto error;
 		esp->auth.icv = esp_hmac_digest;
+		if (x->props.flags & XFRM_STATE_ESN)
+			esp->auth.esn = 1;
 
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
 		BUG_ON(!aalg_desc);
diff --git a/src/net/ipv6/esp6.c b/src/net/ipv6/esp6.c
index 6ad9c12..6b9a27e 100644
--- a/src/net/ipv6/esp6.c
+++ b/src/net/ipv6/esp6.c
@@ -163,6 +163,8 @@ int esp6_output(struct sk_buff **pskb)
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
+	if (unlikely(!x->replay.oseq))
+		x->replay_ext.oseq_hi++;
 
 	if (esp->conf.ivlen)
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
@@ -189,7 +191,9 @@ int esp6_output(struct sk_buff **pskb)
 
 	if (esp->auth.icv_full_len) {
 		esp->auth.icv(esp, *pskb, (u8*)esph-(*pskb)->data,
-			sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
+			sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen+clen,
+			x->replay_ext.oseq_hi,
+			trailer->tail);
 		pskb_put(*pskb, trailer, alen);
 	}
 
@@ -248,7 +252,12 @@ int esp6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_b
 		u8 sum[esp->auth.icv_full_len];
 		u8 sum1[alen];
 
-		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
+		u32 seq_hi = 0;
+		if (x->props.flags & XFRM_STATE_ESN) {
+			u32 seq = ((struct ipv6_esp_hdr *) skb->data)->seq_no;
+			seq_hi = xfrm_replay_seqhi(x, seq);
+		}
+		esp->auth.icv(esp, skb, 0, skb->len-alen, seq_hi, sum);
 
 		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
 			BUG();
@@ -409,6 +418,8 @@ int esp6_init_state(struct xfrm_state *x, void *args)
 		if (esp->auth.tfm == NULL)
 			goto error;
 		esp->auth.icv = esp_hmac_digest;
+		if (x->props.flags & XFRM_STATE_ESN)
+			esp->auth.esn = 1;
  
 		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
 		BUG_ON(!aalg_desc);
-- 
1.5.4.3


--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0005-ipsec-Extended-Sequence-Numbers-support-for-AH.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0005-ipsec-Extended-Sequence-Numbers-support-for-AH.patch"

>From 8c573d0716e88e514a7064991838f6a482e861f4 Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Thu, 18 Jun 2009 17:12:23 +0300
Subject: [PATCH] ipsec: Extended Sequence Numbers support for AH

---
 src/include/net/ah.h |   14 ++++++++++++--
 src/net/ipv4/ah4.c   |   12 ++++++++++--
 src/net/ipv6/ah6.c   |   12 ++++++++++--
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/src/include/net/ah.h b/src/include/net/ah.h
index ceff00a..9b7b4fb 100644
--- a/src/include/net/ah.h
+++ b/src/include/net/ah.h
@@ -2,6 +2,7 @@
 #define _NET_AH_H
 
 #include <net/xfrm.h>
+#include <asm/scatterlist.h>
 
 /* This is the maximum truncated ICV length that we know of. */
 #define MAX_AH_AUTH_LEN	12
@@ -15,19 +16,28 @@ struct ah_data
 	int			icv_trunc_len;
 
 	void			(*icv)(struct ah_data*,
-	                               struct sk_buff *skb, u8 *icv);
+	                               struct sk_buff *skb,
+				       u32 seq_hi, u8 *icv);
 
 	struct crypto_tfm	*tfm;
+	unsigned		esn:1;
 };
 
 static inline void
-ah_hmac_digest(struct ah_data *ahp, struct sk_buff *skb, u8 *auth_data)
+ah_hmac_digest(struct ah_data *ahp, struct sk_buff *skb, u32 seq_hi, u8 *auth_data)
 {
 	struct crypto_tfm *tfm = ahp->tfm;
 
 	memset(auth_data, 0, ahp->icv_trunc_len);
 	crypto_hmac_init(tfm, ahp->key, &ahp->key_len);
 	skb_icv_walk(skb, tfm, 0, skb->len, crypto_hmac_update);
+	if (unlikely(ahp->esn)) {
+		struct scatterlist sg;
+		sg.page = virt_to_page(&seq_hi);
+		sg.offset = offset_in_page(&seq_hi);
+		sg.length = sizeof(u32);
+		crypto_hmac_update(tfm, &sg, 1);
+	}
 	crypto_hmac_final(tfm, ahp->key, &ahp->key_len, ahp->work_icv);
 	memcpy(auth_data, ahp->work_icv, ahp->icv_trunc_len);
 }
diff --git a/src/net/ipv4/ah4.c b/src/net/ipv4/ah4.c
index 0d62398..c0cc4b1 100644
--- a/src/net/ipv4/ah4.c
+++ b/src/net/ipv4/ah4.c
@@ -121,7 +121,9 @@ static int ah_output(struct sk_buff **pskb)
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
-	ahp->icv(ahp, *pskb, ah->auth_data);
+	if (unlikely(!x->replay.oseq))
+		x->replay_ext.oseq_hi++;
+	ahp->icv(ahp, *pskb, x->replay_ext.oseq_hi, ah->auth_data);
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
 	if (x->props.mode) {
@@ -202,9 +204,13 @@ int ah_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buf
         {
 		u8 auth_data[MAX_AH_AUTH_LEN];
 		
+		u32 seq_hi = 0;
+		if (x->props.flags & XFRM_STATE_ESN)
+			seq_hi = xfrm_replay_seqhi(x, ah->seq_no);
+		
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		skb_push(skb, skb->data - skb->nh.raw);
-		ahp->icv(ahp, skb, ah->auth_data);
+		ahp->icv(ahp, skb, seq_hi, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
 			x->stats.integrity_failed++;
 			goto out;
@@ -265,6 +271,8 @@ static int ah_init_state(struct xfrm_state *x, void *args)
 	if (!ahp->tfm)
 		goto error;
 	ahp->icv = ah_hmac_digest;
+	if (x->props.flags & XFRM_STATE_ESN)
+		ahp->esn = 1;
 	
 	/*
 	 * Lookup the algorithm description maintained by xfrm_algo,
diff --git a/src/net/ipv6/ah6.c b/src/net/ipv6/ah6.c
index 185092c..67db5c2 100644
--- a/src/net/ipv6/ah6.c
+++ b/src/net/ipv6/ah6.c
@@ -213,7 +213,9 @@ int ah6_output(struct sk_buff **pskb)
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
-	ahp->icv(ahp, *pskb, ah->auth_data);
+	if (unlikely(!x->replay.oseq))
+		x->replay_ext.oseq_hi++;
+	ahp->icv(ahp, *pskb, x->replay_ext.oseq_hi, ah->auth_data);
 
 	if (x->props.mode) {
 		(*pskb)->nh.ipv6h->hop_limit   = iph->hop_limit;
@@ -320,10 +322,14 @@ int ah6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_bu
         {
 		u8 auth_data[MAX_AH_AUTH_LEN];
 
+		u32 seq_hi = 0;
+		if (x->props.flags & XFRM_STATE_ESN)
+			seq_hi = xfrm_replay_seqhi(x, ah->seq_no);
+
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		memset(ah->auth_data, 0, ahp->icv_trunc_len);
 		skb_push(skb, skb->data - skb->nh.raw);
-		ahp->icv(ahp, skb, ah->auth_data);
+		ahp->icv(ahp, skb, seq_hi, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(
 				printk(KERN_WARNING "ipsec ah authentication error\n"));
@@ -402,6 +408,8 @@ static int ah6_init_state(struct xfrm_state *x, void *args)
 	if (!ahp->tfm)
 		goto error;
 	ahp->icv = ah_hmac_digest;
+	if (x->props.flags & XFRM_STATE_ESN)
+		ahp->esn = 1;
 	
 	/*
 	 * Lookup the algorithm description maintained by xfrm_algo,
-- 
1.5.4.3


--------------040909010204040103060806
Content-Type: text/x-diff;
 name="0006-xfrm-add-test-harness-for-Extended-Sequence-Numbers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0006-xfrm-add-test-harness-for-Extended-Sequence-Numbers.pat";
 filename*1="ch"

>From 813d3e12e5f207d037bb1570a35519da77227f0e Mon Sep 17 00:00:00 2001
From: Alex Badea <abadea@ixiacom.com>
Date: Mon, 29 Jun 2009 12:29:25 +0300
Subject: [PATCH] xfrm: add test harness for Extended Sequence Numbers replay protection algorithm

---
 test/esn/SConstruct |   15 +++
 test/esn/harness.c  |  257 +++++++++++++++++++++++++++++++++++++++++++++++++++
 test/esn/harness.h  |   37 ++++++++
 3 files changed, 309 insertions(+), 0 deletions(-)
 create mode 100644 test/esn/SConstruct
 create mode 100644 test/esn/harness.c
 create mode 100644 test/esn/harness.h

diff --git a/test/esn/SConstruct b/test/esn/SConstruct
new file mode 100644
index 0000000..55177a4
--- /dev/null
+++ b/test/esn/SConstruct
@@ -0,0 +1,15 @@
+env = Environment(
+	CCFLAGS = ['-g', '-Wall', '-Werror', '--include=harness.h'],
+	LINKFLAGS = ['-g'],
+	CPPPATH = ['.', '../../src/include'],
+)
+
+env.Append(
+        CCFLAGS = ['-fprofile-arcs', '-ftest-coverage'],
+        LINKFLAGS = ['-fprofile-arcs', '-ftest-coverage'],
+)
+
+env.Program('test-esn', [
+	'harness.c',
+	'../../src/net/xfrm/xfrm_replay.c',
+])
diff --git a/test/esn/harness.c b/test/esn/harness.c
new file mode 100644
index 0000000..d026023
--- /dev/null
+++ b/test/esn/harness.c
@@ -0,0 +1,257 @@
+#include "harness.h"
+#include <string.h>
+
+static void print_bitmap(struct xfrm_state *x)
+{
+	unsigned k;
+	u32 bm = x->replay.bitmap;
+
+	printk("bitmap: %u [", x->replay.seq - x->props.replay_window + 1);
+	bm <<= 32 - x->props.replay_window;
+	for (k = 0; k < x->props.replay_window; k++) {
+		if (k && !(k % 4))
+			printk(" ");
+		printk("%c", (bm & (1 << 31)) ? '1' : '-');
+		bm <<= 1;
+	}
+	printk("] %u\n", x->replay.seq);
+}
+
+static int do_replay(struct xfrm_state *x, u64 seq64, unsigned should_fail)
+{
+	printk("\ntest: #%llu (%llu / %llu)\n",
+		seq64,
+		seq64 >> 32,
+		seq64 & 0xffffffff);
+	print_bitmap(x);
+	printk("w=%u bottom=%u top(replay.seq)=%u|%u\n",
+		x->props.replay_window,
+		x->replay.seq - x->props.replay_window + 1,
+		x->replay_ext.seq_hi,
+		x->replay.seq);
+
+	u32 seq = htonl(seq64 & 0xffffffff);
+	if (xfrm_replay_check(x, seq)) {
+		printk("### replay check failed\n");
+		if (!should_fail)
+			BUG();
+		return -1;
+	}
+	
+	if (x->props.flags & XFRM_STATE_ESN) {
+		u32 seq_hi = xfrm_replay_seqhi(x, seq);
+		printk("seq_hi=%u\n", seq_hi);
+		if (seq_hi != (seq64 >> 32)) {
+			/* this is equivalent to the integrity check */
+			printk("### seq_hi check failed (expected %llu)\n", seq64 >> 32);
+			if (!should_fail) 
+				BUG();
+			return -1;
+		}
+	}
+
+	if (should_fail) {
+		printk("### replay check didn't fail -- and should have\n");
+		BUG();
+	}
+
+	xfrm_replay_advance(x, seq);
+	return 0;
+}
+
+static inline int test_replay_pass(struct xfrm_state *x, u64 seq64)
+{
+	return do_replay(x, seq64, 0);
+}
+
+static inline int test_replay_fail(struct xfrm_state *x, u64 seq64)
+{
+	return do_replay(x, seq64, 1);
+}
+
+static void init_state(struct xfrm_state *x)
+{
+	memset(x, 0, sizeof(struct xfrm_state));
+	x->props.replay_window = 8;
+}
+
+static void init_state_esn(struct xfrm_state *x)
+{
+	init_state(x);
+	x->props.flags |= XFRM_STATE_ESN;
+}
+
+static void banner(const char *text)
+{
+	printk("\n\n================================================================\n");
+	printk("===== %s\n\n", text);
+
+}
+
+static void sep(void)
+{
+	printk("\n\n-----\n\n");
+}
+
+static void test_0(void)
+{
+	struct xfrm_state st, *x = &st;
+
+	banner("seq == 0");
+	init_state_esn(x);
+	test_replay_fail(x, 0);
+	test_replay_pass(x, 1);
+	test_replay_fail(x, 0);
+	test_replay_pass(x, 128);
+	test_replay_fail(x, 0);
+	test_replay_pass(x, (1ULL << 32) - 20);
+	test_replay_fail(x, 0);
+	test_replay_pass(x, (1ULL << 32));
+	test_replay_pass(x, (1ULL << 32) + 20);
+}
+
+static void test_1(void)
+{
+	struct xfrm_state st, *x = &st;
+	unsigned k;
+	u64 seq64 = 1;
+
+	banner("linear sequence, wrapping");
+	init_state_esn(x);
+
+	seq64 = 1;
+	for (k = 1; k < 5; k++)
+		test_replay_pass(x, seq64++);
+	sep();
+	seq64 = 0xfffffff0;
+	for (k = 0; k < 16; k++)
+		test_replay_pass(x, seq64++);
+	sep();
+	for (k = 0; k < 10; k++)
+		test_replay_pass(x, seq64++);
+}
+
+static void test_2(void)
+{
+	struct xfrm_state st, *x = &st;
+	unsigned k;
+	u64 seq64 = 1;
+
+	banner("short sequence with a few replays");
+	init_state_esn(x);
+
+	for (k = 0; k < 64; k++)
+		test_replay_pass(x, seq64++);
+	/* out-of-window */
+	test_replay_fail(x, 1);
+	test_replay_fail(x, 2);
+	test_replay_fail(x, 3);
+	/* in-window */
+	test_replay_fail(x, 60);
+	test_replay_fail(x, 63);
+
+	test_replay_pass(x, seq64++);
+}
+
+static void test_3(void)
+{
+	struct xfrm_state st, *x = &st;
+
+	banner("swiss cheese");
+	init_state_esn(x);
+	
+	test_replay_pass(x, 3);
+	test_replay_pass(x, 9);
+	test_replay_pass(x, 5);
+	test_replay_fail(x, 5);	/* replayed */
+	test_replay_pass(x, 16);
+	test_replay_fail(x, 4);	/* out of window */
+	test_replay_pass(x, 10);
+}
+
+static void test_4(void)
+{
+	struct xfrm_state st, *x = &st;
+	u64 edge = (1ULL << 32);
+
+	banner("swiss cheese with wrapping");
+	init_state_esn(x);
+	
+	test_replay_pass(x, 1);
+	test_replay_pass(x, 128);
+	test_replay_pass(x, edge + 2);
+	test_replay_pass(x, edge - 2);
+	test_replay_pass(x, edge);
+	test_replay_pass(x, edge + 3);
+	test_replay_pass(x, edge + 1);
+
+	test_replay_fail(x, edge + 1);
+	test_replay_fail(x, edge);
+	test_replay_fail(x, edge - 2);
+	test_replay_pass(x, edge - 1);
+}
+
+static void test_5(void)
+{
+	struct xfrm_state st, *x = &st;
+	unsigned k;
+	u64 seq64 = 1;
+
+	banner("sparse");
+	init_state_esn(x);
+	
+	for (k = 1; k < 10; k++) {
+		seq64 += 2149536563U; /* random prime */
+		test_replay_pass(x, seq64);
+	}
+}
+
+static void test_plain_1(void)
+{
+	struct xfrm_state st, *x = &st;
+	unsigned k;
+	u64 seq64 = 1;
+
+	banner("non-ESN in-sequence");
+	init_state(x);
+
+	for (k = 1; k < 10; k++)
+		test_replay_pass(x, seq64++);
+	for (k = 1; k < 3; k++)
+		test_replay_pass(x, seq64 += 13);
+	for (k = 1; k < 3; k++)
+		test_replay_pass(x, seq64 += 5);
+}
+
+static void test_plain_2(void)
+{
+	struct xfrm_state st, *x = &st;
+
+	banner("non-ESN replay check");
+	init_state(x);
+
+	test_replay_fail(x, 0);	/* seq == 0 */
+	test_replay_pass(x, 3);
+	test_replay_pass(x, 9);
+	test_replay_pass(x, 5);
+	test_replay_fail(x, 5);	/* replayed */
+	test_replay_pass(x, 16);
+	test_replay_fail(x, 4);	/* out of window */
+	test_replay_pass(x, 10);
+}
+
+int main(int argc, char *argv[])
+{
+	test_0();
+	test_1();
+	test_2();
+	test_3();
+	test_4();
+	test_5();
+	test_plain_1();
+	test_plain_2();
+
+	sep();
+	printk("all done.\n");
+	return 0;
+}
diff --git a/test/esn/harness.h b/test/esn/harness.h
new file mode 100644
index 0000000..1e4277b
--- /dev/null
+++ b/test/esn/harness.h
@@ -0,0 +1,37 @@
+#ifndef _HARNESS_H
+#define _HARNESS_H
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <linux/xfrm.h>
+
+#define printk		printf
+#define likely(x)	x
+#define unlikely(x)	x
+#define BUG()		abort()
+#define _NET_XFRM_H
+
+typedef u_int8_t u8;
+typedef u_int32_t u32;
+typedef u_int64_t u64;
+
+struct xfrm_state {
+	struct {
+		u8 flags;
+		u8 replay_window;
+	} props;
+	struct xfrm_replay_state replay;
+	struct xfrm_replay_state_ext replay_ext;
+	struct xfrm_stats stats;
+};
+
+#define XFRM_STATE_ESN	64
+
+extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
+extern u32 xfrm_replay_seqhi(struct xfrm_state *x, u32 seq);
+extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
+
+#endif
-- 
1.5.4.3


--------------040909010204040103060806--
