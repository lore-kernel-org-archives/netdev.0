From: Aurelien Jacobs <aurel@gnuage.org>
Subject: [PATCH] asix: fix infinite loop in rx_fixup()
Date: Sat,  7 Jan 2012 19:09:27 +0100
Message-ID: <1325959767-8075-1-git-send-email-aurel@gnuage.org>
Cc: Aurelien Jacobs <aurel@gnuage.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gnuage.org ([82.234.153.242]:34359 "EHLO gnuage.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497Ab2AGSJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jan 2012 13:09:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point if skb->len happens to be 2, the subsequant skb_pull(skb, 4)
call won't work and the skb->len won't be decreased and won't ever reach 0,
resulting in an infinite loop.

With an ASIX 88772 under heavy load, without this patch, rx_fixup() reaches
an infinite loop in less than a minute. With this patch applied,
no infinite loop even after hours of heavy load.

Signed-off-by: Aurelien Jacobs <aurel@gnuage.org>
---
 drivers/net/usb/asix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index dbdca22..df2b08d 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -374,11 +374,11 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			return 0;
 		}
 
 		skb_pull(skb, (size + 1) & 0xfffe);
 
-		if (skb->len == 0)
+		if (skb->len < sizeof(header))
 			break;
 
 		head = (u8 *) skb->data;
 		memcpy(&header, head, sizeof(header));
 		le32_to_cpus(&header);
-- 
1.7.8.2
