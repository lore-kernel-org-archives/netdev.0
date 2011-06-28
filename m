From: David Lamparter <equinox@diac24.net>
Subject: [PATCH v2] bridge: ignore pause & bonding frames
Date: Wed, 29 Jun 2011 00:10:48 +0200
Message-ID: <1309299048-11619-1-git-send-email-equinox@diac24.net>
References: <1309298599-11266-1-git-send-email-equinox@diac24.net>
Cc: Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55558 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257Ab1F1WLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 18:11:04 -0400
In-Reply-To: <1309298599-11266-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch adds bonding frames to the special treatment party and has
both pause and bonding frames delivered on the underlying bridge member
device. we thus become 802.1AX section 5.2.1 compliant which quite
clearly has the link aggregation directly on top of the MAC layer, below
any bridging.

the matching is changed to mimic hardware switches, which match
802.3x/pause and 802.3ad/lacp by the hardware address (keep in mind the
existence of LLC/SNAP headers).

Signed-off-by: David Lamparter <equinox@diac24.net>
---
[v2:] ... and obviously i forget the "*pskb = skb;" - it's getting late.

note: this should actually fix some issues i was having with bridging
screwing up my bonding. i've resolved those by "brouting" LACP frames
in ebtables... (which this patch will also result in)

compile-tested only

 net/bridge/br_input.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f3ac1e8..3ef2861 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -160,9 +160,14 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	p = br_port_get_rcu(skb->dev);
 
 	if (unlikely(is_link_local(dest))) {
-		/* Pause frames shouldn't be passed up by driver anyway */
-		if (skb->protocol == htons(ETH_P_PAUSE))
-			goto drop;
+		/* Pause/3x frames shouldn't be passed up by driver anyway
+		 * LACP/3ad can never be allowed to cross even a dumb hub
+		 *
+		 * both are usually matched by group address */
+		if (dest[5] == 0x01 || dest[5] == 0x02) {
+			*pskb = skb;
+			return RX_HANDLER_PASS;
+		}
 
 		/* If STP is turned off, then forward */
 		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
-- 
1.7.5.3

