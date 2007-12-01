From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 20/21] [TCP]: Introduce tcp_skb_adjacent to detect holes in wq
Date: Sun,  2 Dec 2007 00:48:15 +0200
Message-ID: <11965492971669-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971864-git-send-email-ilpo.jarvinen@helsinki.f
 i> <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971718-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492972550-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbXLAWs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:26 -0500
In-Reply-To: <11965492972550-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Soon the skbs in the write_queue won't necessary be adjacent
ones because part of the queue is stored elsewhere. Verify that
there isn't hole between skbs when trying to combine two of
them.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    6 ++++++
 net/ipv4/tcp_output.c |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5bb2de6..688ccca 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1245,6 +1245,12 @@ static inline struct sk_buff *tcp_write_queue_pr=
ev(struct sock *sk, struct sk_bu
 	return skb->prev;
 }
=20
+static inline int tcp_skb_adjacent(struct sock *sk, struct sk_buff *sk=
b,
+				   struct sk_buff *next)
+{
+	return TCP_SKB_CB(skb)->end_seq =3D=3D TCP_SKB_CB(next)->seq;
+}
+
 #define tcp_for_write_queue(skb, sk, queue)				\
 		for (skb =3D (sk)->sk_write_queue.next;			\
 		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 202a48a..b81284a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1849,6 +1849,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 	    (skb->len < (cur_mss >> 1)) &&
 	    (tcp_write_queue_next(sk, skb) !=3D tcp_send_head(sk)) &&
 	    (!tcp_skb_is_last(sk, skb)) &&
+	    (tcp_skb_adjacent(sk, skb, tcp_write_queue_next(sk, skb))) &&
 	    (skb_shinfo(skb)->nr_frags =3D=3D 0 && skb_shinfo(tcp_write_queue=
_next(sk, skb))->nr_frags =3D=3D 0) &&
 	    (tcp_skb_pcount(skb) =3D=3D 1 && tcp_skb_pcount(tcp_write_queue_n=
ext(sk, skb)) =3D=3D 1) &&
 	    (sysctl_tcp_retrans_collapse !=3D 0))
--=20
1.5.0.6

