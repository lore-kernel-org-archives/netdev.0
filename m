From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/5] net/packet: add explicit checks for tp_frame_size
Date: Tue, 28 Mar 2017 16:00:44 +0200
Message-ID: <2ee83356bdfba1242ce5d3190fbe9f312f6a7fda.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36788 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdC1OBW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:22 -0400
Received: by mail-lf0-f46.google.com with SMTP id x137so38882247lff.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:01 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tp_frame_size can't be 0 or be larger than tp_block_size.

As a result the check for frames_per_block == 0 is not needed any more.

Also do explicit checks for tp_block_size, instead of casting to int.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2323ee35dc09..506348abdf2f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4188,8 +4188,16 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		}
 
 		err = -EINVAL;
-		if (unlikely((int)req->tp_block_size <= 0))
+
+		if (unlikely(req->tp_block_size > INT_MAX))
+			goto out;
+		if (unlikely(req->tp_block_size == 0))
+			goto out;
+		if (unlikely(req->tp_frame_size > req->tp_block_size))
 			goto out;
+		if (unlikely(req->tp_frame_size == 0))
+			goto out;
+
 		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
 			goto out;
 		if (po->tp_version >= TPACKET_V3 &&
@@ -4203,8 +4211,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 			goto out;
 
 		rb->frames_per_block = req->tp_block_size / req->tp_frame_size;
-		if (unlikely(rb->frames_per_block == 0))
-			goto out;
 		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=
 					req->tp_frame_nr))
 			goto out;
-- 
2.12.2.564.g063fe858b8-goog
