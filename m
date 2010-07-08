From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 18:37:17 +0200
Message-ID: <1278607037.2651.57.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
	 <1278604985.2651.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64025 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0GHQhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:37:22 -0400
Received: by wwb24 with SMTP id 24so4019941wwb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 09:37:20 -0700 (PDT)
In-Reply-To: <1278604985.2651.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we need to shape traffic using low speeds, we need to
disable tso on network interface :

ethtool -K eth0.2240 tso off

It seems vlan interfaces miss the set_tso() ethtool method.

Before enabling TSO, we must check real device supports 
TSO for VLAN-tagged packets and enables TSO.

Note that a TSO change on real device propagates TSO setting
on all vlans, even if admin selected a different TSO setting.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7865a4c..a1b8171 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -836,12 +836,32 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 	return stats;
 }
 
+static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
+{
+       if (data) {
+		struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+
+		/* Underlying device must support TSO for VLAN-tagged packets
+		 * and must have TSO enabled now.
+		 */
+		if (!(real_dev->vlan_features & NETIF_F_TSO))
+			return -EOPNOTSUPP;
+		if (!(real_dev->features & NETIF_F_TSO))
+			return -EINVAL;
+		dev->features |= NETIF_F_TSO;
+	} else {
+		dev->features &= ~NETIF_F_TSO;
+	}
+	return 0;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= vlan_ethtool_get_rx_csum,
 	.get_flags		= vlan_ethtool_get_flags,
+	.set_tso                = vlan_ethtool_set_tso,
 };
 
 static const struct net_device_ops vlan_netdev_ops = {


