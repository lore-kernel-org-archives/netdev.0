From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: record rx queue for LRO packets
Date: Sat, 12 Oct 2013 14:08:34 -0700
Message-ID: <1381612114.3392.14.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34269 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125Ab3JLVIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 17:08:36 -0400
Received: by mail-pa0-f44.google.com with SMTP id lf10so5900169pab.31
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 14:08:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

RPS support is kind of broken on bnx2x, because only non LRO packets
get proper rx queue information. This triggers reorders, as it seems
bnx2x like to generate a non LRO packet for segment including TCP PUSH
flag : (this might be pure coincidence, but all the reorders I've
seen involve segments with a PUSH)

11:13:34.335847 IP A > B: . 415808:447136(31328) ack 1 win 457 <nop,nop,timestamp 3789336 3985797>
11:13:34.335992 IP A > B: . 447136:448560(1424) ack 1 win 457 <nop,nop,timestamp 3789336 3985797>
11:13:34.336391 IP A > B: . 448560:479888(31328) ack 1 win 457 <nop,nop,timestamp 3789337 3985797>
11:13:34.336425 IP A > B: P 511216:512640(1424) ack 1 win 457 <nop,nop,timestamp 3789337 3985798>
11:13:34.336423 IP A > B: . 479888:511216(31328) ack 1 win 457 <nop,nop,timestamp 3789337 3985798>
11:13:34.336924 IP A > B: . 512640:543968(31328) ack 1 win 457 <nop,nop,timestamp 3789337 3985798>
11:13:34.336963 IP A > B: . 543968:575296(31328) ack 1 win 457 <nop,nop,timestamp 3789337 3985798>

We must call skb_record_rx_queue() to properly give to RPS (and more
generally for TX queue selection on forward path) the receive queue
information.

Similar fix is needed for skb_mark_napi_id(), but will be handled
in a separate patch to ease stable backports.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0c64122..6e46cff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -681,6 +681,7 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		}
 	}
 #endif
+	skb_record_rx_queue(skb, fp->rx_queue);
 	napi_gro_receive(&fp->napi, skb);
 }
 
