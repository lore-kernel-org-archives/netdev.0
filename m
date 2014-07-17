From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 4/9] net: set name_assign_type when setting names via ioctls
Date: Thu, 17 Jul 2014 10:06:05 +0200
Message-ID: <1405584370-30054-5-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the user provides a name, set NET_NAME_USER, otherwise an enumerated
name is used, so set NET_NAME_ENUM.

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/net/tun.c         |  9 ++++++---
 drivers/tty/n_gsm.c       | 10 +++++++---
 net/atm/br2684.c          |  5 +++--
 net/bluetooth/bnep/core.c |  2 +-
 net/bridge/br_if.c        |  7 ++++---
 net/bridge/br_ioctl.c     |  4 ++--
 net/bridge/br_private.h   |  2 +-
 7 files changed, 24 insertions(+), 15 deletions(-)

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
index 62a7fa2..5adc136 100644
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
-- 
1.9.3
