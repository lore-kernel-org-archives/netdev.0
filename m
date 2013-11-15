From: Ma JieYue <majieyue@gmail.com>
Subject: [PATCH net] xen-netfront: fix missing rx_refill_timer when allocate memory failed
Date: Fri, 15 Nov 2013 12:26:13 +0800
Message-ID: <1384489573-16605-1-git-send-email-jieyue.majy@alibaba-inc.com>
Cc: Ma JieYue <jieyue.majy@alibaba-inc.com>, david.vrabel@citrix.com,
	annie.li@oracle.com, boris.ostrovsky@oracle.com,
	xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org, konrad.wilk@oracle.com, wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:49091 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3KOE1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 23:27:02 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so3021476pbb.31
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 20:27:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ma JieYue <jieyue.majy@alibaba-inc.com>

There was a bug in xennet_alloc_rx_buffers, when allocating page or
sk_buff failed, and at the same time rx_batch queue not empty,
the rx_refill_timer timer won't be scheduled. If finally the remaining
request buffers in rx ring less than what backend driver expected,
the backend driver would think of rx ring as full and start dropping packets.
In such situation, there is no way for the netfront driver to recover
automatically, so that the device can not work properly.

The patch fixes the problem by always scheduling rx_refill_timer timer when
alloc_page or __netdev_alloc_skb fails, no matter whether rx_batch queue is
empty or not. It ensures that the rx ring request buffers will finally meet
the backend needs.

Signed-off-by: Ma JieYue <jieyue.majy@alibaba-inc.com>
---
 drivers/net/xen-netfront.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index dd1011e..5bd20d9 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -277,12 +277,13 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 		if (!page) {
 			kfree_skb(skb);
 no_skb:
-			/* Any skbuffs queued for refill? Force them out. */
-			if (i != 0)
-				goto refill;
 			/* Could not allocate any skbuffs. Try again later. */
 			mod_timer(&np->rx_refill_timer,
 				  jiffies + (HZ/10));
+
+			/* Any skbuffs queued for refill? Force them out. */
+			if (i != 0)
+				goto refill;
 			break;
 		}
 
-- 
1.8.4
