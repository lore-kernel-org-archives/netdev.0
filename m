From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Weird modem behaviour in 2.5.73-mm1
Date: Wed, 25 Jun 2003 17:35:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625173549.561cfaec.shemminger@osdl.org>
References: <200306242102.49356.kde@myrealbox.com>
	<200306250327.h5P3RwH8001577@turing-police.cc.vt.edu>
	<200306250418.h5P4IWdA001565@turing-police.cc.vt.edu>
	<20030625091013.573f2e7b.shemminger@osdl.org>
	<200306251654.h5PGsUdA022467@turing-police.cc.vt.edu>
	<20030625102134.2046b04f.shemminger@osdl.org>
	<200306251804.h5PI4odA023590@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200306251804.h5PI4odA023590@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try this patch, it is more paranoid in some of the code paths.
I did get PPP over a null modem cable working between 2.4.18 and 2.5.73 with the PPP patches.

diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	Wed Jun 25 17:32:29 2003
+++ b/drivers/net/ppp_generic.c	Wed Jun 25 17:32:29 2003
@@ -1448,7 +1448,7 @@
 		if (ppp->vj == 0 || (ppp->flags & SC_REJ_COMP_TCP))
 			goto err;
 
-		if (skb_tailroom(skb) < 124 || skb_is_nonlinear(skb) ) {
+		if (skb_tailroom(skb) < 124) {
 			/* copy to a new sk_buff with more tailroom */
 			ns = dev_alloc_skb(skb->len + 128);
 			if (ns == 0) {
@@ -1459,7 +1459,9 @@
 			memcpy(skb_put(ns, skb->len), skb->data, skb->len);
 			kfree_skb(skb);
 			skb = ns;
-		}
+		} else if (!pskb_may_pull(skb, skb->len)) 
+			goto err;
+
 		len = slhc_uncompress(ppp->vj, skb->data + 2, skb->len - 2);
 		if (len <= 0) {
 			printk(KERN_DEBUG "PPP: VJ decompression error\n");
@@ -2033,11 +2035,15 @@
 static void
 ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound)
 {
-	unsigned char *dp = skb->data + 2;
+	unsigned char *dp;
 	int len;
 
-	if (!pskb_may_pull(skb, CCP_HDRLEN + 2)
-	    || skb->len < (len = CCP_LENGTH(dp)) + 2)
+	if (!pskb_may_pull(skb, CCP_HDRLEN + 2))
+		return;
+
+	dp = skb->data + 2;
+	len = CCP_LENGTH(dp);
+	if (skb->len < len +2)
 		return;		/* too short */
 
 	switch (CCP_CODE(dp)) {
