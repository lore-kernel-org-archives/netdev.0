From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: better use ooo_last_skb in
 tcp_data_queue_ofo()
Date: Fri, 09 Sep 2016 14:22:45 -0700
Message-ID: <1473456165.18970.66.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34725 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754618AbcIIVWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 17:22:48 -0400
Received: by mail-pa0-f66.google.com with SMTP id gi6so4318310pac.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 14:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Willem noticed that we could avoid an rbtree lookup if the
the attempt to coalesce incoming skb to the last skb failed
for some reason.

Since most ooo additions are at the tail, this is definitely
worth adding a test and fast path.

Suggested-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yaogong Wang <wygivan@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5934c4c8cd4..2e26f3eb0293 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4461,6 +4461,12 @@ coalesce_done:
 		skb = NULL;
 		goto add_sack;
 	}
+	/* Can avoid an rbtree lookup if we are adding skb after ooo_last_skb */
+	if (!before(seq, TCP_SKB_CB(tp->ooo_last_skb)->end_seq)) {
+		parent = &tp->ooo_last_skb->rbnode;
+		p = &parent->rb_right;
+		goto insert;
+	}
 
 	/* Find place to insert this segment. Handle overlaps on the way. */
 	parent = NULL;
@@ -4503,7 +4509,7 @@ coalesce_done:
 		}
 		p = &parent->rb_right;
 	}
-
+insert:
 	/* Insert segment into RB tree. */
 	rb_link_node(&skb->rbnode, parent, p);
 	rb_insert_color(&skb->rbnode, &tp->out_of_order_queue);
