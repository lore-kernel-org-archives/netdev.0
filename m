From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH] smsc95xx: Use skb_cow to deal with cloned skbs
Date: Tue, 18 Apr 2017 15:48:57 +0100
Message-ID: <20170418144857.7810-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00252a01.pphosted.com ([91.207.212.211]:60227 "EHLO
        mx08-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751300AbdDROtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:49:14 -0400
Received: from pps.filterd (m0102629.ppops.net [127.0.0.1])
        by mx08-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3IEh44P031598
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 15:49:12 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx08-00252a01.pphosted.com with ESMTP id 29u80f9jnt-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 15:49:12 +0100
Received: by mail-wr0-f198.google.com with SMTP id f13so19149822wrf.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:49:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was failing to check that the SKB wasn't cloned
before adding checksum data or adding header data.
Replace existing handling to extend the buffer with
skb_cow. Don't use skb_cow_head as the sw checksum
code modifies the data portion.

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
---
 drivers/net/usb/smsc95xx.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index df60c98..04f6397 100644
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
+	/* Make writable and expand space by overhead if required */
+	if (skb_cow(skb, overhead)) {
+		return NULL;
 	}
 
 	if (csum) {
-- 
2.9.3
