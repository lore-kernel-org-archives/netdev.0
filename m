From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] team: call netdev_change_features out of team lock
Date: Thu,  6 Apr 2017 13:41:28 +0800
Message-ID: <dad7cdf64679977bd3ba512180fcfb8ec96d9129.1491457288.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33749 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753481AbdDFFlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 01:41:37 -0400
Received: by mail-pg0-f68.google.com with SMTP id 79so5973087pgf.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 22:41:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f6988cb63a4e ("team: don't call netdev_change_features under
team->lock") fixed the issue calling netdev_change_features under
team->lock for team_compute_features.

But there are still two places where it calls netdev_change_features
under team->lock, team_port_add and team_port_del. It may cause a
dead lock when the slave port with LRO enabled is added.

This patch is to fix this dead lock by moving netdev_change_features
out of team_port_add and team_port_del, and call it after unlocking
the team lock.

Reported-by: Patrick Talbert <ptalbert@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/team/team.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 1b52520..f8c81f1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -990,7 +990,7 @@ static void team_port_disable(struct team *team,
 #define TEAM_ENC_FEATURES	(NETIF_F_HW_CSUM | NETIF_F_SG | \
 				 NETIF_F_RXCSUM | NETIF_F_ALL_TSO)
 
-static void ___team_compute_features(struct team *team)
+static void __team_compute_features(struct team *team)
 {
 	struct team_port *port;
 	u32 vlan_features = TEAM_VLAN_FEATURES & NETIF_F_ALL_FOR_ALL;
@@ -1023,16 +1023,10 @@ static void ___team_compute_features(struct team *team)
 		team->dev->priv_flags |= IFF_XMIT_DST_RELEASE;
 }
 
-static void __team_compute_features(struct team *team)
-{
-	___team_compute_features(team);
-	netdev_change_features(team->dev);
-}
-
 static void team_compute_features(struct team *team)
 {
 	mutex_lock(&team->lock);
-	___team_compute_features(team);
+	__team_compute_features(team);
 	mutex_unlock(&team->lock);
 	netdev_change_features(team->dev);
 }
@@ -1641,6 +1635,7 @@ static void team_uninit(struct net_device *dev)
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
+	netdev_change_features(dev);
 }
 
 static void team_destructor(struct net_device *dev)
@@ -1928,6 +1923,10 @@ static int team_add_slave(struct net_device *dev, struct net_device *port_dev)
 	mutex_lock(&team->lock);
 	err = team_port_add(team, port_dev);
 	mutex_unlock(&team->lock);
+
+	if (!err)
+		netdev_change_features(dev);
+
 	return err;
 }
 
@@ -1939,6 +1938,10 @@ static int team_del_slave(struct net_device *dev, struct net_device *port_dev)
 	mutex_lock(&team->lock);
 	err = team_port_del(team, port_dev);
 	mutex_unlock(&team->lock);
+
+	if (!err)
+		netdev_change_features(dev);
+
 	return err;
 }
 
-- 
2.1.0
