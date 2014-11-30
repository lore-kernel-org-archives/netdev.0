From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] net-PPP: Less function calls in mppe_alloc() after error
 detection
Date: Sun, 30 Nov 2014 17:45:54 +0100
Message-ID: <547B49C2.4020000@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547B4886.4080406@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547B4886.4080406@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 06c1a0fff81142dfa6d933479e17bb1b45ab9dc7 Mon Sep 17 00:00:00 2001
From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 30 Nov 2014 17:07:34 +0100

The functions crypto_free_blkcipher((), crypto_free_hash() and kfree() could be
called in some cases by the mppe_alloc() function during error handling even
if the passed data structure element contained still a null pointer.
This implementation detail could be improved by adjustments for jump labels.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ppp/ppp_mppe.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 7e44212..962c1a0 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -197,11 +197,11 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	if (optlen != CILEN_MPPE + sizeof(state->master_key) ||
 	    options[0] != CI_MPPE || options[1] != CILEN_MPPE)
-		goto out;
+		return NULL;
 
 	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
-		goto out;
+		return NULL;
 
 
 	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
@@ -213,16 +213,16 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	state->sha1 = crypto_alloc_hash("sha1", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->sha1)) {
 		state->sha1 = NULL;
-		goto out_free;
+		goto out_free_blkcipher;
 	}
 
 	digestsize = crypto_hash_digestsize(state->sha1);
 	if (digestsize < MPPE_MAX_KEY_LEN)
-		goto out_free;
+		goto out_free_hash;
 
 	state->sha1_digest = kmalloc(digestsize, GFP_KERNEL);
 	if (!state->sha1_digest)
-		goto out_free;
+		goto out_free_hash;
 
 	/* Save keys. */
 	memcpy(state->master_key, &options[CILEN_MPPE],
@@ -237,14 +237,12 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	return (void *)state;
 
-	out_free:
-	kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
-	out:
+out_free_hash:
+	crypto_free_hash(state->sha1);
+out_free_blkcipher:
+	crypto_free_blkcipher(state->arc4);
+out_free:
+	kfree(state);
 	return NULL;
 }
 
-- 
2.1.3
