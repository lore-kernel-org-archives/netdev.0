From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] [CRYPTO] tcrypt: Move sg_init_table out of timing loops
Date: Fri, 26 Oct 2007 23:00:04 +0800
Message-ID: <E1IlQfM-0003cO-00@gondolin.me.apana.org.au>
References: <20071026145905.GA13850@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] tcrypt: Move sg_init_table out of timing loops

This patch moves the sg_init_table out of the timing loops for hash
algorithms so that it doesn't impact on the speed test results.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/tcrypt.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index c457bdb..24141fb 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -572,9 +572,11 @@ static int test_hash_jiffies_digest(struct hash_desc *desc, char *p, int blen,
 	int bcount;
 	int ret;
 
+	sg_init_table(sg, 1);
+
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
-		sg_init_one(sg, p, blen);
+		sg_set_buf(sg, p, blen);
 		ret = crypto_hash_digest(desc, sg, blen, out);
 		if (ret)
 			return ret;
@@ -597,13 +599,15 @@ static int test_hash_jiffies(struct hash_desc *desc, char *p, int blen,
 	if (plen == blen)
 		return test_hash_jiffies_digest(desc, p, blen, out, sec);
 
+	sg_init_table(sg, 1);
+
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		ret = crypto_hash_init(desc);
 		if (ret)
 			return ret;
 		for (pcount = 0; pcount < blen; pcount += plen) {
-			sg_init_one(sg, p + pcount, plen);
+			sg_set_buf(sg, p + pcount, plen);
 			ret = crypto_hash_update(desc, sg, plen);
 			if (ret)
 				return ret;
@@ -628,12 +632,14 @@ static int test_hash_cycles_digest(struct hash_desc *desc, char *p, int blen,
 	int i;
 	int ret;
 
+	sg_init_table(sg, 1);
+
 	local_bh_disable();
 	local_irq_disable();
 
 	/* Warm-up run. */
 	for (i = 0; i < 4; i++) {
-		sg_init_one(sg, p, blen);
+		sg_set_buf(sg, p, blen);
 		ret = crypto_hash_digest(desc, sg, blen, out);
 		if (ret)
 			goto out;
@@ -645,7 +651,7 @@ static int test_hash_cycles_digest(struct hash_desc *desc, char *p, int blen,
 
 		start = get_cycles();
 
-		sg_init_one(sg, p, blen);
+		sg_set_buf(sg, p, blen);
 		ret = crypto_hash_digest(desc, sg, blen, out);
 		if (ret)
 			goto out;
@@ -679,6 +685,8 @@ static int test_hash_cycles(struct hash_desc *desc, char *p, int blen,
 	if (plen == blen)
 		return test_hash_cycles_digest(desc, p, blen, out);
 
+	sg_init_table(sg, 1);
+
 	local_bh_disable();
 	local_irq_disable();
 
@@ -688,7 +696,7 @@ static int test_hash_cycles(struct hash_desc *desc, char *p, int blen,
 		if (ret)
 			goto out;
 		for (pcount = 0; pcount < blen; pcount += plen) {
-			sg_init_one(sg, p + pcount, plen);
+			sg_set_buf(sg, p + pcount, plen);
 			ret = crypto_hash_update(desc, sg, plen);
 			if (ret)
 				goto out;
@@ -708,7 +716,7 @@ static int test_hash_cycles(struct hash_desc *desc, char *p, int blen,
 		if (ret)
 			goto out;
 		for (pcount = 0; pcount < blen; pcount += plen) {
-			sg_init_one(sg, p + pcount, plen);
+			sg_set_buf(sg, p + pcount, plen);
 			ret = crypto_hash_update(desc, sg, plen);
 			if (ret)
 				goto out;
