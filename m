From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv6: check return value of ipv6_get_lladdr
Date: Mon, 24 Jun 2013 21:42:40 +0200
Message-ID: <20130624194240.GI13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35051 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3FXTml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 15:42:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should check the return value of ipv6_get_lladdr in inet6_set_iftoken.

A possible situation, which could leave ll_addr unassigned is, when
the user removed her link-local address but a global scoped address was
already set. In this case the interface would still be IF_READY and not
dead. In that case the RS source address is some value from the stack.

v2: Daniel Borkmann noted a small indent inconstancy; no semantic
changes.

Cc: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Reviewed-by: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 90788a1..1626cd0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4315,6 +4315,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	struct inet6_ifaddr *ifp;
 	struct net_device *dev = idev->dev;
 	bool update_rs = false;
+	struct in6_addr ll_addr;
 
 	if (token == NULL)
 		return -EINVAL;
@@ -4334,11 +4335,9 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	write_unlock_bh(&idev->lock);
 
-	if (!idev->dead && (idev->if_flags & IF_READY)) {
-		struct in6_addr ll_addr;
-
-		ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
-				IFA_F_OPTIMISTIC);
+	if (!idev->dead && (idev->if_flags & IF_READY) &&
+	    !ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
+			     IFA_F_OPTIMISTIC)) {
 
 		/* If we're not ready, then normal ifup will take care
 		 * of this. Otherwise, we need to request our rs here.
-- 
1.8.1.4
