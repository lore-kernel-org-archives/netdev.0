From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile (was iovnl)
Date: Fri, 23 Apr 2010 17:35:41 -0700
Message-ID: <20100424003540.12745.81403.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:12480 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab0DXAfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 20:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

(This is take #2 on the iovnl patches posted earlier based on feedback from
Chris Wright, Arnd Bergmann, and others.  Thanks guys!)

Add new netdev ops ndo_set_vf_port_profile to allow setting of port-profile
on VF, along the lines of existing nds_set_vf_* ops.  Extends RTM_SETLINK
with new sub cmd called IFLA_VF_PORT_PROFILE (added to end on cmd list).  The
port-profile cmd arguments are (as seen from iproute2 cmdline):

       ip link set DEVICE [ { up | down } ]
                          ...
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ] ] 
                                   [ port_profile [ PORT-PROFILE
                                           [ mac LLADDR ]
                                           [ host_uuid HOST_UUID ]
                                           [ client_uuid CLIENT_UUID ]
                                           [ client_name CLIENT_NAME ] ] ] ]


I took some liberties and s/SR-IOV/IOV in the code comments around the
ndo_set_vf_* cmds as they can apply to both SR-IOV and non-SR-IOV adapters,
as long as there is a PF:VF parent:child relationship.

A port-profile is used to configure/enable the network port backing the VF, not
to configure the host-facing side of the VF.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/if_link.h   |   15 +++++++++++++--
 include/linux/netdevice.h |   11 ++++++++++-
 net/core/rtnetlink.c      |   20 ++++++++++++++++++++
 3 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index cfd420b..2c5cc65 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -110,12 +110,13 @@ enum {
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
-	IFLA_NUM_VF,		/* Number of VFs if device is SR-IOV PF */
+	IFLA_NUM_VF,		/* Number of VFs if device is IOV PF */
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
 	IFLA_STATS64,
+	IFLA_VF_PORT_PROFILE,
 	__IFLA_MAX
 };
 
@@ -234,7 +235,7 @@ enum macvlan_mode {
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 };
 
-/* SR-IOV virtual function managment section */
+/* IOV virtual function managment section */
 
 struct ifla_vf_mac {
 	__u32 vf;
@@ -259,4 +260,14 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 };
+
+struct ifla_vf_port_profile {
+	__u32 vf;
+	__u8 port_profile[64];
+	__u8 mac[32];
+	__u8 host_uuid[64]; /* e.g. "CEEFD3B1-9E11-11DE-BDFD-000BAB01C0FB" */
+	__u8 client_uuid[64];
+	__u8 client_name[64]; /* e.g. "vm0-eth1" */
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..26dd4cb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -690,10 +690,13 @@ struct netdev_rx_queue {
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
  *
- *	SR-IOV management functions.
+ *	IOV management functions.
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_set_vf_port_profile)(struct net_device *dev, int vf,
+ *				  u8 *port_profile, u8 *mac, u8 *host_uuid,
+ *				  u8 *client_uuid, u8 *client_name);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  */
@@ -741,6 +744,12 @@ struct net_device_ops {
 						   int queue, u16 vlan, u8 qos);
 	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
 						      int vf, int rate);
+	int			(*ndo_set_vf_port_profile)(
+					struct net_device *dev, int vf,
+					u8 *port_profile, u8 *mac,
+					u8 *host_uuid,
+					u8 *client_uuid,
+					u8 *client_name);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 78c8598..7268e8e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -824,6 +824,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_VF_PORT_PROFILE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_port_profile)},
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1028,6 +1030,24 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_VF_PORT_PROFILE]) {
+		struct ifla_vf_port_profile *ivp;
+		ivp = nla_data(tb[IFLA_VF_PORT_PROFILE]);
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_port_profile)
+			ivp->port_profile[sizeof(ivp->port_profile)-1] = 0;
+			ivp->host_uuid[sizeof(ivp->host_uuid)-1] = 0;
+			ivp->client_uuid[sizeof(ivp->client_uuid)-1] = 0;
+			ivp->client_name[sizeof(ivp->client_name)-1] = 0;
+			err = ops->ndo_set_vf_port_profile(dev, ivp->vf,
+				ivp->port_profile, ivp->mac, ivp->host_uuid,
+				ivp->client_uuid, ivp->client_name);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

