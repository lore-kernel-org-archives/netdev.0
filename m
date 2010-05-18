From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V9 PATCH 2/2] Add ndo_{set|get}_vf_port support for
	enic dynamic vnics
Date: Mon, 17 May 2010 22:48:42 -0700
Message-ID: <20100518054840.21787.65376.stgit@savbu-pc100.cisco.com>
References: <20100518054330.21787.29398.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:18529 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab0ERFsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:48:43 -0400
In-Reply-To: <20100518054330.21787.29398.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add enic ndo_{set|get}_vf_port ops to support setting/getting
port-profile for enic dynamic devices.  Enic dynamic devices are just like
normal enic eth devices except dynamic enics require an extra configuration
step to assign a port-profile identifier to the interface before the
interface is useable.  Once a port-profile is assigned, link comes up on the
interface and is ready for I/O.  The port-profile is used to configure the
network port assigned to the interface.  The network port configuration
includes VLAN membership, QoS policies, and port security settings typical
of a data center network.

A dynamic enic initially has a zero-mac address.  Before a port-profile is
assigned, a valid non-zero unicast mac address should be assign to the
dynamic enic interface.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 drivers/net/enic/Makefile    |    2 
 drivers/net/enic/enic.h      |   10 +
 drivers/net/enic/enic_main.c |  330 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/enic/enic_res.c  |    5 -
 drivers/net/enic/enic_res.h  |    1 
 drivers/net/enic/vnic_dev.c  |   58 +++++++
 drivers/net/enic/vnic_dev.h  |    7 +
 drivers/net/enic/vnic_vic.c  |   73 +++++++++
 drivers/net/enic/vnic_vic.h  |   59 ++++++++
 9 files changed, 521 insertions(+), 24 deletions(-)

diff --git a/drivers/net/enic/Makefile b/drivers/net/enic/Makefile
index 391c3bc..e7b6c31 100644
--- a/drivers/net/enic/Makefile
+++ b/drivers/net/enic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o vnic_dev.o vnic_rq.o
+	enic_res.o vnic_dev.o vnic_rq.o vnic_vic.o
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 5fa56f1..85f2a2e 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -34,7 +34,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.3.1.1"
+#define DRV_VERSION		"1.3.1.1-pp"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
@@ -74,6 +74,13 @@ struct enic_msix_entry {
 	void *devid;
 };
 
+struct enic_port_profile {
+	u8 request;
+	char name[PORT_PROFILE_MAX];
+	u8 instance_uuid[PORT_UUID_MAX];
+	u8 host_uuid[PORT_UUID_MAX];
+};
+
 /* Per-instance private data structure */
 struct enic {
 	struct net_device *netdev;
@@ -95,6 +102,7 @@ struct enic {
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
+	struct enic_port_profile pp;
 
 	/* work queue cache line section */
 	____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 1232887..e125113 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -29,6 +29,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/if_link.h>
 #include <linux/ethtool.h>
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -40,6 +41,7 @@
 #include "vnic_dev.h"
 #include "vnic_intr.h"
 #include "vnic_stats.h"
+#include "vnic_vic.h"
 #include "enic_res.h"
 #include "enic.h"
 
@@ -49,10 +51,12 @@
 #define ENIC_DESC_MAX_SPLITS		(MAX_TSO / WQ_ENET_MAX_DESC_LEN + 1)
 
 #define PCI_DEVICE_ID_CISCO_VIC_ENET         0x0043  /* ethernet vnic */
+#define PCI_DEVICE_ID_CISCO_VIC_ENET_DYN     0x0044  /* enet dynamic vnic */
 
 /* Supported devices */
 static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
+	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_DYN) },
 	{ 0, }	/* end of table */
 };
 
@@ -113,6 +117,11 @@ static const struct enic_stat enic_rx_stats[] = {
 static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
 static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
 
+static int enic_is_dynamic(struct enic *enic)
+{
+	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
+}
+
 static int enic_get_settings(struct net_device *netdev,
 	struct ethtool_cmd *ecmd)
 {
@@ -810,14 +819,78 @@ static void enic_reset_mcaddrs(struct enic *enic)
 
 static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 {
-	if (!is_valid_ether_addr(addr))
-		return -EADDRNOTAVAIL;
+	struct enic *enic = netdev_priv(netdev);
+
+	if (enic_is_dynamic(enic)) {
+		if (!is_valid_ether_addr(addr) && !is_zero_ether_addr(addr))
+			return -EADDRNOTAVAIL;
+	} else {
+		if (!is_valid_ether_addr(addr))
+			return -EADDRNOTAVAIL;
+	}
 
 	memcpy(netdev->dev_addr, addr, netdev->addr_len);
 
 	return 0;
 }
 
+static int enic_dev_add_station_addr(struct enic *enic)
+{
+	int err = 0;
+
+	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
+		spin_lock(&enic->devcmd_lock);
+		err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
+		spin_unlock(&enic->devcmd_lock);
+	}
+
+	return err;
+}
+
+static int enic_dev_del_station_addr(struct enic *enic)
+{
+	int err = 0;
+
+	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
+		spin_lock(&enic->devcmd_lock);
+		err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
+		spin_unlock(&enic->devcmd_lock);
+	}
+
+	return err;
+}
+
+static int enic_set_mac_address_dynamic(struct net_device *netdev, void *p)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct sockaddr *saddr = p;
+	char *addr = saddr->sa_data;
+	int err;
+
+	if (netif_running(enic->netdev)) {
+		err = enic_dev_del_station_addr(enic);
+		if (err)
+			return err;
+	}
+
+	err = enic_set_mac_addr(netdev, addr);
+	if (err)
+		return err;
+
+	if (netif_running(enic->netdev)) {
+		err = enic_dev_add_station_addr(enic);
+		if (err)
+			return err;
+	}
+
+	return err;
+}
+
+static int enic_set_mac_address(struct net_device *netdev, void *p)
+{
+	return -EOPNOTSUPP;
+}
+
 /* netif_tx_lock held, BHs disabled */
 static void enic_set_multicast_list(struct net_device *netdev)
 {
@@ -922,6 +995,213 @@ static void enic_tx_timeout(struct net_device *netdev)
 	schedule_work(&enic->reset);
 }
 
+static int enic_vnic_dev_deinit(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_deinit(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_init_prov(enic->vdev,
+		(u8 *)vp, vic_provinfo_size(vp));
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_init_done(struct enic *enic, int *done, int *error)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_init_done(enic->vdev, done, error);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_set_port_profile(struct enic *enic, u8 request, u8 *mac,
+	char *name, u8 *instance_uuid, u8 *host_uuid)
+{
+	struct vic_provinfo *vp;
+	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
+	unsigned short *uuid;
+	char uuid_str[38];
+	static char *uuid_fmt = "%04X%04X-%04X-%04X-%04X-%04X%04X%04X";
+	int err;
+
+	if (!name)
+		return -EINVAL;
+
+	if (!is_valid_ether_addr(mac))
+		return -EADDRNOTAVAIL;
+
+	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
+	if (!vp)
+		return -ENOMEM;
+
+	vic_provinfo_add_tlv(vp,
+		VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
+		strlen(name) + 1, name);
+
+	vic_provinfo_add_tlv(vp,
+		VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+		ETH_ALEN, mac);
+
+	if (instance_uuid) {
+		uuid = (unsigned short *)instance_uuid;
+		sprintf(uuid_str, uuid_fmt,
+			uuid[0], uuid[1], uuid[2], uuid[3],
+			uuid[4], uuid[5], uuid[6], uuid[7]);
+		vic_provinfo_add_tlv(vp,
+			VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
+			sizeof(uuid_str), uuid_str);
+	}
+
+	if (host_uuid) {
+		uuid = (unsigned short *)host_uuid;
+		sprintf(uuid_str, uuid_fmt,
+			uuid[0], uuid[1], uuid[2], uuid[3],
+			uuid[4], uuid[5], uuid[6], uuid[7]);
+		vic_provinfo_add_tlv(vp,
+			VIC_LINUX_PROV_TLV_HOST_UUID_STR,
+			sizeof(uuid_str), uuid_str);
+	}
+
+	err = enic_vnic_dev_deinit(enic);
+	if (err)
+		goto err_out;
+
+	memset(&enic->pp, 0, sizeof(enic->pp));
+
+	err = enic_dev_init_prov(enic, vp);
+	if (err)
+		goto err_out;
+
+	enic->pp.request = request;
+	memcpy(enic->pp.name, name, PORT_PROFILE_MAX);
+	if (instance_uuid)
+		memcpy(enic->pp.instance_uuid,
+			instance_uuid, PORT_UUID_MAX);
+	if (host_uuid)
+		memcpy(enic->pp.host_uuid,
+			host_uuid, PORT_UUID_MAX);
+
+err_out:
+	vic_provinfo_free(vp);
+
+	return err;
+}
+
+static int enic_unset_port_profile(struct enic *enic)
+{
+	memset(&enic->pp, 0, sizeof(enic->pp));
+	return enic_vnic_dev_deinit(enic);
+}
+
+static int enic_set_vf_port(struct net_device *netdev, int vf,
+	struct nlattr *port[])
+{
+	struct enic *enic = netdev_priv(netdev);
+	char *name = NULL;
+	u8 *instance_uuid = NULL;
+	u8 *host_uuid = NULL;
+	u8 request = PORT_REQUEST_DISASSOCIATE;
+
+	/* don't support VFs, yet */
+	if (vf != PORT_SELF_VF)
+		return -EOPNOTSUPP;
+
+	if (port[IFLA_PORT_REQUEST])
+		request = nla_get_u8(port[IFLA_PORT_REQUEST]);
+
+	switch (request) {
+	case PORT_REQUEST_ASSOCIATE:
+
+		if (port[IFLA_PORT_PROFILE])
+			name = nla_data(port[IFLA_PORT_PROFILE]);
+
+		if (port[IFLA_PORT_INSTANCE_UUID])
+			instance_uuid =
+				nla_data(port[IFLA_PORT_INSTANCE_UUID]);
+
+		if (port[IFLA_PORT_HOST_UUID])
+			host_uuid = nla_data(port[IFLA_PORT_HOST_UUID]);
+
+		return enic_set_port_profile(enic, request,
+			netdev->dev_addr, name,
+			instance_uuid, host_uuid);
+
+	case PORT_REQUEST_DISASSOCIATE:
+
+		return enic_unset_port_profile(enic);
+
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int enic_get_vf_port(struct net_device *netdev, int vf,
+	struct sk_buff *skb)
+{
+	struct enic *enic = netdev_priv(netdev);
+	int err, error, done;
+	u16 response = PORT_PROFILE_RESPONSE_SUCCESS;
+
+	/* don't support VFs, yet */
+	if (vf != PORT_SELF_VF)
+		return -EOPNOTSUPP;
+
+	err = enic_dev_init_done(enic, &done, &error);
+
+	if (err)
+		return err;
+
+	switch (error) {
+	case ERR_SUCCESS:
+		if (!done)
+			response = PORT_PROFILE_RESPONSE_INPROGRESS;
+		break;
+	case ERR_EINVAL:
+		response = PORT_PROFILE_RESPONSE_INVALID;
+		break;
+	case ERR_EBADSTATE:
+		response = PORT_PROFILE_RESPONSE_BADSTATE;
+		break;
+	case ERR_ENOMEM:
+		response = PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES;
+		break;
+	default:
+		response = PORT_PROFILE_RESPONSE_ERROR;
+		break;
+	}
+
+	NLA_PUT_U16(skb, IFLA_PORT_REQUEST, enic->pp.request);
+	NLA_PUT_U16(skb, IFLA_PORT_RESPONSE, response);
+	NLA_PUT(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX,
+		enic->pp.name);
+	NLA_PUT(skb, IFLA_PORT_INSTANCE_UUID, PORT_UUID_MAX,
+		enic->pp.instance_uuid);
+	NLA_PUT(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX,
+		enic->pp.host_uuid);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 {
 	struct enic *enic = vnic_dev_priv(rq->vdev);
@@ -1440,9 +1720,7 @@ static int enic_open(struct net_device *netdev)
 	for (i = 0; i < enic->rq_count; i++)
 		vnic_rq_enable(&enic->rq[i]);
 
-	spin_lock(&enic->devcmd_lock);
-	enic_add_station_addr(enic);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_add_station_addr(enic);
 	enic_set_multicast_list(netdev);
 
 	netif_wake_queue(netdev);
@@ -1489,6 +1767,8 @@ static int enic_stop(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
+	enic_dev_del_station_addr(enic);
+
 	for (i = 0; i < enic->wq_count; i++) {
 		err = vnic_wq_disable(&enic->wq[i]);
 		if (err)
@@ -1774,14 +2054,34 @@ static void enic_clear_intr_mode(struct enic *enic)
 	vnic_dev_set_intr_mode(enic->vdev, VNIC_DEV_INTR_MODE_UNKNOWN);
 }
 
+static const struct net_device_ops enic_netdev_dynamic_ops = {
+	.ndo_open		= enic_open,
+	.ndo_stop		= enic_stop,
+	.ndo_start_xmit		= enic_hard_start_xmit,
+	.ndo_get_stats		= enic_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list	= enic_set_multicast_list,
+	.ndo_set_mac_address	= enic_set_mac_address_dynamic,
+	.ndo_change_mtu		= enic_change_mtu,
+	.ndo_vlan_rx_register	= enic_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= enic_vlan_rx_kill_vid,
+	.ndo_tx_timeout		= enic_tx_timeout,
+	.ndo_set_vf_port	= enic_set_vf_port,
+	.ndo_get_vf_port	= enic_get_vf_port,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= enic_poll_controller,
+#endif
+};
+
 static const struct net_device_ops enic_netdev_ops = {
 	.ndo_open		= enic_open,
 	.ndo_stop		= enic_stop,
 	.ndo_start_xmit		= enic_hard_start_xmit,
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_set_multicast_list	= enic_set_multicast_list,
+	.ndo_set_mac_address	= enic_set_mac_address,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
@@ -2010,11 +2310,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	netif_carrier_off(netdev);
 
-	err = vnic_dev_init(enic->vdev, 0);
-	if (err) {
-		printk(KERN_ERR PFX
-			"vNIC dev init failed, aborting.\n");
-		goto err_out_dev_close;
+	if (!enic_is_dynamic(enic)) {
+		err = vnic_dev_init(enic->vdev, 0);
+		if (err) {
+			printk(KERN_ERR PFX
+				"vNIC dev init failed, aborting.\n");
+			goto err_out_dev_close;
+		}
 	}
 
 	err = enic_dev_init(enic);
@@ -2054,7 +2356,11 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
 	enic->rx_coalesce_usecs = enic->tx_coalesce_usecs;
 
-	netdev->netdev_ops = &enic_netdev_ops;
+	if (enic_is_dynamic(enic))
+		netdev->netdev_ops = &enic_netdev_dynamic_ops;
+	else
+		netdev->netdev_ops = &enic_netdev_ops;
+
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 02839bf..9b18840 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -103,11 +103,6 @@ int enic_get_vnic_config(struct enic *enic)
 	return 0;
 }
 
-void enic_add_station_addr(struct enic *enic)
-{
-	vnic_dev_add_addr(enic->vdev, enic->mac_addr);
-}
-
 void enic_add_multicast_addr(struct enic *enic, u8 *addr)
 {
 	vnic_dev_add_addr(enic->vdev, addr);
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index abc1974..494664f 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -131,7 +131,6 @@ static inline void enic_queue_rq_desc(struct vnic_rq *rq,
 struct enic;
 
 int enic_get_vnic_config(struct enic *);
-void enic_add_station_addr(struct enic *enic);
 void enic_add_multicast_addr(struct enic *enic, u8 *addr);
 void enic_del_multicast_addr(struct enic *enic, u8 *addr);
 void enic_add_vlan(struct enic *enic, u16 vlanid);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index d43a9d4..2b3e16d 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -530,7 +530,7 @@ void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 		printk(KERN_ERR "Can't set packet filter\n");
 }
 
-void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
+int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
@@ -543,9 +543,11 @@ void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 	if (err)
 		printk(KERN_ERR "Can't add addr [%pM], %d\n", addr, err);
+
+	return err;
 }
 
-void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
+int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
@@ -558,6 +560,8 @@ void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
 	if (err)
 		printk(KERN_ERR "Can't del addr [%pM], %d\n", addr, err);
+
+	return err;
 }
 
 int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
@@ -682,6 +686,56 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	return r;
 }
 
+int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int ret;
+
+	*done = 0;
+
+	ret = vnic_dev_cmd(vdev, CMD_INIT_STATUS, &a0, &a1, wait);
+	if (ret)
+		return ret;
+
+	*done = (a0 == 0);
+
+	*err = (a0 == 0) ? a1 : 0;
+
+	return 0;
+}
+
+int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len)
+{
+	u64 a0, a1 = len;
+	int wait = 1000;
+	u64 prov_pa;
+	void *prov_buf;
+	int ret;
+
+	prov_buf = pci_alloc_consistent(vdev->pdev, len, &prov_pa);
+	if (!prov_buf)
+		return -ENOMEM;
+
+	memcpy(prov_buf, buf, len);
+
+	a0 = prov_pa;
+
+	ret = vnic_dev_cmd(vdev, CMD_INIT_PROV_INFO, &a0, &a1, wait);
+
+	pci_free_consistent(vdev->pdev, len, prov_buf, prov_pa);
+
+	return ret;
+}
+
+int vnic_dev_deinit(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+
+	return vnic_dev_cmd(vdev, CMD_DEINIT, &a0, &a1, wait);
+}
+
 int vnic_dev_link_status(struct vnic_dev *vdev)
 {
 	if (vdev->linkstatus)
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index f5be640..caccce3 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -103,8 +103,8 @@ int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
 int vnic_dev_hang_notify(struct vnic_dev *vdev);
 void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
-void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
-void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
+int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
+int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
 int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
@@ -124,6 +124,9 @@ int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
 int vnic_dev_init(struct vnic_dev *vdev, int arg);
+int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err);
+int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
+int vnic_dev_deinit(struct vnic_dev *vdev);
 int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
new file mode 100644
index 0000000..d769772
--- /dev/null
+++ b/drivers/net/enic/vnic_vic.c
@@ -0,0 +1,73 @@
+/*
+ * Copyright 2010 Cisco Systems, Inc.  All rights reserved.
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
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+
+#include "vnic_vic.h"
+
+struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type)
+{
+	struct vic_provinfo *vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
+
+	if (!vp || !oui)
+		return NULL;
+
+	memcpy(vp->oui, oui, sizeof(vp->oui));
+	vp->type = type;
+	vp->length = htonl(sizeof(vp->num_tlvs));
+
+	return vp;
+}
+
+void vic_provinfo_free(struct vic_provinfo *vp)
+{
+	kfree(vp);
+}
+
+int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
+	void *value)
+{
+	struct vic_provinfo_tlv *tlv;
+
+	if (!vp || !value)
+		return -EINVAL;
+
+	if (ntohl(vp->length) + sizeof(*tlv) + length >
+		VIC_PROVINFO_MAX_TLV_DATA)
+		return -ENOMEM;
+
+	tlv = (struct vic_provinfo_tlv *)((u8 *)vp->tlv +
+		ntohl(vp->length) - sizeof(vp->num_tlvs));
+
+	tlv->type = htons(type);
+	tlv->length = htons(length);
+	memcpy(tlv->value, value, length);
+
+	vp->num_tlvs = htonl(ntohl(vp->num_tlvs) + 1);
+	vp->length = htonl(ntohl(vp->length) + sizeof(*tlv) + length);
+
+	return 0;
+}
+
+size_t vic_provinfo_size(struct vic_provinfo *vp)
+{
+	return vp ?  ntohl(vp->length) + sizeof(*vp) - sizeof(vp->num_tlvs) : 0;
+}
diff --git a/drivers/net/enic/vnic_vic.h b/drivers/net/enic/vnic_vic.h
new file mode 100644
index 0000000..085c2a2
--- /dev/null
+++ b/drivers/net/enic/vnic_vic.h
@@ -0,0 +1,59 @@
+/*
+ * Copyright 2010 Cisco Systems, Inc.  All rights reserved.
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
+#ifndef _VNIC_VIC_H_
+#define _VNIC_VIC_H_
+
+/* Note: All integer fields in NETWORK byte order */
+
+/* Note: String field lengths include null char */
+
+#define VIC_PROVINFO_CISCO_OUI		{ 0x00, 0x00, 0x0c }
+#define VIC_PROVINFO_LINUX_TYPE		0x2
+
+enum vic_linux_prov_tlv_type {
+	VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR = 0,
+	VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR = 1,			/* u8[6] */
+	VIC_LINUX_PROV_TLV_CLIENT_NAME_STR = 2,
+	VIC_LINUX_PROV_TLV_HOST_UUID_STR = 8,
+	VIC_LINUX_PROV_TLV_CLIENT_UUID_STR = 9,
+};
+
+struct vic_provinfo {
+	u8 oui[3];		/* OUI of data provider */
+	u8 type;		/* provider-specific type */
+	u32 length;		/* length of data below */
+	u32 num_tlvs;		/* number of tlvs */
+	struct vic_provinfo_tlv {
+		u16 type;
+		u16 length;
+		u8 value[0];
+	} tlv[0];
+} __attribute__ ((packed));
+
+#define VIC_PROVINFO_MAX_DATA		1385
+#define VIC_PROVINFO_MAX_TLV_DATA (VIC_PROVINFO_MAX_DATA - \
+	sizeof(struct vic_provinfo))
+
+struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type);
+void vic_provinfo_free(struct vic_provinfo *vp);
+int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
+	void *value);
+size_t vic_provinfo_size(struct vic_provinfo *vp);
+
+#endif	/* _VNIC_VIC_H_ */

