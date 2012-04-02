From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 07/51] nfc: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:57 -0400
Message-ID: <1333335521-1348-8-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab2DBC7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:14 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/nfc/netlink.c |   70 +++++++++++++++++++++++++++++++----------------------
 1 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 6404052..8937664 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -63,19 +63,23 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 
 	genl_dump_check_consistent(cb, hdr, &nfc_genl_family);
 
-	NLA_PUT_U32(msg, NFC_ATTR_TARGET_INDEX, target->idx);
-	NLA_PUT_U32(msg, NFC_ATTR_PROTOCOLS, target->supported_protocols);
-	NLA_PUT_U16(msg, NFC_ATTR_TARGET_SENS_RES, target->sens_res);
-	NLA_PUT_U8(msg, NFC_ATTR_TARGET_SEL_RES, target->sel_res);
-	if (target->nfcid1_len > 0)
-		NLA_PUT(msg, NFC_ATTR_TARGET_NFCID1, target->nfcid1_len,
-			target->nfcid1);
-	if (target->sensb_res_len > 0)
-		NLA_PUT(msg, NFC_ATTR_TARGET_SENSB_RES, target->sensb_res_len,
-			target->sensb_res);
-	if (target->sensf_res_len > 0)
-		NLA_PUT(msg, NFC_ATTR_TARGET_SENSF_RES, target->sensf_res_len,
-			target->sensf_res);
+	if (nla_put_u32(msg, NFC_ATTR_TARGET_INDEX, target->idx) ||
+	    nla_put_u32(msg, NFC_ATTR_PROTOCOLS, target->supported_protocols) ||
+	    nla_put_u16(msg, NFC_ATTR_TARGET_SENS_RES, target->sens_res) ||
+	    nla_put_u8(msg, NFC_ATTR_TARGET_SEL_RES, target->sel_res))
+		goto nla_put_failure;
+	if (target->nfcid1_len > 0 &&
+	    nla_put(msg, NFC_ATTR_TARGET_NFCID1, target->nfcid1_len,
+		    target->nfcid1))
+		goto nla_put_failure;
+	if (target->sensb_res_len > 0 &&
+	    nla_put(msg, NFC_ATTR_TARGET_SENSB_RES, target->sensb_res_len,
+		    target->sensb_res))
+		goto nla_put_failure;
+	if (target->sensf_res_len > 0 &&
+	    nla_put(msg, NFC_ATTR_TARGET_SENSF_RES, target->sensf_res_len,
+		    target->sensf_res))
+		goto nla_put_failure;
 
 	return genlmsg_end(msg, hdr);
 
@@ -170,7 +174,8 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 	if (!hdr)
 		goto free_msg;
 
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
+	if (nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx))
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
@@ -197,10 +202,11 @@ int nfc_genl_device_added(struct nfc_dev *dev)
 	if (!hdr)
 		goto free_msg;
 
-	NLA_PUT_STRING(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev));
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
-	NLA_PUT_U32(msg, NFC_ATTR_PROTOCOLS, dev->supported_protocols);
-	NLA_PUT_U8(msg, NFC_ATTR_DEVICE_POWERED, dev->dev_up);
+	if (nla_put_string(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev)) ||
+	    nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx) ||
+	    nla_put_u32(msg, NFC_ATTR_PROTOCOLS, dev->supported_protocols) ||
+	    nla_put_u8(msg, NFC_ATTR_DEVICE_POWERED, dev->dev_up))
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
@@ -229,7 +235,8 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
 	if (!hdr)
 		goto free_msg;
 
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
+	if (nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx))
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
@@ -259,10 +266,11 @@ static int nfc_genl_send_device(struct sk_buff *msg, struct nfc_dev *dev,
 	if (cb)
 		genl_dump_check_consistent(cb, hdr, &nfc_genl_family);
 
-	NLA_PUT_STRING(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev));
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
-	NLA_PUT_U32(msg, NFC_ATTR_PROTOCOLS, dev->supported_protocols);
-	NLA_PUT_U8(msg, NFC_ATTR_DEVICE_POWERED, dev->dev_up);
+	if (nla_put_string(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev)) ||
+	    nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx) ||
+	    nla_put_u32(msg, NFC_ATTR_PROTOCOLS, dev->supported_protocols) ||
+	    nla_put_u8(msg, NFC_ATTR_DEVICE_POWERED, dev->dev_up))
+		goto nla_put_failure;
 
 	return genlmsg_end(msg, hdr);
 
@@ -339,11 +347,14 @@ int nfc_genl_dep_link_up_event(struct nfc_dev *dev, u32 target_idx,
 	if (!hdr)
 		goto free_msg;
 
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
-	if (rf_mode == NFC_RF_INITIATOR)
-		NLA_PUT_U32(msg, NFC_ATTR_TARGET_INDEX, target_idx);
-	NLA_PUT_U8(msg, NFC_ATTR_COMM_MODE, comm_mode);
-	NLA_PUT_U8(msg, NFC_ATTR_RF_MODE, rf_mode);
+	if (nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx))
+		goto nla_put_failure;
+	if (rf_mode == NFC_RF_INITIATOR &&
+	    nla_put_u32(msg, NFC_ATTR_TARGET_INDEX, target_idx))
+		goto nla_put_failure;
+	if (nla_put_u8(msg, NFC_ATTR_COMM_MODE, comm_mode) ||
+	    nla_put_u8(msg, NFC_ATTR_RF_MODE, rf_mode))
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
@@ -376,7 +387,8 @@ int nfc_genl_dep_link_down_event(struct nfc_dev *dev)
 	if (!hdr)
 		goto free_msg;
 
-	NLA_PUT_U32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx);
+	if (nla_put_u32(msg, NFC_ATTR_DEVICE_INDEX, dev->idx))
+		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
 
-- 
1.7.7.6
