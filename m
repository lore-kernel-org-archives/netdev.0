From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 06/10] atl1: use csum_start
Date: Sat,  2 Feb 2008 19:50:08 -0600
Message-ID: <1202003412-4028-6-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:39489 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933297AbYBCBuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:24 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb->csum_start for tx checksum offload preparation. Also swap
the variables css and cso so they hold the intended values of csum
start and offset, respectively.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Acked-by: Chris Snook <csnook@redhat.com>
---
 drivers/net/atlx/atl1.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index f4add3c..9929822 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1347,16 +1347,17 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
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
1.5.3.8

