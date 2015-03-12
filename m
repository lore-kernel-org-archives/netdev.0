From: Jonas Johansson <jonasj76@gmail.com>
Subject: [PATCH net-next] team: Notify state change on ports
Date: Thu, 12 Mar 2015 17:03:56 +0100
Message-ID: <1426176236-28255-1-git-send-email-jonas.johansson@gmail.com>
Cc: ogerlitz@mellanox.com, monis@mellanox.com,
	jonas.johansson@westermo.se, Jonas Johansson <jonasj76@gmail.com>
To: jiri@resnulli.us, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:37495 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964812AbbCLQEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:04:51 -0400
Received: by labgq15 with SMTP id gq15so16893019lab.4
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 09:04:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Johansson <jonasj76@gmail.com>

Use notifier chain to dispatch an event upon a change in port state. The event
is dispatched with the notifier_bonding_info struct.
The notifier_bonding_info struct was introduced to notify state change on
bonding slaves (commit 61bd3857), so some fields are set to -1, due that the
data is not available in team.

Signed-off-by: Jonas Johansson <jonasj76@gmail.com>
---
This patch is just a step into introducing HW bonding support. In a previous
(not applied) patchset [1], I added two (2) new ndo ops which was used to
receive a port state change. This patch will instead use the same mechanism
as introduced in [2] and [3] to notify a port state change.

A state change on a port can be used by a switching device to e.g. load
balance packets over the active ports. Due to that HW bonding isn't added to
the kernel yet this patch may atm only be of use for [4] to use the team
driver instead of the bonding driver. But I hope it will become useful as a
first step to introduce HW bonding.

[1] - [PATCH net-next 0/2] dsa: implement HW bonding'
      http://marc.info/?l=linux-netdev&m=142442948421049&w=2
[2] - net/core: Add event for a change in slave state'
      commit: 61bd3857
[3] - net/bonding: Move slave state changes to a helper function
      commit: 69a2338e
[4] - [PATCH 00/10] Add HA and LAG support to mlx4 RoCE and SRIOV services
      http://marc.info/?l=linux-netdev&m=142309529514580&w=2

 drivers/net/team/team.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_team.h | 10 ++++++
 2 files changed, 95 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a23319f..aef8120 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -659,6 +659,86 @@ static void team_notify_peers_fini(struct team *team)
 	cancel_delayed_work_sync(&team->notify_peers.dw);
 }
 
+/*********************
+ * Port notification
+ *********************/
+
+static void team_fill_ifbond(struct team *team, struct ifbond *info)
+{
+	info->bond_mode = -1;
+	info->miimon = -1;
+	info->num_slaves = team->en_port_count;
+}
+
+static void team_fill_ifslave(struct team_port *port, struct ifslave *info)
+{
+	strcpy(info->slave_name, port->dev->name);
+	info->link = port->state.linkup;
+	if (team_port_enabled(port))
+		info->state = BOND_STATE_ACTIVE;
+	else
+		info->state = BOND_STATE_BACKUP;
+	info->link_failure_count = 0;
+}
+
+static void team_notify_port_work(struct work_struct *work)
+{
+	struct team *team;
+	struct team_port_notify *notify;
+
+	team = container_of(work, struct team, notify_ports.dw.work);
+
+	if (!rtnl_trylock()) {
+		schedule_delayed_work(&team->notify_ports.dw, 0);
+		return;
+	}
+	rcu_read_lock();
+
+	notify = list_first_or_null_rcu(&team->notify_ports.port_list,
+					struct team_port_notify, list);
+	if (!notify)
+		goto unlock;
+
+	netdev_bonding_info_change(notify->dev, &notify->bonding_info);
+	dev_put(notify->dev);
+	list_del_rcu(&notify->list);
+	kfree(notify);
+
+	if (list_first_or_null_rcu(&team->notify_ports.port_list,
+				   struct team_port_notify, list))
+		schedule_delayed_work(&team->notify_ports.dw, msecs_to_jiffies(1));
+unlock:
+	rcu_read_unlock();
+	rtnl_unlock();
+}
+
+static void team_notify_port(struct team *team, struct team_port *port)
+{
+	struct team_port_notify *notify;
+
+	notify = kmalloc(sizeof(*notify), GFP_KERNEL);
+	if (!notify)
+		return;
+
+	dev_hold(port->dev);
+	notify->dev = port->dev;
+	team_fill_ifslave(port, &notify->bonding_info.slave);
+	team_fill_ifbond(team, &notify->bonding_info.master);
+
+	list_add_tail_rcu(&notify->list, &team->notify_ports.port_list);
+	schedule_delayed_work(&team->notify_ports.dw, 0);
+}
+
+static void team_notify_port_init(struct team *team)
+{
+	INIT_LIST_HEAD(&team->notify_ports.port_list);
+	INIT_DELAYED_WORK(&team->notify_ports.dw, team_notify_port_work);
+}
+
+static void team_notify_port_fini(struct team *team)
+{
+	cancel_delayed_work_sync(&team->notify_ports.dw);
+}
 
 /*******************************
  * Send multicast group rejoins
@@ -932,6 +1012,7 @@ static void team_port_enable(struct team *team,
 		team->ops.port_enabled(team, port);
 	team_notify_peers(team);
 	team_mcast_rejoin(team);
+	team_notify_port(team, port);
 }
 
 static void __reconstruct_port_hlist(struct team *team, int rm_index)
@@ -963,6 +1044,7 @@ static void team_port_disable(struct team *team,
 	team_adjust_ops(team);
 	team_notify_peers(team);
 	team_mcast_rejoin(team);
+	team_notify_port(team, port);
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
@@ -1581,6 +1663,7 @@ static int team_init(struct net_device *dev)
 
 	team_notify_peers_init(team);
 	team_mcast_rejoin_init(team);
+	team_notify_port_init(team);
 
 	err = team_options_register(team, team_options, ARRAY_SIZE(team_options));
 	if (err)
@@ -1592,6 +1675,7 @@ static int team_init(struct net_device *dev)
 	return 0;
 
 err_options_register:
+	team_notify_port_fini(team);
 	team_mcast_rejoin_fini(team);
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
@@ -1613,6 +1697,7 @@ static void team_uninit(struct net_device *dev)
 
 	__team_change_mode(team, NULL); /* cleanup */
 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
+	team_notify_port_fini(team);
 	team_mcast_rejoin_fini(team);
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index a6aa970..fc59e39 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -28,6 +28,12 @@ struct team_pcpu_stats {
 
 struct team;
 
+struct team_port_notify {
+	struct list_head list; /* node in notify list */
+	struct net_device *dev;
+	struct netdev_bonding_info bonding_info;
+};
+
 struct team_port {
 	struct net_device *dev;
 	struct hlist_node hlist; /* node in enabled ports hash list */
@@ -207,6 +213,10 @@ struct team {
 		atomic_t count_pending;
 		struct delayed_work dw;
 	} mcast_rejoin;
+	struct {
+		struct list_head port_list; /* list of ports to be notified */
+		struct delayed_work dw;
+	} notify_ports;
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
 };
 
-- 
2.1.0
