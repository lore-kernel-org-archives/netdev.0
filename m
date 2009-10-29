From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] ixgbe: Add support for
	netdev_ops.ndo_fcoe_get_wwn to 82599
Date: Wed, 28 Oct 2009 21:24:56 -0700
Message-ID: <20091029042455.15957.87665.stgit@localhost.localdomain>
References: <20091029042339.15957.37676.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:52247
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751195AbZJ2E2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 00:28:46 -0400
In-Reply-To: <20091029042339.15957.37676.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Implements the netdev_ops.ndo_fcoe_get_wwn in 82599 if it finds valid
prefix for the World Wide Node Name (WWNN) or World Wide Port Name (WWPN),
as well as valid SAN MAC address.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_fcoe.c |   46 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c |    1 +
 3 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2b85416..7eb08a6 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -457,6 +457,7 @@ extern int ixgbe_fcoe_disable(struct net_device *netdev);
 extern u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter);
 extern u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up);
 #endif /* CONFIG_IXGBE_DCB */
+extern int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type);
 #endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index a3c9f99..edecdc8 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -718,3 +718,49 @@ u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up)
 	return 1;
 }
 #endif /* CONFIG_IXGBE_DCB */
+
+/**
+ * ixgbe_fcoe_get_wwn - get world wide name for the node or the port
+ * @netdev : ixgbe adapter
+ * @wwn : the world wide name
+ * @type: the type of world wide name
+ *
+ * Returns the node or port world wide name if both the prefix and the san
+ * mac address are valid, then the wwn is formed based on the NAA-2 for
+ * IEEE Extended name identifier (ref. to T10 FC-LS Spec., Sec. 15.3).
+ *
+ * Returns : 0 on success
+ */
+int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type)
+{
+	int rc = -EINVAL;
+	u16 prefix = 0xffff;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_mac_info *mac = &adapter->hw.mac;
+
+	switch (type) {
+	case NETDEV_FCOE_WWNN:
+		prefix = mac->wwnn_prefix;
+		break;
+	case NETDEV_FCOE_WWPN:
+		prefix = mac->wwpn_prefix;
+		break;
+	default:
+		break;
+	}
+
+	if ((prefix != 0xffff) &&
+	    is_valid_ether_addr(mac->san_addr)) {
+		*wwn = ((u64) prefix << 48) |
+		       ((u64) mac->san_addr[0] << 40) |
+		       ((u64) mac->san_addr[1] << 32) |
+		       ((u64) mac->san_addr[2] << 24) |
+		       ((u64) mac->san_addr[3] << 16) |
+		       ((u64) mac->san_addr[4] << 8)  |
+		       ((u64) mac->san_addr[5]);
+		rc = 0;
+	}
+	return rc;
+}
+
+
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4c8a449..45c5faf 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5449,6 +5449,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fcoe_ddp_done = ixgbe_fcoe_ddp_put,
 	.ndo_fcoe_enable = ixgbe_fcoe_enable,
 	.ndo_fcoe_disable = ixgbe_fcoe_disable,
+	.ndo_fcoe_get_wwn = ixgbe_fcoe_get_wwn,
 #endif /* IXGBE_FCOE */
 };
 

