From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [RFC PATCH 1/2] ppp: adds new error for decompressors to signal that packet must be dropped
Date: Mon, 20 May 2013 18:33:59 +0200
Message-ID: <1369067640-2793-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

Currently decompressors can't signal the generic PPP layer to silently
drop a packet without notifying the PPP daemon or the other party.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 drivers/net/ppp/ppp_generic.c |   12 ++++++++++++
 include/linux/ppp-comp.h      |    6 ++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 72ff14b..7d26825 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1729,6 +1729,10 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 	    (ppp->rstate & (SC_DC_FERROR | SC_DC_ERROR)) == 0)
 		skb = ppp_decompress_frame(ppp, skb);
 
+	/* Packet dropped */
+	if (skb == NULL)
+		goto err;
+
 	if (ppp->flags & SC_MUST_COMP && ppp->rstate & SC_DC_FERROR)
 		goto err;
 
@@ -1888,6 +1892,13 @@ ppp_decompress_frame(struct ppp *ppp, struct sk_buff *skb)
 		len = ppp->rcomp->decompress(ppp->rc_state, skb->data - 2,
 				skb->len + 2, ns->data, obuff_size);
 		if (len < 0) {
+			/* Drop the packet and continue */
+			if (len == DECOMP_DROPERROR) {
+				kfree_skb(ns);
+				kfree_skb(skb);
+				skb = NULL;
+				goto out;
+			}
 			/* Pass the compressed frame to pppd as an
 			   error indication. */
 			if (len == DECOMP_FATALERROR)
@@ -1909,6 +1920,7 @@ ppp_decompress_frame(struct ppp *ppp, struct sk_buff *skb)
 					   skb->len + 2);
 	}
 
+out:
 	return skb;
 
  err:
diff --git a/include/linux/ppp-comp.h b/include/linux/ppp-comp.h
index 4ea1d37..12a8ce8 100644
--- a/include/linux/ppp-comp.h
+++ b/include/linux/ppp-comp.h
@@ -89,8 +89,9 @@ struct compressor {
 /*
  * The return value from decompress routine is the length of the
  * decompressed packet if successful, otherwise DECOMP_ERROR
- * or DECOMP_FATALERROR if an error occurred.
- * 
+ * or DECOMP_FATALERROR if an error occurred but don't want the
+ * PPP generic layer to drop the packet.
+ *
  * We need to make this distinction so that we can disable certain
  * useful functionality, namely sending a CCP reset-request as a result
  * of an error detected after decompression.  This is to avoid infringing
@@ -100,6 +101,7 @@ struct compressor {
 
 #define DECOMP_ERROR		-1	/* error detected before decomp. */
 #define DECOMP_FATALERROR	-2	/* error detected after decomp. */
+#define DECOMP_DROPERROR	-3	/* error detected, drop packet. */
 
 extern int ppp_register_compressor(struct compressor *);
 extern void ppp_unregister_compressor(struct compressor *);
-- 
1.7.10.4


