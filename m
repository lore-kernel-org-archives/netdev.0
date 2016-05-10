From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 1/6] drivers: net: xgene: fix IPv4 forward crash
Date: Mon,  9 May 2016 17:04:11 -0700
Message-ID: <1462838656-22043-2-git-send-email-isubramanian@apm.com>
References: <1462838656-22043-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36028 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869AbcEJADu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:03:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id bt5so77269131pac.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:03:50 -0700 (PDT)
In-Reply-To: <1462838656-22043-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the crash observed during IPv4 forward test by
setting the drop field in the dbptr.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c | 11 ++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h |  2 ++
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
index 6479288..472c0fb 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -43,6 +43,7 @@ static void xgene_cle_idt_to_hw(u32 dstqid, u32 fpsel,
 static void xgene_cle_dbptr_to_hw(struct xgene_enet_pdata *pdata,
 				  struct xgene_cle_dbptr *dbptr, u32 *buf)
 {
+	buf[0] = SET_VAL(CLE_DROP, dbptr->drop);
 	buf[4] = SET_VAL(CLE_FPSEL, dbptr->fpsel) |
 		 SET_VAL(CLE_DSTQIDL, dbptr->dstqid);
 
@@ -412,7 +413,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 			.branch = {
 				{
 					/* IPV4 */
-					.valid = 0,
+					.valid = 1,
 					.next_packet_pointer = 22,
 					.jump_bw = JMP_FW,
 					.jump_rel = JMP_ABS,
@@ -420,7 +421,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 					.next_node = PKT_PROT_NODE,
 					.next_branch = 0,
 					.data = 0x8,
-					.mask = 0xffff
+					.mask = 0x0
 				},
 				{
 					.valid = 0,
@@ -456,7 +457,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 					.next_node = RSS_IPV4_TCP_NODE,
 					.next_branch = 0,
 					.data = 0x0600,
-					.mask = 0xffff
+					.mask = 0x00ff
 				},
 				{
 					/* UDP */
@@ -468,7 +469,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 					.next_node = RSS_IPV4_UDP_NODE,
 					.next_branch = 0,
 					.data = 0x1100,
-					.mask = 0xffff
+					.mask = 0x00ff
 				},
 				{
 					.valid = 0,
@@ -642,7 +643,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 				{
 					/* TCP DST Port */
 					.valid = 0,
-					.next_packet_pointer = 256,
+					.next_packet_pointer = 258,
 					.jump_bw = JMP_FW,
 					.jump_rel = JMP_ABS,
 					.operation = EQT,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
index 13e829a..33c5f6b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
@@ -83,6 +83,8 @@
 #define CLE_TYPE_POS		0
 #define CLE_TYPE_LEN		2
 
+#define CLE_DROP_POS		28
+#define CLE_DROP_LEN		1
 #define CLE_DSTQIDL_POS		25
 #define CLE_DSTQIDL_LEN		7
 #define CLE_DSTQIDH_POS		0
-- 
1.9.1
