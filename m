From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Make IPCOMP more resilient
Date: Sat, 26 Mar 2005 14:58:54 +1100
Message-ID: <20050326035853.GA25162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
To: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Patrick McHardy <kaber@trash.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Since the IPCOMP header is left off when the payload is incompressible
or too small, we can also do the same thing when we encounter an error
during compression.

In other words, we can let outbound IPCOMP always succeed.  In the cases
where it would currently fail we simply skip the IPCOMP transform.  This
makes IPCOMP slightly more resilient when memory is low and simplifies
the code quite a bit.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

 ipv4/ipcomp.c  |   26 ++++++++------------------
 ipv6/ipcomp6.c |   14 +++-----------
 2 files changed, 11 insertions(+), 29 deletions(-)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ipcomp.c 1.32 vs edited =====
--- 1.32/net/ipv4/ipcomp.c	2005-02-09 15:26:16 +11:00
+++ edited/net/ipv4/ipcomp.c	2005-03-26 14:48:44 +11:00
@@ -167,32 +167,22 @@
 	hdr_len = iph->ihl * 4;
 	if ((skb->len - hdr_len) < ipcd->threshold) {
 		/* Don't bother compressing */
-		if (x->props.mode) {
-			ip_send_check(iph);
-		}
 		goto out_ok;
 	}
 
 	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
 	    skb_linearize(skb, GFP_ATOMIC) != 0) {
-	    	err = -ENOMEM;
-	    	goto error;
+		goto out_ok;
 	}
 	
 	err = ipcomp_compress(x, skb);
+	iph = skb->nh.iph;
+
 	if (err) {
-		if (err == -EMSGSIZE) {
-			if (x->props.mode) {
-				iph = skb->nh.iph;
-				ip_send_check(iph);
-			}
-			goto out_ok;
-		}
-		goto error;
+		goto out_ok;
 	}
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
-	iph = skb->nh.iph;
 	iph->tot_len = htons(skb->len);
 	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
 	ipch->nexthdr = iph->protocol;
@@ -200,12 +190,12 @@
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
 	iph->protocol = IPPROTO_COMP;
 	ip_send_check(iph);
+	return 0;
 
 out_ok:
-	err = 0;
-
-error:
-	return err;
+	if (x->props.mode)
+		ip_send_check(iph);
+	return 0;
 }
 
 static void ipcomp4_err(struct sk_buff *skb, u32 info)
===== net/ipv6/ipcomp6.c 1.21 vs edited =====
--- 1.21/net/ipv6/ipcomp6.c	2005-02-09 15:26:16 +11:00
+++ edited/net/ipv6/ipcomp6.c	2005-03-26 14:49:25 +11:00
@@ -160,8 +160,7 @@
 
 	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
 		skb_linearize(skb, GFP_ATOMIC) != 0) {
-		err = -ENOMEM;
-		goto error;
+		goto out_ok;
 	}
 
 	/* compression */
@@ -174,11 +173,7 @@
 	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
 
 	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	if (err) {
-		put_cpu();
-		goto error;
-	}
-	if ((dlen + sizeof(struct ipv6_comp_hdr)) >= plen) {
+	if (err || (dlen + sizeof(struct ipv6_comp_hdr)) >= plen) {
 		put_cpu();
 		goto out_ok;
 	}
@@ -198,10 +193,7 @@
 	*skb->nh.raw = IPPROTO_COMP;
 
 out_ok:
-	err = 0;
-
-error:
-	return err;
+	return 0;
 }
 
 static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,

--huq684BweRXVnRxX--
