From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Subject: [PATCH 1/2] ppp: mppe: sanity error path rework
Date: Sun, 26 Apr 2015 20:40:52 +0200
Message-ID: <1430073653-22131-2-git-send-email-sylvain.rochet@finsecur.com>
References: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Cc: Sylvain Rochet <sylvain.rochet@finsecur.com>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are going to need sanity error path a little further, rework to be
able to use the sanity error path anywhere in decompressor.

Signed-off-by: Sylvain Rochet <sylvain.rochet@finsecur.com>
---
 drivers/net/ppp/ppp_mppe.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 911b216..692ee0f 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -478,7 +478,6 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	unsigned ccount;
 	int flushed = MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
-	int sanity = 0;
 	struct scatterlist sg_in[1], sg_out[1];
 
 	if (isize <= PPP_HDRLEN + MPPE_OVHD) {
@@ -514,31 +513,19 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 		       "mppe_decompress[%d]: ENCRYPTED bit not set!\n",
 		       state->unit);
 		state->sanity_errors += 100;
-		sanity = 1;
+		goto sanity_error;
 	}
 	if (!state->stateful && !flushed) {
 		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set in "
 		       "stateless mode!\n", state->unit);
 		state->sanity_errors += 100;
-		sanity = 1;
+		goto sanity_error;
 	}
 	if (state->stateful && ((ccount & 0xff) == 0xff) && !flushed) {
 		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set on "
 		       "flag packet!\n", state->unit);
 		state->sanity_errors += 100;
-		sanity = 1;
-	}
-
-	if (sanity) {
-		if (state->sanity_errors < SANITY_MAX)
-			return DECOMP_ERROR;
-		else
-			/*
-			 * Take LCP down if the peer is sending too many bogons.
-			 * We don't want to do this for a single or just a few
-			 * instances since it could just be due to packet corruption.
-			 */
-			return DECOMP_FATALERROR;
+		goto sanity_error;
 	}
 
 	/*
@@ -649,6 +636,16 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	state->sanity_errors >>= 1;
 
 	return osize;
+
+sanity_error:
+	if (state->sanity_errors < SANITY_MAX)
+		return DECOMP_ERROR;
+	else
+		/* Take LCP down if the peer is sending too many bogons.
+		 * We don't want to do this for a single or just a few
+		 * instances since it could just be due to packet corruption.
+		 */
+		return DECOMP_FATALERROR;
 }
 
 /*
-- 
2.1.4

