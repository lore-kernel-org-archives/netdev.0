From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Tue, 18 Apr 2017 18:17:06 +0100
Message-ID: <20170418171706.21190-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00252a01.pphosted.com ([91.207.212.211]:35082 "EHLO
        mx08-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753817AbdDRRRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:17:35 -0400
Received: from pps.filterd (m0102629.ppops.net [127.0.0.1])
        by mx08-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3IHHY9H021594
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:17:34 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx08-00252a01.pphosted.com with ESMTP id 29u80f9m6u-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:17:33 +0100
Received: by mail-wr0-f198.google.com with SMTP id v52so19551173wrb.14
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:17:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was failing to check that the SKB wasn't cloned
before adding checksum data.
Replace existing handling to extend/copy the header buffer
with skb_cow_head.

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
---
Changes in v2
 - Changed skb_cow to skb_cow_head as suggested by netdev list


 drivers/net/usb/smsc95xx.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index df60c98..094f0ee 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -2067,13 +2067,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	/* We do not advertise SG, so skbs should be already linearized */
 	BUG_ON(skb_shinfo(skb)->nr_frags);
 
-	if (skb_headroom(skb) < overhead) {
-		struct sk_buff *skb2 = skb_copy_expand(skb,
-			overhead, 0, flags);
-		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+	/* Make writable and expand header space by overhead if required */
+	if (skb_cow_head(skb, overhead)) {
+		return NULL;
 	}
 
 	if (csum) {
-- 
2.9.3
