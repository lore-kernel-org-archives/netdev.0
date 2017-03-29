From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH net v2 2/3] net/packet: fix overflow in check for tp_frame_nr
Date: Wed, 29 Mar 2017 16:11:21 +0200
Message-ID: <b6e4098bf0d0bccc538e133ce5200432be8c4732.1490796500.git.andreyknvl@google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:33359 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752907AbdC2OLi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 10:11:38 -0400
Received: by mail-wr0-f181.google.com with SMTP id w43so17223649wrb.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 07:11:37 -0700 (PDT)
In-Reply-To: <cover.1490796500.git.andreyknvl@google.com>
In-Reply-To: <cover.1490796500.git.andreyknvl@google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating rb->frames_per_block * req->tp_block_nr the result
can overflow.

Add a check that tp_block_size * tp_block_nr <= UINT_MAX.

Since frames_per_block <= tp_block_size, the expression would
never overflow.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2323ee35dc09..3ac286ebb2f4 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4205,6 +4205,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		rb->frames_per_block = req->tp_block_size / req->tp_frame_size;
 		if (unlikely(rb->frames_per_block == 0))
 			goto out;
+		if (unlikely(req->tp_block_size > UINT_MAX / req->tp_block_nr))
+			goto out;
 		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=
 					req->tp_frame_nr))
 			goto out;
-- 
2.12.2.564.g063fe858b8-goog
