From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 3/5] net/packet: fix overflow in check for tp_frame_nr
Date: Tue, 28 Mar 2017 16:00:46 +0200
Message-ID: <69c847e0cfbf26c38d6dfa6289ce5ca830866b42.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:36002 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754155AbdC1OBg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:36 -0400
Received: by mail-wr0-f179.google.com with SMTP id w11so88287388wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:30 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating rb->frames_per_block * req->tp_block_nr the result
can overflow.

Add a check that tp_block_size * tp_block_nr <= UINT_MAX.

Since frames_per_block <= tp_block_size, the expression would
never overflow.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 506348abdf2f..c5c43fff8c01 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4197,6 +4197,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 			goto out;
 		if (unlikely(req->tp_frame_size == 0))
 			goto out;
+		if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
+					UINT_MAX))
+			goto out;
 
 		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
 			goto out;
-- 
2.12.2.564.g063fe858b8-goog
