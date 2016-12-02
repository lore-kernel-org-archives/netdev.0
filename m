From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 5/8] drivers: net: xgene: fix: RSS for non-TCP/UDP
Date: Thu,  1 Dec 2016 16:41:41 -0800
Message-ID: <1480639304-18757-6-git-send-email-isubramanian@apm.com>
References: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Khuong Dinh <kdinh@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34936 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757425AbcLBAko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 19:40:44 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so100702986pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 16:40:44 -0800 (PST)
In-Reply-To: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes RSS feature, for non-TCP/UDP packets.

Signed-off-by: Khuong Dinh <kdinh@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c | 90 ++++++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h |  1 +
 2 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
index caa55bd..1dc6c20 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -485,11 +485,11 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 				},
 				{
 					.valid = 0,
-					.next_packet_pointer = 260,
+					.next_packet_pointer = 26,
 					.jump_bw = JMP_FW,
 					.jump_rel = JMP_ABS,
 					.operation = EQT,
-					.next_node = LAST_NODE,
+					.next_node = RSS_IPV4_OTHERS_NODE,
 					.next_branch = 0,
 					.data = 0x0,
 					.mask = 0xffff
@@ -667,6 +667,92 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 			}
 		},
 		{
+			/* RSS_IPV4_OTHERS_NODE */
+			.node_type = EWDN,
+			.last_node = 0,
+			.hdr_len_store = 1,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = BOTH_BYTES,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 6,
+			.branch = {
+				{
+					/* SRC IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 28,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_OTHERS_NODE,
+					.next_branch = 1,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* SRC IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 30,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_OTHERS_NODE,
+					.next_branch = 2,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 32,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_OTHERS_NODE,
+					.next_branch = 3,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 34,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_OTHERS_NODE,
+					.next_branch = 4,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP SRC Port */
+					.valid = 0,
+					.next_packet_pointer = 36,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_OTHERS_NODE,
+					.next_branch = 5,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP DST Port */
+					.valid = 0,
+					.next_packet_pointer = 260,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = LAST_NODE,
+					.next_branch = 0,
+					.data = 0x0,
+					.mask = 0xffff
+				}
+			}
+		},
+
+		{
 			/* LAST NODE */
 			.node_type = EWDN,
 			.last_node = 1,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
index 903be0c..290d5d1 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
@@ -106,6 +106,7 @@ enum xgene_cle_ptree_nodes {
 	PKT_PROT_NODE,
 	RSS_IPV4_TCP_NODE,
 	RSS_IPV4_UDP_NODE,
+	RSS_IPV4_OTHERS_NODE,
 	LAST_NODE,
 	MAX_NODES
 };
-- 
1.9.1
