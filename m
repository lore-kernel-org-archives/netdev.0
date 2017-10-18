From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: add tc flower support for ETH-SMAC rewrite
Date: Wed, 18 Oct 2017 20:49:12 +0530
Message-ID: <5d785b382ec7a7d76b662cdae7e8eac32188b32f.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:57734 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbdJRPUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:20:49 -0400
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Adds support for ETH-SMAC rewrite via TC-PEDIT action.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c | 10 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h |  3 +++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index 7c8b0c65934c..34d67a2a86f4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -45,6 +45,8 @@
 struct ch_tc_pedit_fields pedits[] = {
 	PEDIT_FIELDS(ETH_, DMAC_31_0, 4, dmac, 0),
 	PEDIT_FIELDS(ETH_, DMAC_47_32, 2, dmac, 4),
+	PEDIT_FIELDS(ETH_, SMAC_15_0, 2, smac, 0),
+	PEDIT_FIELDS(ETH_, SMAC_47_16, 4, smac, 2),
 };
 
 static struct ch_tc_flower_entry *allocate_flower_entry(void)
@@ -291,6 +293,13 @@ static void process_pedit_field(struct ch_filter_specification *fs, u32 val,
 		case PEDIT_ETH_DMAC_47_32_SMAC_15_0:
 			if (~mask & PEDIT_ETH_DMAC_MASK)
 				offload_pedit(fs, val, mask, ETH_DMAC_47_32);
+			else
+				offload_pedit(fs, val >> 16, mask >> 16,
+					      ETH_SMAC_15_0);
+			break;
+		case PEDIT_ETH_SMAC_47_16:
+			fs->newsmac = 1;
+			offload_pedit(fs, val, mask, ETH_SMAC_47_16);
 		}
 	}
 }
@@ -440,6 +449,7 @@ static int cxgb4_validate_flow_actions(struct net_device *dev,
 					switch (offset) {
 					case PEDIT_ETH_DMAC_31_0:
 					case PEDIT_ETH_DMAC_47_32_SMAC_15_0:
+					case PEDIT_ETH_SMAC_47_16:
 						break;
 					default:
 						netdev_err(dev, "%s: Unsupported pedit field\n",
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
index 7bf6cfa892aa..a2acb782918f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
@@ -57,6 +57,8 @@ struct ch_tc_flower_entry {
 enum {
 	ETH_DMAC_31_0,	/* dmac bits 0.. 31 */
 	ETH_DMAC_47_32,	/* dmac bits 32..47 */
+	ETH_SMAC_15_0,	/* smac bits 0.. 15 */
+	ETH_SMAC_47_16,	/* smac bits 16..47 */
 };
 
 struct ch_tc_pedit_fields {
@@ -72,6 +74,7 @@ struct ch_tc_pedit_fields {
 #define PEDIT_ETH_DMAC_MASK		0xffff
 #define PEDIT_ETH_DMAC_31_0		0x0
 #define PEDIT_ETH_DMAC_47_32_SMAC_15_0	0x4
+#define PEDIT_ETH_SMAC_47_16		0x8
 
 int cxgb4_tc_flower_replace(struct net_device *dev,
 			    struct tc_cls_flower_offload *cls);
-- 
2.14.1
