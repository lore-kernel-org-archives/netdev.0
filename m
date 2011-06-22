From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 3/7] qlcnic: Add code to tune FW dump
Date: Wed, 22 Jun 2011 05:52:19 -0700
Message-ID: <1308747144-23785-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:55827 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756698Ab1FVNAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 09:00:22 -0400
In-Reply-To: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To accommodate change in FW dump template, it is required to modify the
FW dump routine that captures cache data. Also, the default mask is changed
to capture a dump that would cover all the protocols that this FW supports.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h    |    5 ++---
 drivers/net/qlcnic/qlcnic_hw.c |   14 +++++++++++---
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 194376e..e5bb332 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1220,8 +1220,7 @@ struct __ctrl {
 
 struct __cache {
 	__le32	addr;
-	u8	stride;
-	u8	rsvd;
+	__le16	stride;
 	__le16	init_tag_val;
 	__le32	size;
 	__le32	no_ops;
@@ -1319,7 +1318,7 @@ enum op_codes {
 #define QLCNIC_DUMP_SKIP	BIT_7
 
 #define QLCNIC_DUMP_MASK_MIN		3
-#define QLCNIC_DUMP_MASK_DEF		0x0f
+#define QLCNIC_DUMP_MASK_DEF		0x7f
 #define QLCNIC_DUMP_MASK_MAX		0xff
 #define QLCNIC_FORCE_FW_DUMP_KEY	0xdeadfeed
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 1947f81..81de563 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1509,18 +1509,26 @@ qlcnic_dump_l2_cache(struct qlcnic_adapter *adapter,
 
 	for (i = 0; i < l2->no_ops; i++) {
 		QLCNIC_WR_DUMP_REG(l2->addr, base, val);
-		do {
+		if (LSW(l2->ctrl_val))
 			QLCNIC_WR_DUMP_REG(l2->ctrl_addr, base,
 				LSW(l2->ctrl_val));
+		if (!poll_mask)
+			goto skip_poll;
+		do {
 			QLCNIC_RD_DUMP_REG(l2->ctrl_addr, base, &data);
 			if (!(data & poll_mask))
 				break;
 			msleep(1);
 			time_out++;
 		} while (time_out <= poll_to);
-		if (time_out > poll_to)
-			return -EINVAL;
 
+		if (time_out > poll_to) {
+			dev_err(&adapter->pdev->dev,
+				"Timeout exceeded in %s, aborting dump\n",
+				__func__);
+			return -EINVAL;
+		}
+skip_poll:
 		addr = l2->read_addr;
 		cnt = l2->read_addr_num;
 		while (cnt) {
-- 
1.7.4.1

