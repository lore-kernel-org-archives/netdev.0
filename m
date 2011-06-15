From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH for 3.0-rc4 2/2] dp83640: drop PHY status frames in the driver.
Date: Wed, 15 Jun 2011 11:55:20 +0200
Message-ID: <c09567e3debd1b20c091e294ab06e071c0654e67.1308129342.git.richard.cochran@omicron.at>
References: <cover.1308129342.git.richard.cochran@omicron.at>
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47658 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348Ab1FOJzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 05:55:19 -0400
In-Reply-To: <cover.1308129342.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308129342.git.richard.cochran@omicron.at>
References: <cover.1308129342.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dp83640 PHY provides time stamp and other information via special
PHY status frames. Previously, the driver decoded the frames and then
let the network stack drop them. This works fine when the PTP messages
come over UDP.

However, when receiving PTP messages via L2 packets, this creates a
problem. The status frames use the official PTP destination MAC address,
and so they are delivered to user space along with the "real" frames,
causing confusion for applications.

This commit fixes the issue by simply dropping the PHY status frames
in the driver.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/dp83640.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index ead323e..2cd8dc5 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1044,8 +1044,8 @@ static bool dp83640_rxtstamp(struct phy_device *phydev,
 
 	if (is_status_frame(skb, type)) {
 		decode_status_frame(dp83640, skb);
-		/* Let the stack drop this frame. */
-		return false;
+		kfree_skb(skb);
+		return true;
 	}
 
 	SKB_PTP_TYPE(skb) = type;
-- 
1.7.0.4

