From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 2/2] sunvnet: implement basic ethtool get_settings
Date: Wed, 21 Jun 2017 09:09:54 -0700
Message-ID: <1498061394-233018-3-git-send-email-shannon.nelson@oracle.com>
References: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:23150 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdFUR7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 13:59:40 -0400
In-Reply-To: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the get_settings callback so that both the ldmvsw and sunvnet
drivers will give a little more information when asked for its
basic settings.  These aren't necessarily very useful, but they
make some users happier.  Also, a side effect is that the speed
attribute in /sys/class/net/<dev> is now readable, which makes
a couple of the ldom management tools happier.

Orabug: 26175474

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |    1 +
 drivers/net/ethernet/sun/sunvnet.c        |    1 +
 drivers/net/ethernet/sun/sunvnet_common.c |   11 +++++++++++
 drivers/net/ethernet/sun/sunvnet_common.h |    2 ++
 4 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index de512ef..0ac389b 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -88,6 +88,7 @@ static void vsw_set_msglevel(struct net_device *dev, u32 value)
 }
 
 static const struct ethtool_ops vsw_ethtool_ops = {
+	.get_settings		= sunvnet_get_settings,
 	.get_drvinfo		= vsw_get_drvinfo,
 	.get_msglevel		= vsw_get_msglevel,
 	.set_msglevel		= vsw_set_msglevel,
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 75b167e..d16c351 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -189,6 +189,7 @@ static void vnet_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops vnet_ethtool_ops = {
+	.get_settings		= sunvnet_get_settings,
 	.get_drvinfo		= vnet_get_drvinfo,
 	.get_msglevel		= vnet_get_msglevel,
 	.set_msglevel		= vnet_set_msglevel,
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 9e86833..6ca27b0 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1759,3 +1759,14 @@ void sunvnet_port_rm_txq_common(struct vnet_port *port)
 	port->q_index = 0;
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_rm_txq_common);
+
+int sunvnet_get_settings(struct net_device *netdev,
+			 struct ethtool_cmd *ecmd)
+{
+	ethtool_cmd_speed_set(ecmd, 0);
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->port = PORT_NONE;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(sunvnet_get_settings);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index b20d6fa..c566ec9 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -151,5 +151,7 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 bool sunvnet_port_is_up_common(struct vnet_port *vnet);
 void sunvnet_port_add_txq_common(struct vnet_port *port);
 void sunvnet_port_rm_txq_common(struct vnet_port *port);
+int sunvnet_get_settings(struct net_device *netdev,
+			 struct ethtool_cmd *ecmd);
 
 #endif /* _SUNVNETCOMMON_H */
-- 
1.7.1
