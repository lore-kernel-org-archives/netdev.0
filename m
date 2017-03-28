From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 4/5] net/packet: fix overflow in check for tp_reserve
Date: Tue, 28 Mar 2017 16:00:48 +0200
Message-ID: <0f3f9342c09be4d97a820cf9abeb9dabed8eb69f.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35985 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbdC1OBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:11 -0400
Received: by mail-wr0-f171.google.com with SMTP id w11so88286645wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:10 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating po->tp_hdrlen + po->tp_reserve the result can overflow.

Fix by checking that tp_reserve <= INT_MAX on assign.

This also takes cared of an overflow when calculating
 macoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 + po->tp_reserve
 snaplen = skb->len
 macoff + snaplen
since macoff ~ INT_MAX and snaplen < SKB_MAX_ALLOC.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c5c43fff8c01..28b49749d1af 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3665,6 +3665,8 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			return -EBUSY;
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
+		if (val > INT_MAX)
+			return -EINVAL;
 		po->tp_reserve = val;
 		return 0;
 	}
@@ -4200,6 +4202,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
 					UINT_MAX))
 			goto out;
+		if (unlikely(po->tp_reserve >= req->tp_frame_size))
+			goto out;
 
 		if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
 			goto out;
@@ -4207,9 +4211,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		    req->tp_block_size <=
 			  BLK_PLUS_PRIV((u64)req_u->req3.tp_sizeof_priv))
 			goto out;
-		if (unlikely(req->tp_frame_size < po->tp_hdrlen +
-					po->tp_reserve))
-			goto out;
 		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
 			goto out;
 
-- 
2.12.2.564.g063fe858b8-goog
