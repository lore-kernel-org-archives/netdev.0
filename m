From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 22:16:48 +1100
Message-ID: <20050114111648.GA27964@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <20050114012504.GF6309@krispykreme.ozlabs.ibm.com> <20050113201914.46b7c4a2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050113201914.46b7c4a2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 13, 2005 at 08:19:14PM -0800, David S. Miller wrote:
> 
> The easiest way to fix this is to simply make do_tcp_sendpages()
> account just like tcp_sendmsg() does.  This is implemented below
> and should be the real fix for the sk_forward_alloc assertion
> failures.

Sorry, but this may bypass the memory checks if sk_forward_alloc
is less than mss_now.

Since the packet is bounded by mss_now, and most of the time it
will be exactly mss_now bytes long, how about if we simply
replace tp->mss_cache by mss_now?

Could you guys please give this patch a go?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp.c 1.88 vs edited =====
--- 1.88/net/ipv4/tcp.c	2005-01-07 10:13:39 +11:00
+++ edited/net/ipv4/tcp.c	2005-01-14 22:14:41 +11:00
@@ -664,7 +664,7 @@
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			skb = sk_stream_alloc_pskb(sk, 0, tp->mss_cache,
+			skb = sk_stream_alloc_pskb(sk, 0, mss_now,
 						   sk->sk_allocation);
 			if (!skb)
 				goto wait_for_memory;

--gBBFr7Ir9EOA20Yy--
