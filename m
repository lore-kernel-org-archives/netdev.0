From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: check return value of ipv6_get_lladdr
Date: Sun, 23 Jun 2013 21:56:48 +0200
Message-ID: <20130623195648.GC13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32987 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3FWT4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 15:56:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should check the return value of ipv6_get_lladdr in inet6_set_iftoken.

A possible situation, which could leave ll_addr unassigned is, when
the user removed her link-local address but a global scoped address was
already set. In this case the interface would still be IF_READY and not
dead. In that case the RS source address is some value from the stack.

Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Maybe -net, or even stable?

 net/ipv6/addrconf.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8044912..9392c6e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4317,6 +4317,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	struct inet6_ifaddr *ifp;
 	struct net_device *dev = idev->dev;
 	bool update_rs = false;
+	struct in6_addr ll_addr;
 
 	if (token == NULL)
 		return -EINVAL;
@@ -4336,11 +4337,9 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	write_unlock_bh(&idev->lock);
 
-	if (!idev->dead && (idev->if_flags & IF_READY)) {
-		struct in6_addr ll_addr;
-
-		ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
-				IFA_F_OPTIMISTIC);
+	if (!idev->dead && (idev->if_flags & IF_READY) &&
+	    !ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
+					    IFA_F_OPTIMISTIC)) {
 
 		/* If we're not ready, then normal ifup will take care
 		 * of this. Otherwise, we need to request our rs here.
-- 
1.8.1.4
