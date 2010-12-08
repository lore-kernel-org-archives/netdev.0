From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/2] enic: Use VF mac set by IFLA_VF_MAC in port
	profile provisioning data
Date: Wed, 08 Dec 2010 15:54:03 -0800
Message-ID: <20101208235403.24874.89187.stgit@savbu-pc100.cisco.com>
References: <20101208235340.24874.50597.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:56518 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab0LHXyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 18:54:03 -0500
In-Reply-To: <20101208235340.24874.50597.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support in enic 802.1Qbh port profile provisioning code
to use the mac address set by IFLA_VF_MAC. For now we handle this mac as a
special case for a VM mac address sent to us by libvirt. The VM mac address
is sent to the switch along with the rest of the port profile provisioning
data. This patch also adds calls to register and deregister the mac address
during port profile association/deassociation.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    1 +
 drivers/net/enic/enic_main.c |   79 ++++++++++++++++++++++++++++++------------
 2 files changed, 57 insertions(+), 23 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index bd473a9..577067e 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -62,6 +62,7 @@ struct enic_port_profile {
 	u8 instance_uuid[PORT_UUID_MAX];
 	u8 host_uuid[PORT_UUID_MAX];
 	u8 vf_mac[ETH_ALEN];
+	u8 mac_addr[ETH_ALEN];
 };
 
 /* Per-instance private data structure */
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index ddeffb5..21be989 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1278,9 +1278,14 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 			VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
 			strlen(enic->pp.name) + 1, enic->pp.name);
 
-		vic_provinfo_add_tlv(vp,
-			VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
-			ETH_ALEN, mac);
+		if (!is_zero_ether_addr(enic->pp.mac_addr))
+			vic_provinfo_add_tlv(vp,
+				VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+				ETH_ALEN, enic->pp.mac_addr);
+		else
+			vic_provinfo_add_tlv(vp,
+				VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+				ETH_ALEN, mac);
 
 		if (enic->pp.set & ENIC_SET_INSTANCE) {
 			sprintf(uuid_str, "%pUB", enic->pp.instance_uuid);
@@ -1300,16 +1305,18 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 		vic_provinfo_free(vp);
 		if (err)
 			return err;
+
+		enic->pp.set |= ENIC_SET_APPLIED;
 		break;
 
 	case PORT_REQUEST_DISASSOCIATE:
+		enic->pp.set &= ~ENIC_SET_APPLIED;
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
-	enic->pp.set |= ENIC_SET_APPLIED;
 	return 0;
 }
 
@@ -1317,29 +1324,31 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 	struct nlattr *port[])
 {
 	struct enic *enic = netdev_priv(netdev);
+	struct enic_port_profile new_pp;
+	int err = 0;
 
-	memset(&enic->pp, 0, sizeof(enic->pp));
+	memset(&new_pp, 0, sizeof(new_pp));
 
 	if (port[IFLA_PORT_REQUEST]) {
-		enic->pp.set |= ENIC_SET_REQUEST;
-		enic->pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
+		new_pp.set |= ENIC_SET_REQUEST;
+		new_pp.request = nla_get_u8(port[IFLA_PORT_REQUEST]);
 	}
 
 	if (port[IFLA_PORT_PROFILE]) {
-		enic->pp.set |= ENIC_SET_NAME;
-		memcpy(enic->pp.name, nla_data(port[IFLA_PORT_PROFILE]),
+		new_pp.set |= ENIC_SET_NAME;
+		memcpy(new_pp.name, nla_data(port[IFLA_PORT_PROFILE]),
 			PORT_PROFILE_MAX);
 	}
 
 	if (port[IFLA_PORT_INSTANCE_UUID]) {
-		enic->pp.set |= ENIC_SET_INSTANCE;
-		memcpy(enic->pp.instance_uuid,
+		new_pp.set |= ENIC_SET_INSTANCE;
+		memcpy(new_pp.instance_uuid,
 			nla_data(port[IFLA_PORT_INSTANCE_UUID]), PORT_UUID_MAX);
 	}
 
 	if (port[IFLA_PORT_HOST_UUID]) {
-		enic->pp.set |= ENIC_SET_HOST;
-		memcpy(enic->pp.host_uuid,
+		new_pp.set |= ENIC_SET_HOST;
+		memcpy(new_pp.host_uuid,
 			nla_data(port[IFLA_PORT_HOST_UUID]), PORT_UUID_MAX);
 	}
 
@@ -1347,21 +1356,39 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 	if (vf != PORT_SELF_VF)
 		return -EOPNOTSUPP;
 
-	if (!(enic->pp.set & ENIC_SET_REQUEST))
+	if (!(new_pp.set & ENIC_SET_REQUEST))
 		return -EOPNOTSUPP;
 
-	if (enic->pp.request == PORT_REQUEST_ASSOCIATE) {
-
-		/* If the interface mac addr hasn't been assigned,
-		 * assign a random mac addr before setting port-
-		 * profile.
-		 */
+	if (new_pp.request == PORT_REQUEST_ASSOCIATE) {
+		/* Special case handling */
+		if (!is_zero_ether_addr(enic->pp.vf_mac))
+			memcpy(new_pp.mac_addr, enic->pp.vf_mac, ETH_ALEN);
 
 		if (is_zero_ether_addr(netdev->dev_addr))
 			random_ether_addr(netdev->dev_addr);
+	} else if (new_pp.request == PORT_REQUEST_DISASSOCIATE) {
+		if (!is_zero_ether_addr(enic->pp.mac_addr))
+			enic_dev_del_addr(enic, enic->pp.mac_addr);
 	}
 
-	return enic_set_port_profile(enic, netdev->dev_addr);
+	memcpy(&enic->pp, &new_pp, sizeof(struct enic_port_profile));
+
+	err = enic_set_port_profile(enic, netdev->dev_addr);
+	if (err)
+		goto set_port_profile_cleanup;
+
+	if (!is_zero_ether_addr(enic->pp.mac_addr))
+		enic_dev_add_addr(enic, enic->pp.mac_addr);
+
+set_port_profile_cleanup:
+	memset(enic->pp.vf_mac, 0, ETH_ALEN);
+
+	if (err || enic->pp.request == PORT_REQUEST_DISASSOCIATE) {
+		memset(netdev->dev_addr, 0, ETH_ALEN);
+		memset(enic->pp.mac_addr, 0, ETH_ALEN);
+	}
+
+	return err;
 }
 
 static int enic_get_vf_port(struct net_device *netdev, int vf,
@@ -1941,7 +1968,10 @@ static int enic_open(struct net_device *netdev)
 	for (i = 0; i < enic->rq_count; i++)
 		vnic_rq_enable(&enic->rq[i]);
 
-	enic_dev_add_station_addr(enic);
+	if (enic_is_dynamic(enic) && !is_zero_ether_addr(enic->pp.mac_addr))
+		enic_dev_add_addr(enic, enic->pp.mac_addr);
+	else
+		enic_dev_add_station_addr(enic);
 	enic_set_rx_mode(netdev);
 
 	netif_wake_queue(netdev);
@@ -1989,7 +2019,10 @@ static int enic_stop(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
-	enic_dev_del_station_addr(enic);
+	if (enic_is_dynamic(enic) && !is_zero_ether_addr(enic->pp.mac_addr))
+		enic_dev_del_addr(enic, enic->pp.mac_addr);
+	else
+		enic_dev_del_station_addr(enic);
 
 	for (i = 0; i < enic->wq_count; i++) {
 		err = vnic_wq_disable(&enic->wq[i]);

