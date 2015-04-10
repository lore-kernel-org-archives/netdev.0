From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: add new bridge mode support function.
Date: Fri, 10 Apr 2015 00:53:14 -0700
Message-ID: <1428652398-10147-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:33743 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638AbbDJHxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:22 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch gathers together all the logic needed to configure bridge
modes.  Currently that it is rather simple but this is really laying
the ground work for future X550 feature enhancement.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 50 ++++++++++++++++++---------
 1 file changed, 34 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aceb13c..cb9c43f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7870,6 +7870,36 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return ndo_dflt_fdb_add(ndm, tb, dev, addr, vid, flags);
 }
 
+/**
+ * ixgbe_configure_bridge_mode - set various bridge modes
+ * @adapter - the private structure
+ * @mode - requested bridge mode
+ *
+ * Configure some settings require for various bridge modes.
+ **/
+static int ixgbe_configure_bridge_mode(struct ixgbe_adapter *adapter,
+				       __u16 mode)
+{
+	switch (mode) {
+	case BRIDGE_MODE_VEPA:
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, 0);
+		break;
+	case BRIDGE_MODE_VEB:
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC,
+				IXGBE_PFDTXGSWC_VT_LBEN);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	adapter->bridge_mode = mode;
+
+	e_info(drv, "enabling bridge mode: %s\n",
+	       mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+
+	return 0;
+}
+
 static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 				    struct nlmsghdr *nlh, u16 flags)
 {
@@ -7885,6 +7915,7 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 		return -EINVAL;
 
 	nla_for_each_nested(attr, br_spec, rem) {
+		u32 status;
 		__u16 mode;
 
 		if (nla_type(attr) != IFLA_BRIDGE_MODE)
@@ -7894,22 +7925,9 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 			return -EINVAL;
 
 		mode = nla_get_u16(attr);
-		switch (mode) {
-		case BRIDGE_MODE_VEPA:
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, 0);
-			break;
-		case BRIDGE_MODE_VEB:
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC,
-					IXGBE_PFDTXGSWC_VT_LBEN);
-			break;
-		default:
-			return -EINVAL;
-		}
-
-		adapter->bridge_mode = mode;
-
-		e_info(drv, "enabling bridge mode: %s\n",
-			mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+		status = ixgbe_configure_bridge_mode(adapter, mode);
+		if (status)
+			return status;
 
 		break;
 	}
-- 
1.9.3
