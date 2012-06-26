From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/3] team: fix team_adjust_ops with regard to enabled ports
Date: Tue, 26 Jun 2012 18:52:45 +0200
Message-ID: <1340729567-3164-2-git-send-email-jpirko@redhat.com>
References: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758499Ab2FZRHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 13:07:31 -0400
In-Reply-To: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

team_adjust_ops should check for enabled ports, not all ports.
This may lead to division by zero. This patch fixes this.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 3a4a74b..6b4cf6e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -508,26 +508,31 @@ static void team_set_no_mode(struct team *team)
 	team->mode = &__team_no_mode;
 }
 
-static void team_adjust_ops(struct team *team)
+static void __team_adjust_ops(struct team *team, int en_port_count)
 {
 	/*
 	 * To avoid checks in rx/tx skb paths, ensure here that non-null and
 	 * correct ops are always set.
 	 */
 
-	if (list_empty(&team->port_list) ||
-	    !team_is_mode_set(team) || !team->mode->ops->transmit)
+	if (!en_port_count || !team_is_mode_set(team) ||
+	    !team->mode->ops->transmit)
 		team->ops.transmit = team_dummy_transmit;
 	else
 		team->ops.transmit = team->mode->ops->transmit;
 
-	if (list_empty(&team->port_list) ||
-	    !team_is_mode_set(team) || !team->mode->ops->receive)
+	if (!en_port_count || !team_is_mode_set(team) ||
+	    !team->mode->ops->receive)
 		team->ops.receive = team_dummy_receive;
 	else
 		team->ops.receive = team->mode->ops->receive;
 }
 
+static void team_adjust_ops(struct team *team)
+{
+	__team_adjust_ops(team, team->en_port_count);
+}
+
 /*
  * We can benefit from the fact that it's ensured no port is present
  * at the time of mode change. Therefore no packets are in fly so there's no
@@ -687,6 +692,7 @@ static void team_port_enable(struct team *team,
 	port->index = team->en_port_count++;
 	hlist_add_head_rcu(&port->hlist,
 			   team_port_index_hash(team, port->index));
+	team_adjust_ops(team);
 	if (team->ops.port_enabled)
 		team->ops.port_enabled(team, port);
 }
@@ -708,16 +714,20 @@ static void __reconstruct_port_hlist(struct team *team, int rm_index)
 static void team_port_disable(struct team *team,
 			      struct team_port *port)
 {
-	int rm_index = port->index;
-
 	if (!team_port_enabled(port))
 		return;
 	if (team->ops.port_disabled)
 		team->ops.port_disabled(team, port);
 	hlist_del_rcu(&port->hlist);
-	__reconstruct_port_hlist(team, rm_index);
-	team->en_port_count--;
+	__reconstruct_port_hlist(team, port->index);
 	port->index = -1;
+	__team_adjust_ops(team, team->en_port_count - 1);
+	/*
+	 * Wait until readers see adjusted ops. This ensures that
+	 * readers never see team->en_port_count == 0
+	 */
+	synchronize_rcu();
+	team->en_port_count--;
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
@@ -874,7 +884,6 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	port->index = -1;
 	team_port_enable(team, port);
 	list_add_tail_rcu(&port->list, &team->port_list);
-	team_adjust_ops(team);
 	__team_compute_features(team);
 	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
 	__team_options_change_check(team);
@@ -928,7 +937,6 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	__team_port_change_check(port, false);
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
-	team_adjust_ops(team);
 	netdev_rx_handler_unregister(port_dev);
 	netdev_set_master(port_dev, NULL);
 	vlan_vids_del_by_dev(port_dev, dev);
-- 
1.7.10.4
