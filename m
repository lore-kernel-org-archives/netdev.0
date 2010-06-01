From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-2.6 PATCH] enic: bug fix: make the set/get netlink VF_PORT
	support symmetrical
Date: Tue, 01 Jun 2010 11:59:33 -0700
Message-ID: <20100601185933.4323.2212.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:22752 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab0FAS7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 14:59:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

To make get/set netlink VF_PORT truly symmetrical, we need to keep track
of what items are set and only return those items on get.  Previously, the
driver wasn't differentiating between a set of attr with a NULL string,
for example, and not setting the attr at all.  We only want to return
the NULL string if the attr was actually set with a NULL string.  Otherwise,
don't return the attr.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    7 +
 drivers/net/enic/enic_main.c |  200 ++++++++++++++++++++----------------------
 2 files changed, 104 insertions(+), 103 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 85f2a2e..45e86d1 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -74,7 +74,14 @@ struct enic_msix_entry {
 	void *devid;
 };
 
+#define ENIC_SET_APPLIED		(1 << 0)
+#define ENIC_SET_REQUEST		(1 << 1)
+#define ENIC_SET_NAME			(1 << 2)
+#define ENIC_SET_INSTANCE		(1 << 3)
+#define ENIC_SET_HOST			(1 << 4)
+
 struct enic_port_profile {
+	u32 set;
 	u8 request;
 	char name[PORT_PROFILE_MAX];
 	u8 instance_uuid[PORT_UUID_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6586b5c..bc7d6b9 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1029,8 +1029,7 @@ static int enic_dev_init_done(struct enic *enic, int *done, int *error)
 	return err;
 }
 
-static int enic_set_port_profile(struct enic *enic, u8 request, u8 *mac,
-	char *name, u8 *instance_uuid, u8 *host_uuid)
+static int enic_set_port_profile(struct enic *enic, u8 *mac)
 {
 	struct vic_provinfo *vp;
 	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
@@ -1040,97 +1039,112 @@ static int enic_set_port_profile(struct enic *enic, u8 request, u8 *mac,
 		"%02X%02X-%02X%02X%02X%02X%0X%02X";
 	int err;
 
-	if (!name)
-		return -EINVAL;
+	err = enic_vnic_dev_deinit(enic);
+	if (err)
+		return err;
 
-	if (!is_valid_ether_addr(mac))
-		return -EADDRNOTAVAIL;
+	switch (enic->pp.request) {
 
-	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
-	if (!vp)
-		return -ENOMEM;
+	case PORT_REQUEST_ASSOCIATE:
 
-	vic_provinfo_add_tlv(vp,
-		VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
-		strlen(name) + 1, name);
-
-	vic_provinfo_add_tlv(vp,
-		VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
-		ETH_ALEN, mac);
-
-	if (instance_uuid) {
-		uuid = instance_uuid;
-		sprintf(uuid_str, uuid_fmt,
-			uuid[0],  uuid[1],  uuid[2],  uuid[3],
-			uuid[4],  uuid[5],  uuid[6],  uuid[7],
-			uuid[8],  uuid[9],  uuid[10], uuid[11],
-			uuid[12], uuid[13], uuid[14], uuid[15]);
-		vic_provinfo_add_tlv(vp,
-			VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
-			sizeof(uuid_str), uuid_str);
-	}
+		if (!(enic->pp.set & ENIC_SET_NAME) || !strlen(enic->pp.name))
+			return -EINVAL;
 
-	if (host_uuid) {
-		uuid = host_uuid;
-		sprintf(uuid_str, uuid_fmt,
-			uuid[0],  uuid[1],  uuid[2],  uuid[3],
-			uuid[4],  uuid[5],  uuid[6],  uuid[7],
-			uuid[8],  uuid[9],  uuid[10], uuid[11],
-			uuid[12], uuid[13], uuid[14], uuid[15]);
-		vic_provinfo_add_tlv(vp,
-			VIC_LINUX_PROV_TLV_HOST_UUID_STR,
-			sizeof(uuid_str), uuid_str);
-	}
+		if (!is_valid_ether_addr(mac))
+			return -EADDRNOTAVAIL;
 
-	err = enic_vnic_dev_deinit(enic);
-	if (err)
-		goto err_out;
+		vp = vic_provinfo_alloc(GFP_KERNEL, oui,
+			VIC_PROVINFO_LINUX_TYPE);
+		if (!vp)
+			return -ENOMEM;
 
-	memset(&enic->pp, 0, sizeof(enic->pp));
+		vic_provinfo_add_tlv(vp,
+			VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
+			strlen(enic->pp.name) + 1, enic->pp.name);
 
-	err = enic_dev_init_prov(enic, vp);
-	if (err)
-		goto err_out;
+		vic_provinfo_add_tlv(vp,
+			VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+			ETH_ALEN, mac);
+
+		if (enic->pp.set & ENIC_SET_INSTANCE) {
+			uuid = enic->pp.instance_uuid;
+			sprintf(uuid_str, uuid_fmt,
+				uuid[0],  uuid[1],  uuid[2],  uuid[3],
+				uuid[4],  uuid[5],  uuid[6],  uuid[7],
+				uuid[8],  uuid[9],  uuid[10], uuid[11],
+				uuid[12], uuid[13], uuid[14], uuid[15]);
+			vic_provinfo_add_tlv(vp,
+				VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
+				sizeof(uuid_str), uuid_str);
+		}
 
-	enic->pp.request = request;
-	memcpy(enic->pp.name, name, PORT_PROFILE_MAX);
-	if (instance_uuid)
-		memcpy(enic->pp.instance_uuid,
-			instance_uuid, PORT_UUID_MAX);
-	if (host_uuid)
-		memcpy(enic->pp.host_uuid,
-			host_uuid, PORT_UUID_MAX);
+		if (enic->pp.set & ENIC_SET_HOST) {
+			uuid = enic->pp.host_uuid;
+			sprintf(uuid_str, uuid_fmt,
+				uuid[0],  uuid[1],  uuid[2],  uuid[3],
+				uuid[4],  uuid[5],  uuid[6],  uuid[7],
+				uuid[8],  uuid[9],  uuid[10], uuid[11],
+				uuid[12], uuid[13], uuid[14], uuid[15]);
+			vic_provinfo_add_tlv(vp,
+				VIC_LINUX_PROV_TLV_HOST_UUID_STR,
+				sizeof(uuid_str), uuid_str);
+		}
 
-err_out:
-	vic_provinfo_free(vp);
+		err = enic_dev_init_prov(enic, vp);
+		vic_provinfo_free(vp);
+		if (err)
+			return err;
+		break;
 
-	return err;
-}
+	case PORT_REQUEST_DISASSOCIATE:
+		break;
 
-static int enic_unset_port_profile(struct enic *enic)
-{
-	memset(&enic->pp, 0, sizeof(enic->pp));
-	return enic_vnic_dev_deinit(enic);
+	default:
+		return -EINVAL;
+	}
+
+	enic->pp.set |= ENIC_SET_APPLIED;
+	return 0;
 }
 
 static int enic_set_vf_port(struct net_device *netdev, int vf,
 	struct nlattr *port[])
 {
 	struct enic *enic = netdev_priv(netdev);
-	char *name = NULL;
-	u8 *instance_uuid = NULL;
-	u8 *host_uuid = NULL;
-	u8 request = PORT_REQUEST_DISASSOCIATE;
+
+	memset(&enic->pp, 0, sizeof(enic->pp));
+
+	if (port[IFLA_PORT_REQUEST]) {
+		enic->pp.set |= ENIC_SET_REQUEST;
+		enic->pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
+	}
+
+	if (port[IFLA_PORT_PROFILE]) {
+		enic->pp.set |= ENIC_SET_NAME;
+		memcpy(enic->pp.name, nla_data(port[IFLA_PORT_PROFILE]),
+			PORT_PROFILE_MAX);
+	}
+
+	if (port[IFLA_PORT_INSTANCE_UUID]) {
+		enic->pp.set |= ENIC_SET_INSTANCE;
+		memcpy(enic->pp.instance_uuid,
+			nla_data(port[IFLA_PORT_INSTANCE_UUID]), PORT_UUID_MAX);
+	}
+
+	if (port[IFLA_PORT_HOST_UUID]) {
+		enic->pp.set |= ENIC_SET_HOST;
+		memcpy(enic->pp.host_uuid,
+			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
+	}
 
 	/* don't support VFs, yet */
 	if (vf != PORT_SELF_VF)
 		return -EOPNOTSUPP;
 
-	if (port[IFLA_PORT_REQUEST])
-		request = nla_get_u8(port[IFLA_PORT_REQUEST]);
+	if (!(enic->pp.set & ENIC_SET_REQUEST))
+		return -EOPNOTSUPP;
 
-	switch (request) {
-	case PORT_REQUEST_ASSOCIATE:
+	if (enic->pp.request == PORT_REQUEST_ASSOCIATE) {
 
 		/* If the interface mac addr hasn't been assigned,
 		 * assign a random mac addr before setting port-
@@ -1139,30 +1153,9 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 
 		if (is_zero_ether_addr(netdev->dev_addr))
 			random_ether_addr(netdev->dev_addr);
-
-		if (port[IFLA_PORT_PROFILE])
-			name = nla_data(port[IFLA_PORT_PROFILE]);
-
-		if (port[IFLA_PORT_INSTANCE_UUID])
-			instance_uuid =
-				nla_data(port[IFLA_PORT_INSTANCE_UUID]);
-
-		if (port[IFLA_PORT_HOST_UUID])
-			host_uuid = nla_data(port[IFLA_PORT_HOST_UUID]);
-
-		return enic_set_port_profile(enic, request,
-			netdev->dev_addr, name,
-			instance_uuid, host_uuid);
-
-	case PORT_REQUEST_DISASSOCIATE:
-
-		return enic_unset_port_profile(enic);
-
-	default:
-		break;
 	}
 
-	return -EOPNOTSUPP;
+	return enic_set_port_profile(enic, netdev->dev_addr);
 }
 
 static int enic_get_vf_port(struct net_device *netdev, int vf,
@@ -1172,14 +1165,12 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 	int err, error, done;
 	u16 response = PORT_PROFILE_RESPONSE_SUCCESS;
 
-	/* don't support VFs, yet */
-	if (vf != PORT_SELF_VF)
-		return -EOPNOTSUPP;
+	if (!(enic->pp.set & ENIC_SET_APPLIED))
+		return -ENODATA;
 
 	err = enic_dev_init_done(enic, &done, &error);
-
 	if (err)
-		return err;
+		error = err;
 
 	switch (error) {
 	case ERR_SUCCESS:
@@ -1202,12 +1193,15 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 
 	NLA_PUT_U16(skb, IFLA_PORT_REQUEST, enic->pp.request);
 	NLA_PUT_U16(skb, IFLA_PORT_RESPONSE, response);
-	NLA_PUT(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX,
-		enic->pp.name);
-	NLA_PUT(skb, IFLA_PORT_INSTANCE_UUID, PORT_UUID_MAX,
-		enic->pp.instance_uuid);
-	NLA_PUT(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX,
-		enic->pp.host_uuid);
+	if (enic->pp.set & ENIC_SET_NAME)
+		NLA_PUT(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX,
+			enic->pp.name);
+	if (enic->pp.set & ENIC_SET_INSTANCE)
+		NLA_PUT(skb, IFLA_PORT_INSTANCE_UUID, PORT_UUID_MAX,
+			enic->pp.instance_uuid);
+	if (enic->pp.set & ENIC_SET_HOST)
+		NLA_PUT(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX,
+			enic->pp.host_uuid);
 
 	return 0;
 

