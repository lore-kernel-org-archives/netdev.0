From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: optimize link local address search
Date: Sun, 19 Jan 2014 21:58:19 +0100
Message-ID: <20140119205819.GD16462@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50129 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaASU6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 15:58:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_link_dev_addr sorts newly added addresses by scope in
ifp->addr_list. Smaller scope addresses are added to the tail of the
list. Use this fact to iterate in reverse over addr_list and break out
as soon as a higher scoped one showes up, so we can spare some cycles
on machines with lot's of addresses.

The ordering of the addresses is not relevant and we are more likely to
get the eui64 generated address with this change anyway.

Suggested-by: Brian Haley <brian.haley@hp.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f91e107..31bdedc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1437,7 +1437,9 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 	struct inet6_ifaddr *ifp;
 	int err = -EADDRNOTAVAIL;
 
-	list_for_each_entry(ifp, &idev->addr_list, if_list) {
+	list_for_each_entry_reverse(ifp, &idev->addr_list, if_list) {
+		if (ifp->scope > IFA_LINK)
+			break;
 		if (ifp->scope == IFA_LINK &&
 		    !(ifp->flags & banned_flags)) {
 			*addr = ifp->addr;
@@ -1858,7 +1860,9 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
-	list_for_each_entry(ifp, &idev->addr_list, if_list) {
+	list_for_each_entry_reverse(ifp, &idev->addr_list, if_list) {
+		if (ifp->scope > IFA_LINK)
+			break;
 		if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
 			memcpy(eui, ifp->addr.s6_addr+8, 8);
 			err = 0;
@@ -3239,7 +3243,9 @@ static bool ipv6_lonely_lladdr(struct inet6_ifaddr *ifp)
 	struct inet6_ifaddr *ifpiter;
 	struct inet6_dev *idev = ifp->idev;
 
-	list_for_each_entry(ifpiter, &idev->addr_list, if_list) {
+	list_for_each_entry_reverse(ifpiter, &idev->addr_list, if_list) {
+		if (ifpiter->scope > IFA_LINK)
+			break;
 		if (ifp != ifpiter && ifpiter->scope == IFA_LINK &&
 		    (ifpiter->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|
 				       IFA_F_OPTIMISTIC|IFA_F_DADFAILED)) ==
-- 
1.8.4.2
