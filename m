From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCH 4.4-stable 2/3] geneve: Relax MTU constraints
Date: Fri,  3 Jun 2016 18:58:14 -0400
Message-ID: <1464994695-25178-3-git-send-email-dan.streetman@canonical.com>
References: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56151 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbcFCXDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:03:45 -0400
In-Reply-To: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>

Allow the MTU of geneve devices to be set to large values, in order to
exploit underlying networks with larger frame sizes.

GENEVE does not have a fixed encapsulation overhead (an openvswitch
rule can add variable length options), so there is no relevant maximum
MTU to enforce.  A maximum of IP_MAX_MTU is used instead.
Encapsulated packets that are too big for the underlying network will
get dropped on the floor.

Signed-off-by: David Wragg <david@weave.works>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/geneve.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 58efdec..0fb2ced 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -998,6 +998,17 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	return geneve_xmit_skb(skb, dev, info);
 }
 
+static int geneve_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* GENEVE overhead is not fixed, so we can't enforce a more
+	 * precise max MTU.
+	 */
+	if (new_mtu < 68 || new_mtu > IP_MAX_MTU)
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
@@ -1042,7 +1053,7 @@ static const struct net_device_ops geneve_netdev_ops = {
 	.ndo_stop		= geneve_stop,
 	.ndo_start_xmit		= geneve_xmit,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= geneve_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_fill_metadata_dst	= geneve_fill_metadata_dst,
-- 
2.7.4
