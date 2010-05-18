From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] ipv6: Never schedule DAD timer on dead address
Date: Tue, 18 May 2010 21:04:22 +1000
Message-ID: <E1OEKb0-000235-KM@gondolin.me.apana.org.au>
References: <20100518110243.GA7750@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42316 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756388Ab0ERLE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: Never schedule DAD timer on dead address

This patch ensures that all places that schedule the DAD timer
look at the address state in a safe manner before scheduling the
timer.  This ensures that we don't end up with pending timers
after deleting an address.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/addrconf.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e7e9643..dd72f9c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2865,10 +2865,10 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	net_srandom(ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
+	spin_lock(&ifp->lock);
 	if (ifp->state == INET6_IFADDR_STATE_DEAD)
 		goto out;
 
-	spin_lock(&ifp->lock);
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
@@ -2902,8 +2902,8 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 		ip6_ins_rt(ifp->rt);
 
 	addrconf_dad_kick(ifp);
-	spin_unlock(&ifp->lock);
 out:
+	spin_unlock(&ifp->lock);
 	read_unlock_bh(&idev->lock);
 }
 
@@ -2923,6 +2923,12 @@ static void addrconf_dad_timer(unsigned long data)
 	}
 
 	spin_lock(&ifp->lock);
+	if (ifp->state == INET6_IFADDR_STATE_DEAD) {
+		spin_unlock(&ifp->lock);
+		read_unlock(&idev->lock);
+		goto out;
+	}
+
 	if (ifp->probes == 0) {
 		/*
 		 * DAD was successful
