From: Thomas Huth <thuth@redhat.com>
Subject: [PATCH] ibmveth: Add a proper check for the availability of the
 checksum features
Date: Tue, 24 Jan 2017 07:28:41 +0100
Message-ID: <1485239321-14947-1-git-send-email-thuth@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

When using the ibmveth driver in a KVM/QEMU based VM, it currently
always prints out a scary error message like this when it is started:

 ibmveth 71000003 (unregistered net_device): unable to change
 checksum offload settings. 1 rc=-2 ret_attr=71000003

This happens because the driver always tries to enable the checksum
offloading without checking for the availability of this feature first.
QEMU does not support checksum offloading for the spapr-vlan device,
thus we always get the error message here.
According to the LoPAPR specification, the "ibm,illan-options" property
of the corresponding device tree node should be checked first to see
whether the H_ILLAN_ATTRIUBTES hypercall and thus the checksum offloading
feature is available. Thus let's do this in the ibmveth driver, too, so
that the error message is really only limited to cases where something
goes wrong, and does not occur if the feature is just missing.

Signed-off-by: Thomas Huth <thuth@redhat.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index a831f94..309f5c6 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1601,8 +1601,11 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	netdev->netdev_ops = &ibmveth_netdev_ops;
 	netdev->ethtool_ops = &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
-	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	netdev->hw_features = NETIF_F_SG;
+	if (vio_get_attribute(dev, "ibm,illan-options", NULL) != NULL) {
+		netdev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+				       NETIF_F_RXCSUM;
+	}
 
 	netdev->features |= netdev->hw_features;
 
-- 
1.8.3.1
