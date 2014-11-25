From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/17] bridge: add API to notify bridge driver of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 11:28:40 +0100
Message-ID: <1416911328-10979-10-git-send-email-jiri@resnulli.us>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:55658 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbaKYK3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 05:29:04 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so11620427wiv.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 02:29:03 -0800 (PST)
In-Reply-To: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

When the swdev device learns a new mac/vlan on a port, it sends some async
notification to the driver and the driver installs an FDB in the device.
To give a holistic system view, the learned mac/vlan should be reflected
in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
what is currently learned by the device.  This API on the bridge driver gives
a way for the swdev driver to install an FBD entry in the bridge FBD table.
(And remove one).

This is equivalent to the device running these cmds:

  bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master

This patch needs some extra eyeballs for review, in paricular around the
locking and contexts.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v2->v3:
-added "external" word into function names to emphasize fdbs are learned
 externally
-added "added_by_external_learn" to fbd entry struct indicate the entry
 was learned externaly and build some logic around that
-expose the fact that fdb entry was learned externally to userspace
v1->v2:
-no change
---
 include/linux/if_bridge.h      | 18 +++++++++
 include/uapi/linux/neighbour.h |  1 +
 net/bridge/br_fdb.c            | 91 +++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_private.h        |  1 +
 4 files changed, 110 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 808dcb8..fa2eca6 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -37,6 +37,24 @@ extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __use
 typedef int br_should_route_hook_t(struct sk_buff *skb);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
 
+#if IS_ENABLED(CONFIG_BRIDGE)
+int br_fdb_external_learn_add(struct net_device *dev,
+			      const unsigned char *addr, u16 vid);
+int br_fdb_external_learn_del(struct net_device *dev,
+			      const unsigned char *addr, u16 vid);
+#else
+static inline int br_fdb_external_learn_add(struct net_device *dev,
+					    const unsigned char *addr, u16 vid)
+{
+	return 0;
+}
+static inline int br_fdb_external_learn_del(struct net_device *dev,
+					    const unsigned char *addr, u16 vid)
+{
+	return 0;
+}
+#endif
+
 #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_IGMP_SNOOPING)
 int br_multicast_list_adjacent(struct net_device *dev,
 			       struct list_head *br_ip_list);
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 4a1d7e9..3a9b0df 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -40,6 +40,7 @@ enum {
 
 #define NTF_SELF	0x02
 #define NTF_MASTER	0x04
+#define NTF_EXT_LEARNED	0x10
 
 /*
  *	Neighbor Cache Entry States.
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b1be971..b42e71d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -481,6 +481,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		fdb->is_local = 0;
 		fdb->is_static = 0;
 		fdb->added_by_user = 0;
+		fdb->added_by_external_learn = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
@@ -613,7 +614,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm->ndm_family	 = AF_BRIDGE;
 	ndm->ndm_pad1    = 0;
 	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags	 = 0;
+	ndm->ndm_flags	 = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
 	ndm->ndm_state   = fdb_to_nud(fdb);
@@ -983,3 +984,91 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 		}
 	}
 }
+
+int br_fdb_external_learn_add(struct net_device *dev,
+			      const unsigned char *addr, u16 vid)
+{
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+	struct hlist_head *head;
+	struct net_bridge_fdb_entry *fdb;
+	int err = 0;
+
+	rtnl_lock();
+
+	p = br_port_get_rtnl(dev);
+	if (!p) {
+		pr_info("bridge: %s not a bridge port\n", dev->name);
+		err = -EINVAL;
+		goto err_rtnl_unlock;
+	}
+
+	br = p->br;
+
+	spin_lock(&br->hash_lock);
+
+	head = &br->hash[br_mac_hash(addr, vid)];
+	fdb = fdb_find(head, addr, vid);
+	if (!fdb) {
+		fdb = fdb_create(head, p, addr, vid);
+		if (!fdb) {
+			err = -ENOMEM;
+			goto err_unlock;
+		}
+		fdb->added_by_external_learn = 1;
+		fdb_notify(br, fdb, RTM_NEWNEIGH);
+	} else if (fdb->added_by_external_learn) {
+		/* Refresh entry */
+		fdb->updated = fdb->used = jiffies;
+	} else if (!fdb->added_by_user) {
+		/* Take over SW learned entry */
+		fdb->added_by_external_learn = 1;
+		fdb->updated = jiffies;
+		fdb_notify(br, fdb, RTM_NEWNEIGH);
+	}
+
+err_unlock:
+	spin_unlock(&br->hash_lock);
+err_rtnl_unlock:
+	rtnl_unlock();
+
+	return err;
+}
+EXPORT_SYMBOL(br_fdb_external_learn_add);
+
+int br_fdb_external_learn_del(struct net_device *dev,
+			      const unsigned char *addr, u16 vid)
+{
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+	struct hlist_head *head;
+	struct net_bridge_fdb_entry *fdb;
+	int err = 0;
+
+	rtnl_lock();
+
+	p = br_port_get_rtnl(dev);
+	if (!p) {
+		pr_info("bridge: %s not a bridge port\n", dev->name);
+		err = -EINVAL;
+		goto err_rtnl_unlock;
+	}
+
+	br = p->br;
+
+	spin_lock(&br->hash_lock);
+
+	head = &br->hash[br_mac_hash(addr, vid)];
+	fdb = fdb_find(head, addr, vid);
+	if (fdb && fdb->added_by_external_learn)
+		fdb_delete(br, fdb);
+	else
+		err = -ENOENT;
+
+	spin_unlock(&br->hash_lock);
+err_rtnl_unlock:
+	rtnl_unlock();
+
+	return err;
+}
+EXPORT_SYMBOL(br_fdb_external_learn_del);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4f577c4..02cd63b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -101,6 +101,7 @@ struct net_bridge_fdb_entry
 	unsigned char			is_local;
 	unsigned char			is_static;
 	unsigned char			added_by_user;
+	unsigned char			added_by_external_learn;
 	__u16				vlan_id;
 };
 
-- 
1.9.3
