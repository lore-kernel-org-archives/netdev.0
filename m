From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: dad: don't remove dynamic addresses if link is down
Date: Thu, 29 Jun 2017 16:56:54 +0200
Message-ID: <cd87260f67fdd2a0b8feba4bed443d162d06254d.1498745606.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42009 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751974AbdF2O5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 10:57:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when the link for $DEV is down, this command succeeds but the
address is removed immediately by DAD (1):

    ip addr add 1111::12/64 dev $DEV valid_lft 3600 preferred_lft 1800

In the same situation, this will succeed and not remove the address (2):

    ip addr add 1111::12/64 dev $DEV
    ip addr change 1111::12/64 dev $DEV valid_lft 3600 preferred_lft 1800

The comment in addrconf_dad_begin() when !IF_READY makes it look like
this is the intended behavior, but doesn't explain why:

     * If the device is not ready:
     * - keep it tentative if it is a permanent address.
     * - otherwise, kill it.

We clearly cannot prevent userspace from doing (2), but we can make (1)
work consistently with (2).

addrconf_dad_stop() is only called in two cases: if DAD failed, or to
skip DAD when the link is down. In that second case, the fix is to avoid
deleting the address, like we already do for permanent addresses.

Fixes: 3c21edbd1137 ("[IPV6]: Defer IPv6 device initialization until the link becomes ready.")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv6/addrconf.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 686c92375e81..00f0cf183996 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1912,15 +1912,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 	if (dad_failed)
 		ifp->flags |= IFA_F_DADFAILED;
 
-	if (ifp->flags&IFA_F_PERMANENT) {
-		spin_lock_bh(&ifp->lock);
-		addrconf_del_dad_work(ifp);
-		ifp->flags |= IFA_F_TENTATIVE;
-		spin_unlock_bh(&ifp->lock);
-		if (dad_failed)
-			ipv6_ifa_notify(0, ifp);
-		in6_ifa_put(ifp);
-	} else if (ifp->flags&IFA_F_TEMPORARY) {
+	if (ifp->flags&IFA_F_TEMPORARY) {
 		struct inet6_ifaddr *ifpub;
 		spin_lock_bh(&ifp->lock);
 		ifpub = ifp->ifpub;
@@ -1933,6 +1925,14 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 			spin_unlock_bh(&ifp->lock);
 		}
 		ipv6_del_addr(ifp);
+	} else if (ifp->flags&IFA_F_PERMANENT || !dad_failed) {
+		spin_lock_bh(&ifp->lock);
+		addrconf_del_dad_work(ifp);
+		ifp->flags |= IFA_F_TENTATIVE;
+		spin_unlock_bh(&ifp->lock);
+		if (dad_failed)
+			ipv6_ifa_notify(0, ifp);
+		in6_ifa_put(ifp);
 	} else {
 		ipv6_del_addr(ifp);
 	}
-- 
2.13.2
