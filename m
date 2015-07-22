From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net-next] be2net: support ndo_get_phys_port_id()
Date: Wed, 22 Jul 2015 11:15:12 +0530
Message-ID: <1437543912-3096-1-git-send-email-sriharsha.basavapatna@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:58008 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751589AbbGVFrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:47:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>

Add be_get_phys_port_id() function to report physical port id. The port id
should be unique across different be2net devices in the system. We use the
chip serial number along with the physical port number for this.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  3 +++
 drivers/net/ethernet/emulex/benet/be_cmds.c |  7 ++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |  8 +++++---
 drivers/net/ethernet/emulex/benet/be_main.c | 22 ++++++++++++++++++++++
 4 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cb5777b..8cd384d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -105,6 +105,8 @@
 
 #define MAX_VFS			30 /* Max VFs supported by BE3 FW */
 #define FW_VER_LEN		32
+#define	CNTL_SERIAL_NUM_WORDS	8  /* Controller serial number words */
+#define	CNTL_SERIAL_NUM_WORD_SZ	(sizeof(u16)) /* Byte-sz of serial num word */
 
 #define	RSS_INDIR_TABLE_LEN	128
 #define RSS_HASH_KEY_LEN	40
@@ -590,6 +592,7 @@ struct be_adapter {
 	struct rss_info rss_info;
 	/* Filters for packets that need to be sent to BMC */
 	u32 bmc_filt_mask;
+	u16 serial_num[CNTL_SERIAL_NUM_WORDS];
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ecad46f..3be1fbd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2852,10 +2852,11 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_cntl_attribs *req;
 	struct be_cmd_resp_cntl_attribs *resp;
-	int status;
+	int status, i;
 	int payload_len = max(sizeof(*req), sizeof(*resp));
 	struct mgmt_controller_attrib *attribs;
 	struct be_dma_mem attribs_cmd;
+	u32 *serial_num;
 
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
@@ -2886,6 +2887,10 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	if (!status) {
 		attribs = attribs_cmd.va + sizeof(struct be_cmd_resp_hdr);
 		adapter->hba_port_num = attribs->hba_attribs.phy_port;
+		serial_num = attribs->hba_attribs.controller_serial_number;
+		for (i = 0; i < CNTL_SERIAL_NUM_WORDS; i++)
+			adapter->serial_num[i] = le32_to_cpu(serial_num[i]) &
+				(BIT_MASK(16) - 1);
 	}
 
 err:
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index a4479f7..36d835b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1637,10 +1637,12 @@ struct be_cmd_req_set_qos {
 struct mgmt_hba_attribs {
 	u32 rsvd0[24];
 	u8 controller_model_number[32];
-	u32 rsvd1[79];
-	u8 rsvd2[3];
+	u32 rsvd1[16];
+	u32 controller_serial_number[8];
+	u32 rsvd2[55];
+	u8 rsvd3[3];
 	u8 phy_port;
-	u32 rsvd3[13];
+	u32 rsvd4[13];
 } __packed;
 
 struct mgmt_controller_attrib {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c996dd7..5e92db8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5219,6 +5219,27 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 }
 #endif
 
+static int be_get_phys_port_id(struct net_device *dev,
+			       struct netdev_phys_item_id *ppid)
+{
+	int i, id_len = CNTL_SERIAL_NUM_WORDS * CNTL_SERIAL_NUM_WORD_SZ + 1;
+	struct be_adapter *adapter = netdev_priv(dev);
+	u8 *id;
+
+	if (MAX_PHYS_ITEM_ID_LEN < id_len)
+		return -ENOSPC;
+
+	ppid->id[0] = adapter->hba_port_num + 1;
+	id = &ppid->id[1];
+	for (i = CNTL_SERIAL_NUM_WORDS - 1; i >= 0;
+	     i--, id += CNTL_SERIAL_NUM_WORD_SZ)
+		memcpy(id, &adapter->serial_num[i], CNTL_SERIAL_NUM_WORD_SZ);
+
+	ppid->id_len = id_len;
+
+	return 0;
+}
+
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -5249,6 +5270,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_del_vxlan_port	= be_del_vxlan_port,
 	.ndo_features_check	= be_features_check,
 #endif
+	.ndo_get_phys_port_id   = be_get_phys_port_id,
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.8.3.1
