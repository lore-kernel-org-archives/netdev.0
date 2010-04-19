From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 2/2] add enic iovnl ops for dynamic vnics
Date: Mon, 19 Apr 2010 12:18:12 -0700
Message-ID: <20100419191812.10423.6378.stgit@savbu-pc100.cisco.com>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:10596 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab0DSTSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 15:18:13 -0400
In-Reply-To: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add enic iovnl ops to support setting port-profile for dynamic vnics.  Enic
dynamic vnics are just like normal enic eth vnics except dynamic vnics require
an extra configuration step to assign a port-profile identifier to the
interface before the interface is useable. Once assigned, link comes up
on the interface and is ready for I/O.  The port-profile is used to configure
the network port assigned to the interface.  The network port configuration
includes VLAN membership, QoS policies, and port security settings typical
of a data center network.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 drivers/net/enic/Makefile     |    2 -
 drivers/net/enic/enic.h       |    3 +
 drivers/net/enic/enic_iovnl.c |  136 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/enic/enic_main.c  |   67 +++++++++++++++++---
 drivers/net/enic/enic_res.c   |    5 ++
 drivers/net/enic/enic_res.h   |    1 
 drivers/net/enic/vnic_dev.c   |   58 +++++++++++++++++
 drivers/net/enic/vnic_dev.h   |    4 +
 drivers/net/enic/vnic_vic.c   |   73 ++++++++++++++++++++++
 drivers/net/enic/vnic_vic.h   |   58 +++++++++++++++++
 10 files changed, 394 insertions(+), 13 deletions(-)

diff --git a/drivers/net/enic/Makefile b/drivers/net/enic/Makefile
index 391c3bc..311613b 100644
--- a/drivers/net/enic/Makefile
+++ b/drivers/net/enic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o vnic_dev.o vnic_rq.o
+	enic_res.o vnic_dev.o vnic_rq.o vnic_vic.o enic_iovnl.o
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 5fa56f1..5790655 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -122,4 +122,7 @@ struct enic {
 	unsigned int cq_count;
 };
 
+void enic_set_multicast_list(struct net_device *netdev);
+void enic_set_iovnl_ops(struct net_device *netdev);
+
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/enic/enic_iovnl.c b/drivers/net/enic/enic_iovnl.c
new file mode 100644
index 0000000..37c5d85
--- /dev/null
+++ b/drivers/net/enic/enic_iovnl.c
@@ -0,0 +1,136 @@
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
+#include <linux/netdevice.h>
+#include <linux/iovnl.h>
+#include <net/iovnl.h>
+
+#include "enic_res.h"
+#include "enic.h"
+#include "vnic_dev.h"
+#include "vnic_vic.h"
+
+static int enic_provinfo_add_tlv_str(struct vic_provinfo *vp, u16 type,
+	char *str)
+{
+	return str ? vic_provinfo_add_tlv(vp, type, strlen(str) + 1, str) : 0;
+}
+
+static int enic_set_port_profile(struct net_device *dev,
+	struct net_device *vf_dev, char *port_profile,
+	u8 *client_mac_addr, char *client_name, char *host_uuid)
+{
+	struct enic *enic = netdev_priv(dev);
+	struct vic_provinfo *vp;
+	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
+	int enable = 1;
+	int err;
+
+	if (vf_dev && dev != vf_dev)
+		return -EINVAL;
+
+	if (!port_profile)
+		return -EINVAL;
+
+	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
+	if (!vp)
+		return -ENOMEM;
+
+	enic_provinfo_add_tlv_str(vp,
+		VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR, port_profile);
+	vic_provinfo_add_tlv(vp, VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
+		6, client_mac_addr);
+	enic_provinfo_add_tlv_str(vp,
+		VIC_LINUX_PROV_TLV_CLIENT_NAME_STR, client_name);
+	enic_provinfo_add_tlv_str(vp,
+		VIC_LINUX_PROV_TLV_HOST_UUID_STR, host_uuid);
+
+	spin_lock(&enic->devcmd_lock);
+
+	err = vnic_dev_deinit(enic->vdev);
+	if (err)
+		goto err_out;
+
+	err = vnic_dev_logical_uplink(enic->vdev, enable);
+	if (err)
+		goto err_out;
+
+	err = vnic_dev_init_prov(enic->vdev, (u8 *)vp,
+		vic_provinfo_size(vp));
+
+err_out:
+	spin_unlock(&enic->devcmd_lock);
+
+	vic_provinfo_free(vp);
+
+	enic_set_multicast_list(dev);
+
+	return err;
+}
+
+static int enic_get_init_status(struct net_device *dev,
+	struct net_device *vf_dev)
+{
+	struct enic *enic = netdev_priv(dev);
+	int done, err, error;
+
+	if (vf_dev && dev != vf_dev)
+		return IOV_PORT_PROFILE_STATUS_UNKNOWN;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_init_done(enic->vdev, &done, &error);
+	spin_unlock(&enic->devcmd_lock);
+
+	if (err || error)
+		return IOV_PORT_PROFILE_STATUS_ERROR;
+
+	if (!done)
+		return IOV_PORT_PROFILE_STATUS_INPROGRESS;
+
+	if (!error)
+		return IOV_PORT_PROFILE_STATUS_SUCCESS;
+
+	return IOV_PORT_PROFILE_STATUS_UNKNOWN;
+}
+
+static int enic_unset_port_profile(struct net_device *dev,
+	struct net_device *vf_dev)
+{
+	struct enic *enic = netdev_priv(dev);
+	int err;
+
+	if (vf_dev && dev != vf_dev)
+		return -EINVAL;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_deinit(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static const struct iovnl_ops enic_iovnl_ops = {
+	.set_port_profile		= enic_set_port_profile,
+	.unset_port_profile		= enic_unset_port_profile,
+	.get_port_profile_status	= enic_get_init_status,
+};
+
+void enic_set_iovnl_ops(struct net_device *netdev)
+{
+	netdev->iovnl_ops = &enic_iovnl_ops;
+}
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 1232887..2fcc161 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -49,10 +49,12 @@
 #define ENIC_DESC_MAX_SPLITS		(MAX_TSO / WQ_ENET_MAX_DESC_LEN + 1)
 
 #define PCI_DEVICE_ID_CISCO_VIC_ENET         0x0043  /* ethernet vnic */
+#define PCI_DEVICE_ID_CISCO_VIC_ENET_DYN     0x0044  /* enet dynamic vnic */
 
 /* Supported devices */
 static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
+	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_DYN) },
 	{ 0, }	/* end of table */
 };
 
@@ -113,6 +115,11 @@ static const struct enic_stat enic_rx_stats[] = {
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
@@ -810,16 +817,44 @@ static void enic_reset_mcaddrs(struct enic *enic)
 
 static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 {
-	if (!is_valid_ether_addr(addr))
-		return -EADDRNOTAVAIL;
+	struct enic *enic = netdev_priv(netdev);
+
+	if (enic_is_dynamic(enic)) {
+		if (!is_zero_ether_addr(addr) && !is_valid_ether_addr(addr))
+			return -EADDRNOTAVAIL;
+	} else {
+		if (!is_valid_ether_addr(addr))
+			return -EADDRNOTAVAIL;
+	}
 
 	memcpy(netdev->dev_addr, addr, netdev->addr_len);
 
 	return 0;
 }
 
+static int enic_set_mac_address(struct net_device *netdev, void *p)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct sockaddr *saddr = p;
+	char *addr = saddr->sa_data;
+	int err;
+
+	if (!enic_is_dynamic(enic))
+		return 0;
+
+	err = enic_set_mac_addr(netdev, addr);
+	if (!err) {
+		spin_lock(&enic->devcmd_lock);
+		enic_del_station_addr(enic);
+		enic_add_station_addr(enic);
+		spin_unlock(&enic->devcmd_lock);
+	}
+
+	return err;
+}
+
 /* netif_tx_lock held, BHs disabled */
-static void enic_set_multicast_list(struct net_device *netdev)
+void enic_set_multicast_list(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
@@ -1440,10 +1475,12 @@ static int enic_open(struct net_device *netdev)
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
@@ -1782,6 +1819,7 @@ static const struct net_device_ops enic_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_set_multicast_list	= enic_set_multicast_list,
+	.ndo_set_mac_address	= enic_set_mac_address,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
@@ -2010,11 +2048,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
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
@@ -2069,6 +2109,9 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	if (enic_is_dynamic(enic))
+		enic_set_iovnl_ops(netdev);
+
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
 	enic->lro_mgr.max_aggr = ENIC_LRO_MAX_AGGR;
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 02839bf..9f31f58 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -108,6 +108,11 @@ void enic_add_station_addr(struct enic *enic)
 	vnic_dev_add_addr(enic->vdev, enic->mac_addr);
 }
 
+void enic_del_station_addr(struct enic *enic)
+{
+	vnic_dev_del_addr(enic->vdev, enic->mac_addr);
+}
+
 void enic_add_multicast_addr(struct enic *enic, u8 *addr)
 {
 	vnic_dev_add_addr(enic->vdev, addr);
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index abc1974..0e16ba0 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -132,6 +132,7 @@ struct enic;
 
 int enic_get_vnic_config(struct enic *);
 void enic_add_station_addr(struct enic *enic);
+void enic_del_station_addr(struct enic *enic);
 void enic_add_multicast_addr(struct enic *enic, u8 *addr);
 void enic_del_multicast_addr(struct enic *enic, u8 *addr);
 void enic_add_vlan(struct enic *enic, u16 vlanid);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index d43a9d4..44b2e41 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -682,6 +682,64 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
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
+int vnic_dev_logical_uplink(struct vnic_dev *vdev, int enable)
+{
+	u64 a0 = enable, a1 = 0;
+	int wait = 1000;
+
+	return vnic_dev_cmd(vdev, CMD_LOGICAL_UPLINK, &a0, &a1, wait);
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
index f5be640..bd40045 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -124,6 +124,10 @@ int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
 int vnic_dev_init(struct vnic_dev *vdev, int arg);
+int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err);
+int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
+int vnic_dev_logical_uplink(struct vnic_dev *vdev, int enable);
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
index 0000000..a7899fb
--- /dev/null
+++ b/drivers/net/enic/vnic_vic.h
@@ -0,0 +1,58 @@
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

