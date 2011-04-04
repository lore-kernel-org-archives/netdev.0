From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/8] benet: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:40 -0700
Message-ID: <20110404210805.802043416@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Kha
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43895 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755785Ab1DDWST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:19 -0400
Content-Disposition: inline; filename=benet-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/benet/be.h         |    1 
 drivers/net/benet/be_ethtool.c |   42 ++++++++++++++++++++++-------------------
 2 files changed, 24 insertions(+), 19 deletions(-)

--- a/drivers/net/benet/be.h	2011-04-04 13:27:59.285137429 -0700
+++ b/drivers/net/benet/be.h	2011-04-04 13:31:08.107089776 -0700
@@ -313,6 +313,7 @@ struct be_adapter {
 	char fw_ver[FW_VER_LEN];
 	u32 if_handle;		/* Used to configure filtering */
 	u32 pmac_id;		/* MAC addr handle used by BE card */
+	u32 beacon_state;	/* for set_phys_id */
 
 	bool eeh_err;
 	bool link_up;
--- a/drivers/net/benet/be_ethtool.c	2011-04-04 13:24:55.943254754 -0700
+++ b/drivers/net/benet/be_ethtool.c	2011-04-04 13:32:35.043991789 -0700
@@ -526,29 +526,33 @@ be_set_pauseparam(struct net_device *net
 }
 
 static int
-be_phys_id(struct net_device *netdev, u32 data)
+be_set_phys_id(struct net_device *netdev,
+	       enum ethtool_phys_id_state state)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	int status;
-	u32 cur;
-
-	be_cmd_get_beacon_state(adapter, adapter->hba_port_num, &cur);
-
-	if (cur == BEACON_STATE_ENABLED)
-		return 0;
-
-	if (data < 2)
-		data = 2;
 
-	status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
-			BEACON_STATE_ENABLED);
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(data*HZ);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		be_cmd_get_beacon_state(adapter, adapter->hba_port_num,
+					&adapter->beacon_state);
+		return -EINVAL;
 
-	status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
-			BEACON_STATE_DISABLED);
+	case ETHTOOL_ID_ON:
+		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
+					BEACON_STATE_ENABLED);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
+					BEACON_STATE_DISABLED);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
+					adapter->beacon_state);
+	}
 
-	return status;
+	return 0;
 }
 
 static bool
@@ -753,7 +757,7 @@ const struct ethtool_ops be_ethtool_ops
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_strings = be_get_stat_strings,
-	.phys_id = be_phys_id,
+	.set_phys_id = be_set_phys_id,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.get_regs_len = be_get_reg_len,


