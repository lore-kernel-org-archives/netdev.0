From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 01/10] net/core: Add support for configuring VF GUIDs
Date: Tue,  1 Mar 2016 18:52:14 +0200
Message-ID: <1456851143-138332-2-git-send-email-eli@mellanox.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456851143-138332-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add two new NLAs to support configuration of Infiniband node or port
GUIDs. New applications can choose to use this interface to configure
GUIDs with iproute2 with commands such as:

ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78

For backwards compatibility, old applications which set the MAC of a VF
may set the VF's port GUID for an infiniband port also via set MAC. The
GUID will be generated from the 6-byte MAC per IETF RFC 7042. Note that
when using set MAC to set a port GUID, the node GUID is set as well (to
the port guid value).

A new ndo, ndo_sef_vf_guid is introduced to notify the net device of the
request to change the GUID.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 include/linux/netdevice.h    |  3 ++
 include/uapi/linux/if_link.h |  7 ++++
 net/core/rtnetlink.c         | 79 ++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 83 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5440b7b705eb..7b4ae218b90b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1147,6 +1147,9 @@ struct net_device_ops {
 						   struct nlattr *port[]);
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
+	int			(*ndo_set_vf_guid)(struct net_device *dev,
+						   int vf, u64 guid,
+						   int guid_type);
 	int			(*ndo_set_vf_rss_query_en)(
 						   struct net_device *dev,
 						   int vf, bool setting);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a30b78090594..1d01e8a4e5dd 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -556,6 +556,8 @@ enum {
 				 */
 	IFLA_VF_STATS,		/* network device statistics */
 	IFLA_VF_TRUST,		/* Trust VF */
+	IFLA_VF_IB_NODE_GUID,	/* VF Infiniband node GUID */
+	IFLA_VF_IB_PORT_GUID,	/* VF Infiniband port GUID */
 	__IFLA_VF_MAX,
 };
 
@@ -588,6 +590,11 @@ struct ifla_vf_spoofchk {
 	__u32 setting;
 };
 
+struct ifla_vf_guid {
+	__u32 vf;
+	__u64 guid;
+};
+
 enum {
 	IFLA_VF_LINK_STATE_AUTO,	/* link state of the uplink */
 	IFLA_VF_LINK_STATE_ENABLE,	/* link always up */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d735e854f916..9db6e5bde786 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1387,6 +1387,8 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_RSS_QUERY_EN]	= { .len = sizeof(struct ifla_vf_rss_query_en) },
 	[IFLA_VF_STATS]		= { .type = NLA_NESTED },
 	[IFLA_VF_TRUST]		= { .len = sizeof(struct ifla_vf_trust) },
+	[IFLA_VF_IB_NODE_GUID]	= { .len = sizeof(struct ifla_vf_guid) },
+	[IFLA_VF_IB_PORT_GUID]	= { .len = sizeof(struct ifla_vf_guid) },
 };
 
 static const struct nla_policy ifla_vf_stats_policy[IFLA_VF_STATS_MAX + 1] = {
@@ -1534,6 +1536,58 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 	return 0;
 }
 
+static int handle_infiniband_guid(struct net_device *dev, struct ifla_vf_guid *ivt,
+				  int guid_type)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	return ops->ndo_set_vf_guid(dev, ivt->vf, ivt->guid, guid_type);
+}
+
+static int handle_vf_guid(struct net_device *dev, struct ifla_vf_guid *ivt, int guid_type)
+{
+	if (dev->type != ARPHRD_INFINIBAND)
+		return -EOPNOTSUPP;
+
+	return handle_infiniband_guid(dev, ivt, guid_type);
+}
+
+static int handle_vf_mac(struct net_device *dev, struct ifla_vf_mac *ivm)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct ifla_vf_guid ivt;
+	u8 *s = ivm->mac;
+	u8 d[8];
+	int err;
+
+	if (dev->type != ARPHRD_INFINIBAND) {
+		if (!ops->ndo_set_vf_mac)
+			return -EOPNOTSUPP;
+
+		return ops->ndo_set_vf_mac(dev, ivm->vf, ivm->mac);
+	}
+
+	if (!ops->ndo_set_vf_guid)
+		return -EOPNOTSUPP;
+
+	d[0] = s[0];
+	d[1] = s[1];
+	d[2] = s[2];
+	d[3] = 0xff;
+	d[4] = 0xfe;
+	d[5] = s[3];
+	d[6] = s[4];
+	d[7] = s[5];
+
+	ivt.vf = ivm->vf;
+	ivt.guid = be64_to_cpu(*(__be64 *)d);
+	err = handle_infiniband_guid(dev, &ivt, IFLA_VF_IB_NODE_GUID);
+	if (err)
+		return err;
+
+	return handle_infiniband_guid(dev, &ivt, IFLA_VF_IB_PORT_GUID);
+}
+
 static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
@@ -1542,12 +1596,7 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 	if (tb[IFLA_VF_MAC]) {
 		struct ifla_vf_mac *ivm = nla_data(tb[IFLA_VF_MAC]);
 
-		err = -EOPNOTSUPP;
-		if (ops->ndo_set_vf_mac)
-			err = ops->ndo_set_vf_mac(dev, ivm->vf,
-						  ivm->mac);
-		if (err < 0)
-			return err;
+		return handle_vf_mac(dev, ivm);
 	}
 
 	if (tb[IFLA_VF_VLAN]) {
@@ -1636,6 +1685,24 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 			return err;
 	}
 
+	if (tb[IFLA_VF_IB_NODE_GUID]) {
+		struct ifla_vf_guid *ivt = nla_data(tb[IFLA_VF_IB_NODE_GUID]);
+
+		if (!ops->ndo_set_vf_guid)
+			return -EOPNOTSUPP;
+
+		return handle_vf_guid(dev, ivt, IFLA_VF_IB_NODE_GUID);
+	}
+
+	if (tb[IFLA_VF_IB_PORT_GUID]) {
+		struct ifla_vf_guid *ivt = nla_data(tb[IFLA_VF_IB_PORT_GUID]);
+
+		if (!ops->ndo_set_vf_guid)
+			return -EOPNOTSUPP;
+
+		return handle_vf_guid(dev, ivt, IFLA_VF_IB_PORT_GUID);
+	}
+
 	return err;
 }
 
-- 
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
