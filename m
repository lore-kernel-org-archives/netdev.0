From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 11/28] team: fill-up LAG changeupper info struct and pass it along
Date: Thu,  3 Dec 2015 12:12:13 +0100
Message-ID: <1449141150-8172-12-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34082 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbbLCLMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:51 -0500
Received: by wmvv187 with SMTP id v187so21656304wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:50 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Initialize netdev_lag_upper_info structure by TX type according to
current team mode and pass it along via netdev_master_upper_dev_link.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team.c                   | 23 ++++++++++++-----------
 drivers/net/team/team_mode_activebackup.c |  1 +
 drivers/net/team/team_mode_broadcast.c    |  1 +
 drivers/net/team/team_mode_loadbalance.c  |  1 +
 drivers/net/team/team_mode_random.c       |  1 +
 drivers/net/team/team_mode_roundrobin.c   |  1 +
 include/linux/if_team.h                   |  1 +
 7 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f7b6ff7..dd1504b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1078,23 +1078,24 @@ static void team_port_disable_netpoll(struct team_port *port)
 }
 #endif
 
-static int team_upper_dev_link(struct net_device *dev,
-			       struct net_device *port_dev)
+static int team_upper_dev_link(struct team *team, struct team_port *port)
 {
+	struct netdev_lag_upper_info lag_upper_info;
 	int err;
 
-	err = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
+	lag_upper_info.tx_type = team->mode->lag_tx_type;
+	err = netdev_master_upper_dev_link(port->dev, team->dev, NULL,
+					   &lag_upper_info);
 	if (err)
 		return err;
-	port_dev->priv_flags |= IFF_TEAM_PORT;
+	port->dev->priv_flags |= IFF_TEAM_PORT;
 	return 0;
 }
 
-static void team_upper_dev_unlink(struct net_device *dev,
-				  struct net_device *port_dev)
+static void team_upper_dev_unlink(struct team *team, struct team_port *port)
 {
-	netdev_upper_dev_unlink(port_dev, dev);
-	port_dev->priv_flags &= ~IFF_TEAM_PORT;
+	netdev_upper_dev_unlink(port->dev, team->dev);
+	port->dev->priv_flags &= ~IFF_TEAM_PORT;
 }
 
 static void __team_port_change_port_added(struct team_port *port, bool linkup);
@@ -1194,7 +1195,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_handler_register;
 	}
 
-	err = team_upper_dev_link(dev, port_dev);
+	err = team_upper_dev_link(team, port);
 	if (err) {
 		netdev_err(dev, "Device %s failed to set upper link\n",
 			   portname);
@@ -1220,7 +1221,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	return 0;
 
 err_option_port_add:
-	team_upper_dev_unlink(dev, port_dev);
+	team_upper_dev_unlink(team, port);
 
 err_set_upper_link:
 	netdev_rx_handler_unregister(port_dev);
@@ -1264,7 +1265,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
-	team_upper_dev_unlink(dev, port_dev);
+	team_upper_dev_unlink(team, port);
 	netdev_rx_handler_unregister(port_dev);
 	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 40fd338..3f18982 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -127,6 +127,7 @@ static const struct team_mode ab_mode = {
 	.owner		= THIS_MODULE,
 	.priv_size	= sizeof(struct ab_priv),
 	.ops		= &ab_mode_ops,
+	.lag_tx_type	= NETDEV_LAG_TX_TYPE_ACTIVEBACKUP,
 };
 
 static int __init ab_init_module(void)
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index c366cd2..302ff35 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -56,6 +56,7 @@ static const struct team_mode bc_mode = {
 	.kind		= "broadcast",
 	.owner		= THIS_MODULE,
 	.ops		= &bc_mode_ops,
+	.lag_tx_type	= NETDEV_LAG_TX_TYPE_BROADCAST,
 };
 
 static int __init bc_init_module(void)
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index a1536d0..cdb19b3 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -661,6 +661,7 @@ static const struct team_mode lb_mode = {
 	.priv_size	= sizeof(struct lb_priv),
 	.port_priv_size	= sizeof(struct lb_port_priv),
 	.ops		= &lb_mode_ops,
+	.lag_tx_type	= NETDEV_LAG_TX_TYPE_HASH,
 };
 
 static int __init lb_init_module(void)
diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index cd2f692..215f845 100644
--- a/drivers/net/team/team_mode_random.c
+++ b/drivers/net/team/team_mode_random.c
@@ -46,6 +46,7 @@ static const struct team_mode rnd_mode = {
 	.kind		= "random",
 	.owner		= THIS_MODULE,
 	.ops		= &rnd_mode_ops,
+	.lag_tx_type	= NETDEV_LAG_TX_TYPE_RANDOM,
 };
 
 static int __init rnd_init_module(void)
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 5366585..0aa2341 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -58,6 +58,7 @@ static const struct team_mode rr_mode = {
 	.owner		= THIS_MODULE,
 	.priv_size	= sizeof(struct rr_priv),
 	.ops		= &rr_mode_ops,
+	.lag_tx_type	= NETDEV_LAG_TX_TYPE_ROUNDROBIN,
 };
 
 static int __init rr_init_module(void)
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index a6aa970..b84e49c 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -164,6 +164,7 @@ struct team_mode {
 	size_t priv_size;
 	size_t port_priv_size;
 	const struct team_mode_ops *ops;
+	enum netdev_lag_tx_type lag_tx_type;
 };
 
 #define TEAM_PORT_HASHBITS 4
-- 
1.9.3
