From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] vxlan: fix ethernet address initialization
Date: Thu, 28 Apr 2016 12:04:16 +0200
Message-ID: <1461837856-4316-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Benc <jbenc@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:58553 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbcD1KEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 06:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0c867c9bf84c, when the user specifies an ethernet address with
IFLA_ADDRESS, it's overridden by vxlan_ether_setup() (rtnl_link_ops->setup
is called in rtnetlink.c before handling IFLA_ADDRESS).

To test it:
ip link add name vxlan1 address de:ad:de:4c:0f:c2 type vxlan id 1 group 239.0.0.10 dev eth0

CC: Jiri Benc <jbenc@redhat.com>
Fixes: 0c867c9bf84c ("vxlan: move Ethernet initialization to a separate function")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6fb93b57a724..d454c7e7d16e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2592,7 +2592,8 @@ static void vxlan_setup(struct net_device *dev)
 
 static void vxlan_ether_setup(struct net_device *dev)
 {
-	eth_hw_addr_random(dev);
+	if (!is_valid_ether_addr(dev->dev_addr))
+		eth_hw_addr_random(dev);
 	ether_setup(dev);
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
-- 
2.4.2
