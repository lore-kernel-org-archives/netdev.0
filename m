From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/15]: [IPSEC] esp: Defer output IV initialization to
 first use.
Date: Thu, 17 Aug 2006 01:28:43 -0700 (PDT)
Message-ID: <20060817.012843.88472740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40122
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932447AbWHQI2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:40 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[IPSEC] esp: Defer output IV initialization to first use.

First of all, if the xfrm_state only gets used for input
packets this entropy is a complete waste.

Secondly, it is often the case that a configuration loads
many rules (perhaps even dynamically) and they don't all
necessarily ever get used.

This get_random_bytes() call was showing up in the profiles
for xfrm_state inserts which is how I noticed this.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/esp.h |    5 +++--
 net/ipv4/esp4.c   |   10 +++++++---
 net/ipv6/esp6.c   |    9 +++++++--
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index 90cd94f..636163c 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -14,13 +14,14 @@ struct esp_data
 	struct {
 		u8			*key;		/* Key */
 		int			key_len;	/* Key length */
-		u8			*ivec;		/* ivec buffer */
+		int			padlen;		/* 0..255 */
 		/* ivlen is offset from enc_data, where encrypted data start.
 		 * It is logically different of crypto_tfm_alg_ivsize(tfm).
 		 * We assume that it is either zero (no ivec), or
 		 * >= crypto_tfm_alg_ivsize(tfm). */
 		int			ivlen;
-		int			padlen;		/* 0..255 */
+		int			ivinitted;
+		u8			*ivec;		/* ivec buffer */
 		struct crypto_tfm	*tfm;		/* crypto handle */
 	} conf;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index fc2f8ce..1ceda9f 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -91,9 +91,13 @@ static int esp_output(struct xfrm_state 
 	esph->seq_no = htonl(++x->replay.oseq);
 	xfrm_aevent_doreplay(x);
 
-	if (esp->conf.ivlen)
+	if (esp->conf.ivlen) {
+		if (unlikely(!esp->conf.ivinitted)) {
+			get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
+			esp->conf.ivinitted = 1;
+		}
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
-
+	}
 	do {
 		struct scatterlist *sg = &esp->sgbuf[0];
 
@@ -363,7 +367,7 @@ static int esp_init_state(struct xfrm_st
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
 		if (unlikely(esp->conf.ivec == NULL))
 			goto error;
-		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
+		esp->conf.ivinitted = 0;
 	}
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index a278d5e..efa6155 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -95,8 +95,13 @@ static int esp6_output(struct xfrm_state
 	esph->seq_no = htonl(++x->replay.oseq);
 	xfrm_aevent_doreplay(x);
 
-	if (esp->conf.ivlen)
+	if (esp->conf.ivlen) {
+		if (unlikely(!esp->conf.ivinitted)) {
+			get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
+			esp->conf.ivinitted = 1;
+		}
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+	}
 
 	do {
 		struct scatterlist *sg = &esp->sgbuf[0];
@@ -339,7 +344,7 @@ static int esp6_init_state(struct xfrm_s
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
 		if (unlikely(esp->conf.ivec == NULL))
 			goto error;
-		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
+		esp->conf.ivinitted = 0;
 	}
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
-- 
1.4.2.rc2.g3e042

