From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 3/4] ethoc: align received packet to make IP header at word boundary
Date: Mon,  5 Oct 2009 17:33:19 +0800
Message-ID: <1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
 <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
Cc: netdev@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr33.hinet.net ([168.95.4.133]:57909 "EHLO msr33.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932288AbZJEKCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 06:02:20 -0400
In-Reply-To: <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet buffer is allocated at 4 bytes boundary, but the IP header
length and version bits is located at byte 14. These bit fields access
as 32 bits word and caused exception on processors that do not support
unaligned access.

The patch adds 2 bytes offset to make the bit fields word aligned.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index f92747f..0c6c7f4 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -399,6 +399,10 @@ static int ethoc_rx(struct net_device *dev, int limit)
 		if (ethoc_update_rx_stats(priv, &bd) == 0) {
 			int size = bd.stat >> 16;
 			struct sk_buff *skb = netdev_alloc_skb(dev, size);
+
+			size -= 4; /* strip the CRC */
+			skb_reserve(skb, 2); /* align TCP/IP header */
+
 			if (likely(skb)) {
 				void *src = phys_to_virt(bd.addr);
 				memcpy_fromio(skb_put(skb, size), src, size);
-- 
1.6.2.5

