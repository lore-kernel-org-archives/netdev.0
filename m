From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V5 PATCH 2/3] Add ndo_{set|get}_vf_port_profile op
	support for enic dynamic vnics
Date: Wed, 05 May 2010 21:42:11 -0700
Message-ID: <20100506044211.29677.59331.stgit@savbu-pc100.cisco.com>
References: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:12701 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab0EFEmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 00:42:11 -0400
In-Reply-To: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add enic ndo_{set|get}_vf_port_profile ops to support setting/getting
port-profile for enic dynamic devices.  Enic dynamic devices are just like
normal enic eth devices except dynamic enics require an extra configuration
step to assign a port-profile identifier to the interface before the
interface is useable.  Once a port-profile is assigned, link comes up on the
interface and is ready for I/O.  The port-profile is used to configure the
network port assigned to the interface.  The network port configuration
includes VLAN membership, QoS policies, and port security settings typical
of a data center network.

A dynamic enic is assigned a default random mac address.  If no mac address
parameter is specified in the ndo_set_vf_port_profile op, the default random
mac address is used when assigning the port-profile.  Otherwise the mac
address specified in the op is used.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 drivers/net/enic/Makefile    |    2 
 drivers/net/enic/enic.h      |    3 -
 drivers/net/enic/enic_main.c |  200 +++++++++++++++++++++++++++++++++++++-----
 drivers/net/enic/vnic_dev.c  |   50 +++++++++++
 drivers/net/enic/vnic_dev.h  |    3 +
 drivers/net/enic/vnic_vic.c  |   73 +++++++++++++++
 drivers/net/enic/vnic_vic.h  |   59 ++++++++++++
 7 files changed, 363 insertions(+), 27 deletions(-)

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
index 5fa56f1..718033f 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -34,7 +34,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.3.1.1"
+#define DRV_VERSION		"1.3.1.1-pp"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
@@ -95,6 +95,7 @@ struct enic {
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
+	struct ifla_vf_port_profile pp;
 
 	/* work queue cache line section */
 	____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 1232887..8e5e46b 100644
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
@@ -810,14 +819,24 @@ static void enic_reset_mcaddrs(struct enic *enic)
 
 static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 {
-	if (!is_valid_ether_addr(addr))
-		return -EADDRNOTAVAIL;
+	struct enic *enic = netdev_priv(netdev);
 
-	memcpy(netdev->dev_addr, addr, netdev->addr_len);
+	if (enic_is_dynamic(enic)) {
+		random_ether_addr(netdev->dev_addr);
+	} else {
+		if (!is_valid_ether_addr(addr))
+			return -EADDRNOTAVAIL;
+		memcpy(netdev->dev_addr, addr, netdev->addr_len);
+	}
 
 	return 0;
 }
 
+static int enic_set_mac_address(struct net_device *netdev, void *p)
+{
+	return -EOPNOTSUPP;
+}
+
 /* netif_tx_lock held, BHs disabled */
 static void enic_set_multicast_list(struct net_device *netdev)
 {
@@ -922,6 +941,131 @@ static void enic_tx_timeout(struct net_device *netdev)
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
+static int enic_provinfo_add_tlv_str(struct vic_provinfo *vp, u16 type,
+	u16 max_length, char *str)
+{
+	if (!str)
+		return 0;
+
+	if (strlen(str) + 1 > max_length)
+		return 0;
+
+	return vic_provinfo_add_tlv(vp, type, strlen(str) + 1, str);
+}
+
+static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
+	struct ifla_vf_port_profile *ivp)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct vic_provinfo *vp;
+	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
+	u8 *mac = ivp->mac;
+	int err;
+
+	if (!enic_is_dynamic(enic))
+		return -EOPNOTSUPP;
+
+	memset(&enic->pp, 0, sizeof(enic->pp));
+
+	enic_vnic_dev_deinit(enic);
+
+	if (strlen(ivp->port_profile) == 0)
+		return 0;
+
+	if (is_zero_ether_addr(mac))
+		mac = netdev->dev_addr;
+
+	if (!is_valid_ether_addr(mac))
+		return -EADDRNOTAVAIL;
+
+	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
+	if (!vp)
+		return -ENOMEM;
+
+	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
+		IFLA_VF_PORT_PROFILE_MAX, ivp->port_profile);
+	vic_provinfo_add_tlv(vp, VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+		ETH_ALEN, mac);
+	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_HOST_UUID_STR,
+		IFLA_VF_UUID_MAX, ivp->host_uuid);
+	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
+		IFLA_VF_UUID_MAX, ivp->client_uuid);
+	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_NAME_STR,
+		IFLA_VF_CLIENT_NAME_MAX, ivp->client_name);
+
+	err = enic_dev_init_prov(enic, vp);
+	if (err)
+		goto err_out;
+
+	memcpy(&enic->pp, ivp, sizeof(enic->pp));
+
+err_out:
+	vic_provinfo_free(vp);
+
+	return err;
+}
+
+static int enic_get_vf_port_profile(struct net_device *netdev, int vf,
+	struct ifla_vf_port_profile *ivp)
+{
+	struct enic *enic = netdev_priv(netdev);
+	int err, error, done;
+
+	if (!enic_is_dynamic(enic))
+		return -EOPNOTSUPP;
+
+	enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_UNKNOWN;
+
+	err = enic_dev_init_done(enic, &done, &error);
+
+	if (err || error)
+		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_ERROR;
+
+	if (!done)
+		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_INPROGRESS;
+
+	if (!error)
+		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_SUCCESS;
+
+	memcpy(ivp, &enic->pp, sizeof(enic->pp));
+
+	return 0;
+}
+
 static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 {
 	struct enic *enic = vnic_dev_priv(rq->vdev);
@@ -1440,10 +1584,12 @@ static int enic_open(struct net_device *netdev)
 	for (i = 0; i < enic->rq_count; i++)
 		vnic_rq_enable(&enic->rq[i]);
 
-	spin_lock(&enic->devcmd_lock);
-	enic_add_station_addr(enic);
-	spin_unlock(&enic->devcmd_lock);
-	enic_set_multicast_list(netdev);
+	if (!enic_is_dynamic(enic)) {
+		spin_lock(&enic->devcmd_lock);
+		enic_add_station_addr(enic);
+		spin_unlock(&enic->devcmd_lock);
+		enic_set_multicast_list(netdev);
+	}
 
 	netif_wake_queue(netdev);
 	napi_enable(&enic->napi);
@@ -1775,20 +1921,22 @@ static void enic_clear_intr_mode(struct enic *enic)
 }
 
 static const struct net_device_ops enic_netdev_ops = {
-	.ndo_open		= enic_open,
-	.ndo_stop		= enic_stop,
-	.ndo_start_xmit		= enic_hard_start_xmit,
-	.ndo_get_stats		= enic_get_stats,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_set_multicast_list	= enic_set_multicast_list,
-	.ndo_change_mtu		= enic_change_mtu,
-	.ndo_vlan_rx_register	= enic_vlan_rx_register,
-	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= enic_vlan_rx_kill_vid,
-	.ndo_tx_timeout		= enic_tx_timeout,
+	.ndo_open			= enic_open,
+	.ndo_stop			= enic_stop,
+	.ndo_start_xmit			= enic_hard_start_xmit,
+	.ndo_get_stats			= enic_get_stats,
+	.ndo_validate_addr		= eth_validate_addr,
+	.ndo_set_multicast_list		= enic_set_multicast_list,
+	.ndo_set_mac_address		= enic_set_mac_address,
+	.ndo_change_mtu			= enic_change_mtu,
+	.ndo_vlan_rx_register		= enic_vlan_rx_register,
+	.ndo_vlan_rx_add_vid		= enic_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		= enic_vlan_rx_kill_vid,
+	.ndo_tx_timeout			= enic_tx_timeout,
+	.ndo_set_vf_port_profile	= enic_set_vf_port_profile,
+	.ndo_get_vf_port_profile	= enic_get_vf_port_profile,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= enic_poll_controller,
+	.ndo_poll_controller		= enic_poll_controller,
 #endif
 };
 
@@ -2010,11 +2158,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
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
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index d43a9d4..e351b0f 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -682,6 +682,56 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
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
index f5be640..27f5a5a 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
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

