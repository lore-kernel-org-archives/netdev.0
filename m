From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: RFC: pskb_expand_head instead of skb_copy in skb_checksum_help
Date: Tue, 24 Aug 2004 21:05:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824110532.GA10241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Here is the patch that you wanted to shoot holes at :)

The idea is simple.  None of the callers of skb_checksum are passing it
skb's which are shared.  They may be cloned however.  But the application
checksum is always in the skb header so there is no need to linearise it.

Supposing all these assumptions are correct, then we can avoid the overhead
of skb_copy() and get away with pskb_expand_head().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/dev.c 1.155 vs edited =====
--- 1.155/net/core/dev.c	2004-07-31 07:23:04 +10:00
+++ edited/net/core/dev.c	2004-08-24 20:59:57 +10:00
@@ -1144,16 +1144,10 @@
 		goto out;
 	}
 
-	if (skb_shared(*pskb)  || skb_cloned(*pskb)) {
-		struct sk_buff *newskb = skb_copy(*pskb, GFP_ATOMIC);
-		if (!newskb) {
-			ret = -ENOMEM;
+	if (skb_cloned(*pskb)) {
+		ret = pskb_expand_head(*pskb, 0, 0, GFP_ATOMIC);
+		if (ret)
 			goto out;
-		}
-		if ((*pskb)->sk)
-			skb_set_owner_w(newskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = newskb;
 	}
 
 	if (offset > (int)(*pskb)->len)

--/9DWx/yDrRhgMJTb--
