From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 21/33] net: batman-adv - set name assign type
Date: Thu, 10 Jul 2014 10:17:26 +0200
Message-ID: <1404980258-30853-22-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	b.a.t.m.a.n@lists.open-mesh.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Marek Lindner <mareklindner@neomailbox.ch>
Cc: Simon Wunderlich <sw@simonwunderlich.de>
Cc: Antonio Quartulli <antonio@meshcoding.com>
Cc: b.a.t.m.a.n@lists.open-mesh.org
---
 net/batman-adv/hard-interface.c | 5 +++--
 net/batman-adv/hard-interface.h | 3 ++-
 net/batman-adv/soft-interface.c | 9 ++++++---
 net/batman-adv/soft-interface.h | 2 +-
 net/batman-adv/sysfs.c          | 2 +-
 5 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index fbda6b5..b25241f 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -365,7 +365,8 @@ static int batadv_master_del_slave(struct batadv_hard_iface *slave,
 }
 
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
-				   const char *iface_name)
+				   const char *iface_name,
+				   unsigned char name_assign_type)
 {
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface, *master;
@@ -382,7 +383,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	soft_iface = dev_get_by_name(&init_net, iface_name);
 
 	if (!soft_iface) {
-		soft_iface = batadv_softif_create(iface_name);
+		soft_iface = batadv_softif_create(iface_name, name_assign_type);
 
 		if (!soft_iface) {
 			ret = -ENOMEM;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 1918cd5..45dc1ba 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -44,7 +44,8 @@ bool batadv_is_wifi_iface(int ifindex);
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
-				   const char *iface_name);
+				   const char *iface_name,
+				   unsigned char name_assign_type);
 void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 				     enum batadv_hard_if_cleanup autodel);
 void batadv_hardif_remove_interfaces(void);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d551e63..6de7ae3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -790,7 +790,8 @@ static int batadv_softif_slave_add(struct net_device *dev,
 	if (!hard_iface || hard_iface->soft_iface != NULL)
 		goto out;
 
-	ret = batadv_hardif_enable_interface(hard_iface, dev->name);
+	ret = batadv_hardif_enable_interface(hard_iface, dev->name,
+					     dev->name_assign_type);
 
 out:
 	if (hard_iface)
@@ -889,13 +890,15 @@ static void batadv_softif_init_early(struct net_device *dev)
 	memset(priv, 0, sizeof(*priv));
 }
 
-struct net_device *batadv_softif_create(const char *name)
+struct net_device *batadv_softif_create(const char *name,
+					unsigned char name_assign_type)
 {
 	struct net_device *soft_iface;
 	int ret;
 
 	soft_iface = alloc_netdev(sizeof(struct batadv_priv), name,
-				  NET_NAME_UNKNOWN, batadv_softif_init_early);
+				  name_assign_type,
+				  batadv_softif_init_early);
 	if (!soft_iface)
 		return NULL;
 
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index dbab22f..1ea6f05 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -22,7 +22,7 @@ int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
 void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size, struct batadv_orig_node *orig_node);
-struct net_device *batadv_softif_create(const char *name);
+struct net_device *batadv_softif_create(const char *name, unsigned char name_assign_type);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
 extern struct rtnl_link_ops batadv_link_ops;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index fc47baa..f2295c1 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -797,7 +797,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 		batadv_hardif_disable_interface(hard_iface,
 						BATADV_IF_CLEANUP_AUTO);
 
-	ret = batadv_hardif_enable_interface(hard_iface, buff);
+	ret = batadv_hardif_enable_interface(hard_iface, buff, NET_NAME_USER);
 
 unlock:
 	rtnl_unlock();
-- 
1.9.3
