From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: add client name to port profile
Date: Wed,  1 Oct 2014 03:29:17 +0530
Message-ID: <1412114357-11557-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:49563 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807AbaI3V7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 17:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware has support for sending client name of the port profile to the switch
it's connected to.

This patch adds client name to port profile which is sent to hardware while
associating a port profile to VF.

Since port profile are defined in switch, this patch makes it easier to check
what VM is using a port profile.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c | 6 ++++++
 drivers/net/ethernet/cisco/enic/enic_pp.c   | 5 +++++
 include/uapi/linux/if_link.h                | 1 +
 net/core/rtnetlink.c                        | 2 ++
 5 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 5ba5ad0..0b63227 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -88,6 +88,7 @@ struct enic_rx_coal {
 #define ENIC_SET_NAME			(1 << 2)
 #define ENIC_SET_INSTANCE		(1 << 3)
 #define ENIC_SET_HOST			(1 << 4)
+#define ENIC_SET_VMNAME			(1 << 5)
 
 struct enic_port_profile {
 	u32 set;
@@ -97,6 +98,7 @@ struct enic_port_profile {
 	u8 host_uuid[PORT_UUID_MAX];
 	u8 vf_mac[ETH_ALEN];
 	u8 mac_addr[ETH_ALEN];
+	char vmname[PORT_PROFILE_MAX];
 };
 
 /* enic_rfs_fltr_node - rfs filter node in hash table
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 929bfe7..6c7cd1b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -831,6 +831,12 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
 	}
 
+	if (port[IFLA_PORT_VMNAME]) {
+		pp->set |= ENIC_SET_VMNAME;
+		memcpy(pp->vmname,
+		       nla_data(port[IFLA_PORT_VMNAME]), PORT_PROFILE_MAX);
+	}
+
 	if (vf == PORT_SELF_VF) {
 		/* Special case handling: mac came from IFLA_VF_MAC */
 		if (!is_zero_ether_addr(prev_pp.vf_mac))
diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index e6a8319..c2b620f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -128,6 +128,11 @@ static int enic_set_port_profile(struct enic *enic, int vf)
 			sizeof(uuid_str), uuid_str);
 	}
 
+	if (pp->set & ENIC_SET_VMNAME) {
+		VIC_PROVINFO_ADD_TLV(vp, VIC_GENERIC_PROV_TLV_CLIENT_NAME_STR,
+				     sizeof(pp->vmname), pp->vmname);
+	}
+
 	VIC_PROVINFO_ADD_TLV(vp,
 		VIC_GENERIC_PROV_TLV_OS_TYPE,
 		sizeof(os_type), &os_type);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0bdb77e..6ae0b0b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -512,6 +512,7 @@ enum {
 	IFLA_PORT_HOST_UUID,		/* binary UUID */
 	IFLA_PORT_REQUEST,		/* __u8 */
 	IFLA_PORT_RESPONSE,		/* __u16, output only */
+	IFLA_PORT_VMNAME,		/* vm-name used by port profile */
 	__IFLA_PORT_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..98a864d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1238,6 +1238,8 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 				    .len = PORT_UUID_MAX },
 	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
+	[IFLA_PORT_VMNAME]	= { .type = NLA_STRING,
+				    .len = PORT_PROFILE_MAX},
 };
 
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
-- 
2.1.0
