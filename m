From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 1/4] be2net: Fix to use version 2 of cq_create for
 SkyHawk-R devices
Date: Wed, 1 May 2013 14:37:17 -0500
Message-ID: <20130501193717.GA3790@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6203 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab3EAThV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:37:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SkyHawk-R devices should use v2 of cq_create command.
BE3/BE2 devices can use version 0 of the command to create a CQ.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   27 ++++++++++++++-------------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 24c80d1..3c1632a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -963,19 +963,8 @@ int be_cmd_cq_create(struct be_adapter *adapter, struct be_queue_info *cq,
 		OPCODE_COMMON_CQ_CREATE, sizeof(*req), wrb, NULL);
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
-	if (lancer_chip(adapter)) {
-		req->hdr.version = 2;
-		req->page_size = 1; /* 1 for 4K */
-		AMAP_SET_BITS(struct amap_cq_context_lancer, nodelay, ctxt,
-								no_delay);
-		AMAP_SET_BITS(struct amap_cq_context_lancer, count, ctxt,
-						__ilog2_u32(cq->len/256));
-		AMAP_SET_BITS(struct amap_cq_context_lancer, valid, ctxt, 1);
-		AMAP_SET_BITS(struct amap_cq_context_lancer, eventable,
-								ctxt, 1);
-		AMAP_SET_BITS(struct amap_cq_context_lancer, eqid,
-								ctxt, eq->id);
-	} else {
+
+	if (BEx_chip(adapter)) {
 		AMAP_SET_BITS(struct amap_cq_context_be, coalescwm, ctxt,
 								coalesce_wm);
 		AMAP_SET_BITS(struct amap_cq_context_be, nodelay,
@@ -985,6 +974,18 @@ int be_cmd_cq_create(struct be_adapter *adapter, struct be_queue_info *cq,
 		AMAP_SET_BITS(struct amap_cq_context_be, valid, ctxt, 1);
 		AMAP_SET_BITS(struct amap_cq_context_be, eventable, ctxt, 1);
 		AMAP_SET_BITS(struct amap_cq_context_be, eqid, ctxt, eq->id);
+	} else {
+		req->hdr.version = 2;
+		req->page_size = 1; /* 1 for 4K */
+		AMAP_SET_BITS(struct amap_cq_context_v2, nodelay, ctxt,
+								no_delay);
+		AMAP_SET_BITS(struct amap_cq_context_v2, count, ctxt,
+						__ilog2_u32(cq->len/256));
+		AMAP_SET_BITS(struct amap_cq_context_v2, valid, ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_v2, eventable,
+								ctxt, 1);
+		AMAP_SET_BITS(struct amap_cq_context_v2, eqid,
+								ctxt, eq->id);
 	}
 
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 07fd927..ebaace8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -380,7 +380,7 @@ struct amap_cq_context_be {
 	u8 rsvd5[32];		/* dword 3*/
 } __packed;
 
-struct amap_cq_context_lancer {
+struct amap_cq_context_v2 {
 	u8 rsvd0[12];		/* dword 0*/
 	u8 coalescwm[2];	/* dword 0*/
 	u8 nodelay;		/* dword 0*/
-- 
1.7.10.4
