From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH 1/2] Add netdev port-profile support (take III,
	was iovnl)
Date: Tue, 27 Apr 2010 21:42:35 -0700
Message-ID: <20100428044235.8646.61943.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42783 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab0D1Emg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 00:42:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add new netdev ops ndo_{set|get}_port_profile to allow setting of port-profile
on a netdev interface.  Extends RTM_SETLINK/RTM_GETLINK with new sub cmd called
IFLA_PORT_PROFILE (added to end of IFLA_cmd list).  The port-profile cmd
arguments are (as seen from modified iproute2 cmdline):

       ip link set DEVICE [ { up | down } ]
                          [ arp { on | off } ]
                          [ dynamic { on | off } ]
                          [ multicast { on | off } ]
                          ...
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ] ] 
                          [ port_profile [ PORT-PROFILE
                                   [ mac LLADDR ]
                                   [ host_uuid HOST_UUID ]
                                   [ client_uuid CLIENT_UUID ]
                                   [ client_name CLIENT_NAME ] ] ]
       ip link show [ DEVICE ]


A port-profile is used to configure/enable the switch port backing the netdev
interface, not to configure the host-facing side of the netdev.  A port-
profile is an identifier known to the switch.  How port-profiles are installed
on the switch or how available port-profiles is made know to the host is
outside the scope of this patch.

The general flow is the port-profile is applied to a host netdev interface
using RTM_SETLINK, the receiver of the RTM_SETLINK msg (more about that later)
communicates with the switch, and the switch port backing the host netdev
interface is configured/enabled based on the settings defined by the port-
profile.  What those settings comprise, and how those settings are managed is
again outside the scope of this patch, since this patch only deals with the
first step in the flow.

Since we're using netlink sockets, the receiver of the RTM_SETLINK msg can
be in kernel- or user-space.  For kernel-space recipient, rtnetlink.c, the
new ndo_set_port_profile netdev op is called to set the port-profile.
User-space recipients can decide how they propagate the msg to the switch.
There is also a RTM_GETLINK cmd to to return port-profile setting of an
interface and to also return the status of the last port-profile.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/if_link.h   |   26 ++++++++++++++++++++++++++
 include/linux/netdevice.h |   10 ++++++++++
 net/core/rtnetlink.c      |   22 ++++++++++++++++++++++
 3 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index cfd420b..6f02398 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,7 @@ enum {
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
 	IFLA_STATS64,
+	IFLA_PORT_PROFILE,
 	__IFLA_MAX
 };
 
@@ -259,4 +260,29 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 };
+
+/* Port-profile managment section */
+
+#define IFLA_PORT_PROFILE_MAX	40
+#define IFLA_PP_HOST_UUID_MAX	40
+#define IFLA_PP_CLIENT_UUID_MAX	40
+#define IFLA_PP_CLIENT_NAME_MAX	40
+
+enum ifla_port_profile_status {
+	IFLA_PORT_PROFILE_STATUS_UNKNOWN,
+	IFLA_PORT_PROFILE_STATUS_SUCCESS,
+	IFLA_PORT_PROFILE_STATUS_ERROR,
+	IFLA_PORT_PROFILE_STATUS_INPROGRESS,
+};
+
+struct ifla_port_profile {
+	__u8 status;
+	__u8 port_profile[IFLA_PORT_PROFILE_MAX];
+	__u8 mac[32]; /* MAX_ADDR_LEN */
+	__u8 host_uuid[IFLA_PP_HOST_UUID_MAX];
+		/* e.g. "CEEFD3B1-9E11-11DE-BDFD-000BAB01C0FB" */
+	__u8 client_uuid[IFLA_PP_CLIENT_UUID_MAX];
+	__u8 client_name[IFLA_PP_CLIENT_NAME_MAX]; /* e.g. "vm0-eth1" */
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..2962288 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -696,6 +696,12 @@ struct netdev_rx_queue {
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ *
+ *	Port-profile management functions.
+ * int (*ndo_set_port_profile)(struct net_device *dev,
+ *			       struct ifla_port_profile *ipp);
+ * int (*ndo_get_port_profile)(struct net_device *dev,
+ *			       struct ifla_port_profile *ipp);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -744,6 +750,10 @@ struct net_device_ops {
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
+	int			(*ndo_set_port_profile)(struct net_device *dev,
+					struct ifla_port_profile *ipp);
+	int			(*ndo_get_port_profile)(struct net_device *dev,
+					struct ifla_port_profile *ipp);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 78c8598..1d7e9a7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -758,6 +758,14 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);
 		}
 	}
+
+	if (dev->netdev_ops->ndo_get_port_profile) {
+		struct ifla_port_profile ipp;
+
+		if (!dev->netdev_ops->ndo_get_port_profile(dev, &ipp))
+			NLA_PUT(skb, IFLA_PORT_PROFILE, sizeof(ipp), &ipp);
+	}
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -824,6 +832,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_PORT_PROFILE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_port_profile)},
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1028,6 +1038,18 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_PORT_PROFILE]) {
+		struct ifla_port_profile *ipp;
+		ipp = nla_data(tb[IFLA_PORT_PROFILE]);
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_port_profile)
+			err = ops->ndo_set_port_profile(dev, ipp);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

