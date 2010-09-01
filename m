From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC PATCH net-next-2.6] gro: drivers should feed GRO only with
 TCP packets
Date: Wed, 01 Sep 2010 19:04:46 +0200
Message-ID: <1283360686.2556.381.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:38770 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110Ab0IAREv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 13:04:51 -0400
Received: by ewy23 with SMTP id 23so4473799ewy.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 10:04:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many network devices can tell if an incoming frame is a TCP one for a
small cost.

Instead of feeding GRO with all packets, we could filter packets on this
information ?

This should help machines handling a mixed UDP/TCP workload, keeping gro
overhead as small as possible.

patch against tg3 as an example...

Alternative would be to set a bit "is_tcp" on napi_struct to let this
choice being done in network stack, not by each driver. 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tg3.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bc3af78..d530a0a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4748,13 +4748,25 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			}
 		}
 
+		/*
+		 * give to GRO stack only TCP frames, with good checksums.
+		 */
+		if ((desc->type_flags & RXD_FLAG_IS_TCP) &&
+		    skb->ip_summed == CHECKSUM_UNNECESSARY) {
 #if TG3_VLAN_TAG_USED
-		if (hw_vlan)
-			vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
-		else
+			if (hw_vlan)
+				vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
+			else
 #endif
-			napi_gro_receive(&tnapi->napi, skb);
-
+				napi_gro_receive(&tnapi->napi, skb);
+		} else {
+#if TG3_VLAN_TAG_USED
+			if (hw_vlan)
+				vlan_hwaccel_receive_skb(skb, tp->vlgrp, vtag);
+			else
+#endif
+				netif_receive_skb(skb);
+		}
 		received++;
 		budget--;
 


