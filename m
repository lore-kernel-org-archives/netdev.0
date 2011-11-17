From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/2] team: add fix_features
Date: Thu, 17 Nov 2011 15:16:04 +0100
Message-ID: <1321539365-1125-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757357Ab1KQOQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 09:16:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do fix features in similar way as bonding code does

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f309274..5b169c1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -953,6 +953,27 @@ static int team_del_slave(struct net_device *dev, struct net_device *port_dev)
 	return err;
 }
 
+static netdev_features_t team_fix_features(struct net_device *dev,
+					   netdev_features_t features)
+{
+	struct team_port *port;
+	struct team *team = netdev_priv(dev);
+	netdev_features_t mask;
+
+	mask = features;
+	features &= ~NETIF_F_ONE_FOR_ALL;
+	features |= NETIF_F_ALL_FOR_ALL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(port, &team->port_list, list) {
+		features = netdev_increment_features(features,
+						     port->dev->features,
+						     mask);
+	}
+	rcu_read_unlock();
+	return features;
+}
+
 static const struct net_device_ops team_netdev_ops = {
 	.ndo_init		= team_init,
 	.ndo_uninit		= team_uninit,
@@ -968,6 +989,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= team_vlan_rx_kill_vid,
 	.ndo_add_slave		= team_add_slave,
 	.ndo_del_slave		= team_del_slave,
+	.ndo_fix_features	= team_fix_features,
 };
 
 
-- 
1.7.6
