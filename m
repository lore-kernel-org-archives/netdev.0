From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 4/6] net-PPP: Less function calls in mppe_alloc() after
 error detection
Date: Thu, 04 Dec 2014 23:16:48 +0100
Message-ID: <5480DD50.5060805@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net> <547B4886.4080406@users.sourceforge.net> <547B
 496E.604@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com> <547C82A6.2030808@users.sourceforge.net> <547CA157.1080401@cogentembedded.com> <5480DA32.8000201@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5480DA32.8000201@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 Dec 2014 22:30:20 +0100

The functions crypto_free_blkcipher((), crypto_free_hash() and kfree() could be
called in some cases by the mppe_alloc() function during error handling even
if the passed data structure element contained still a null pointer.

This implementation detail could be improved by adjustments for jump labels.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ppp/ppp_mppe.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 94ff216..c82198f 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -196,11 +196,11 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	if (optlen != CILEN_MPPE + sizeof(state->master_key) ||
 	    options[0] != CI_MPPE || options[1] != CILEN_MPPE)
-		goto out;
+		return NULL;
 
 	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
-		goto out;
+		return NULL;
 
 
 	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
@@ -212,16 +212,16 @@ static void *mppe_alloc(unsigned char *options, int optlen)
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
@@ -236,14 +236,12 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	return (void *)state;
 
+out_free_hash:
+	crypto_free_hash(state->sha1);
+out_free_blkcipher:
+	crypto_free_blkcipher(state->arc4);
 out_free:
-	kfree(state->sha1_digest);
-	if (state->sha1)
-		crypto_free_hash(state->sha1);
-	if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
 	kfree(state);
-out:
 	return NULL;
 }
 
-- 
2.1.3
