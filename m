From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Tue, 9 Nov 2004 22:48:39 +1100
Message-ID: <20041109114839.GA1942@gondor.apana.org.au>
References: <20041108061529.GA1774@gondor.apana.org.au> <20041108073441.GA2200@gondor.apana.org.au> <20041108121040.GA3618@gondor.apana.org.au> <20041108203741.GA993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041108203741.GA993@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 09, 2004 at 07:37:41AM +1100, herbert wrote:
> 
> Well I've found a way for this to occur, but I must say that it is
> fairly unlikely.  When you bring the interface down, addrconf_ifdown
> will try to to delete the addrconf timer and then notify DELADDR.
> Since it doesn't wait for the timer to complete, it might still be
> executing.  Therefore it is possible to have a NEWADDR after a DELADDR
> event.

The attractive thing about this theory is that it is an SMP-only
race.  This could explain why only Jeff/Lennert are seeing it.

Jeff/Lennert, could you please go back to 2.6.9, and then apply
this patch? If this warning triggers, then that would confirm
this theory.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/addrconf.c 1.115 vs edited =====
--- 1.115/net/ipv6/addrconf.c	2004-10-26 14:11:35 +10:00
+++ edited/net/ipv6/addrconf.c	2004-11-09 22:44:35 +11:00
@@ -2989,6 +2989,7 @@
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_ins_rt(ifp->rt, NULL, NULL))
 			dst_release(&ifp->rt->u.dst);
+		WARN_ON(ifp->dead);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
 		break;

--YZ5djTAD1cGYuMQK--
