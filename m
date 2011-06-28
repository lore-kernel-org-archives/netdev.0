From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 2/2] bridge: pass through 802.1X & co. in 'dumb' mode
Date: Wed, 29 Jun 2011 00:03:19 +0200
Message-ID: <1309298599-11266-2-git-send-email-equinox@diac24.net>
References: <20110628214637.GE2121496@jupiter.n2.diac24.net>
 <1309298599-11266-1-git-send-email-equinox@diac24.net>
Cc: Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:37241 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600Ab1F1WDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 18:03:47 -0400
In-Reply-To: <1309298599-11266-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when operating without STP, we're a dumb switch and should be able to
forward ethernet management protocols like 802.1X, LLDP and GVRP.

if this is not desired, it can be enacted as local policy through
ebtables.

if we're in STP mode we basically claim to be an intelligent switch and
should implement these protocols properly (in userspace).

Signed-off-by: David Lamparter <equinox@diac24.net>
---
compile-tested only

 net/bridge/br_input.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index c873db5..4cee1b5 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -167,16 +167,19 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		if (dest[5] == 0x01 || dest[5] == 0x02)
 			return RX_HANDLER_PASS;
 
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+		/* If STP is turned off, we're a dumb switch and therefore
+		 * forward the remaining link-locals. (STP, 802.1X, LLDP,
+		 * GVRP & co.) */
+		if (p->br->stp_enabled == BR_NO_STP)
 			goto forward;
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
 		} else {
+			/* stay on physdev for userspace implementation */
 			*pskb = skb;
-			return RX_HANDLER_PASS;	/* continue processing */
+			return RX_HANDLER_PASS;
 		}
 	}
 
-- 
1.7.5.3

