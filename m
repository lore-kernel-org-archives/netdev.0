From: Nick Carter <ncarter100@gmail.com>
Subject: [PATCH] bridge: Forward EAPOL when STP off
Date: Thu, 2 Jun 2011 16:59:13 +0100
Message-ID: <BANLkTimdK-5tsWcTFbe_-82fHxr4TN4F_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: benjamin.poirier@gmail.com, davem@davemloft.net,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53091 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab1FBP7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 11:59:13 -0400
Received: by pzk9 with SMTP id 9so448872pzk.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 08:59:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nick Carter <ncarter100@gmail.com>

If STP is disabled then forward frames destined to the 802.1X PAE group
address (01-80-C2-00-00-03)

This change is required to support virtual machines running an 802.1X
supplicant and bridged to an ethernet interface.

This change has been tested and works fine with a range of supplicants.

I don't think this change will break 802.3ad bonding inside of a bridge.
[See commit f01cb5fbea1c1613621f9f32f385e12c1a29dde0
 Revert "bridge: Forward reserved group addresses if !STP"]
Bonding uses the IEEE Std 802.3ad Slow_Protocols_Multicast address
"#define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}"
Which will not be caught by this patch.
---
 net/bridge/br_input.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f3ac1e8..d6b4479 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -165,7 +165,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 			goto drop;

 		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+		if (p->br->stp_enabled == BR_NO_STP &&
+		    (dest[5] == 0 || /* Bridge group address */
+		     dest[5] == 3))  /* 802.1X PAE address */
 			goto forward;

 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-- 
1.7.4.1
