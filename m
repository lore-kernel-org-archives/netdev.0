From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: r8169: page allocation failure
Date: Sun, 17 Oct 2004 19:08:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017090837.GA24362@gondor.apana.org.au>
References: <20041016204848.GB21849@electric-eye.fr.zoreil.com> <E1CJ5lg-0005eC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: jkillius@arcor.de, netdev@oss.sgi.com, davem@davemloft.net,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <E1CJ5lg-0005eC-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Oct 17, 2004 at 05:47:52PM +1000, Herbert Xu wrote:
> 
> It should instead allocate a new skb of 1 mss.  I'll work on it.

In fact it was allocating space that it wasn't even using :)

The following patch makes it allocate skb_headlen(skb) - len instead
of skb->len - len.  When skb is linear there is no difference.  When
it's non-linear we only ever copy the bytes in the header.

Please let me know whether this fixes your problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_output.c 1.67 vs edited =====
--- 1.67/net/ipv4/tcp_output.c	2004-10-01 13:56:45 +10:00
+++ edited/net/ipv4/tcp_output.c	2004-10-17 18:58:47 +10:00
@@ -455,8 +455,12 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sk_buff *buff;
-	int nsize = skb->len - len;
+	int nsize;
 	u16 flags;
+
+	nsize = skb_headlen(skb) - len;
+	if (nsize < 0)
+		nsize = 0;
 
 	if (skb_cloned(skb) &&
 	    skb_is_nonlinear(skb) &&

--PNTmBPCT7hxwcZjr--
