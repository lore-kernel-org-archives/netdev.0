From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6] cnic: Fix big endian bug
Date: Wed, 26 Jan 2011 00:14:50 -0800
Message-ID: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3045 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097Ab1AZJJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 04:09:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip's page tables did not set up properly on big endian machines,
causing EEH errors on PPC machines.

Reported-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 263a294..7ff170c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -699,13 +699,13 @@ static void cnic_free_dma(struct cnic_dev *dev, struct cnic_dma *dma)
 static void cnic_setup_page_tbl(struct cnic_dev *dev, struct cnic_dma *dma)
 {
 	int i;
-	u32 *page_table = dma->pgtbl;
+	__le32 *page_table = (__le32 *) dma->pgtbl;
 
 	for (i = 0; i < dma->num_pages; i++) {
 		/* Each entry needs to be in big endian format. */
-		*page_table = (u32) ((u64) dma->pg_map_arr[i] >> 32);
+		*page_table = cpu_to_le32((u64) dma->pg_map_arr[i] >> 32);
 		page_table++;
-		*page_table = (u32) dma->pg_map_arr[i];
+		*page_table = cpu_to_le32(dma->pg_map_arr[i] & 0xffffffff);
 		page_table++;
 	}
 }
@@ -713,13 +713,13 @@ static void cnic_setup_page_tbl(struct cnic_dev *dev, struct cnic_dma *dma)
 static void cnic_setup_page_tbl_le(struct cnic_dev *dev, struct cnic_dma *dma)
 {
 	int i;
-	u32 *page_table = dma->pgtbl;
+	__le32 *page_table = (__le32 *) dma->pgtbl;
 
 	for (i = 0; i < dma->num_pages; i++) {
 		/* Each entry needs to be in little endian format. */
-		*page_table = dma->pg_map_arr[i] & 0xffffffff;
+		*page_table = cpu_to_le32(dma->pg_map_arr[i] & 0xffffffff);
 		page_table++;
-		*page_table = (u32) ((u64) dma->pg_map_arr[i] >> 32);
+		*page_table = cpu_to_le32((u64) dma->pg_map_arr[i] >> 32);
 		page_table++;
 	}
 }
-- 
1.6.4.GIT


