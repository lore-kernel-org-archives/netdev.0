From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 4/6] be2net: fix to ignore transparent vlan ids
 wrongly indicated by NIC
Date: Sun, 20 Feb 2011 15:41:53 -0600
Message-ID: <20110220214153.GA13675@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11624 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755162Ab1BTVmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:42:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With transparent VLAN tagging, the ASIC wrongly indicates packets with VLAN ID.
Strip them off in the driver. The VLAN Tag to be stripped will be given to the host
as an async message.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   14 ++++++++++++++
 drivers/net/benet/be_cmds.h |   13 +++++++++++++
 drivers/net/benet/be_main.c |    6 ++++++
 4 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index fb605e8..7bf8dd4 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -311,6 +311,7 @@ struct be_adapter {
 	struct be_vf_cfg vf_cfg[BE_MAX_VF];
 	u8 is_virtfn;
 	u32 sli_family;
+	u16 pvid;
 };
 
 #define be_physfn(adapter) (!adapter->is_virtfn)
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 7120106..59d25ac 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -124,6 +124,16 @@ static void be_async_grp5_qos_speed_process(struct be_adapter *adapter,
 	}
 }
 
+/*Grp5 PVID evt*/
+static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
+		struct be_async_event_grp5_pvid_state *evt)
+{
+	if (evt->enabled)
+		adapter->pvid = evt->tag;
+	else
+		adapter->pvid = 0;
+}
+
 static void be_async_grp5_evt_process(struct be_adapter *adapter,
 		u32 trailer, struct be_mcc_compl *evt)
 {
@@ -141,6 +151,10 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 		be_async_grp5_qos_speed_process(adapter,
 		(struct be_async_event_grp5_qos_link_speed *)evt);
 	break;
+	case ASYNC_EVENT_PVID_STATE:
+		be_async_grp5_pvid_state_process(adapter,
+		(struct be_async_event_grp5_pvid_state *)evt);
+	break;
 	default:
 		dev_warn(&adapter->pdev->dev, "Unknown grp5 event!\n");
 		break;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 331e954..a5af296 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -88,6 +88,7 @@ struct be_mcc_compl {
 #define ASYNC_EVENT_CODE_GRP_5		0x5
 #define ASYNC_EVENT_QOS_SPEED		0x1
 #define ASYNC_EVENT_COS_PRIORITY	0x2
+#define ASYNC_EVENT_PVID_STATE		0x3
 struct be_async_event_trailer {
 	u32 code;
 };
@@ -134,6 +135,18 @@ struct be_async_event_grp5_cos_priority {
 	struct be_async_event_trailer trailer;
 } __packed;
 
+/* When the event code of an async trailer is GRP5 and event type is
+ * PVID state, the mcc_compl must be interpreted as follows
+ */
+struct be_async_event_grp5_pvid_state {
+	u8 enabled;
+	u8 rsvd0;
+	u16 tag;
+	u32 event_tag;
+	u32 rsvd1;
+	struct be_async_event_trailer trailer;
+} __packed;
+
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
 	struct be_mcc_compl compl;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index b9e170d..cd6fda7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1047,6 +1047,9 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	if ((adapter->function_mode & 0x400) && !vtm)
 		vlanf = 0;
 
+	if ((adapter->pvid == vlanf) && !adapter->vlan_tag[vlanf])
+		vlanf = 0;
+
 	if (unlikely(vlanf)) {
 		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
 			kfree_skb(skb);
@@ -1087,6 +1090,9 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	if ((adapter->function_mode & 0x400) && !vtm)
 		vlanf = 0;
 
+	if ((adapter->pvid == vlanf) && !adapter->vlan_tag[vlanf])
+		vlanf = 0;
+
 	skb = napi_get_frags(&eq_obj->napi);
 	if (!skb) {
 		be_rx_compl_discard(adapter, rxo, rxcp);
-- 
1.7.1

