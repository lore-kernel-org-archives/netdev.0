From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 9 Sep 2004 11:54:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909015442.GA12935@gondor.apana.org.au>
References: <20040909000330.GA5581@gondor.apana.org.au> <20040909.092428.125540781.yoshfuji@linux-ipv6.org> <20040909011016.GA9238@gondor.apana.org.au> <20040909.102736.94408944.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040909.102736.94408944.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 09, 2004 at 10:27:36AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> > > And, I think 
> > >   u16 ecn = (iph->tos + 1) & INET_ECN_MASK;
> > >   check += (u32)htons(0xfffb) + (u32)htons(ecn);
> > 
> > The second htons is less optimal than the shift because htons doesn't
> > know that ecn is only a byte.  So it'll end up doing a full swap.
> 
> Not true; gcc is clever enough to produces same code, and my code looks better.

Sorry, you're right.  Here is an updated patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/inet_ecn.h 1.7 vs edited =====
--- 1.7/include/net/inet_ecn.h	2004-09-09 08:04:37 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-09 11:45:45 +10:00
@@ -49,19 +49,25 @@
 static inline void IP_ECN_set_ce(struct iphdr *iph)
 {
 	u32 check = iph->check;
+	u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
 
-	switch (iph->tos & INET_ECN_MASK) {
-	default:
-	case INET_ECN_NOT_ECT:
-	case INET_ECN_CE:
+	/*
+	 * After the last operation we have (in binary):
+	 * INET_ECN_NOT_ECT => 01
+	 * INET_ECN_ECT_1   => 10
+	 * INET_ECN_ECT_0   => 11
+	 * INET_ECN_CE      => 00
+	 */
+	if (!(ecn & 2))
 		return;
-	case INET_ECN_ECT_1:
-		check += __constant_htons(0xFFFD);
-		break;
-	case INET_ECN_ECT_0:
-		check += __constant_htons(0xFFFE);
-		break;
-	}
+
+	/*
+	 * The following gives us:
+	 * INET_ECN_ECT_1 => check += htons(0xFFFD)
+	 * INET_ECN_ECT_0 => check += htons(0xFFFE)
+	 */
+	check += htons(0xFFFB) + htons(ecn);
+
 	iph->check = check + (check>=0xFFFF);
 	iph->tos |= INET_ECN_CE;
 }

--vkogqOf2sHV7VnPd--
