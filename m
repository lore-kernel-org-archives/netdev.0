From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6]: Do not set IF_READY if device is down
Date: Wed, 28 Mar 2007 07:30:32 +1000
Message-ID: <20070327213032.GA30935@gondor.apana.org.au>
References: <200703080359.l283xo6S012573@hera.kernel.org> <1175003838.3277.41.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1119 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965489AbXC0Var (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:30:47 -0400
Content-Disposition: inline
In-Reply-To: <1175003838.3277.41.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 02:57:18PM +0100, David Woodhouse wrote:
>
> >     [IPV6]: Do not set IF_READY if device is down
> >     
> >     Now that we add the IPv6 device at registration time we don't need
> >     to set IF_READY in ipv6_add_dev anymore because we will always get
> >     a NETDEV_UP event later on should the device ever become ready.
> >     
> >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> This commit seems to have broken NetworkManager, which removes the
> link-local IPv6 address from each wireless interface while it's only
> intending to use it for scanning, then adds it back when it actually
> wants to _use_ the interface in question.

Sorry, that patch is indeed broken.  We do need to set IF_READY in
the case where all addresses were deleted (including the link-local)
and then recreated.  The IPv6 device will be destroyed and recreated
too in that case.

[IPV6]: Set IF_READY if the device is up and has carrier

We still need to set the IF_READY flag in ipv6_add_dev for the case
where all addresses (including the link-local) are deleted and then
recreated.  In that case the IPv6 device too will be destroyed and
then recreated.

In order to prevent the original problem, we simply ensure that
the device is up before setting IF_READY.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1b61699..7552663 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -342,6 +342,9 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	}
 #endif
 
+	if (netif_running(dev) && netif_carrier_ok(dev))
+		ndev->if_flags |= IF_READY;
+
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
 #ifdef CONFIG_SYSCTL
