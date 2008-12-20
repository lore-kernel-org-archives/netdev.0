From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/3] net: fix DCB setstate to return success/failure
Date: Fri, 19 Dec 2008 16:14:38 -0800
Message-ID: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:34020
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487AbYLTAPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 19:15:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Data Center Bridging (DCB) had no way to know if setstate had failed in the
driver.  This patch enables dcb netlink code to handle the status for the DCB
setstate interface.  Likewise it allows the driver to return a failed status
if MSI-X isn't enabled.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   52 +++++++++++++++++++++-----------------
 include/net/dcbnl.h              |    2 +
 net/dcb/dcbnl.c                  |    5 +---
 3 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 615c280..7d158a5 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -124,39 +124,45 @@ static u16 ixgbe_dcb_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
+static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
+	u8 err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	DPRINTK(DRV, INFO, "Set DCB Admin Mode.\n");
 
 	if (state > 0) {
 		/* Turn on DCB */
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			return;
-		} else {
-			if (netif_running(netdev))
-				netdev->stop(netdev);
-			ixgbe_reset_interrupt_capability(adapter);
-			ixgbe_napi_del_all(adapter);
-			kfree(adapter->tx_ring);
-			kfree(adapter->rx_ring);
-			adapter->tx_ring = NULL;
-			adapter->rx_ring = NULL;
-			netdev->select_queue = &ixgbe_dcb_select_queue;
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+			goto out;
 
-			adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-			adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-			ixgbe_init_interrupt_scheme(adapter);
-			ixgbe_napi_add_all(adapter);
-			if (netif_running(netdev))
-				netdev->open(netdev);
+		if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+			DPRINTK(DRV, ERR, "Enable failed, needs MSI-X\n");
+			err = 1;
+			goto out;
 		}
+
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_reset_interrupt_capability(adapter);
+		ixgbe_napi_del_all(adapter);
+		kfree(adapter->tx_ring);
+		kfree(adapter->rx_ring);
+		adapter->tx_ring = NULL;
+		adapter->rx_ring = NULL;
+		netdev->select_queue = &ixgbe_dcb_select_queue;
+
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+		ixgbe_init_interrupt_scheme(adapter);
+		ixgbe_napi_add_all(adapter);
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_open(netdev);
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			if (netif_running(netdev))
-				netdev->stop(netdev);
+				netdev->netdev_ops->ndo_stop(netdev);
 			ixgbe_reset_interrupt_capability(adapter);
 			ixgbe_napi_del_all(adapter);
 			kfree(adapter->tx_ring);
@@ -170,11 +176,11 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			ixgbe_init_interrupt_scheme(adapter);
 			ixgbe_napi_add_all(adapter);
 			if (netif_running(netdev))
-				netdev->open(netdev);
-		} else {
-			return;
+				netdev->netdev_ops->ndo_open(netdev);
 		}
 	}
+out:
+	return err;
 }
 
 static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 91e0a3d..775cfc8 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -26,7 +26,7 @@
  */
 struct dcbnl_rtnl_ops {
 	u8   (*getstate)(struct net_device *);
-	void (*setstate)(struct net_device *, u8);
+	u8   (*setstate)(struct net_device *, u8);
 	void (*getpermhwaddr)(struct net_device *, u8 *);
 	void (*setpgtccfgtx)(struct net_device *, int, u8, u8, u8, u8);
 	void (*setpgbwgcfgtx)(struct net_device *, int, u8);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index a125406..fc88fc4 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -714,9 +714,8 @@ static int dcbnl_setstate(struct net_device *netdev, struct nlattr **tb,
 
 	value = nla_get_u8(tb[DCB_ATTR_STATE]);
 
-	netdev->dcbnl_ops->setstate(netdev, value);
-
-	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_SSTATE, DCB_ATTR_STATE,
+	ret = dcbnl_reply(netdev->dcbnl_ops->setstate(netdev, value),
+	                  RTM_SETDCB, DCB_CMD_SSTATE, DCB_ATTR_STATE,
 	                  pid, seq, flags);
 
 	return ret;

