From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Subject: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Thu, 22 Sep 2016 16:13:08 +1200
Message-ID: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
Cc: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
To: netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:47427 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbcIVENp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 00:13:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous patch to ensure that the original iif was used when
checking for forwarding also meant that this same interface was used to
determine whether multicast packets should be received or not. This was
incorrect, and would cause multicast packets to be dropped.

The fix here is to use skb->dev when checking multicast addresses.
skb->dev has been set to the l3mdev by this point, so the check will be
against that, rather than the ingress interface.

Fixes: "net:VRF: Pass original iif to ip_route_input()"
Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a1f2830..75e1de6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1971,7 +1971,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   route cache entry is created eventually.
 	 */
 	if (ipv4_is_multicast(daddr)) {
-		struct in_device *in_dev = __in_dev_get_rcu(dev);
+		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 
 		if (in_dev) {
 			int our = ip_check_mc_rcu(in_dev, daddr, saddr,
-- 
2.9.3
