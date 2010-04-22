From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 22:25:06 +0800
Message-ID: <20100422142506.GA15858@gondor.apana.org.au>
References: <20100420174401.GB1334@midget.suse.cz> <20100421213429.GA2799@midget.suse.cz> <20100422023211.GA7109@gondor.apana.org.au> <20100422.004324.67422011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:57708 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754886Ab0DVOZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:25:18 -0400
Content-Disposition: inline
In-Reply-To: <20100422.004324.67422011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 12:43:24AM -0700, David Miller wrote:
>
> Thanks Herbert.

No worries :)

BTW similar races exist in other NDISC receive functions, but
it's too late today so I'll look at this tomorrow unless someone
else wants to have a go at this.

ipv6: Prevent DAD races

The NDISC receive path has not been written in a way that handles
unexpected packets properly.

For example, if we get two identical simultaneous NA/NS packets
that result in a DAD failure, we may try to delete the same address
twice.

A similar problem occurs when we get a DAD failure just as we're
about to mark an address as having passed DAD.

This patch fixes this by using the DADFAILED bit to synchronise
the two paths while holding the ifp lock.  It relies on the fact
that the TENTATIVE bit is always set during DAD, and that the
DADFAILED bit is only set on failure.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index de7a194..1d15d5e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1401,6 +1401,16 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
+	int ignore;
+
+	spin_lock(&ifp->lock);
+	ignore = (ifp->flags & (IFA_F_DADFAILED|IFA_F_TENTATIVE)) ^
+		 IFA_F_TENTATIVE;
+	ifp->flags |= IFA_F_DADFAILED;
+	spin_unlock(&ifp->lock);
+
+	if (ignore)
+		return;
 
 	if (net_ratelimit())
 		printk(KERN_INFO "%s: IPv6 duplicate address %pI6c detected!\n",
@@ -2789,7 +2799,10 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	read_lock_bh(&idev->lock);
 	if (ifp->dead)
 		goto out;
+
 	spin_lock_bh(&ifp->lock);
+	if (ifp->flags & IFA_F_DADFAILED)
+		goto unlock_ifp;
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    idev->cnf.accept_dad < 1 ||
@@ -2824,6 +2837,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 		ip6_ins_rt(ifp->rt);
 
 	addrconf_dad_kick(ifp);
+unlock_ifp:
 	spin_unlock_bh(&ifp->lock);
 out:
 	read_unlock_bh(&idev->lock);
@@ -2841,6 +2855,11 @@ static void addrconf_dad_timer(unsigned long data)
 		goto out;
 	}
 	spin_lock_bh(&ifp->lock);
+	if (ifp->flags & IFA_F_DADFAILED) {
+		spin_unlock_bh(&ifp->lock);
+		read_unlock_bh(&idev->lock);
+		goto out;
+	}
 	if (ifp->probes == 0) {
 		/*
 		 * DAD was successful

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
