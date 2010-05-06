From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V5 PATCH 1/3] Add netdev/netlink port-profile support
	(was iovnl)
Date: Wed, 05 May 2010 21:42:06 -0700
Message-ID: <20100506044206.29677.58436.stgit@savbu-pc100.cisco.com>
References: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:12701 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab0EFEmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 00:42:06 -0400
In-Reply-To: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add new netdev ops ndo_{set|get}_vf_port_profile to allow setting of
port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
RTM_GETLINK with new sub cmd called IFLA_VF_PORT_PROFILE (added to end of
IFLA_cmd list).

A port-profile is used to configure/enable the external switch port backing
the netdev interface, not to configure the host-facing side of the netdev.  A
port-profile is an identifier known to the switch.  How port-profiles are
installed on the switch or how available port-profiles are made know to the
host is outside the scope of this patch.

The general flow is the port-profile is applied to a host netdev interface
using RTM_SETLINK, the receiver of the RTM_SETLINK msg (more about that later)
communicates with the switch, and the switch port backing the host netdev
interface is configured/enabled based on the settings defined by the port-
profile.  What those settings comprise, and how those settings are managed is
again outside the scope of this patch, since this patch only deals with the
first step in the flow.

Since we're using netlink sockets, the receiver of the RTM_SETLINK msg can
be in kernel- or user-space.  For kernel-space recipient, rtnetlink.c, the
new ndo_set_vf_port_profile netdev op is called to set the port-profile.
User-space recipients can decide how they comminucate the IFLA_VF_PORT_PROFILE
to the external switch.

There is a RTM_GETLINK cmd to to return port-profile setting of an
interface and to also return the status of the last port-profile.

IFLA_VF_PORT_PROFILE is modeled after the existing IFLA_VF_* cmd where a
VF number is passed in to identify the virtual function (VF) of an SR-IOV-
capable device.  In this case, the target of IFLA_VF_PORT_PROFILE msg is the
netdev physical function (PF) device.  The PF will apply the port-profile
to the VF.  IFLA_VF_PORT_PROFILE can also be used for devices that don't
adhere to SR-IOV and can apply the port-profile directly to the netdev
target.  In this case, the VF number is ignored.

Passing in a NULL port-profile is used to delete the port-profile association.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/if_link.h   |   25 +++++++++++++++++++++++++
 include/linux/netdevice.h |   10 ++++++++++
 net/core/rtnetlink.c      |   39 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 73 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index cfd420b..d763358 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,7 @@ enum {
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
 	IFLA_STATS64,
+	IFLA_VF_PORT_PROFILE,
 	__IFLA_MAX
 };
 
@@ -259,4 +260,28 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 };
+
+enum {
+	IFLA_VF_PORT_PROFILE_STATUS_UNKNOWN,
+	IFLA_VF_PORT_PROFILE_STATUS_SUCCESS,
+	IFLA_VF_PORT_PROFILE_STATUS_INPROGRESS,
+	IFLA_VF_PORT_PROFILE_STATUS_ERROR,
+};
+
+#define IFLA_VF_PORT_PROFILE_MAX	40
+#define IFLA_VF_UUID_MAX		40
+#define IFLA_VF_CLIENT_NAME_MAX		40
+
+struct ifla_vf_port_profile {
+	__u32 vf;
+	__u32 flags;
+	__u32 status;
+	__u8 port_profile[IFLA_VF_PORT_PROFILE_MAX];
+	__u8 mac[32];					/* MAX_ADDR_LEN */
+	/* UUID e.g. "CEEFD3B1-9E11-11DE-BDFD-000BAB01C0FB" */
+	__u8 host_uuid[IFLA_VF_UUID_MAX];
+	__u8 client_uuid[IFLA_VF_UUID_MAX];
+	__u8 client_name[IFLA_VF_CLIENT_NAME_MAX];	/* e.g. "vm0-eth1" */
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..949abdb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -696,6 +696,10 @@ struct netdev_rx_queue {
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ * int (*ndo_set_vf_port_profile)(struct net_device *dev, int vf,
+ *				  struct ifla_vf_port_profile *ivp);
+ * int (*ndo_get_vf_port_profile)(struct net_device *dev, int vf,
+ *				  struct ifla_vf_port_profile *ivp);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -744,6 +748,12 @@ struct net_device_ops {
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
+	int			(*ndo_set_vf_port_profile)(
+					struct net_device *dev, int vf,
+					struct ifla_vf_port_profile *ivp);
+	int			(*ndo_get_vf_port_profile)(
+					struct net_device *dev, int vf,
+					struct ifla_vf_port_profile *ivp);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 78c8598..e427a70 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -747,17 +747,40 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
+	if (dev->dev.parent)
+		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
 		int i;
 		struct ifla_vf_info ivi;
 
-		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
 		for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
 			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);
 		}
 	}
+
+	if (dev->netdev_ops->ndo_get_vf_port_profile && dev->dev.parent) {
+		struct ifla_vf_port_profile ivp;
+
+		if (dev_num_vf(dev->dev.parent)) {
+			int i;
+
+			for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
+				if (dev->netdev_ops->ndo_get_vf_port_profile(
+					dev, i, &ivp))
+					break;
+				NLA_PUT(skb, IFLA_VF_PORT_PROFILE,
+					sizeof(ivp), &ivp);
+			}
+		} else if (!dev->netdev_ops->ndo_get_vf_port_profile(dev,
+			0, &ivp)) {
+			NLA_PUT(skb, IFLA_VF_PORT_PROFILE,
+				sizeof(ivp), &ivp);
+		}
+	}
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -824,6 +847,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_VF_PORT_PROFILE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_port_profile)},
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1028,6 +1053,18 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_VF_PORT_PROFILE]) {
+		struct ifla_vf_port_profile *ivp;
+		ivp = nla_data(tb[IFLA_VF_PORT_PROFILE]);
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_port_profile)
+			err = ops->ndo_set_vf_port_profile(dev, ivp->vf, ivp);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

