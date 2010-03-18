From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: Fix tx checksum offload for small packets
Date: Thu, 18 Mar 2010 19:20:10 +0000
Message-ID: <1268940010-19394-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:33320 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751823Ab0CRTUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 15:20:13 -0400
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 6A79267BC8
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 19:20:10 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX checksum offload does not work properly when transmitting
UDP packets with 0, 1 or 2 bytes of data.  This patch works
around the problem by calculating checksums for these packets
in the driver.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d222d7e..829963f 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1189,9 +1189,21 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	}
 
 	if (csum) {
-		u32 csum_preamble = smsc95xx_calc_csum_preamble(skb);
-		skb_push(skb, 4);
-		memcpy(skb->data, &csum_preamble, 4);
+		if (skb->len <= 45) {
+			/* workaround - hardware tx checksum does not work
+			 * properly with extremely small packets */
+			long csstart = skb->csum_start - skb_headroom(skb);
+			__wsum calc = csum_partial(skb->data + csstart,
+				skb->len - csstart, 0);
+			*((__sum16 *)(skb->data + csstart 
+				+ skb->csum_offset)) = csum_fold(calc);
+
+			csum = false;
+		} else {
+			u32 csum_preamble = smsc95xx_calc_csum_preamble(skb);
+			skb_push(skb, 4);
+			memcpy(skb->data, &csum_preamble, 4);
+		}
 	}
 
 	skb_push(skb, 4);
-- 
1.6.6.1

