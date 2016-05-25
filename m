From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v2] team: don't call netdev_change_features under team->lock
Date: Wed, 25 May 2016 21:21:52 +0200
Message-ID: <1464204112-4044-1-git-send-email-ivecera@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.inext.cz ([212.111.0.12]:55610 "EHLO mx.inext.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbcEYThA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 15:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The team_device_event() notifier calls team_compute_features() to fix
vlan_features under team->lock to protect team->port_list. The problem is
that subsequent __team_compute_features() calls netdev_change_features()
to propagate vlan_features to upper vlan devices while team->lock is still
taken. This can lead to deadlock when NETIF_F_LRO is modified on lower
devices or team device itself.

Example:
The team0 as active backup with eth0 and eth1 NICs. Both eth0 & eth1 are
LRO capable and LRO is enabled. Thus LRO is also enabled on team0.

The command 'ethtool -K team0 lro off' now hangs due to this deadlock:

dev_ethtool()
-> ethtool_set_features()
 -> __netdev_update_features(team)
  -> netdev_sync_lower_features()
   -> netdev_update_features(lower_1)
    -> __netdev_update_features(lower_1)
    -> netdev_features_change(lower_1)
     -> call_netdevice_notifiers(...)
      -> team_device_event(lower_1)
       -> team_compute_features(team) [TAKES team->lock]
        -> netdev_change_features(team)
         -> __netdev_update_features(team)
          -> netdev_sync_lower_features()
           -> netdev_update_features(lower_2)
            -> __netdev_update_features(lower_2)
            -> netdev_features_change(lower_2)
             -> call_netdevice_notifiers(...)
              -> team_device_event(lower_2)
               -> team_compute_features(team) [DEADLOCK]

The bug is present in team from the beginning but it appeared after the commit
fd867d5 (net/core: generic support for disabling netdev features down stack)
that adds synchronization of features with lower devices.

Fixes: fd867d5 (net/core: generic support for disabling netdev features down stack)
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/team/team.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 718ceea..800a449 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -988,7 +988,7 @@ static void team_port_disable(struct team *team,
 #define TEAM_ENC_FEATURES	(NETIF_F_HW_CSUM | NETIF_F_SG | \
 				 NETIF_F_RXCSUM | NETIF_F_ALL_TSO)
 
-static void __team_compute_features(struct team *team)
+static void ___team_compute_features(struct team *team)
 {
 	struct team_port *port;
 	u32 vlan_features = TEAM_VLAN_FEATURES & NETIF_F_ALL_FOR_ALL;
@@ -1019,15 +1019,20 @@ static void __team_compute_features(struct team *team)
 	team->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 	if (dst_release_flag == (IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM))
 		team->dev->priv_flags |= IFF_XMIT_DST_RELEASE;
+}
 
+static void __team_compute_features(struct team *team)
+{
+	___team_compute_features(team);
 	netdev_change_features(team->dev);
 }
 
 static void team_compute_features(struct team *team)
 {
 	mutex_lock(&team->lock);
-	__team_compute_features(team);
+	___team_compute_features(team);
 	mutex_unlock(&team->lock);
+	netdev_change_features(team->dev);
 }
 
 static int team_port_enter(struct team *team, struct team_port *port)
-- 
2.7.3
