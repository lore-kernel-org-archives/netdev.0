From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 4/5] bridge: let HW control FDB ageing by setting NTF_EXT_AGED
Date: Thu, 19 Feb 2015 23:09:54 -0800
Message-ID: <1424416195-19098-5-git-send-email-sfeldma@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39752 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbbBTHJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:34 -0500
Received: by pablf10 with SMTP id lf10so5960435pab.6
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:32 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

During bridge's ageing function, exclude FDB entries marked with NTF_EXT_AGED.
The external driver/device which set NTF_EXT_AGED flag will age out these
entries.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_fdb.c     |   16 +++++++++++++---
 net/bridge/br_private.h |    8 +++++---
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e0670d7..9311858 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -24,6 +24,7 @@
 #include <linux/atomic.h>
 #include <asm/unaligned.h>
 #include <linux/if_vlan.h>
+#include <net/switchdev.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
@@ -280,7 +281,7 @@ void br_fdb_cleanup(unsigned long _data)
 
 		hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
 			unsigned long this_timer;
-			if (f->is_static)
+			if (f->is_static || f->is_external_aged)
 				continue;
 			this_timer = f->updated + delay;
 			if (time_before_eq(this_timer, jiffies))
@@ -482,6 +483,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		fdb->is_static = 0;
 		fdb->added_by_user = 0;
 		fdb->added_by_external_learn = 0;
+		fdb->is_external_aged = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
@@ -615,6 +617,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm->ndm_pad1    = 0;
 	ndm->ndm_pad2    = 0;
 	ndm->ndm_flags	 = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
+	ndm->ndm_flags	 |= fdb->is_external_aged ? NTF_EXT_AGED : 0;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
 	ndm->ndm_state   = fdb_to_nud(fdb);
@@ -990,10 +993,13 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 }
 
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid)
+			      struct netdev_switch_notifier_fdb_info *fdb_info)
 {
 	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
+	const unsigned char *addr = fdb_info->addr;
+	u16 vid = fdb_info->vid;
+	bool is_external_aged = !!(fdb_info->ntf_flags & NTF_EXT_AGED);
 	int err = 0;
 
 	ASSERT_RTNL();
@@ -1008,6 +1014,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 			goto err_unlock;
 		}
 		fdb->added_by_external_learn = 1;
+		fdb->is_external_aged = is_external_aged;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	} else if (fdb->added_by_external_learn) {
 		/* Refresh entry */
@@ -1015,6 +1022,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 	} else if (!fdb->added_by_user) {
 		/* Take over SW learned entry */
 		fdb->added_by_external_learn = 1;
+		fdb->is_external_aged = is_external_aged;
 		fdb->updated = jiffies;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	}
@@ -1026,10 +1034,12 @@ err_unlock:
 }
 
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid)
+			      struct netdev_switch_notifier_fdb_info *fdb_info)
 {
 	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
+	const unsigned char *addr = fdb_info->addr;
+	u16 vid = fdb_info->vid;
 	int err = 0;
 
 	ASSERT_RTNL();
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..8fb822e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <net/switchdev.h>
 #include <linux/if_vlan.h>
 
 #define BR_HASH_BITS 8
@@ -101,7 +102,8 @@ struct net_bridge_fdb_entry
 	unsigned char			is_local:1,
 					is_static:1,
 					added_by_user:1,
-					added_by_external_learn:1;
+					added_by_external_learn:1,
+					is_external_aged:1;
 	__u16				vlan_id;
 };
 
@@ -403,9 +405,9 @@ int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid);
+			      struct netdev_switch_notifier_fdb_info *fdb_info);
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
-			      const unsigned char *addr, u16 vid);
+			      struct netdev_switch_notifier_fdb_info *fdb_info);
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-- 
1.7.10.4
