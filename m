From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] ipv6: Use state_lock to protect ifa state
Date: Tue, 18 May 2010 21:04:20 +1000
Message-ID: <E1OEKay-00022j-DX@gondolin.me.apana.org.au>
References: <20100518110243.GA7750@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42311 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756304Ab0ERLE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: Use state_lock to protect ifa state

This patch makes use of the new state_lock to synchronise between
updates to the ifa state.  This fixes the issue where a remotely
triggered address deletion (through DAD failure) coincides with a
local administrative address deletion, causing certain actions to
be performed twice incorrectly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/addrconf.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 14b2ccf..d8d7c63 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -711,13 +711,20 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 {
 	struct inet6_ifaddr *ifa, **ifap;
 	struct inet6_dev *idev = ifp->idev;
+	int state;
 	int hash;
 	int deleted = 0, onlink = 0;
 	unsigned long expires = jiffies;
 
 	hash = ipv6_addr_hash(&ifp->addr);
 
+	spin_lock_bh(&ifp->state_lock);
+	state = ifp->state;
 	ifp->state = INET6_IFADDR_STATE_DEAD;
+	spin_unlock_bh(&ifp->state_lock);
+
+	if (state == INET6_IFADDR_STATE_DEAD)
+		goto out;
 
 	write_lock_bh(&addrconf_hash_lock);
 	for (ifap = &inet6_addr_lst[hash]; (ifa=*ifap) != NULL;
@@ -831,6 +838,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		dst_release(&rt->u.dst);
 	}
 
+out:
 	in6_ifa_put(ifp);
 }
 
@@ -2621,6 +2629,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa, *keep_list, **bifa;
 	struct net *net = dev_net(dev);
+	int state;
 	int i;
 
 	ASSERT_RTNL();
@@ -2680,7 +2689,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	while ((ifa = idev->tempaddr_list) != NULL) {
 		idev->tempaddr_list = ifa->tmp_next;
 		ifa->tmp_next = NULL;
-		ifa->state = INET6_IFADDR_STATE_DEAD;
 		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);
 
@@ -2723,14 +2731,25 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
+
+			write_unlock_bh(&idev->lock);
+
 			in6_ifa_hold(ifa);
 		} else {
+			write_unlock_bh(&idev->lock);
+			spin_lock_bh(&ifa->state_lock);
+			state = ifa->state;
 			ifa->state = INET6_IFADDR_STATE_DEAD;
+			spin_unlock_bh(&ifa->state_lock);
+
+			if (state == INET6_IFADDR_STATE_DEAD)
+				goto put_ifa;
 		}
-		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+
+put_ifa:
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
