From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: add support for non-ethernet devices
Date: Fri, 17 Aug 2012 16:00:48 +0200
Message-ID: <1345212048-1378-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50858 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124Ab2HQOAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 10:00:55 -0400
Received: by eaac11 with SMTP id c11so1325833eaa.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 07:00:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is resolved by two things:
1) allow dev_addr of different length than ETH_ALEN
2) during port add, check for dev->type and change it if necessary

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/Kconfig                |    4 +-
 drivers/net/team/team.c                 |   89 +++++++++++++++++++++++--------
 drivers/net/team/team_mode_broadcast.c  |    8 +--
 drivers/net/team/team_mode_roundrobin.c |    8 +--
 include/linux/if_team.h                 |    4 +-
 5 files changed, 79 insertions(+), 34 deletions(-)

diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
index 6a7260b..6b08bd4 100644
--- a/drivers/net/team/Kconfig
+++ b/drivers/net/team/Kconfig
@@ -21,7 +21,7 @@ config NET_TEAM_MODE_BROADCAST
 	---help---
 	  Basic mode where packets are transmitted always by all suitable ports.
 
-	  All added ports are setup to have team's mac address.
+	  All added ports are setup to have team's device address.
 
 	  To compile this team mode as a module, choose M here: the module
 	  will be called team_mode_broadcast.
@@ -33,7 +33,7 @@ config NET_TEAM_MODE_ROUNDROBIN
 	  Basic mode where port used for transmitting packets is selected in
 	  round-robin fashion using packet counter.
 
-	  All added ports are setup to have team's mac address.
+	  All added ports are setup to have team's device address.
 
 	  To compile this team mode as a module, choose M here: the module
 	  will be called team_mode_roundrobin.
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dabddc5..659e510 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -54,29 +54,29 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
 }
 
 /*
- * Since the ability to change mac address for open port device is tested in
+ * Since the ability to change device address for open port device is tested in
  * team_port_add, this function can be called without control of return value
  */
-static int __set_port_mac(struct net_device *port_dev,
-			  const unsigned char *dev_addr)
+static int __set_port_dev_addr(struct net_device *port_dev,
+			       const unsigned char *dev_addr)
 {
 	struct sockaddr addr;
 
-	memcpy(addr.sa_data, dev_addr, ETH_ALEN);
-	addr.sa_family = ARPHRD_ETHER;
+	memcpy(addr.sa_data, dev_addr, port_dev->addr_len);
+	addr.sa_family = port_dev->type;
 	return dev_set_mac_address(port_dev, &addr);
 }
 
-static int team_port_set_orig_mac(struct team_port *port)
+static int team_port_set_orig_dev_addr(struct team_port *port)
 {
-	return __set_port_mac(port->dev, port->orig.dev_addr);
+	return __set_port_dev_addr(port->dev, port->orig.dev_addr);
 }
 
-int team_port_set_team_mac(struct team_port *port)
+int team_port_set_team_dev_addr(struct team_port *port)
 {
-	return __set_port_mac(port->dev, port->team->dev->dev_addr);
+	return __set_port_dev_addr(port->dev, port->team->dev->dev_addr);
 }
-EXPORT_SYMBOL(team_port_set_team_mac);
+EXPORT_SYMBOL(team_port_set_team_dev_addr);
 
 static void team_refresh_port_linkup(struct team_port *port)
 {
@@ -965,6 +965,8 @@ static struct netpoll_info *team_netpoll_info(struct team *team)
 #endif
 
 static void __team_port_change_check(struct team_port *port, bool linkup);
+static int team_dev_type_check_change(struct net_device *dev,
+				      struct net_device *port_dev);
 
 static int team_port_add(struct team *team, struct net_device *port_dev)
 {
@@ -973,9 +975,8 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	char *portname = port_dev->name;
 	int err;
 
-	if (port_dev->flags & IFF_LOOPBACK ||
-	    port_dev->type != ARPHRD_ETHER) {
-		netdev_err(dev, "Device %s is of an unsupported type\n",
+	if (port_dev->flags & IFF_LOOPBACK) {
+		netdev_err(dev, "Device %s is loopback device. Loopback devices can't be added as a team port\n",
 			   portname);
 		return -EINVAL;
 	}
@@ -986,6 +987,10 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		return -EBUSY;
 	}
 
+	err = team_dev_type_check_change(dev, port_dev);
+	if (err)
+		return err;
+
 	if (port_dev->flags & IFF_UP) {
 		netdev_err(dev, "Device %s is up. Set it down before adding it as a team port\n",
 			   portname);
@@ -1008,7 +1013,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_set_mtu;
 	}
 
-	memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALEN);
+	memcpy(port->orig.dev_addr, port_dev->dev_addr, port_dev->addr_len);
 
 	err = team_port_enter(team, port);
 	if (err) {
@@ -1090,7 +1095,7 @@ err_vids_add:
 
 err_dev_open:
 	team_port_leave(team, port);
-	team_port_set_orig_mac(port);
+	team_port_set_orig_dev_addr(port);
 
 err_port_enter:
 	dev_set_mtu(port_dev, port->orig.mtu);
@@ -1127,7 +1132,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
 	team_port_leave(team, port);
-	team_port_set_orig_mac(port);
+	team_port_set_orig_dev_addr(port);
 	dev_set_mtu(port_dev, port->orig.mtu);
 	synchronize_rcu();
 	kfree(port);
@@ -1478,17 +1483,18 @@ static void team_set_rx_mode(struct net_device *dev)
 
 static int team_set_mac_address(struct net_device *dev, void *p)
 {
+	struct sockaddr *addr = p;
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
-	int err;
 
-	err = eth_mac_addr(dev, p);
-	if (err)
-		return err;
+	if (dev->type == ARPHRD_ETHER && !is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list)
-		if (team->ops.port_change_mac)
-			team->ops.port_change_mac(team, port);
+		if (team->ops.port_change_dev_addr)
+			team->ops.port_change_dev_addr(team, port);
 	rcu_read_unlock();
 	return 0;
 }
@@ -1719,6 +1725,45 @@ static const struct net_device_ops team_netdev_ops = {
  * rt netlink interface
  ***********************/
 
+static void team_setup_by_port(struct net_device *dev,
+			       struct net_device *port_dev)
+{
+	dev->header_ops	= port_dev->header_ops;
+	dev->type = port_dev->type;
+	dev->hard_header_len = port_dev->hard_header_len;
+	dev->addr_len = port_dev->addr_len;
+	dev->mtu = port_dev->mtu;
+	memcpy(dev->broadcast, port_dev->broadcast, port_dev->addr_len);
+	memcpy(dev->dev_addr, port_dev->dev_addr, port_dev->addr_len);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+}
+
+static int team_dev_type_check_change(struct net_device *dev,
+				      struct net_device *port_dev)
+{
+	struct team *team = netdev_priv(dev);
+	char *portname = port_dev->name;
+	int err;
+
+	if (dev->type == port_dev->type)
+		return 0;
+	if (!list_empty(&team->port_list)) {
+		netdev_err(dev, "Device %s is of different type\n", portname);
+		return -EBUSY;
+	}
+	err = call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE, dev);
+	err = notifier_to_errno(err);
+	if (err) {
+		netdev_err(dev, "Refused to change device type\n");
+		return err;
+	}
+	dev_uc_flush(dev);
+	dev_mc_flush(dev);
+	team_setup_by_port(dev, port_dev);
+	call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev);
+	return 0;
+}
+
 static void team_setup(struct net_device *dev)
 {
 	ether_setup(dev);
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index c96e4d2..9db0171 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -48,18 +48,18 @@ static bool bc_transmit(struct team *team, struct sk_buff *skb)
 
 static int bc_port_enter(struct team *team, struct team_port *port)
 {
-	return team_port_set_team_mac(port);
+	return team_port_set_team_dev_addr(port);
 }
 
-static void bc_port_change_mac(struct team *team, struct team_port *port)
+static void bc_port_change_dev_addr(struct team *team, struct team_port *port)
 {
-	team_port_set_team_mac(port);
+	team_port_set_team_dev_addr(port);
 }
 
 static const struct team_mode_ops bc_mode_ops = {
 	.transmit		= bc_transmit,
 	.port_enter		= bc_port_enter,
-	.port_change_mac	= bc_port_change_mac,
+	.port_change_dev_addr	= bc_port_change_dev_addr,
 };
 
 static const struct team_mode bc_mode = {
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index ad7ed0e..105135a 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -66,18 +66,18 @@ drop:
 
 static int rr_port_enter(struct team *team, struct team_port *port)
 {
-	return team_port_set_team_mac(port);
+	return team_port_set_team_dev_addr(port);
 }
 
-static void rr_port_change_mac(struct team *team, struct team_port *port)
+static void rr_port_change_dev_addr(struct team *team, struct team_port *port)
 {
-	team_port_set_team_mac(port);
+	team_port_set_team_dev_addr(port);
 }
 
 static const struct team_mode_ops rr_mode_ops = {
 	.transmit		= rr_transmit,
 	.port_enter		= rr_port_enter,
-	.port_change_mac	= rr_port_change_mac,
+	.port_change_dev_addr	= rr_port_change_dev_addr,
 };
 
 static const struct team_mode rr_mode = {
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 33fcc20..8b000b2 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -123,7 +123,7 @@ struct team_mode_ops {
 	bool (*transmit)(struct team *team, struct sk_buff *skb);
 	int (*port_enter)(struct team *team, struct team_port *port);
 	void (*port_leave)(struct team *team, struct team_port *port);
-	void (*port_change_mac)(struct team *team, struct team_port *port);
+	void (*port_change_dev_addr)(struct team *team, struct team_port *port);
 	void (*port_enabled)(struct team *team, struct team_port *port);
 	void (*port_disabled)(struct team *team, struct team_port *port);
 };
@@ -238,7 +238,7 @@ static inline struct team_port *team_get_port_by_index_rcu(struct team *team,
 	return NULL;
 }
 
-extern int team_port_set_team_mac(struct team_port *port);
+extern int team_port_set_team_dev_addr(struct team_port *port);
 extern int team_options_register(struct team *team,
 				 const struct team_option *option,
 				 size_t option_count);
-- 
1.7.10.4
