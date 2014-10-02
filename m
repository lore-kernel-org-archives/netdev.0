From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 2/2] enic: add vmname port-profile handler
Date: Fri,  3 Oct 2014 04:11:23 +0530
Message-ID: <1412289683-8278-3-git-send-email-_govind@gmx.com>
References: <1412289683-8278-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:57648 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaJBWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 18:45:49 -0400
In-Reply-To: <1412289683-8278-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to read vmname from port-profile netlink message and
send it to firmware.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c | 6 ++++++
 drivers/net/ethernet/cisco/enic/enic_pp.c   | 5 +++++
 3 files changed, 13 insertions(+)

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
-- 
2.1.0
