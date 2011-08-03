From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/6] be2net: non-member vlan pkts not received in promiscous mode
Date: Wed, 3 Aug 2011 11:27:43 +0530
Message-ID: <1312351066-16745-4-git-send-email-sathya.perla@emulex.com>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Xavier Selvin <xavier.selvin@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:24506 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754511Ab1HCF4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 01:56:31 -0400
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While configuring promiscous mode, explicitly set the
VLAN_PROMISCOUS bit to make this happen. When switching off
promiscous mode, re-program the vids.

Signed-off-by: Xavier Selvin <xavier.selvin@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    6 ++++--
 drivers/net/benet/be_main.c |    7 +++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1c25dbd..73fd949 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1586,9 +1586,11 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, bool en)
 			OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req));
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
-	req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS);
+	req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS
+				| BE_IF_FLAGS_VLAN_PROMISCUOUS);
 	if (en)
-		req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS);
+		req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS
+				| BE_IF_FLAGS_VLAN_PROMISCUOUS);
 
 	sge->pa_hi = cpu_to_le32(upper_32_bits(promiscous_cmd.dma));
 	sge->pa_lo = cpu_to_le32(promiscous_cmd.dma & 0xFFFFFFFF);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3b2c5e6..32a5b11 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -728,6 +728,10 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 		status = be_cmd_vlan_config(adapter, if_handle, vtag, 1, 1, 0);
 	}
 
+	/* No need to further configure vids if in promiscuous mode */
+	if (adapter->promiscuous)
+		return 0;
+
 	if (adapter->vlans_added <= adapter->max_vlans)  {
 		/* Construct VLAN Table to give to HW */
 		for (i = 0; i < VLAN_N_VID; i++) {
@@ -787,6 +791,9 @@ static void be_set_multicast_list(struct net_device *netdev)
 	if (adapter->promiscuous) {
 		adapter->promiscuous = false;
 		be_cmd_promiscuous_config(adapter, false);
+
+		if (adapter->vlans_added)
+			be_vid_config(adapter, false, 0);
 	}
 
 	/* Enable multicast promisc if num configured exceeds what we support */
-- 
1.7.4

