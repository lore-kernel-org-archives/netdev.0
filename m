From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V5 PATCH 3/3] Add SR-IOV support to enic (please don't
	apply this patch)
Date: Wed, 05 May 2010 21:42:16 -0700
Message-ID: <20100506044216.29677.55191.stgit@savbu-pc100.cisco.com>
References: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:37252 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab0EFEmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 00:42:17 -0400
In-Reply-To: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

This patch is to illustrate how port-profiles will be assigned to VFs in
a compliant SR-IOV enic device.  Here the VF devices are dynamic enics and
the PF device is a "static" enic device.  Only the PF device resonds to
ndo_vf_{set|get}_port_profile to set/get the port-profile on a VF.  It's
not possible to set a port-profile on a PF since PFs have an immutable port
assignment on the external switch, established when the PF was provisioned.

The same driver (enic) is used for both PFs and VFs devices.  The PF
enables N number of VFs based on a PF configuration parameter assigned
when the PF is provisioned.

While this patch is functionally complete, we (Cisco) need to do more testing
before we can cliam full SR-IOV support in Linux, so we ask that this patch
not be applied at this time.  it is provide with this patch set for
illustrative purposes only to show how the port-profile netlink API would
be used for a SR-IOV compliant device that supports port-profiles.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 drivers/net/enic/enic.h      |    5 +-
 drivers/net/enic/enic_main.c |   96 +++++++++++++++++++++++++++++++-----------
 drivers/net/enic/enic_res.c  |    3 +
 drivers/net/enic/vnic_dev.c  |   12 +++--
 drivers/net/enic/vnic_dev.h  |    6 +--
 drivers/net/enic/vnic_enet.h |    1 
 6 files changed, 86 insertions(+), 37 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 718033f..4d00e5e 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -34,7 +34,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.3.1.1-pp"
+#define DRV_VERSION		"1.3.1.1-sr-iov"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
@@ -95,7 +95,8 @@ struct enic {
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
-	struct ifla_vf_port_profile pp;
+	struct ifla_vf_port_profile *pp;
+	unsigned int vf_count;
 
 	/* work queue cache line section */
 	____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 8e5e46b..1488431 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -941,35 +941,36 @@ static void enic_tx_timeout(struct net_device *netdev)
 	schedule_work(&enic->reset);
 }
 
-static int enic_vnic_dev_deinit(struct enic *enic)
+static int enic_vnic_dev_deinit(struct enic *enic, int vf)
 {
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_deinit(enic->vdev);
+	err = vnic_dev_deinit(enic->vdev, vf);
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }
 
-static int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp)
+static int enic_dev_init_prov(struct enic *enic, int vf,
+	struct vic_provinfo *vp)
 {
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_prov(enic->vdev,
+	err = vnic_dev_init_prov(enic->vdev, vf,
 		(u8 *)vp, vic_provinfo_size(vp));
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }
 
-static int enic_dev_init_done(struct enic *enic, int *done, int *error)
+static int enic_dev_init_done(struct enic *enic, int vf, int *done, int *error)
 {
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_done(enic->vdev, done, error);
+	err = vnic_dev_init_done(enic->vdev, vf, done, error);
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
@@ -993,23 +994,22 @@ static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
 	struct enic *enic = netdev_priv(netdev);
 	struct vic_provinfo *vp;
 	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
-	u8 *mac = ivp->mac;
 	int err;
 
-	if (!enic_is_dynamic(enic))
+	if (enic_is_dynamic(enic))
 		return -EOPNOTSUPP;
 
-	memset(&enic->pp, 0, sizeof(enic->pp));
+	if (vf < 0 || vf >= enic->vf_count)
+		return -EOPNOTSUPP;
+
+	memset(&enic->pp[vf], 0, sizeof(enic->pp[vf]));
 
-	enic_vnic_dev_deinit(enic);
+	enic_vnic_dev_deinit(enic, vf);
 
 	if (strlen(ivp->port_profile) == 0)
 		return 0;
 
-	if (is_zero_ether_addr(mac))
-		mac = netdev->dev_addr;
-
-	if (!is_valid_ether_addr(mac))
+	if (!is_valid_ether_addr(ipv->mac))
 		return -EADDRNOTAVAIL;
 
 	vp = vic_provinfo_alloc(GFP_KERNEL, oui, VIC_PROVINFO_LINUX_TYPE);
@@ -1019,7 +1019,7 @@ static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
 	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_PORT_PROFILE_NAME_STR,
 		IFLA_VF_PORT_PROFILE_MAX, ivp->port_profile);
 	vic_provinfo_add_tlv(vp, VIC_LINUX_PROV_TLV_CLIENT_MAC_ADDR,
-		ETH_ALEN, mac);
+		ETH_ALEN, ivp->mac);
 	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_HOST_UUID_STR,
 		IFLA_VF_UUID_MAX, ivp->host_uuid);
 	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
@@ -1027,11 +1027,11 @@ static int enic_set_vf_port_profile(struct net_device *netdev, int vf,
 	enic_provinfo_add_tlv_str(vp, VIC_LINUX_PROV_TLV_CLIENT_NAME_STR,
 		IFLA_VF_CLIENT_NAME_MAX, ivp->client_name);
 
-	err = enic_dev_init_prov(enic, vp);
+	err = enic_dev_init_prov(enic, vf, vp);
 	if (err)
 		goto err_out;
 
-	memcpy(&enic->pp, ivp, sizeof(enic->pp));
+	memcpy(&enic->pp[vf], ivp, sizeof(enic->pp[vf]));
 
 err_out:
 	vic_provinfo_free(vp);
@@ -1045,23 +1045,26 @@ static int enic_get_vf_port_profile(struct net_device *netdev, int vf,
 	struct enic *enic = netdev_priv(netdev);
 	int err, error, done;
 
-	if (!enic_is_dynamic(enic))
+	if (enic_is_dynamic(enic))
+		return -EOPNOTSUPP;
+
+	if (vf < 0 || vf >= enic->vf_count)
 		return -EOPNOTSUPP;
 
-	enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_UNKNOWN;
+	enic->pp[vf].status = IFLA_VF_PORT_PROFILE_STATUS_UNKNOWN;
 
-	err = enic_dev_init_done(enic, &done, &error);
+	err = enic_dev_init_done(enic, vf, &done, &error);
 
 	if (err || error)
-		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_ERROR;
+		enic->pp[vf].status = IFLA_VF_PORT_PROFILE_STATUS_ERROR;
 
 	if (!done)
-		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_INPROGRESS;
+		enic->pp[vf].status = IFLA_VF_PORT_PROFILE_STATUS_INPROGRESS;
 
 	if (!error)
-		enic->pp.status = IFLA_VF_PORT_PROFILE_STATUS_SUCCESS;
+		enic->pp[vf].status = IFLA_VF_PORT_PROFILE_STATUS_SUCCESS;
 
-	memcpy(ivp, &enic->pp, sizeof(enic->pp));
+	memcpy(ivp, &enic->pp[vf], sizeof(enic->pp[vf]));
 
 	return 0;
 }
@@ -2023,6 +2026,37 @@ err_out_free_vnic_resources:
 	return err;
 }
 
+static int enic_enable_vfs(struct enic *enic)
+{
+	int err;
+
+	enic->vf_count = enic->config.vf_count;
+
+	enic->pp = kzalloc(enic->vf_count  *
+		sizeof(struct ifla_vf_port_profile), GFP_KERNEL);
+	if (!enic->pp)
+		return -ENOMEM;
+
+	if (enic->pdev->is_physfn && enic->vf_count > 0) {
+
+		err = pci_enable_sriov(enic->pdev, enic->vf_count);
+		if (err) {
+			kfree(enic->pp);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static void enic_disable_vfs(struct enic *enic)
+{
+       if (enic->pdev->is_physfn && enic->vf_count > 0)
+               pci_disable_sriov(enic->pdev);
+       kfree(enic->pp);
+       enic->vf_count = 0;
+}
+
 static void enic_iounmap(struct enic *enic)
 {
 	unsigned int i;
@@ -2174,6 +2208,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_dev_close;
 	}
 
+	err = enic_enable_vfs(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"SR-IOV VF enable failed, aborting.\n");
+		goto err_out_dev_deinit;
+	}
+
 	/* Setup notification timer, HW reset task, and locks
 	 */
 
@@ -2198,7 +2239,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR PFX
 			"Invalid MAC address, aborting.\n");
-		goto err_out_dev_deinit;
+		goto err_out_disable_vfs;
 	}
 
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
@@ -2234,11 +2275,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR PFX
 			"Cannot register net device, aborting.\n");
-		goto err_out_dev_deinit;
+		goto err_out_disable_vfs;
 	}
 
 	return 0;
 
+err_out_disable_vfs:
+	enic_disable_vfs(enic);
 err_out_dev_deinit:
 	enic_dev_deinit(enic);
 err_out_dev_close:
@@ -2267,6 +2310,7 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 
 		flush_scheduled_work();
 		unregister_netdev(netdev);
+		enic_disable_vfs(enic);
 		enic_dev_deinit(enic);
 		vnic_dev_close(enic->vdev);
 		vnic_dev_unregister(enic->vdev);
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 02839bf..dfb37f2 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -69,6 +69,7 @@ int enic_get_vnic_config(struct enic *enic)
 	GET_CONFIG(intr_timer_type);
 	GET_CONFIG(intr_mode);
 	GET_CONFIG(intr_timer_usec);
+	GET_CONFIG(vf_count);
 
 	c->wq_desc_count =
 		min_t(u32, ENIC_MAX_WQ_DESCS,
@@ -99,6 +100,8 @@ int enic_get_vnic_config(struct enic *enic)
 		c->mtu, ENIC_SETTING(enic, TXCSUM),
 		ENIC_SETTING(enic, RXCSUM), ENIC_SETTING(enic, TSO),
 		ENIC_SETTING(enic, LRO), c->intr_timer_usec);
+	if (c->vf_count)
+		printk(KERN_INFO PFX "vNIC SR-IOV VF count %d\n", c->vf_count);
 
 	return 0;
 }
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index e351b0f..261d5f0 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -682,9 +682,9 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	return r;
 }
 
-int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err)
+int vnic_dev_init_done(struct vnic_dev *vdev, u16 vf, int *done, int *err)
 {
-	u64 a0 = 0, a1 = 0;
+	u64 a0 = vf, a1 = 0;
 	int wait = 1000;
 	int ret;
 
@@ -701,9 +701,9 @@ int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err)
 	return 0;
 }
 
-int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len)
+int vnic_dev_init_prov(struct vnic_dev *vdev, u16 vf, u8 *buf, u32 len)
 {
-	u64 a0, a1 = len;
+	u64 a0, a1 = (u64)len | ((u64)vf << 32);
 	int wait = 1000;
 	u64 prov_pa;
 	void *prov_buf;
@@ -724,9 +724,9 @@ int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len)
 	return ret;
 }
 
-int vnic_dev_deinit(struct vnic_dev *vdev)
+int vnic_dev_deinit(struct vnic_dev *vdev, u16 vf)
 {
-	u64 a0 = 0, a1 = 0;
+	u64 a0 = vf, a1 = 0;
 	int wait = 1000;
 
 	return vnic_dev_cmd(vdev, CMD_DEINIT, &a0, &a1, wait);
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 27f5a5a..d508187 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -124,9 +124,9 @@ int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
 int vnic_dev_init(struct vnic_dev *vdev, int arg);
-int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err);
-int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
-int vnic_dev_deinit(struct vnic_dev *vdev);
+int vnic_dev_init_done(struct vnic_dev *vdev, u16 vf, int *done, int *err);
+int vnic_dev_init_prov(struct vnic_dev *vdev, u16 vf, u8 *buf, u32 len);
+int vnic_dev_deinit(struct vnic_dev *vdev, u16 vf);
 int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index 8eeb675..466a7b3 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -35,6 +35,7 @@ struct vnic_enet_config {
 	u8 intr_mode;
 	char devname[16];
 	u32 intr_timer_usec;
+	u16 vf_count;
 };
 
 #define VENETF_TSO		0x1	/* TSO enabled */

