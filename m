From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: "Badness" again
Date: Sat, 15 Jan 2005 11:26:38 +1100
Message-ID: <20050115002638.GA13849@gondor.apana.org.au>
References: <41E83B8D.8020003@pobox.com> <20050114215833.GA12981@gondor.apana.org.au> <41E844AC.6040200@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41E844AC.6040200@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 14, 2005 at 05:16:12PM -0500, Jeff Garzik wrote:
> 
> Blah.  Any other suggestions for debugging this thing?

Yes I have a better theory now :)

All your "badness" messages start with a call to udpv6_sendmsg().
That function calls ip6_dst_lookup() to get its dst entry.  Note
that udpv6_sendmsg() does not hold a lock on the sk at all.  However,
ip6_dst_lookup() uses __sk_dst_check() which is only safe if you can
either guarantee single-threadedness or if you hold sk_dst_lock.

Neither is true here and therefore we may have a situation where
the cached dst is released twice.  In fact I tracked down the
address closest to the "badness" messages and it belongs to
one of your domain's name servers.  That means the requests were
probably made by named, which is multi-threaded.

So please give this patch a spin and see if it makes things any
better.  I've verified that no callers to ip6_dst_lookup() holds
sk_dst_lock so it's safe (but possibly redundant in cases where
they hold locks on the sk itself) to use sk_dst_check().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/ip6_output.c 1.79 vs edited =====
--- 1.79/net/ipv6/ip6_output.c	2005-01-14 15:41:06 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-01-15 11:17:44 +11:00
@@ -745,7 +745,7 @@
 	if (sk) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 	
-		*dst = __sk_dst_check(sk, np->dst_cookie);
+		*dst = sk_dst_check(sk, np->dst_cookie);
 		if (*dst) {
 			struct rt6_info *rt = (struct rt6_info*)*dst;
 	
@@ -772,9 +772,9 @@
 			     && (np->daddr_cache == NULL ||
 				 !ipv6_addr_equal(&fl->fl6_dst, np->daddr_cache)))
 			    || (fl->oif && fl->oif != (*dst)->dev->ifindex)) {
+				dst_release(*dst);
 				*dst = NULL;
-			} else
-				dst_hold(*dst);
+			}
 		}
 	}
 

--ew6BAiZeqk4r7MaW--
