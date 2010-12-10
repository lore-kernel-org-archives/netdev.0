From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Move enic port profile handling code to a
	new 802.1Qbh provisioning info type
Date: Fri, 10 Dec 2010 14:02:33 -0800
Message-ID: <20101210220233.5010.37181.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:11792 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864Ab0LJWCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:02:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>



Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |   33 +++++++++++++++++++++++----------
 drivers/net/enic/vnic_vic.h  |   31 +++++++++++++++++++++++--------
 3 files changed, 47 insertions(+), 19 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 577067e..a937f49 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.9"
+#define DRV_VERSION		"1.4.1.10"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 21be989..9befd54 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1252,7 +1252,10 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 {
 	struct vic_provinfo *vp;
 	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
+	u16 os_type = VIC_GENERIC_PROV_OS_TYPE_LINUX;
 	char uuid_str[38];
+	char client_mac_str[18];
+	u8 *client_mac;
 	int err;
 
 	err = enic_vnic_dev_deinit(enic);
@@ -1270,37 +1273,47 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 			return -EADDRNOTAVAIL;
 
 		vp = vic_provinfo_alloc(GFP_KERNEL, oui,
-			VIC_PROVINFO_LINUX_TYPE);
+			VIC_PROVINFO_GENERIC_TYPE);
 		if (!vp)
 			return -ENOMEM;
 
 		vic_provinfo_add_tlv(vp,
-			VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
+			VIC_GENERIC_PROV_TLV_PORT_PROFILE_NAME_STR,
 			strlen(enic->pp.name) + 1, enic->pp.name);
 
 		if (!is_zero_ether_addr(enic->pp.mac_addr))
-			vic_provinfo_add_tlv(vp,
-				VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
-				ETH_ALEN, enic->pp.mac_addr);
+			client_mac = enic->pp.mac_addr;
 		else
-			vic_provinfo_add_tlv(vp,
-				VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
-				ETH_ALEN, mac);
+			client_mac = mac;
+
+		vic_provinfo_add_tlv(vp,
+			VIC_GENERIC_PROV_TLV_CLIENT_MAC_ADDR,
+			ETH_ALEN, client_mac);
+
+		sprintf(client_mac_str, "%pM", client_mac);
+		vic_provinfo_add_tlv(vp,
+			VIC_GENERIC_PROV_TLV_CLUSTER_PORT_UUID_STR,
+			sizeof(client_mac_str), client_mac_str);
 
 		if (enic->pp.set & ENIC_SET_INSTANCE) {
 			sprintf(uuid_str, "%pUB", enic->pp.instance_uuid);
 			vic_provinfo_add_tlv(vp,
-				VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
+				VIC_GENERIC_PROV_TLV_CLIENT_UUID_STR,
 				sizeof(uuid_str), uuid_str);
 		}
 
 		if (enic->pp.set & ENIC_SET_HOST) {
 			sprintf(uuid_str, "%pUB", enic->pp.host_uuid);
 			vic_provinfo_add_tlv(vp,
-				VIC_LINUX_PROV_TLV_HOST_UUID_STR,
+				VIC_GENERIC_PROV_TLV_HOST_UUID_STR,
 				sizeof(uuid_str), uuid_str);
 		}
 
+		os_type = htons(os_type);
+		vic_provinfo_add_tlv(vp,
+			VIC_GENERIC_PROV_TLV_OS_TYPE,
+			sizeof(os_type), &os_type);
+
 		err = enic_dev_init_prov(enic, vp);
 		vic_provinfo_free(vp);
 		if (err)
diff --git a/drivers/net/enic/vnic_vic.h b/drivers/net/enic/vnic_vic.h
index 7e46e5e..f700f5d 100644
--- a/drivers/net/enic/vnic_vic.h
+++ b/drivers/net/enic/vnic_vic.h
@@ -24,14 +24,29 @@
 /* Note: String field lengths include null char */
 
 #define VIC_PROVINFO_CISCO_OUI		{ 0x00, 0x00, 0x0c }
-#define VIC_PROVINFO_LINUX_TYPE		0x2
-
-enum vic_linux_prov_tlv_type {
-	VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR = 0,
-	VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR = 1,			/* u8[6] */
-	VIC_LINUX_PROV_TLV_CLIENT_NAME_STR = 2,
-	VIC_LINUX_PROV_TLV_HOST_UUID_STR = 8,
-	VIC_LINUX_PROV_TLV_CLIENT_UUID_STR = 9,
+#define VIC_PROVINFO_GENERIC_TYPE		0x4
+
+enum vic_generic_prov_tlv_type {
+	VIC_GENERIC_PROV_TLV_PORT_PROFILE_NAME_STR = 0,
+	VIC_GENERIC_PROV_TLV_CLIENT_MAC_ADDR = 1,
+	VIC_GENERIC_PROV_TLV_CLIENT_NAME_STR = 2,
+	VIC_GENERIC_PROV_TLV_CLUSTER_PORT_NAME_STR = 3,
+	VIC_GENERIC_PROV_TLV_CLUSTER_PORT_UUID_STR = 4,
+	VIC_GENERIC_PROV_TLV_CLUSTER_UUID_STR = 5,
+	VIC_GENERIC_PROV_TLV_CLUSTER_NAME_STR = 7,
+	VIC_GENERIC_PROV_TLV_HOST_UUID_STR = 8,
+	VIC_GENERIC_PROV_TLV_CLIENT_UUID_STR = 9,
+	VIC_GENERIC_PROV_TLV_INCARNATION_NUMBER = 10,
+	VIC_GENERIC_PROV_TLV_OS_TYPE = 11,
+	VIC_GENERIC_PROV_TLV_OS_VENDOR = 12,
+	VIC_GENERIC_PROV_TLV_CLIENT_TYPE = 15,
+};
+
+enum vic_generic_prov_os_type {
+	VIC_GENERIC_PROV_OS_TYPE_UNKNOWN = 0,
+	VIC_GENERIC_PROV_OS_TYPE_ESX = 1,
+	VIC_GENERIC_PROV_OS_TYPE_LINUX = 2,
+	VIC_GENERIC_PROV_OS_TYPE_WINDOWS = 3,
 };
 
 struct vic_provinfo {

