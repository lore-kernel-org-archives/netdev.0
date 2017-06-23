From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] net: dp83640: Avoid NULL pointer dereference.
Date: Fri, 23 Jun 2017 17:51:31 +0200
Message-ID: <20170623155131.21427-1-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Manfred Rudigier <Manfred.Rudigier@omicron.at>,
        =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34468 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbdFWPx0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 11:53:26 -0400
Received: by mail-wr0-f195.google.com with SMTP id k67so13446041wrc.1
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 08:53:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function, skb_complete_tx_timestamp(), used to allow passing in a
NULL pointer for the time stamps, but that was changed in commit
62bccb8cdb69051b95a55ab0c489e3cab261c8ef ("net-timestamp: Make the
clone operation stand-alone from phy timestamping"), and the existing
call sites, all of which are in the dp83640 driver, were fixed up.

Even though the kernel-doc was subsequently updated in commit
7a76a021cd5a292be875fbc616daf03eab1e6996 ("net-timestamp: Update
skb_complete_tx_timestamp comment"), still a bug fix from Manfred
Rudigier came into the driver using the old semantics.  Probably
Manfred derived that patch from an older kernel version.

This fix should be applied to the stable trees as well.

Fixes: 81e8f2e930fe ("net: dp83640: Fix tx timestamp overflow handling.")
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index ed0d10f54f26..c3065236ffcc 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -908,7 +908,7 @@ static void decode_txts(struct dp83640_private *dp83640,
 	if (overflow) {
 		pr_debug("tx timestamp queue overflow, count %d\n", overflow);
 		while (skb) {
-			skb_complete_tx_timestamp(skb, NULL);
+			kfree_skb(skb);
 			skb = skb_dequeue(&dp83640->tx_queue);
 		}
 		return;
-- 
2.11.0
