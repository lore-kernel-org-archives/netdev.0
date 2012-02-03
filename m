From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 2/4] qlcnic: report valid speed and duplex status when link is down
Date: Fri, 3 Feb 2012 15:45:42 -0800
Message-ID: <1328312745-19245-2-git-send-email-sony.chacko@qlogic.com>
References: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:43381
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754037Ab2BDABl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:01:41 -0500
In-Reply-To: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report valid link statistics when link is down.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    7 ++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    8 +++++++-
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index cc228cf..6b2cf8b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -155,7 +155,6 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int check_sfp_module = 0;
-	u16 pcifn = adapter->ahw->pci_func;
 
 	/* read which mode */
 	if (adapter->ahw->port_type == QLCNIC_GBE) {
@@ -194,10 +193,8 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			goto skip;
 		}
 
-		val = QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn));
-		ethtool_cmd_speed_set(ecmd, P3P_LINK_SPEED_MHZ *
-				      P3P_LINK_SPEED_VAL(pcifn, val));
-		ecmd->duplex = DUPLEX_FULL;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 		ecmd->autoneg = AUTONEG_DISABLE;
 	} else
 		return -EIO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 3866958..41d85ef 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1369,7 +1369,13 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 
 	adapter->module_type = module;
 	adapter->link_autoneg = autoneg;
-	adapter->link_speed = link_speed;
+
+	if (link_status) {
+		adapter->link_speed = link_speed;
+	} else {
+		adapter->link_speed = SPEED_UNKNOWN;
+		adapter->link_duplex = DUPLEX_UNKNOWN;
+	}
 }
 
 static void
-- 
1.6.4.4
