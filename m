From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 11:39:31 +0200
Message-ID: <1278581971.2651.10.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65159 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846Ab0GHJjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 05:39:35 -0400
Received: by wyf23 with SMTP id 23so377034wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 02:39:34 -0700 (PDT)
In-Reply-To: <1278571587.2543.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we need to shape traffic with low speeds, we need to disable tso on
network interface :

ethtool -K eth0.2240 tso off

It seems vlan interfaces miss the set_tso() ethtool method.
Propagating tso changes from lower device is not always wanted, some
vlans want TSO on, others want TSO off.

Before enabling TSO, we must check real device supports it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c6456cb..870bc53 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -838,12 +838,25 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev)
 	return stats;
 }
 
+static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+		unsigned long rdev_vfeatures = real_dev->features & real_dev->vlan_features;
+
+		dev->features |= (NETIF_F_TSO & rdev_vfeatures);
+	} else
+		dev->features &= ~NETIF_F_TSO;
+	return 0;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= vlan_ethtool_get_rx_csum,
 	.get_flags		= vlan_ethtool_get_flags,
+	.set_tso		= vlan_ethtool_set_tso,
 };
 
 static const struct net_device_ops vlan_netdev_ops = {


