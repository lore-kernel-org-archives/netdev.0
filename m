From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] team: add netpoll support
Date: Tue, 17 Jul 2012 17:22:36 +0200
Message-ID: <1342538556-22601-3-git-send-email-jiri@resnulli.us>
References: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45818 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2GQPWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:22:47 -0400
Received: by wibhr14 with SMTP id hr14so531049wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 08:22:45 -0700 (PDT)
In-Reply-To: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's done in very similar way this is done in bonding and bridge.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c                   |  113 +++++++++++++++++++++++++++++
 drivers/net/team/team_mode_activebackup.c |    3 +-
 drivers/net/team/team_mode_broadcast.c    |    7 +-
 drivers/net/team/team_mode_loadbalance.c  |    3 +-
 drivers/net/team/team_mode_roundrobin.c   |    3 +-
 include/linux/if_team.h                   |   33 +++++++++
 6 files changed, 152 insertions(+), 10 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 3620c63..1a13470 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -18,6 +18,7 @@
 #include <linux/ctype.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/if_vlan.h>
 #include <linux/if_arp.h>
 #include <linux/socket.h>
@@ -787,6 +788,58 @@ static void team_port_leave(struct team *team, struct team_port *port)
 	dev_put(team->dev);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static int team_port_enable_netpoll(struct team *team, struct team_port *port)
+{
+	struct netpoll *np;
+	int err;
+
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
+	if (!np)
+		return -ENOMEM;
+
+	err = __netpoll_setup(np, port->dev);
+	if (err) {
+		kfree(np);
+		return err;
+	}
+	port->np = np;
+	return err;
+}
+
+static void team_port_disable_netpoll(struct team_port *port)
+{
+	struct netpoll *np = port->np;
+
+	if (!np)
+		return;
+	port->np = NULL;
+
+	/* Wait for transmitting packets to finish before freeing. */
+	synchronize_rcu_bh();
+	__netpoll_cleanup(np);
+	kfree(np);
+}
+
+static struct netpoll_info *team_netpoll_info(struct team *team)
+{
+	return team->dev->npinfo;
+}
+
+#else
+static int team_port_enable_netpoll(struct team *team, struct team_port *port)
+{
+	return 0;
+}
+static void team_port_disable_netpoll(struct team_port *port)
+{
+}
+static struct netpoll_info *team_netpoll_info(struct team *team)
+{
+	return NULL;
+}
+#endif
+
 static void __team_port_change_check(struct team_port *port, bool linkup);
 
 static int team_port_add(struct team *team, struct net_device *port_dev)
@@ -853,6 +906,15 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_vids_add;
 	}
 
+	if (team_netpoll_info(team)) {
+		err = team_port_enable_netpoll(team, port);
+		if (err) {
+			netdev_err(dev, "Failed to enable netpoll on device %s\n",
+				   portname);
+			goto err_enable_netpoll;
+		}
+	}
+
 	err = netdev_set_master(port_dev, dev);
 	if (err) {
 		netdev_err(dev, "Device %s failed to set master\n", portname);
@@ -892,6 +954,9 @@ err_handler_register:
 	netdev_set_master(port_dev, NULL);
 
 err_set_master:
+	team_port_disable_netpoll(port);
+
+err_enable_netpoll:
 	vlan_vids_del_by_dev(port_dev, dev);
 
 err_vids_add:
@@ -932,6 +997,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
 	netdev_set_master(port_dev, NULL);
+	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
 	team_port_leave(team, port);
@@ -1307,6 +1373,48 @@ static int team_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void team_poll_controller(struct net_device *dev)
+{
+}
+
+static void __team_netpoll_cleanup(struct team *team)
+{
+	struct team_port *port;
+
+	list_for_each_entry(port, &team->port_list, list)
+		team_port_disable_netpoll(port);
+}
+
+static void team_netpoll_cleanup(struct net_device *dev)
+{
+	struct team *team = netdev_priv(dev);
+
+	mutex_lock(&team->lock);
+	__team_netpoll_cleanup(team);
+	mutex_unlock(&team->lock);
+}
+
+static int team_netpoll_setup(struct net_device *dev,
+			      struct netpoll_info *npifo)
+{
+	struct team *team = netdev_priv(dev);
+	struct team_port *port;
+	int err;
+
+	mutex_lock(&team->lock);
+	list_for_each_entry(port, &team->port_list, list) {
+		err = team_port_enable_netpoll(team, port);
+		if (err) {
+			__team_netpoll_cleanup(team);
+			break;
+		}
+	}
+	mutex_unlock(&team->lock);
+	return err;
+}
+#endif
+
 static int team_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
 	struct team *team = netdev_priv(dev);
@@ -1363,6 +1471,11 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_get_stats64	= team_get_stats64,
 	.ndo_vlan_rx_add_vid	= team_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= team_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= team_poll_controller,
+	.ndo_netpoll_setup	= team_netpoll_setup,
+	.ndo_netpoll_cleanup	= team_netpoll_cleanup,
+#endif
 	.ndo_add_slave		= team_add_slave,
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 253b8a5..6262b4d 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -43,8 +43,7 @@ static bool ab_transmit(struct team *team, struct sk_buff *skb)
 	active_port = rcu_dereference_bh(ab_priv(team)->active_port);
 	if (unlikely(!active_port))
 		goto drop;
-	skb->dev = active_port->dev;
-	if (dev_queue_xmit(skb))
+	if (team_dev_queue_xmit(team, active_port, skb))
 		return false;
 	return true;
 
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index 5562345..c96e4d2 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -29,8 +29,8 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
 			if (last) {
 				skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2) {
-					skb2->dev = last->dev;
-					ret = dev_queue_xmit(skb2);
+					ret = team_dev_queue_xmit(team, last,
+								  skb2);
 					if (!sum_ret)
 						sum_ret = ret;
 				}
@@ -39,8 +39,7 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
 		}
 	}
 	if (last) {
-		skb->dev = last->dev;
-		ret = dev_queue_xmit(skb);
+		ret = team_dev_queue_xmit(team, last, skb);
 		if (!sum_ret)
 			sum_ret = ret;
 	}
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 51a4b19..cdc31b5 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -217,8 +217,7 @@ static bool lb_transmit(struct team *team, struct sk_buff *skb)
 	port = select_tx_port_func(team, lb_priv, skb, hash);
 	if (unlikely(!port))
 		goto drop;
-	skb->dev = port->dev;
-	if (dev_queue_xmit(skb))
+	if (team_dev_queue_xmit(team, port, skb))
 		return false;
 	lb_update_tx_stats(tx_bytes, lb_priv, get_lb_port_priv(port), hash);
 	return true;
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 0cf38e9..ad7ed0e 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -55,8 +55,7 @@ static bool rr_transmit(struct team *team, struct sk_buff *skb)
 	port = __get_first_port_up(team, port);
 	if (unlikely(!port))
 		goto drop;
-	skb->dev = port->dev;
-	if (dev_queue_xmit(skb))
+	if (team_dev_queue_xmit(team, port, skb))
 		return false;
 	return true;
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index dfa0c8e..7fd0cde 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -13,6 +13,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/netpoll.h>
+
 struct team_pcpu_stats {
 	u64			rx_packets;
 	u64			rx_bytes;
@@ -60,6 +62,10 @@ struct team_port {
 		unsigned int mtu;
 	} orig;
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll *np;
+#endif
+
 	long mode_priv[0];
 };
 
@@ -73,6 +79,33 @@ static inline bool team_port_txable(struct team_port *port)
 	return port->linkup && team_port_enabled(port);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline void team_netpoll_send_skb(struct team_port *port,
+					 struct sk_buff *skb)
+{
+	struct netpoll *np = port->np;
+
+	if (np)
+		netpoll_send_skb(np, skb);
+}
+#else
+static inline void team_netpoll_send_skb(struct team_port *port,
+					 struct sk_buff *skb)
+{
+}
+#endif
+
+static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
+				      struct sk_buff *skb)
+{
+	skb->dev = port->dev;
+	if (unlikely(netpoll_tx_running(port->dev))) {
+		team_netpoll_send_skb(port, skb);
+		return 0;
+	}
+	return dev_queue_xmit(skb);
+}
+
 struct team_mode_ops {
 	int (*init)(struct team *team);
 	void (*exit)(struct team *team);
-- 
1.7.10.4
