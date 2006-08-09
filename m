From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: another networking lockdep trace.
Date: Wed, 09 Aug 2006 21:52:23 +1000
Message-ID: <E1GAmbn-0006Ts-00@gondolin.me.apana.org.au>
References: <20060808184157.GB4880@redhat.com>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, mingo@elte.hu,
	arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29715 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161002AbWHILwo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 07:52:44 -0400
To: davem@davemloft.net, davej@redhat.com (Dave Jones)
In-Reply-To: <20060808184157.GB4880@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones <davej@redhat.com> wrote:
>
> Aug  7 06:47:44 localhost kernel: inconsistent {in-softirq-W} -> {softirq-on-W}
> usage.
> Aug  7 06:47:44 localhost kernel: ip/2617 [HC0[0]:SC0[0]:HE1:SE1] takes:
> Aug  7 06:47:44 localhost kernel:  (&ifa->lock){-+..}, at: [<f90a3836>]
> inet6_addr_add+0xf8/0x13e [ipv6]
> Aug  7 06:47:44 localhost kernel: {in-softirq-W} state was registered at:
> Aug  7 06:47:44 localhost kernel:   [<c043bfb9>] lock_acquire+0x4b/0x6a
> Aug  7 06:47:44 localhost kernel:   [<c060f428>] _spin_lock_bh+0x1e/0x2d
> Aug  7 06:47:44 localhost kernel:   [<f90a4757>] addrconf_dad_timer+0x3a/0xe2 [ipv6]

Nice.  This is a bug introduced less than 2 weeks ago.  We're finally
getting some dividends from the lock validator :) Thanks guys!

[IPV6]: The ifa lock is a BH lock

The ifa lock is expected to be taken in BH context (by addrconf timers)
so we must disable BH when accessing it from user context.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8ea1e36..0c5042e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1909,11 +1909,11 @@ static int inet6_addr_add(int ifindex, s
 	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
 
 	if (!IS_ERR(ifp)) {
-		spin_lock(&ifp->lock);
+		spin_lock_bh(&ifp->lock);
 		ifp->valid_lft = valid_lft;
 		ifp->prefered_lft = prefered_lft;
 		ifp->tstamp = jiffies;
-		spin_unlock(&ifp->lock);
+		spin_unlock_bh(&ifp->lock);
 
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
