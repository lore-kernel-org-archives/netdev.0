From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2] bridge: vlan: allow to suppress local
	mac install for all vlans
Date: Tue, 25 Aug 2015 17:34:55 -0700
Message-ID: <1440549295-3979-1-git-send-email-razor@blackwall.org>
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	wkok@cumulusnetworks.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch adds a new knob that, when enabled, allows to suppress the
installation of local fdb entries in newly created vlans. This could
pose a big scalability issue if we have a large number of ports and a
large number of vlans, e.g. in a 48 port device with 2000 vlans these
entries easily go up to 96000.
Note that packets for these macs are still received properly because they
are added in vlan 0 as "own" macs and referenced when fdb lookup by vlan
results in a miss.
Also note that vlan membership of ingress port and the bridge device
as egress are still being correctly enforced.

The default (0/off) is keeping the current behaviour.

Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: Triple checked the timezone

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_input.c        |  7 +++++++
 net/bridge/br_netlink.c      | 14 +++++++++++++-
 net/bridge/br_private.h      | 18 ++++++++++++++++++
 net/bridge/br_sysfs_br.c     | 18 ++++++++++++++++++
 net/bridge/br_vlan.c         | 18 +++++++++++++-----
 6 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 313c305fd1ad..df1c601dd315 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -231,6 +231,7 @@ enum {
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
 	IFLA_BR_VLAN_FILTERING,
+	IFLA_BR_VLAN_IGNORE_LOCAL_FDB,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5dce22d..a2b00849de3c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -186,6 +186,13 @@ int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb)
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
+	} else if (br_vlan_enabled(br) && br_vlan_ignore_local_fdb(br)) {
+		dst = __br_fdb_get(br, dest, 0);
+		if (dst && dst->is_local) {
+			skb2 = skb;
+			/* Do not forward the packet since it's local. */
+			skb = NULL;
+		}
 	}
 
 	if (skb) {
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dbcb1949ea58..07978f7b6245 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -729,6 +729,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_STP_STATE] = { .type = NLA_U32 },
 	[IFLA_BR_PRIORITY] = { .type = NLA_U16 },
 	[IFLA_BR_VLAN_FILTERING] = { .type = NLA_U8 },
+	[IFLA_BR_VLAN_IGNORE_LOCAL_FDB] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -784,6 +785,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 			return err;
 	}
 
+	if (data[IFLA_BR_VLAN_IGNORE_LOCAL_FDB]) {
+		u8 vlan_ignore_local = nla_get_u8(data[IFLA_BR_VLAN_IGNORE_LOCAL_FDB]);
+
+		err = br_vlan_ignore_local_fdb_toggle(br, vlan_ignore_local);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -796,6 +805,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_STP_STATE */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_PRIORITY */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_FILTERING */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_IGNORE_LOCAL_FDB */
 	       0;
 }
 
@@ -809,6 +819,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u32 stp_enabled = br->stp_enabled;
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
 	u8 vlan_enabled = br_vlan_enabled(br);
+	u8 vlan_ignore_local = br_vlan_ignore_local_fdb(br);
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -816,7 +827,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_AGEING_TIME, ageing_time) ||
 	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
-	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled))
+	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
+	    nla_put_u8(skb, IFLA_BR_VLAN_IGNORE_LOCAL_FDB, vlan_ignore_local))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3d95647039d0..2bda472c5a6e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -294,6 +294,7 @@ struct net_bridge
 	u32				auto_cnt;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
+	bool				vlan_ignore_local_fdb;
 	__be16				vlan_proto;
 	u16				default_pvid;
 	struct net_port_vlans __rcu	*vlan_info;
@@ -624,6 +625,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
 bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
 int nbp_vlan_init(struct net_bridge_port *port);
+int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br, unsigned long val);
 
 static inline struct net_port_vlans *br_get_vlan_info(
 						const struct net_bridge *br)
@@ -667,6 +669,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return br->vlan_enabled;
 }
+
+static inline bool br_vlan_ignore_local_fdb(struct net_bridge *br)
+{
+	return br->vlan_ignore_local_fdb;
+}
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
@@ -778,6 +785,17 @@ static inline int __br_vlan_filter_toggle(struct net_bridge *br,
 {
 	return -EOPNOTSUPP;
 }
+
+static inline int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br,
+						  unsigned long val)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline bool br_vlan_ignore_local_fdb(struct net_bridge *br)
+{
+	return false;
+}
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc50fb70..fca352f0943a 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -741,6 +741,23 @@ static ssize_t default_pvid_store(struct device *d,
 	return store_bridge_parm(d, buf, len, br_vlan_set_default_pvid);
 }
 static DEVICE_ATTR_RW(default_pvid);
+
+static ssize_t vlan_ignore_local_fdb_show(struct device *d,
+					  struct device_attribute *attr,
+					  char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%d\n", br->vlan_ignore_local_fdb);
+}
+
+static ssize_t vlan_ignore_local_fdb_store(struct device *d,
+					   struct device_attribute *attr,
+					   const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_vlan_ignore_local_fdb_toggle);
+}
+static DEVICE_ATTR_RW(vlan_ignore_local_fdb);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -788,6 +805,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_vlan_filtering.attr,
 	&dev_attr_vlan_protocol.attr,
 	&dev_attr_default_pvid.attr,
+	&dev_attr_vlan_ignore_local_fdb.attr,
 #endif
 	NULL
 };
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 3cef6892c0bb..f9efa1b07994 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -98,11 +98,12 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 			return err;
 	}
 
-	err = br_fdb_insert(br, p, dev->dev_addr, vid);
-	if (err) {
-		br_err(br, "failed insert local address into bridge "
-		       "forwarding table\n");
-		goto out_filt;
+	if (!br_vlan_ignore_local_fdb(br) || !v->port_idx) {
+		err = br_fdb_insert(br, p, dev->dev_addr, vid);
+		if (err) {
+			br_err(br, "failed insert local address into bridge forwarding table\n");
+			goto out_filt;
+		}
 	}
 
 	set_bit(vid, v->vlan_bitmap);
@@ -492,6 +493,13 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
+int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br, unsigned long val)
+{
+	br->vlan_ignore_local_fdb = val ? true : false;
+
+	return 0;
+}
+
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 {
 	int err = 0;
-- 
2.4.3
