From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next] bridge: Add netlink support for
	vlan_protocol attribute
Date: Thu, 27 Aug 2015 15:32:26 +0900
Message-ID: <1440657146-23437-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

This enables bridge vlan_protocol to be configured through netlink.

When CONFIG_BRIDGE_VLAN_FILTERING is disabled, kernel behaves the
same way as this feature is not implemented.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
v2: Fix u16 to __be16

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 34 ++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h      |  1 +
 net/bridge/br_vlan.c         | 35 +++++++++++++++++++++--------------
 4 files changed, 57 insertions(+), 14 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 313c305..2d13dd4 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -231,6 +231,7 @@ enum {
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
 	IFLA_BR_VLAN_FILTERING,
+	IFLA_BR_VLAN_PROTOCOL,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dbcb194..9cea3cf 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -673,6 +673,21 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EADDRNOTAVAIL;
 	}
 
+	if (!data)
+		return 0;
+
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	if (data[IFLA_BR_VLAN_PROTOCOL]) {
+		switch (nla_get_be16(data[IFLA_BR_VLAN_PROTOCOL])) {
+		case htons(ETH_P_8021Q):
+		case htons(ETH_P_8021AD):
+			break;
+		default:
+			return -EPROTONOSUPPORT;
+		}
+	}
+#endif
+
 	return 0;
 }
 
@@ -729,6 +744,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_STP_STATE] = { .type = NLA_U32 },
 	[IFLA_BR_PRIORITY] = { .type = NLA_U16 },
 	[IFLA_BR_VLAN_FILTERING] = { .type = NLA_U8 },
+	[IFLA_BR_VLAN_PROTOCOL] = { .type = NLA_U16 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -784,6 +800,16 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 			return err;
 	}
 
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	if (data[IFLA_BR_VLAN_PROTOCOL]) {
+		__be16 vlan_proto = nla_get_be16(data[IFLA_BR_VLAN_PROTOCOL]);
+
+		err = __br_vlan_set_proto(br, vlan_proto);
+		if (err)
+			return err;
+	}
+#endif
+
 	return 0;
 }
 
@@ -796,6 +822,9 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_STP_STATE */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_PRIORITY */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_FILTERING */
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	       nla_total_size(sizeof(__be16)) +	/* IFLA_BR_VLAN_PROTOCOL */
+#endif
 	       0;
 }
 
@@ -819,6 +848,11 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled))
 		return -EMSGSIZE;
 
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	if (nla_put_be16(skb, IFLA_BR_VLAN_PROTOCOL, br->vlan_proto))
+		return -EMSGSIZE;
+#endif
+
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3d95647..19e8f79 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -616,6 +616,7 @@ bool br_vlan_find(struct net_bridge *br, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
 int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+int __br_vlan_set_proto(struct net_bridge *br, __be16 proto);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 int br_vlan_init(struct net_bridge *br);
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 3cef689..3cd8cc9 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -492,23 +492,16 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 	return 0;
 }
 
-int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
+int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 {
 	int err = 0;
 	struct net_bridge_port *p;
 	struct net_port_vlans *pv;
-	__be16 proto, oldproto;
+	__be16 oldproto;
 	u16 vid, errvid;
 
-	if (val != ETH_P_8021Q && val != ETH_P_8021AD)
-		return -EPROTONOSUPPORT;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	proto = htons(val);
 	if (br->vlan_proto == proto)
-		goto unlock;
+		return 0;
 
 	/* Add VLANs for the new proto to the device filter. */
 	list_for_each_entry(p, &br->port_list, list) {
@@ -539,9 +532,7 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 			vlan_vid_del(p->dev, oldproto, vid);
 	}
 
-unlock:
-	rtnl_unlock();
-	return err;
+	return 0;
 
 err_filt:
 	errvid = vid;
@@ -557,7 +548,23 @@ err_filt:
 			vlan_vid_del(p->dev, proto, vid);
 	}
 
-	goto unlock;
+	return err;
+}
+
+int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
+{
+	int err;
+
+	if (val != ETH_P_8021Q && val != ETH_P_8021AD)
+		return -EPROTONOSUPPORT;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	err = __br_vlan_set_proto(br, htons(val));
+	rtnl_unlock();
+
+	return err;
 }
 
 static bool vlan_default_pvid(struct net_port_vlans *pv, u16 vid)
-- 
1.8.1.2
