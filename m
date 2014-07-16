From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v8] net: nl802154 - make add_iface take name assign type
Date: Thu, 17 Jul 2014 00:43:13 +0200
Message-ID: <1405550594-11786-6-git-send-email-teg@jklm.no>
References: <1405550594-11786-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405550594-11786-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Acked-by: Alexander Aring <alex.aring@gmail.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net
---

This patch goes on top of net-next.

 include/net/wpan-phy.h         | 4 +++-
 net/ieee802154/nl-phy.c        | 5 ++++-
 net/mac802154/ieee802154_dev.c | 7 ++++---
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 10ab0fc..bb07a1b 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -58,7 +58,9 @@ struct wpan_phy {
 	int idx;
 
 	struct net_device *(*add_iface)(struct wpan_phy *phy,
-					const char *name, int type);
+					const char *name,
+					unsigned char name_assign_type,
+					int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	int (*set_txpower)(struct wpan_phy *phy, int db);
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 972baf8..5e1a28e 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -174,6 +174,7 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 	struct wpan_phy *phy;
 	const char *name;
 	const char *devname;
+	unsigned char name_assign_type;
 	int rc = -ENOBUFS;
 	struct net_device *dev;
 	int type = __IEEE802154_DEV_INVALID;
@@ -192,8 +193,10 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 		if (devname[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1]
 				!= '\0')
 			return -EINVAL; /* phy name should be null-terminated */
+		name_assign_type = NET_NAME_USER;
 	} else  {
 		devname = "wpan%d";
+		name_assign_type = NET_NAME_ENUM;
 	}
 
 	if (strlen(devname) >= IFNAMSIZ)
@@ -227,7 +230,7 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
-	dev = phy->add_iface(phy, devname, type);
+	dev = phy->add_iface(phy, devname, name_assign_type, type);
 	if (IS_ERR(dev)) {
 		rc = PTR_ERR(dev);
 		goto nla_put_failure;
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index b36b2b9..cee12b2 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -159,7 +159,8 @@ mac802154_del_iface(struct wpan_phy *phy, struct net_device *dev)
 }
 
 static struct net_device *
-mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
+mac802154_add_iface(struct wpan_phy *phy, const char *name,
+		    unsigned char name_assign_type, int type)
 {
 	struct net_device *dev;
 	int err = -ENOMEM;
@@ -167,12 +168,12 @@ mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
 	switch (type) {
 	case IEEE802154_DEV_MONITOR:
 		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
-				   name, NET_NAME_UNKNOWN,
+				   name, name_assign_type,
 				   mac802154_monitor_setup);
 		break;
 	case IEEE802154_DEV_WPAN:
 		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
-				   name, NET_NAME_UNKNOWN,
+				   name, name_assign_type,
 				   mac802154_wpan_setup);
 		break;
 	default:
-- 
1.9.3
