From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 12/12] bnx2x: SR-IOV version compatibility
 bugfix
Date: Wed, 23 Jan 2013 15:21:54 +0200
Message-ID: <1358947314-3851-13-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1454 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755363Ab3AWOXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:17 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

When posting a message on the bulletin board, the PF calculates crc
over the message and places the result in the message. When the VF
samples the Bulletin Board it copies the message aside and validates
this crc. The length of the message is crucial here and must be the
same in both parties. Since the PF is running in the Hypervisor and
the VF is running in a Vm, they can possibly be of different versions.
As the Bulletin Board is designed to grow forward in future versions,
in the VF the length must not be the size of the message structure
but instead it should be a field in the message itself.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h  | 3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 5e45cb9..6adfa20 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3124,7 +3124,7 @@ u32 bnx2x_crc_vf_bulletin(struct bnx2x *bp,
 {
 	return crc32(BULLETIN_CRC_SEED,
 		 ((u8 *)bulletin) + sizeof(bulletin->crc),
-		 BULLETIN_CONTENT_SIZE - sizeof(bulletin->crc));
+		 bulletin->length - sizeof(bulletin->crc));
 }
 
 /* Check for new posts on the bulletin board */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 9cef520..3624612 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1631,7 +1631,6 @@ int bnx2x_post_vf_bulletin(struct bnx2x *bp, int vf)
 	dma_addr_t pf_addr = BP_VF_BULLETIN_DMA(bp)->mapping +
 		vf * BULLETIN_CONTENT_SIZE;
 	dma_addr_t vf_addr = bnx2x_vf(bp, vf, bulletin_map);
-	u32 len = BULLETIN_CONTENT_SIZE;
 	int rc;
 
 	/* can only update vf after init took place */
@@ -1641,11 +1640,12 @@ int bnx2x_post_vf_bulletin(struct bnx2x *bp, int vf)
 
 	/* increment bulletin board version and compute crc */
 	bulletin->version++;
+	bulletin->length = BULLETIN_CONTENT_SIZE;
 	bulletin->crc = bnx2x_crc_vf_bulletin(bp, bulletin);
 
 	/* propagate bulletin board via dmae to vm memory */
 	rc = bnx2x_copy32_vf_dmae(bp, false, pf_addr,
 				  bnx2x_vf(bp, vf, abs_vfid), U64_HI(vf_addr),
-				  U64_LO(vf_addr), len/4);
+				  U64_LO(vf_addr), bulletin->length / 4);
 	return rc;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index a74477c..bfc80ba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -318,7 +318,8 @@ struct pf_vf_bulletin_content {
 	u32 crc;			/* crc of structure to ensure is not in
 					 * mid-update
 					 */
-	u32 version;
+	u16 version;
+	u16 length;
 
 	aligned_u64 valid_bitmap;	/* bitmap indicating which fields
 					 * hold valid values
-- 
1.8.1.227.g44fe835
