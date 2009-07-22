From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [net-next-2.6 PATCH 1/5] vlan: adds fcoe offload
	related	net_device_ops and updates fcoe_ddp_xid field
Date: Wed, 22 Jul 2009 16:28:20 -0700
Message-ID: <20090722232759.26937.78765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Adds fcoe offload related net_device_ops functions vlan_dev_fcoe_ddp_setup
and vlan_dev_fcoe_ddp_done, their implementation simply calls real eth device
net_device_ops for FCoE DDP setup and done operations.

Updates VLAN netdev field value for fcoe_ddp_xid from real eth device netdev.

Above changes are required for fcoe DDP offload working on a VLAN interface.

Signed-off-by: Vasu Dev <vasu.dev-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

 net/8021q/vlan_dev.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

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
