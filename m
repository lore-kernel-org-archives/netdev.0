From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 01/10] tcp: collapse more than two on retransmission
Date: Mon, 24 Nov 2008 16:21:58 +0200
Message-ID: <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54925 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbYKXOWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:10 -0500
In-Reply-To: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I always had thought that collapsing up to two at a time was
intentional decision to avoid excessive processing if 1 byte
sized skbs are to be combined for a full mtu, and consecutive
retransmissions would make the size of the retransmittee
double each round anyway, but some recent discussion made me
to understand that was not the case. Thus make collapse work
more and wait less.

It would be possible to take advantage of the shifting
machinery (added in the later patch) in the case of paged
data but that can be implemented on top of this change.

tcp_skb_is_last check is now provided by the loop.

I tested a bit (ss-after-idle-off, fill 4096x4096B xfer,
10s sleep + 4096 x 1byte writes while dropping them for
some a while with netem):

=2E 16774097:16775545(1448) ack 1 win 46
=2E 16775545:16776993(1448) ack 1 win 46
=2E ack 16759617 win 2399
P 16776993:16777217(224) ack 1 win 46
=2E ack 16762513 win 2399
=2E ack 16765409 win 2399
=2E ack 16768305 win 2399
=2E ack 16771201 win 2399
=2E ack 16774097 win 2399
=2E ack 16776993 win 2399
=2E ack 16777217 win 2399
P 16777217:16777257(40) ack 1 win 46
=2E ack 16777257 win 2399
P 16777257:16778705(1448) ack 1 win 46
P 16778705:16780153(1448) ack 1 win 46
=46P 16780153:16781313(1160) ack 1 win 46
=2E ack 16778705 win 2399
=2E ack 16780153 win 2399
=46 1:1(0) ack 16781314 win 2399

While without drop-all period I get this:

=2E 16773585:16775033(1448) ack 1 win 46
=2E ack 16764897 win 9367
=2E ack 16767793 win 9367
=2E ack 16770689 win 9367
=2E ack 16773585 win 9367
=2E 16775033:16776481(1448) ack 1 win 46
P 16776481:16777217(736) ack 1 win 46
=2E ack 16776481 win 9367
=2E ack 16777217 win 9367
P 16777217:16777218(1) ack 1 win 46
P 16777218:16777219(1) ack 1 win 46
P 16777219:16777220(1) ack 1 win 46
  ...
P 16777247:16777248(1) ack 1 win 46
=2E ack 16777218 win 9367
=2E ack 16777219 win 9367
  ...
=2E ack 16777233 win 9367
=2E ack 16777248 win 9367
P 16777248:16778696(1448) ack 1 win 46
P 16778696:16780144(1448) ack 1 win 46
=46P 16780144:16781313(1169) ack 1 win 46
=2E ack 16780144 win 9367
=46 1:1(0) ack 16781314 win 9367

The window seems to be 30-40 segments, which were successfully
combined into: P 16777217:16777257(40) ack 1 win 46

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   96 ++++++++++++++++++++++++++++++-----------=
--------
 1 files changed, 59 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a524627..86ef989 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1766,46 +1766,22 @@ u32 __tcp_select_window(struct sock *sk)
 	return window;
 }
=20
-/* Attempt to collapse two adjacent SKB's during retransmission. */
-static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *=
skb,
-				     int mss_now)
+/* Collapses two adjacent SKB's during retransmission. */
+static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *next_skb =3D tcp_write_queue_next(sk, skb);
 	int skb_size, next_skb_size;
 	u16 flags;
=20
-	/* The first test we must make is that neither of these two
-	 * SKB's are still referenced by someone else.
-	 */
-	if (skb_cloned(skb) || skb_cloned(next_skb))
-		return;
-
 	skb_size =3D skb->len;
 	next_skb_size =3D next_skb->len;
 	flags =3D TCP_SKB_CB(skb)->flags;
=20
-	/* Also punt if next skb has been SACK'd. */
-	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
-		return;
-
-	/* Next skb is out of window. */
-	if (after(TCP_SKB_CB(next_skb)->end_seq, tcp_wnd_end(tp)))
-		return;
-
-	/* Punt if not enough space exists in the first SKB for
-	 * the data in the second, or the total combined payload
-	 * would exceed the MSS.
-	 */
-	if ((next_skb_size > skb_tailroom(skb)) ||
-	    ((skb_size + next_skb_size) > mss_now))
-		return;
-
 	BUG_ON(tcp_skb_pcount(skb) !=3D 1 || tcp_skb_pcount(next_skb) !=3D 1)=
;
=20
 	tcp_highest_sack_combine(sk, next_skb, skb);
=20
-	/* Ok.	We will be able to collapse the packet. */
 	tcp_unlink_write_queue(next_skb, sk);
=20
 	skb_copy_from_linear_data(next_skb, skb_put(skb, next_skb_size),
@@ -1847,6 +1823,62 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb,
 	sk_wmem_free_skb(sk, next_skb);
 }
=20
+static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
+{
+	if (tcp_skb_pcount(skb) > 1)
+		return 0;
+	/* TODO: SACK collapsing could be used to remove this condition */
+	if (skb_shinfo(skb)->nr_frags !=3D 0)
+		return 0;
+	if (skb_cloned(skb))
+		return 0;
+	if (skb =3D=3D tcp_send_head(sk))
+		return 0;
+	/* Some heurestics for collapsing over SACK'd could be invented */
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+		return 0;
+
+	return 1;
+}
+
+static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *=
to,
+				     int space)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb =3D to, *tmp;
+	int first =3D 1;
+
+	if (!sysctl_tcp_retrans_collapse)
+		return;
+	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
+		return;
+
+	tcp_for_write_queue_from_safe(skb, tmp, sk) {
+		if (!tcp_can_collapse(sk, skb))
+			break;
+
+		space -=3D skb->len;
+
+		if (first) {
+			first =3D 0;
+			continue;
+		}
+
+		if (space < 0)
+			break;
+		/* Punt if not enough space exists in the first SKB for
+		 * the data in the second
+		 */
+		if (skb->len > skb_tailroom(to))
+			break;
+
+		if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))
+			break;
+
+		tcp_collapse_retrans(sk, to);
+	}
+}
+
 /* Do a simple retransmit without using the backoff mechanisms in
  * tcp_timer. This is used for path mtu discovery.
  * The socket is already locked here.
@@ -1946,17 +1978,7 @@ int tcp_retransmit_skb(struct sock *sk, struct s=
k_buff *skb)
 			return -ENOMEM; /* We'll try again later. */
 	}
=20
-	/* Collapse two adjacent packets if worthwhile and we can. */
-	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
-	    (skb->len < (cur_mss >> 1)) &&
-	    (!tcp_skb_is_last(sk, skb)) &&
-	    (tcp_write_queue_next(sk, skb) !=3D tcp_send_head(sk)) &&
-	    (skb_shinfo(skb)->nr_frags =3D=3D 0 &&
-	     skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags =3D=3D 0) &&
-	    (tcp_skb_pcount(skb) =3D=3D 1 &&
-	     tcp_skb_pcount(tcp_write_queue_next(sk, skb)) =3D=3D 1) &&
-	    (sysctl_tcp_retrans_collapse !=3D 0))
-		tcp_retrans_try_collapse(sk, skb, cur_mss);
+	tcp_retrans_try_collapse(sk, skb, cur_mss);
=20
 	/* Some Solaris stacks overoptimize and ignore the FIN on a
 	 * retransmit when old data is attached.  So strip it off
--=20
1.5.2.2

