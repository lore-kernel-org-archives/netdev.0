From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv6: bump genid when the IFA_F_TENTATIVE flag is clear
Date: Tue, 22 Nov 2016 16:57:40 +0100
Message-ID: <f91712a692016619312fdb480ff4ef290bd961db.1479830136.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hideaki YOSHIFUJI <hideaki.yoshifuji@miraclelinux.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755145AbcKVP5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 10:57:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an ipv6 address has the tentative flag set, it can't be
used as source for egress traffic, while the associated route,
if any, can be looked up and even stored into some dst_cache.

In the latter scenario, the source ipv6 address selected and
stored in the cache is most probably wrong (e.g. with
link-local scope) and the entity using the dst_cache will
experience lack of ipv6 connectivity until said cache is
cleared or invalidated.

Overall this may cause lack of connectivity over most IPv6 tunnels
(comprising geneve and vxlan), if the first egress packet reaches
the tunnel before the DaD is completed for the used ipv6
address.

This patch bumps a new genid after that the IFA_F_TENTATIVE flag
is cleared, so that dst_cache will be invalidated on
next lookup and ipv6 connectivity restored.

Fixes: 0c1d70af924b ("net: use dst_cache for vxlan device")
Fixes: 468dfffcd762 ("geneve: add dst caching support")
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/addrconf.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 060dd99..4bc5ba3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -183,7 +183,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp);
 static void addrconf_dad_work(struct work_struct *w);
-static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
+static void addrconf_dad_completed(struct inet6_ifaddr *ifp, bool bump_id);
 static void addrconf_dad_run(struct inet6_dev *idev);
 static void addrconf_rs_timer(unsigned long data);
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
@@ -2898,6 +2898,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
+		rt_genid_bump_ipv6(dev_net(idev->dev));
 		ipv6_ifa_notify(RTM_NEWADDR, ifp);
 		in6_ifa_put(ifp);
 	}
@@ -3740,7 +3741,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
-	bool notify = false;
+	bool bump_id, notify = false;
 
 	addrconf_join_solict(dev, &ifp->addr);
 
@@ -3755,11 +3756,12 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
+		bump_id = ifp->flags & IFA_F_TENTATIVE;
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
-		addrconf_dad_completed(ifp);
+		addrconf_dad_completed(ifp, bump_id);
 		return;
 	}
 
@@ -3819,8 +3821,8 @@ static void addrconf_dad_work(struct work_struct *w)
 						struct inet6_ifaddr,
 						dad_work);
 	struct inet6_dev *idev = ifp->idev;
+	bool bump_id, disable_ipv6 = false;
 	struct in6_addr mcaddr;
-	bool disable_ipv6 = false;
 
 	enum {
 		DAD_PROCESS,
@@ -3890,11 +3892,12 @@ static void addrconf_dad_work(struct work_struct *w)
 		 * DAD was successful
 		 */
 
+		bump_id = ifp->flags & IFA_F_TENTATIVE;
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock(&ifp->lock);
 		write_unlock_bh(&idev->lock);
 
-		addrconf_dad_completed(ifp);
+		addrconf_dad_completed(ifp, bump_id);
 
 		goto out;
 	}
@@ -3931,7 +3934,7 @@ static bool ipv6_lonely_lladdr(struct inet6_ifaddr *ifp)
 	return true;
 }
 
-static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
+static void addrconf_dad_completed(struct inet6_ifaddr *ifp, bool bump_id)
 {
 	struct net_device *dev = ifp->idev->dev;
 	struct in6_addr lladdr;
@@ -3983,6 +3986,9 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 		spin_unlock(&ifp->lock);
 		write_unlock_bh(&ifp->idev->lock);
 	}
+
+	if (bump_id)
+		rt_genid_bump_ipv6(dev_net(dev));
 }
 
 static void addrconf_dad_run(struct inet6_dev *idev)
-- 
1.8.3.1
