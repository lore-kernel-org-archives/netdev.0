From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH v4] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Wed, 19 Apr 2017 11:13:40 +0100
Message-ID: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00252a01.pphosted.com ([62.209.51.214]:62471 "EHLO
        mx07-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761917AbdDSKNp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 06:13:45 -0400
Received: from pps.filterd (m0102628.ppops.net [127.0.0.1])
        by mx07-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JAAZ22015352
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 11:13:43 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx07-00252a01.pphosted.com with ESMTP id 29wqp2r9s9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 11:13:43 +0100
Received: by mail-wr0-f198.google.com with SMTP id p111so1943914wrc.10
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 03:13:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was failing to check that the SKB wasn't cloned
before adding checksum data.
Replace existing handling to extend/copy the header buffer
with skb_cow_head.

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
---
Changes 
v3 
 - Added the dev_kfree_skb_any call to ensure skb is deallocated 
   as when returning NULL the caller won't deallocate
v4 
 - Fix typo in comment (reallocate to deallocate) 

 drivers/net/usb/smsc95xx.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index df60c98..f6661e3 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -2067,13 +2067,13 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	/* We do not advertise SG, so skbs should be already linearized */
 	BUG_ON(skb_shinfo(skb)->nr_frags);
 
-	if (skb_headroom(skb) < overhead) {
-		struct sk_buff *skb2 = skb_copy_expand(skb,
-			overhead, 0, flags);
+	/* Make writable and expand header space by overhead if required */
+	if (skb_cow_head(skb, overhead)) {
+		/* Must deallocate here as returning NULL to indicate error
+		 * means the skb won't be deallocated in the caller.
+		 */
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	if (csum) {
-- 
2.9.3
