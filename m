From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ipv6, token: allow for clearing the current device token
Date: Fri,  8 Apr 2016 15:55:00 +0200
Message-ID: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, robbat2@gentoo.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50790 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbcDHNzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 09:55:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original tokenized iid support implemented via f53adae4eae5 ("net: ipv6:
add tokenized interface identifier support") didn't allow for clearing a
device token as it was intended that this addressing mode was the only one
active for globally scoped IPv6 addresses. Later we relaxed that restriction
via 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses"),
and we should also allow for clearing tokens as there's no good reason why
it shouldn't be allowed.

Fixes: 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses")
Reported-by: Robin H. Johnson <robbat2@gentoo.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Dave, I think net-next is fine, but don't have any objections if you rather
 want to put it into net. Thanks!

 net/ipv6/addrconf.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27aed1a..a6c9927 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4995,15 +4995,13 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 {
 	struct inet6_ifaddr *ifp;
 	struct net_device *dev = idev->dev;
-	bool update_rs = false;
+	bool clear_token, update_rs = false;
 	struct in6_addr ll_addr;
 
 	ASSERT_RTNL();
 
 	if (!token)
 		return -EINVAL;
-	if (ipv6_addr_any(token))
-		return -EINVAL;
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
 		return -EINVAL;
 	if (!ipv6_accept_ra(idev))
@@ -5018,10 +5016,13 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	write_unlock_bh(&idev->lock);
 
+	clear_token = ipv6_addr_any(token);
+	if (clear_token)
+		goto update_lft;
+
 	if (!idev->dead && (idev->if_flags & IF_READY) &&
 	    !ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
 			     IFA_F_OPTIMISTIC)) {
-
 		/* If we're not ready, then normal ifup will take care
 		 * of this. Otherwise, we need to request our rs here.
 		 */
@@ -5029,6 +5030,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 		update_rs = true;
 	}
 
+update_lft:
 	write_lock_bh(&idev->lock);
 
 	if (update_rs) {
-- 
1.9.3
