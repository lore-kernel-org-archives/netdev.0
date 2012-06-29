From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 1/1] netxen_nic: restrict force firmware dump when dump is disabled.
Date: Fri, 29 Jun 2012 02:12:21 -0400
Message-ID: <1340950341-27252-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1340950341-27252-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:32920 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751751Ab2F2G2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 02:28:50 -0400
In-Reply-To: <1340950341-27252-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o Set the ethtool_dump flag (=ETH_FW_DUMP_DISABLE) when dump is disabled.
o update driver version to 4.0.80

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    4 ++--
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   13 ++++++++++---
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 37ccbe5..eb3dfdb 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 79
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.79"
+#define _NETXEN_NIC_LINUX_SUBVERSION 80
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.80"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 9103e3e..10468e7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -826,7 +826,12 @@ netxen_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 		dump->len = mdump->md_dump_size;
 	else
 		dump->len = 0;
-	dump->flag = mdump->md_capture_mask;
+
+	if (!mdump->md_enabled)
+		dump->flag = ETH_FW_DUMP_DISABLE;
+	else
+		dump->flag = mdump->md_capture_mask;
+
 	dump->version = adapter->fw_version;
 	return 0;
 }
@@ -840,8 +845,10 @@ netxen_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 
 	switch (val->flag) {
 	case NX_FORCE_FW_DUMP_KEY:
-		if (!mdump->md_enabled)
-			mdump->md_enabled = 1;
+		if (!mdump->md_enabled) {
+			netdev_info(netdev, "FW dump not enabled\n");
+			return 0;
+		}
 		if (adapter->fw_mdump_rdy) {
 			netdev_info(netdev, "Previous dump not cleared, not forcing dump\n");
 			return 0;
-- 
1.7.3.3
