From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: More IPSEC trouble
Date: Sat, 12 Mar 2005 12:35:15 +1100
Message-ID: <20050312013515.GA17539@gondor.apana.org.au>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho> <42323125.20706@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Cc: Steve Hill <steve@services.navaho.net>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42323125.20706@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Mar 12, 2005 at 01:00:37AM +0100, Patrick McHardy wrote:
> 
> Thanks for tracking this down, we need to unlock the state before
> calling icmp_send(). This patch fixes it, it should apply to 2.6.10
> if you replace dst_mtu() by dst_pmtu() in the context.

Good catch.  However let's try to avoid spreading lock/unlock calls
around if possible.

Since tunnel_check_size only looks at the state to determine whether
it's tunnel mode, it doesn't need to hold the lock at all.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/xfrm4_output.c 1.7 vs edited =====
--- 1.7/net/ipv4/xfrm4_output.c	2005-03-07 16:33:59 +11:00
+++ edited/net/ipv4/xfrm4_output.c	2005-03-12 12:26:20 +11:00
@@ -103,16 +103,16 @@
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
 	if (x->props.mode) {
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
-			goto error;
+			goto error_nolock;
 	}
+
+	spin_lock_bh(&x->lock);
+	err = xfrm_state_check(x, skb);
+	if (err)
+		goto error;
 
 	xfrm4_encap(skb);
 
===== net/ipv6/xfrm6_output.c 1.9 vs edited =====
--- 1.9/net/ipv6/xfrm6_output.c	2005-03-07 16:33:59 +11:00
+++ edited/net/ipv6/xfrm6_output.c	2005-03-12 12:29:00 +11:00
@@ -103,16 +103,16 @@
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
 	if (x->props.mode) {
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
-			goto error;
+			goto error_nolock;
 	}
+
+	spin_lock_bh(&x->lock);
+	err = xfrm_state_check(x, skb);
+	if (err)
+		goto error;
 
 	xfrm6_encap(skb);
 

--Q68bSM7Ycu6FN28Q--
