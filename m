From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next v2 1/3] vlan: more careful checksum features handling
Date: Tue, 20 May 2014 08:29:25 +0200 (CEST)
Message-ID: <106e1cfaa47e489460375596e41005f8da4d0d06.1400565116.git.mkubecek@suse.cz>
References: <20140507.140846.1449010184057650775.davem@davemloft.net>
	<cover.1400565116.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Michal Miroslaw <mirq-linux@rere.qmqm.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44342 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbaETG30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:29:26 -0400
In-Reply-To: <cover.1400565116.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When combining real_dev's features and vlan_features, simple
bitwise AND is used. This doesn't work well for checksum
offloading features as if one set has NETIF_F_HW_CSUM and the
other NETIF_F_IP_CSUM and/or NETIF_F_IPV6_CSUM, we end up with
no checksum offloading. However, from the logical point of view
(how can_checksum_protocol() works), NETIF_F_HW_CSUM contains
the functionality of NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM so
that the result should be IP/IPV6.

Add helper function netdev_intersect_features() implementing
this logic and use it in vlan_dev_fix_features().

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/linux/netdevice.h | 14 ++++++++++++++
 net/8021q/vlan_dev.c      |  4 ++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2dea98c..f4ad247 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3153,6 +3153,20 @@ const char *netdev_drivername(const struct net_device *dev);
 
 void linkwatch_run_queue(void);
 
+static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
+							  netdev_features_t f2)
+{
+	if (f1 & NETIF_F_GEN_CSUM)
+		f1 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+	if (f2 & NETIF_F_GEN_CSUM)
+		f2 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+	f1 &= f2;
+	if (f1 & NETIF_F_GEN_CSUM)
+		f1 &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+
+	return f1;
+}
+
 static inline netdev_features_t netdev_get_wanted_features(
 	struct net_device *dev)
 {
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8f025af..4181fb7 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -678,9 +678,9 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	netdev_features_t old_features = features;
 
-	features &= real_dev->vlan_features;
+	features = netdev_intersect_features(features, real_dev->vlan_features);
 	features |= NETIF_F_RXCSUM;
-	features &= real_dev->features;
+	features = netdev_intersect_features(features, real_dev->features);
 
 	features |= old_features & NETIF_F_SOFT_FEATURES;
 	features |= NETIF_F_LLTX;
-- 
1.8.1.4
