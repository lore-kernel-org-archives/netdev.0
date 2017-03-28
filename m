From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 1/5] net/packet: fix overflow in check for priv area size
Date: Tue, 28 Mar 2017 16:00:42 +0200
Message-ID: <56da2aa1dec51c258eb25693ed87e4de72413463.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:36003 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752667AbdC1OBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:17 -0400
Received: by mail-wr0-f175.google.com with SMTP id w11so88287414wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:11 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subtracting tp_sizeof_priv from tp_block_size and casting to int
to check whether one is less then the other doesn't always work
(both of them are unsigned ints).

Compare them as is instead.

Also cast tp_sizeof_priv to u64 before using BLK_PLUS_PRIV, as
it can overflow inside BLK_PLUS_PRIV otherwise.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a0dbe7ca8f72..2323ee35dc09 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4193,8 +4193,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
 			goto out;
 		if (po->tp_version >= TPACKET_V3 &&
-		    (int)(req->tp_block_size -
-			  BLK_PLUS_PRIV(req_u->req3.tp_sizeof_priv)) <= 0)
+		    req->tp_block_size <=
+			  BLK_PLUS_PRIV((u64)req_u->req3.tp_sizeof_priv))
 			goto out;
 		if (unlikely(req->tp_frame_size < po->tp_hdrlen +
 					po->tp_reserve))
-- 
2.12.2.564.g063fe858b8-goog
