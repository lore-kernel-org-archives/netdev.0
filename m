From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/4] enic: Add support for
	PORT_REQUEST_PREASSOCIATE_RR
Date: Tue, 29 Mar 2011 23:36:07 -0700
Message-ID: <20110330063607.7187.72722.stgit@savbu-pc100.cisco.com>
References: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:20378 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364Ab1C3GgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:36:08 -0400
In-Reply-To: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

Current enic code only supports ASSOCIATE and DISASSOCIATE port profile
operations. This patch adds enic support for port profile
PORT_REQUEST_PREASSOCIATE_RR operation. The VIC adapter (8021qbh) is capable
of handling port profile requests done in two steps namely PREASSOCIATE_RR
and ASSOCIATE today. The motivation to support PREASSOCIATE_RR comes mainly
from its use as an optimization during VM migration ie, to do resource
reservation on destination host before resources on source host are released.

PREASSOCIATE_RR is a VDP operation and according to the latest at IEEE,
8021qbh will also need to support VDP commands.

In addition to handling the new PORT_REQUEST_PREASSOCIATE_RR operation
this patch also does the below:
- Introduces handlers for PORT_REQUEST operations
- Moves most of the port profile handling code to new files enic_pp.[ch]
- Uses new fw devcmds for port profile operations

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/Makefile    |    2 
 drivers/net/enic/enic.h      |    4 -
 drivers/net/enic/enic_main.c |  196 ++++++++-----------------------
 drivers/net/enic/enic_pp.c   |  264 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/enic/enic_pp.h   |   27 ++++
 5 files changed, 344 insertions(+), 149 deletions(-)
 create mode 100644 drivers/net/enic/enic_pp.c
 create mode 100644 drivers/net/enic/enic_pp.h


diff --git a/drivers/net/enic/Makefile b/drivers/net/enic/Makefile
index 2e573be..9d4974b 100644
--- a/drivers/net/enic/Makefile
+++ b/drivers/net/enic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o enic_dev.o vnic_dev.o vnic_rq.o vnic_vic.o
+	enic_res.o enic_dev.o enic_pp.o vnic_dev.o vnic_rq.o vnic_vic.o
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 3a3c3c8..178b94d 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.12"
+#define DRV_VERSION		"2.1.1.13"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -120,4 +120,6 @@ static inline struct device *enic_get_dev(struct enic *enic)
 	return &(enic->pdev->dev);
 }
 
+void enic_reset_addr_lists(struct enic *enic);
+
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 8b9cad5..9a3a027 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -45,6 +45,7 @@
 #include "enic_res.h"
 #include "enic.h"
 #include "enic_dev.h"
+#include "enic_pp.h"
 
 #define ENIC_NOTIFY_TIMER_PERIOD	(2 * HZ)
 #define WQ_ENET_MAX_DESC_LEN		(1 << WQ_ENET_LEN_BITS)
@@ -874,7 +875,7 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	return net_stats;
 }
 
-static void enic_reset_addr_lists(struct enic *enic)
+void enic_reset_addr_lists(struct enic *enic)
 {
 	enic->mc_count = 0;
 	enic->uc_count = 0;
@@ -1112,157 +1113,77 @@ static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 		return -EINVAL;
 }
 
-static int enic_set_port_profile(struct enic *enic, u8 *mac)
-{
-	struct vic_provinfo *vp;
-	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
-	u16 os_type = VIC_GENERIC_PROV_OS_TYPE_LINUX;
-	char uuid_str[38];
-	char client_mac_str[18];
-	u8 *client_mac;
-	int err;
-
-	err = enic_vnic_dev_deinit(enic);
-	if (err)
-		return err;
-
-	enic_reset_addr_lists(enic);
-
-	switch (enic->pp.request) {
-
-	case PORT_REQUEST_ASSOCIATE:
-
-		if (!(enic->pp.set & ENIC_SET_NAME) || !strlen(enic->pp.name))
-			return -EINVAL;
-
-		if (!is_valid_ether_addr(mac))
-			return -EADDRNOTAVAIL;
-
-		vp = vic_provinfo_alloc(GFP_KERNEL, oui,
-			VIC_PROVINFO_GENERIC_TYPE);
-		if (!vp)
-			return -ENOMEM;
-
-		vic_provinfo_add_tlv(vp,
-			VIC_GENERIC_PROV_TLV_PORT_PROFILE_NAME_STR,
-			strlen(enic->pp.name) + 1, enic->pp.name);
-
-		if (!is_zero_ether_addr(enic->pp.mac_addr))
-			client_mac = enic->pp.mac_addr;
-		else
-			client_mac = mac;
-
-		vic_provinfo_add_tlv(vp,
-			VIC_GENERIC_PROV_TLV_CLIENT_MAC_ADDR,
-			ETH_ALEN, client_mac);
-
-		sprintf(client_mac_str, "%pM", client_mac);
-		vic_provinfo_add_tlv(vp,
-			VIC_GENERIC_PROV_TLV_CLUSTER_PORT_UUID_STR,
-			sizeof(client_mac_str), client_mac_str);
-
-		if (enic->pp.set & ENIC_SET_INSTANCE) {
-			sprintf(uuid_str, "%pUB", enic->pp.instance_uuid);
-			vic_provinfo_add_tlv(vp,
-				VIC_GENERIC_PROV_TLV_CLIENT_UUID_STR,
-				sizeof(uuid_str), uuid_str);
-		}
-
-		if (enic->pp.set & ENIC_SET_HOST) {
-			sprintf(uuid_str, "%pUB", enic->pp.host_uuid);
-			vic_provinfo_add_tlv(vp,
-				VIC_GENERIC_PROV_TLV_HOST_UUID_STR,
-				sizeof(uuid_str), uuid_str);
-		}
-
-		os_type = htons(os_type);
-		vic_provinfo_add_tlv(vp,
-			VIC_GENERIC_PROV_TLV_OS_TYPE,
-			sizeof(os_type), &os_type);
-
-		err = enic_dev_init_prov(enic, vp);
-		vic_provinfo_free(vp);
-		if (err)
-			return err;
-		break;
-
-	case PORT_REQUEST_DISASSOCIATE:
-		break;
-
-	default:
-		return -EINVAL;
-	}
-
-	/* Set flag to indicate that the port assoc/disassoc
-	 * request has been sent out to fw
-	 */
-	enic->pp.set |= ENIC_PORT_REQUEST_APPLIED;
-
-	return 0;
-}
-
 static int enic_set_vf_port(struct net_device *netdev, int vf,
 	struct nlattr *port[])
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct enic_port_profile new_pp;
-	int err = 0;
+	struct enic_port_profile prev_pp;
+	int err = 0, restore_pp = 1;
 
-	memset(&new_pp, 0, sizeof(new_pp));
+	/* don't support VFs, yet */
+	if (vf != PORT_SELF_VF)
+		return -EOPNOTSUPP;
 
-	if (port[IFLA_PORT_REQUEST]) {
-		new_pp.set |= ENIC_SET_REQUEST;
-		new_pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
-	}
+	if (!port[IFLA_PORT_REQUEST])
+		return -EOPNOTSUPP;
+
+	memcpy(&prev_pp, &enic->pp, sizeof(enic->pp));
+	memset(&enic->pp, 0, sizeof(enic->pp));
+
+	enic->pp.set |= ENIC_SET_REQUEST;
+	enic->pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
 
 	if (port[IFLA_PORT_PROFILE]) {
-		new_pp.set |= ENIC_SET_NAME;
-		memcpy(new_pp.name, nla_data(port[IFLA_PORT_PROFILE]),
+		enic->pp.set |= ENIC_SET_NAME;
+		memcpy(enic->pp.name, nla_data(port[IFLA_PORT_PROFILE]),
 			PORT_PROFILE_MAX);
 	}
 
 	if (port[IFLA_PORT_INSTANCE_UUID]) {
-		new_pp.set |= ENIC_SET_INSTANCE;
-		memcpy(new_pp.instance_uuid,
+		enic->pp.set |= ENIC_SET_INSTANCE;
+		memcpy(enic->pp.instance_uuid,
 			nla_data(port[IFLA_PORT_INSTANCE_UUID]), PORT_UUID_MAX);
 	}
 
 	if (port[IFLA_PORT_HOST_UUID]) {
-		new_pp.set |= ENIC_SET_HOST;
-		memcpy(new_pp.host_uuid,
+		enic->pp.set |= ENIC_SET_HOST;
+		memcpy(enic->pp.host_uuid,
 			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
 	}
 
-	/* don't support VFs, yet */
-	if (vf != PORT_SELF_VF)
-		return -EOPNOTSUPP;
-
-	if (!(new_pp.set & ENIC_SET_REQUEST))
-		return -EOPNOTSUPP;
-
-	if (new_pp.request == PORT_REQUEST_ASSOCIATE) {
-		/* Special case handling */
-		if (!is_zero_ether_addr(enic->pp.vf_mac))
-			memcpy(new_pp.mac_addr, enic->pp.vf_mac, ETH_ALEN);
+	/* Special case handling: mac came from IFLA_VF_MAC */
+	if (!is_zero_ether_addr(prev_pp.vf_mac))
+		memcpy(enic->pp.mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
 		if (is_zero_ether_addr(netdev->dev_addr))
 			random_ether_addr(netdev->dev_addr);
-	}
 
-	memcpy(&enic->pp, &new_pp, sizeof(struct enic_port_profile));
+	err = enic_process_set_pp_request(enic, &prev_pp, &restore_pp);
+	if (err) {
+		if (restore_pp) {
+			/* Things are still the way they were: Implicit
+			 * DISASSOCIATE failed
+			 */
+			memcpy(&enic->pp, &prev_pp, sizeof(enic->pp));
+		} else {
+			memset(&enic->pp, 0, sizeof(enic->pp));
+			memset(netdev->dev_addr, 0, ETH_ALEN);
+		}
+	} else {
+		/* Set flag to indicate that the port assoc/disassoc
+		 * request has been sent out to fw
+		 */
+		enic->pp.set |= ENIC_PORT_REQUEST_APPLIED;
 
-	err = enic_set_port_profile(enic, netdev->dev_addr);
-	if (err)
-		goto set_port_profile_cleanup;
+		/* If DISASSOCIATE, clean up all assigned/saved macaddresses */
+		if (enic->pp.request == PORT_REQUEST_DISASSOCIATE) {
+			memset(enic->pp.mac_addr, 0, ETH_ALEN);
+			memset(netdev->dev_addr, 0, ETH_ALEN);
+		}
+	}
 
-set_port_profile_cleanup:
 	memset(enic->pp.vf_mac, 0, ETH_ALEN);
 
-	if (err || enic->pp.request == PORT_REQUEST_DISASSOCIATE) {
-		memset(netdev->dev_addr, 0, ETH_ALEN);
-		memset(enic->pp.mac_addr, 0, ETH_ALEN);
-	}
-
 	return err;
 }
 
@@ -1270,34 +1191,15 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 	struct sk_buff *skb)
 {
 	struct enic *enic = netdev_priv(netdev);
-	int err, error, done;
 	u16 response = PORT_PROFILE_RESPONSE_SUCCESS;
+	int err;
 
 	if (!(enic->pp.set & ENIC_PORT_REQUEST_APPLIED))
 		return -ENODATA;
 
-	err = enic_dev_init_done(enic, &done, &error);
+	err = enic_process_get_pp_request(enic, enic->pp.request, &response);
 	if (err)
-		error = err;
-
-	switch (error) {
-	case ERR_SUCCESS:
-		if (!done)
-			response = PORT_PROFILE_RESPONSE_INPROGRESS;
-		break;
-	case ERR_EINVAL:
-		response = PORT_PROFILE_RESPONSE_INVALID;
-		break;
-	case ERR_EBADSTATE:
-		response = PORT_PROFILE_RESPONSE_BADSTATE;
-		break;
-	case ERR_ENOMEM:
-		response = PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES;
-		break;
-	default:
-		response = PORT_PROFILE_RESPONSE_ERROR;
-		break;
-	}
+		return err;
 
 	NLA_PUT_U16(skb, IFLA_PORT_REQUEST, enic->pp.request);
 	NLA_PUT_U16(skb, IFLA_PORT_RESPONSE, response);
diff --git a/drivers/net/enic/enic_pp.c b/drivers/net/enic/enic_pp.c
new file mode 100644
index 0000000..ffaa75d
--- /dev/null
+++ b/drivers/net/enic/enic_pp.c
@@ -0,0 +1,264 @@
+/*
+ * Copyright 2011 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
+#include <net/ip.h>
+
+#include "vnic_vic.h"
+#include "enic_res.h"
+#include "enic.h"
+#include "enic_dev.h"
+
+static int enic_set_port_profile(struct enic *enic)
+{
+	struct net_device *netdev = enic->netdev;
+	struct vic_provinfo *vp;
+	const u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
+	const u16 os_type = htons(VIC_GENERIC_PROV_OS_TYPE_LINUX);
+	char uuid_str[38];
+	char client_mac_str[18];
+	u8 *client_mac;
+	int err;
+
+	if (!(enic->pp.set & ENIC_SET_NAME) || !strlen(enic->pp.name))
+		return -EINVAL;
+
+	vp = vic_provinfo_alloc(GFP_KERNEL, oui,
+		VIC_PROVINFO_GENERIC_TYPE);
+	if (!vp)
+		return -ENOMEM;
+
+	VIC_PROVINFO_ADD_TLV(vp,
+		VIC_GENERIC_PROV_TLV_PORT_PROFILE_NAME_STR,
+		strlen(enic->pp.name) + 1, enic->pp.name);
+
+	if (!is_zero_ether_addr(enic->pp.mac_addr))
+		client_mac = enic->pp.mac_addr;
+	else
+		client_mac = netdev->dev_addr;
+
+	VIC_PROVINFO_ADD_TLV(vp,
+		VIC_GENERIC_PROV_TLV_CLIENT_MAC_ADDR,
+		ETH_ALEN, client_mac);
+
+	snprintf(client_mac_str, sizeof(client_mac_str), "%pM", client_mac);
+	VIC_PROVINFO_ADD_TLV(vp,
+		VIC_GENERIC_PROV_TLV_CLUSTER_PORT_UUID_STR,
+		sizeof(client_mac_str), client_mac_str);
+
+	if (enic->pp.set & ENIC_SET_INSTANCE) {
+		sprintf(uuid_str, "%pUB", enic->pp.instance_uuid);
+		VIC_PROVINFO_ADD_TLV(vp,
+			VIC_GENERIC_PROV_TLV_CLIENT_UUID_STR,
+			sizeof(uuid_str), uuid_str);
+	}
+
+	if (enic->pp.set & ENIC_SET_HOST) {
+		sprintf(uuid_str, "%pUB", enic->pp.host_uuid);
+		VIC_PROVINFO_ADD_TLV(vp,
+			VIC_GENERIC_PROV_TLV_HOST_UUID_STR,
+			sizeof(uuid_str), uuid_str);
+	}
+
+	VIC_PROVINFO_ADD_TLV(vp,
+		VIC_GENERIC_PROV_TLV_OS_TYPE,
+		sizeof(os_type), &os_type);
+
+	err = enic_dev_status_to_errno(enic_dev_init_prov2(enic, vp));
+
+add_tlv_failure:
+	vic_provinfo_free(vp);
+
+	return err;
+}
+
+static int enic_unset_port_profile(struct enic *enic)
+{
+	int err;
+
+	err = enic_vnic_dev_deinit(enic);
+	if (err)
+		return enic_dev_status_to_errno(err);
+
+	enic_reset_addr_lists(enic);
+
+	return 0;
+}
+
+static int enic_are_pp_different(struct enic_port_profile *pp1,
+		struct enic_port_profile *pp2)
+{
+	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
+		pp2->instance_uuid, PORT_UUID_MAX) |
+		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
+		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
+}
+
+static int enic_pp_preassociate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp);
+static int enic_pp_disassociate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp);
+static int enic_pp_preassociate_rr(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp);
+static int enic_pp_associate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp);
+
+static int (*enic_pp_handlers[])(struct enic *enic,
+		struct enic_port_profile *prev_state, int *restore_pp) = {
+	[PORT_REQUEST_PREASSOCIATE]	= enic_pp_preassociate,
+	[PORT_REQUEST_PREASSOCIATE_RR]	= enic_pp_preassociate_rr,
+	[PORT_REQUEST_ASSOCIATE]	= enic_pp_associate,
+	[PORT_REQUEST_DISASSOCIATE]	= enic_pp_disassociate,
+};
+
+static const int enic_pp_handlers_count =
+			sizeof(enic_pp_handlers)/sizeof(*enic_pp_handlers);
+
+static int enic_pp_preassociate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp)
+{
+	return -EOPNOTSUPP;
+}
+
+static int enic_pp_disassociate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp)
+{
+	return enic_unset_port_profile(enic);
+}
+
+static int enic_pp_preassociate_rr(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp)
+{
+	int err;
+	int active = 0;
+
+	if (enic->pp.request != PORT_REQUEST_ASSOCIATE) {
+		/* If pre-associate is not part of an associate.
+		We always disassociate first */
+		err = enic_pp_handlers[PORT_REQUEST_DISASSOCIATE](enic,
+			prev_pp, restore_pp);
+		if (err)
+			return err;
+
+		*restore_pp = 0;
+	}
+
+	*restore_pp = 0;
+
+	err = enic_set_port_profile(enic);
+	if (err)
+		return err;
+
+	/* If pre-associate is not part of an associate. */
+	if (enic->pp.request != PORT_REQUEST_ASSOCIATE)
+		err = enic_dev_status_to_errno(enic_dev_enable2(enic, active));
+
+	return err;
+}
+
+static int enic_pp_associate(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp)
+{
+	int err;
+	int active = 1;
+
+	/* Check if a pre-associate was called before */
+	if (prev_pp->request != PORT_REQUEST_PREASSOCIATE_RR ||
+		(prev_pp->request == PORT_REQUEST_PREASSOCIATE_RR &&
+			enic_are_pp_different(prev_pp, &enic->pp))) {
+		err = enic_pp_handlers[PORT_REQUEST_DISASSOCIATE](
+			enic, prev_pp, restore_pp);
+		if (err)
+			return err;
+
+		*restore_pp = 0;
+	}
+
+	err = enic_pp_handlers[PORT_REQUEST_PREASSOCIATE_RR](
+			enic, prev_pp, restore_pp);
+	if (err)
+		return err;
+
+	*restore_pp = 0;
+
+	return enic_dev_status_to_errno(enic_dev_enable2(enic, active));
+}
+
+int enic_process_set_pp_request(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp)
+{
+	if (enic->pp.request < enic_pp_handlers_count
+		&& enic_pp_handlers[enic->pp.request])
+		return enic_pp_handlers[enic->pp.request](enic,
+			prev_pp, restore_pp);
+	else
+		return -EOPNOTSUPP;
+}
+
+int enic_process_get_pp_request(struct enic *enic, int request,
+	u16 *response)
+{
+	int err, status = ERR_SUCCESS;
+
+	switch (request) {
+
+	case PORT_REQUEST_PREASSOCIATE_RR:
+	case PORT_REQUEST_ASSOCIATE:
+		err = enic_dev_enable2_done(enic, &status);
+		break;
+
+	case PORT_REQUEST_DISASSOCIATE:
+		err = enic_dev_deinit_done(enic, &status);
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (err)
+		status = err;
+
+	switch (status) {
+	case ERR_SUCCESS:
+		*response = PORT_PROFILE_RESPONSE_SUCCESS;
+		break;
+	case ERR_EINVAL:
+		*response = PORT_PROFILE_RESPONSE_INVALID;
+		break;
+	case ERR_EBADSTATE:
+		*response = PORT_PROFILE_RESPONSE_BADSTATE;
+		break;
+	case ERR_ENOMEM:
+		*response = PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES;
+		break;
+	case ERR_EINPROGRESS:
+		*response = PORT_PROFILE_RESPONSE_INPROGRESS;
+		break;
+	default:
+		*response = PORT_PROFILE_RESPONSE_ERROR;
+		break;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/enic/enic_pp.h b/drivers/net/enic/enic_pp.h
new file mode 100644
index 0000000..699e365
--- /dev/null
+++ b/drivers/net/enic/enic_pp.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright 2011 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _ENIC_PP_H_
+#define _ENIC_PP_H_
+
+int enic_process_set_pp_request(struct enic *enic,
+	struct enic_port_profile *prev_pp, int *restore_pp);
+int enic_process_get_pp_request(struct enic *enic, int request,
+	u16 *response);
+
+#endif /* _ENIC_PP_H_ */

