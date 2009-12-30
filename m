From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] netxen: fix ethtool link test
Date: Wed, 30 Dec 2009 04:39:18 -0800
Message-ID: <1262176758-17803-3-git-send-email-amit.salecha@qlogic.com>
References: <1262176758-17803-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:32550 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751326AbZL3MjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2009 07:39:22 -0500
In-Reply-To: <1262176758-17803-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Fix ethtool link test for NX3031 chip.
o Remove unused code from phy interrupt callback

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |   23 ++++++++---------------
 drivers/net/netxen/netxen_nic_main.c    |    8 ++------
 2 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index e5af8b2..6f94c59 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -381,25 +381,18 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 static u32 netxen_nic_test_link(struct net_device *dev)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	__u32 status;
-	int val;
+	u32 val, port;
 
-	/* read which mode */
-	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		if (adapter->phy_read &&
-		    adapter->phy_read(adapter,
-				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-				      &status) != 0)
-			return -EIO;
-		else {
-			val = netxen_get_phy_link(status);
-			return !val;
-		}
-	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
+	port = adapter->physical_port;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		val = NXRD32(adapter, CRB_XG_STATE_P3);
+		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
+		return (val == XG_LINK_UP_P3) ? 0 : 1;
+	} else {
 		val = NXRD32(adapter, CRB_XG_STATE);
+		val = (val >> port*8) & 0xff;
 		return (val == XG_LINK_UP) ? 0 : 1;
 	}
-	return -EIO;
 }
 
 static int
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6cae26a..880fcd0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1898,12 +1898,8 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 		linkup = (val == XG_LINK_UP_P3);
 	} else {
 		val = NXRD32(adapter, CRB_XG_STATE);
-		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
-			linkup = (val >> port) & 1;
-		else {
-			val = (val >> port*8) & 0xff;
-			linkup = (val == XG_LINK_UP);
-		}
+		val = (val >> port*8) & 0xff;
+		linkup = (val == XG_LINK_UP);
 	}
 
 	netxen_advert_link_change(adapter, linkup);
-- 
1.6.0.2

