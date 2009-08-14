From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 01/12] vlan: adds fcoe offload related net_device_ops
	and updates fcoe_ddp_xid field
Date: Fri, 14 Aug 2009 15:41:07 -0700
Message-ID: <20090814224106.1640.6910.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev@intel.com>

Adds fcoe offload related net_device_ops functions vlan_dev_fcoe_ddp_setup
and vlan_dev_fcoe_ddp_done, their implementation simply calls real eth device
net_device_ops for FCoE DDP setup and done operations.

Updates VLAN netdev field value for fcoe_ddp_xid from real eth device netdev.

Above changes are required for fcoe DDP offload working on a VLAN interface.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan.c     |    3 +++
 net/8021q/vlan_dev.c |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a1f1630..e814794 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -391,6 +391,9 @@ static void vlan_transfer_features(struct net_device *dev,
 	vlandev->features &= ~dev->vlan_features;
 	vlandev->features |= dev->features & dev->vlan_features;
 	vlandev->gso_max_size = dev->gso_max_size;
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
+#endif
 
 	if (old_features != vlandev->features)
 		netdev_features_change(vlandev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 96bad8f..6e695ac 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -561,6 +561,33 @@ static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
 	return err;
 }
 
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+static int vlan_dev_fcoe_ddp_setup(struct net_device *dev, u16 xid,
+				   struct scatterlist *sgl, unsigned int sgc)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int rc = 0;
+
+	if (ops->ndo_fcoe_ddp_setup)
+		rc = ops->ndo_fcoe_ddp_setup(real_dev, xid, sgl, sgc);
+
+	return rc;
+}
+
+static int vlan_dev_fcoe_ddp_done(struct net_device *dev, u16 xid)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int len = 0;
+
+	if (ops->ndo_fcoe_ddp_done)
+		len = ops->ndo_fcoe_ddp_done(real_dev, xid);
+
+	return len;
+}
+#endif
+
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
@@ -635,6 +662,10 @@ static int vlan_dev_init(struct net_device *dev)
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	dev->fcoe_ddp_xid = real_dev->fcoe_ddp_xid;
+#endif
+
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
@@ -715,6 +746,10 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
+	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+#endif
 };
 
 static const struct net_device_ops vlan_netdev_accel_ops = {
@@ -731,6 +766,10 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
+	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+#endif
 };
 
 void vlan_setup(struct net_device *dev)

