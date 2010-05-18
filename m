From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] ipv6: Use POSTDAD state
Date: Tue, 18 May 2010 21:04:21 +1000
Message-ID: <E1OEKaz-00022u-HO@gondolin.me.apana.org.au>
References: <20100518110243.GA7750@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42315 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756380Ab0ERLE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: Use POSTDAD state

This patch makes use of the new POSTDAD state.  This prevents
a race between DAD completion and failure.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/addrconf.c |   29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d8d7c63..e7e9643 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1412,10 +1412,27 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 		ipv6_del_addr(ifp);
 }
 
+static int addrconf_dad_end(struct inet6_ifaddr *ifp)
+{
+	int err = -ENOENT;
+
+	spin_lock(&ifp->state_lock);
+	if (ifp->state == INET6_IFADDR_STATE_DAD) {
+		ifp->state = INET6_IFADDR_STATE_POSTDAD;
+		err = 0;
+	}
+	spin_unlock(&ifp->state_lock);
+
+	return err;
+}
+
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 
+	if (addrconf_dad_end(ifp))
+		return;
+
 	if (net_ratelimit())
 		printk(KERN_INFO "%s: IPv6 duplicate address %pI6c detected!\n",
 			ifp->idev->dev->name, &ifp->addr);
@@ -2731,6 +2748,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
+			ifa->state = INET6_IFADDR_STATE_DAD;
 
 			write_unlock_bh(&idev->lock);
 
@@ -2895,6 +2913,9 @@ static void addrconf_dad_timer(unsigned long data)
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr mcaddr;
 
+	if (!ifp->probes && addrconf_dad_end(ifp))
+		goto out;
+
 	read_lock(&idev->lock);
 	if (idev->dead || !(idev->if_flags & IF_READY)) {
 		read_unlock(&idev->lock);
@@ -2967,12 +2988,10 @@ static void addrconf_dad_run(struct inet6_dev *idev) {
 	read_lock_bh(&idev->lock);
 	for (ifp = idev->addr_list; ifp; ifp = ifp->if_next) {
 		spin_lock(&ifp->lock);
-		if (!(ifp->flags & IFA_F_TENTATIVE)) {
-			spin_unlock(&ifp->lock);
-			continue;
-		}
+		if (ifp->flags & IFA_F_TENTATIVE &&
+		    ifp->state == INET6_IFADDR_STATE_DAD)
+			addrconf_dad_kick(ifp);
 		spin_unlock(&ifp->lock);
-		addrconf_dad_kick(ifp);
 	}
 	read_unlock_bh(&idev->lock);
 }
