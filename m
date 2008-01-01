From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 10/26] atl1: use csum_start
Date: Mon, 31 Dec 2007 20:22:37 -0600
Message-ID: <1199154173-4058-11-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:64476 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbYAAC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:12 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb->csum_start for tx checksum offload preparation.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index b0c3273..31aad9f 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1376,16 +1376,17 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 	u8 css, cso;
 
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
-		cso = skb_transport_offset(skb);
-		css = cso + skb->csum_offset;
-		if (unlikely(cso & 0x1)) {
+		css = (u8) (skb->csum_start - skb_headroom(skb));
+		cso = css + (u8) skb->csum_offset;
+		if (unlikely(css & 0x1)) {
+			/* L1 hardware requires an even number here */
 			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"payload offset not an even number\n");
 			return -1;
 		}
-		ptpd->word3 |= (cso & TPD_PLOADOFFSET_MASK) <<
+		ptpd->word3 |= (css & TPD_PLOADOFFSET_MASK) <<
 			TPD_PLOADOFFSET_SHIFT;
-		ptpd->word3 |= (css & TPD_CCSUMOFFSET_MASK) <<
+		ptpd->word3 |= (cso & TPD_CCSUMOFFSET_MASK) <<
 			TPD_CCSUMOFFSET_SHIFT;
 		ptpd->word3 |= 1 << TPD_CUST_CSUM_EN_SHIFT;
 		return true;
-- 
1.5.3.3

