From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net]tg3: Clear NETIF_F_TSO6 flag before doing software GSO
Date: Wed, 18 Jun 2014 18:38:13 -0700
Message-ID: <1403141893-21735-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:8860 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbaFSBmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 21:42:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d3f6f3a1d818410c17445bce4f4caab52eb102f1 "tg3: Prevent page
allocation failure during TSO workaround" modified driver logic
to use tg3_tso_bug() for any TSO fragment that hits hardware bug
conditions thus the patch increased the scope of work for tg3_tso_bug()
to cover devices that support NETIF_F_TSO6 as well. Prior to the
patch, tg3_tso_bug() would only be used on devices supporting
NETIF_F_TSO.

A regression was introduced for IPv6 packets requiring the workaround.
To properly perform GSO on SKBs with TCPV6 gso_type, we need to call
skb_gso_segment() with NETIF_F_TSO6 feature flag cleared, or the
function will return NULL and cause a kernel oops as tg3 is not handling
a NULL return value. This patch fixes the problem.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cd92c49..ccb0023 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7859,8 +7859,8 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		netif_wake_queue(tp->dev);
 	}
 
-	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
-	if (IS_ERR(segs))
+	segs = skb_gso_segment(skb, tp->dev->features & ~(NETIF_F_TSO | NETIF_F_TSO6));
+	if (IS_ERR(segs) || !segs)
 		goto tg3_tso_bug_end;
 
 	do {
-- 
1.7.1
