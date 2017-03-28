From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 5/5] net/packet: reorder checks for ring buffer parameters
Date: Tue, 28 Mar 2017 16:00:50 +0200
Message-ID: <c2f4929f3fcdc610c49dbf3d86f7312e84be8579.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:34723 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdC1OBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:09 -0400
Received: by mail-wr0-f176.google.com with SMTP id l43so106458047wre.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:08 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No semantic changes.

Improves readability.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 28b49749d1af..de25736a7988 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4191,6 +4191,11 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 
 		err = -EINVAL;
 
+		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
+			goto out;
+		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
+			goto out;
+
 		if (unlikely(req->tp_block_size > INT_MAX))
 			goto out;
 		if (unlikely(req->tp_block_size == 0))
@@ -4205,19 +4210,15 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		if (unlikely(po->tp_reserve >= req->tp_frame_size))
 			goto out;
 
-		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
+		rb->frames_per_block = req->tp_block_size / req->tp_frame_size;
+		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=
+					req->tp_frame_nr))
 			goto out;
+
 		if (po->tp_version >= TPACKET_V3 &&
 		    req->tp_block_size <=
 			  BLK_PLUS_PRIV((u64)req_u->req3.tp_sizeof_priv))
 			goto out;
-		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
-			goto out;
-
-		rb->frames_per_block = req->tp_block_size / req->tp_frame_size;
-		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=
-					req->tp_frame_nr))
-			goto out;
 
 		err = -ENOMEM;
 		order = get_order(req->tp_block_size);
-- 
2.12.2.564.g063fe858b8-goog
