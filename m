From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 06/33] net: set name assign type for names passed directly from userspace
Date: Thu, 10 Jul 2014 10:17:11 +0200
Message-ID: <1404980258-30853-7-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:61286 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaGJISO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:14 -0400
Received: by mail-lb0-f170.google.com with SMTP id 10so5889980lbg.29
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:12 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Such names should be NET_NAME_USER, in case the emptystring is given we
fallback to an enumerated name.

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/net/bonding/bond_main.c |  3 ++-
 drivers/net/tun.c               |  9 ++++++---
 drivers/tty/n_gsm.c             | 10 +++++++---
 net/atm/br2684.c                |  5 +++--
 net/bluetooth/bnep/core.c       |  2 +-
 net/bridge/br_if.c              |  7 ++++---
 net/bridge/br_ioctl.c           |  4 ++--
 net/bridge/br_private.h         |  2 +-
 net/ipv4/ip_tunnel.c            |  9 ++++++---
 net/ipv6/ip6_gre.c              | 10 +++++++---
 net/ipv6/ip6_tunnel.c           | 10 +++++++---
 net/ipv6/ip6_vti.c              | 10 +++++++---
 net/ipv6/sit.c                  | 10 +++++++---
 net/l2tp/l2tp_eth.c             |  8 ++++++--
 14 files changed, 66 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a2678fe..48e28ca 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4440,7 +4440,8 @@ int bond_create(struct net *net, const char *name)
 	rtnl_lock();
 
 	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
-				   name ? name : "bond%d", NET_NAME_UNKNOWN,
+				   name ? name : "bond%d",
+				   name ? NET_NAME_USER : NET_NAME_ENUM,
 				   bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index acaaf67..eac34f5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1607,6 +1607,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	}
 	else {
 		char *name;
+		unsigned char name_assign_type = NET_NAME_ENUM;
 		unsigned long flags = 0;
 		int queues = ifr->ifr_flags & IFF_MULTI_QUEUE ?
 			     MAX_TAP_QUEUES : 1;
@@ -1629,12 +1630,14 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		} else
 			return -EINVAL;
 
-		if (*ifr->ifr_name)
+		if (*ifr->ifr_name) {
 			name = ifr->ifr_name;
+			name_assign_type = NET_NAME_USER;
+		}
 
 		dev = alloc_netdev_mqs(sizeof(struct tun_struct), name,
-				       NET_NAME_UNKNOWN, tun_setup, queues,
-				       queues);
+				       name_assign_type, tun_setup,
+				       queues, queues);
 
 		if (!dev)
 			return -ENOMEM;
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index cde3ab9..d0262d9 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -2767,6 +2767,7 @@ static void gsm_destroy_network(struct gsm_dlci *dlci)
 static int gsm_create_network(struct gsm_dlci *dlci, struct gsm_netconfig *nc)
 {
 	char *netname;
+	unsigned char name_assign_type = NET_NAME_ENUM;
 	int retval = 0;
 	struct net_device *net;
 	struct gsm_mux_net *mux_net;
@@ -2787,10 +2788,13 @@ static int gsm_create_network(struct gsm_dlci *dlci, struct gsm_netconfig *nc)
 	pr_debug("create network interface");
 
 	netname = "gsm%d";
-	if (nc->if_name[0] != '\0')
+	if (nc->if_name[0] != '\0') {
 		netname = nc->if_name;
-	net = alloc_netdev(sizeof(struct gsm_mux_net), netname,
-			   NET_NAME_UNKNOWN, gsm_mux_net_init);
+		name_assign_type = NET_NAME_USER;
+	}
+	net = alloc_netdev(sizeof(struct gsm_mux_net),
+			netname, name_assign_type,
+			gsm_mux_net_init);
 	if (!net) {
 		pr_err("alloc_netdev failed");
 		return -ENOMEM;
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index cc78538..cb8d122 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -682,8 +682,9 @@ static int br2684_create(void __user *arg)
 
 	netdev = alloc_netdev(sizeof(struct br2684_dev),
 			      ni.ifname[0] ? ni.ifname : "nas%d",
-			      NET_NAME_UNKNOWN,
-			      (payload == p_routed) ? br2684_setup_routed : br2684_setup);
+			      ni.ifname[0] ? NET_NAME_USER : NET_NAME_ENUM,
+			      (payload == p_routed) ?
+			      br2684_setup_routed : br2684_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 85bcc21..6bed7b3 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -539,7 +539,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 	/* session struct allocated as private part of net_device */
 	dev = alloc_netdev(sizeof(struct bnep_session),
 			   (*req->device) ? req->device : "bnep%d",
-			   NET_NAME_UNKNOWN,
+			   (*req->device) ? NET_NAME_USER : NET_NAME_ENUM,
 			   bnep_net_setup);
 	if (!dev)
 		return -ENOMEM;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 078d336..f9c6766 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -339,13 +339,14 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	return p;
 }
 
-int br_add_bridge(struct net *net, const char *name)
+int br_add_bridge(struct net *net, const char *name,
+		  unsigned char name_assign_type)
 {
 	struct net_device *dev;
 	int res;
 
-	dev = alloc_netdev(sizeof(struct net_bridge), name, NET_NAME_UNKNOWN,
-			   br_dev_setup);
+	dev = alloc_netdev(sizeof(struct net_bridge), name,
+			   name_assign_type, br_dev_setup);
 
 	if (!dev)
 		return -ENOMEM;
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index a9a4a1b..bdc79a1 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -340,7 +340,7 @@ static int old_deviceless(struct net *net, void __user *uarg)
 		buf[IFNAMSIZ-1] = 0;
 
 		if (args[0] == BRCTL_ADD_BRIDGE)
-			return br_add_bridge(net, buf);
+			return br_add_bridge(net, buf, NET_NAME_USER);
 
 		return br_del_bridge(net, buf);
 	}
@@ -369,7 +369,7 @@ int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uar
 
 		buf[IFNAMSIZ-1] = 0;
 		if (cmd == SIOCBRADDBR)
-			return br_add_bridge(net, buf);
+			return br_add_bridge(net, buf, NET_NAME_USER);
 
 		return br_del_bridge(net, buf);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 23caf5b..1fc6196 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -415,7 +415,7 @@ void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 
 /* br_if.c */
 void br_port_carrier_check(struct net_bridge_port *p);
-int br_add_bridge(struct net *net, const char *name);
+int br_add_bridge(struct net *net, const char *name, unsigned char name_assign_type);
 int br_del_bridge(struct net *net, const char *name);
 int br_add_if(struct net_bridge *br, struct net_device *dev);
 int br_del_if(struct net_bridge *br, struct net_device *dev);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0157a7a..cb6248b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -288,20 +288,23 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	struct ip_tunnel *tunnel;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	unsigned char name_assign_type;
 
-	if (parms->name[0])
+	if (parms->name[0]) {
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else {
+		name_assign_type = NET_NAME_USER;
+	} else {
 		if (strlen(ops->kind) > (IFNAMSIZ - 3)) {
 			err = -E2BIG;
 			goto failed;
 		}
 		strlcpy(name, ops->kind, IFNAMSIZ);
 		strncat(name, "%d", 2);
+		name_assign_type = NET_NAME_ENUM;
 	}
 
 	ASSERT_RTNL();
-	dev = alloc_netdev(ops->priv_size, name, NET_NAME_UNKNOWN, ops->setup);
+	dev = alloc_netdev(ops->priv_size, name, name_assign_type, ops->setup);
 	if (!dev) {
 		err = -ENOMEM;
 		goto failed;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 780e6fe..2a25b68 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -311,18 +311,22 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	struct ip6_tnl *t, *nt;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	unsigned char name_assign_type;
 	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
 
 	t = ip6gre_tunnel_find(net, parms, ARPHRD_IP6GRE);
 	if (t || !create)
 		return t;
 
-	if (parms->name[0])
+	if (parms->name[0]) {
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		strcpy(name, "ip6gre%d");
+		name_assign_type = NET_NAME_ENUM;
+	}
 
-	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*t), name, name_assign_type,
 			   ip6gre_tunnel_setup);
 	if (!dev)
 		return NULL;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cbba655..10d35c4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -308,14 +308,18 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 	struct net_device *dev;
 	struct ip6_tnl *t;
 	char name[IFNAMSIZ];
+	unsigned char name_assign_type;
 	int err;
 
-	if (p->name[0])
+	if (p->name[0]) {
 		strlcpy(name, p->name, IFNAMSIZ);
-	else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		sprintf(name, "ip6tnl%%d");
+		name_assign_type = NET_NAME_ENUM;
+	}
 
-	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof (*t), name, name_assign_type,
 			   ip6_tnl_dev_setup);
 	if (dev == NULL)
 		goto failed;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 67fd4e5..337a32e 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -197,14 +197,18 @@ static struct ip6_tnl *vti6_tnl_create(struct net *net, struct __ip6_tnl_parm *p
 	struct net_device *dev;
 	struct ip6_tnl *t;
 	char name[IFNAMSIZ];
+	char name_assign_type;
 	int err;
 
-	if (p->name[0])
+	if (p->name[0]) {
 		strlcpy(name, p->name, IFNAMSIZ);
-	else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		sprintf(name, "ip6_vti%%d");
+		name_assign_type = NET_NAME_ENUM;
+	}
 
-	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN, vti6_dev_setup);
+	dev = alloc_netdev(sizeof(*t), name, name_assign_type, vti6_dev_setup);
 	if (dev == NULL)
 		goto failed;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ff5aff8..5699516 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -228,6 +228,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	struct ip_tunnel __rcu **tp;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	unsigned char name_assign_type;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	for (tp = __ipip6_bucket(sitn, parms);
@@ -245,12 +246,15 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	if (!create)
 		goto failed;
 
-	if (parms->name[0])
+	if (parms->name[0]) {
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		strcpy(name, "sit%d");
+		name_assign_type = NET_NAME_ENUM;
+	}
 
-	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*t), name, name_assign_type,
 			   ipip6_tunnel_setup);
 	if (dev == NULL)
 		return NULL;
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index edb78e6..7416b6b 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -209,6 +209,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 {
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	unsigned char name_assign_type;
 	struct l2tp_tunnel *tunnel;
 	struct l2tp_session *session;
 	struct l2tp_eth *priv;
@@ -236,8 +237,11 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 			goto out;
 		}
 		strlcpy(name, cfg->ifname, IFNAMSIZ);
-	} else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		strcpy(name, L2TP_ETH_DEV_NAME);
+		name_assign_type = NET_NAME_ENUM;
+	}
 
 	session = l2tp_session_create(sizeof(*spriv), tunnel, session_id,
 				      peer_session_id, cfg);
@@ -246,7 +250,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 		goto out;
 	}
 
-	dev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*priv), name, name_assign_type,
 			   l2tp_eth_dev_setup);
 	if (!dev) {
 		rc = -ENOMEM;
-- 
1.9.3
