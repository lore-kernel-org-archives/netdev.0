From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/7] tcp: remove pointless .dsack/.num_sacks code
Date: Sun, 15 Mar 2009 02:23:01 +0200
Message-ID: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49486 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbZCOAXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the pure assignment case, the earlier zeroing is
still in effect.

David S. Miller raised concerns if the ifs are there to avoid
dirtying cachelines. I came to these conclusions:

> We'll be dirty it anyway (now that I check), the first "real" stateme=
nt
> in tcp_rcv_established is:
>
>       tp->rx_opt.saw_tstamp =3D 0;
>
> ...that'll land on the same dword. :-/
>
> I suppose the blocks are there just because they had more complexity
> inside when they had to calculate the eff_sacks too (maybe it would
> have been better to just remove them in that drop-patch so you would
> have had less head-ache :-)).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---

My apologies for the duplicated patches, I succeeded once again
to make mess out of it with git-send-email and 8-bit chars in
header which vger consistently is known to reject... Thus resending
to get a copy to appear on netdev too.

Grr, 3rd attempt, now with --no-signed-off-by-cc though it _should_
have worked without that too like it used to.

 net/ipv4/tcp_input.c  |    7 ++-----
 net/ipv4/tcp_output.c |    3 +--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5ecd7aa..cd39d1d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4248,8 +4248,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 		this_sack++;
 		sp++;
 	}
-	if (num_sacks !=3D tp->rx_opt.num_sacks)
-		tp->rx_opt.num_sacks =3D num_sacks;
+	tp->rx_opt.num_sacks =3D num_sacks;
 }
=20
 /* This one checks to see if we can put data from the
@@ -4325,8 +4324,7 @@ static void tcp_data_queue(struct sock *sk, struc=
t sk_buff *skb)
=20
 	TCP_ECN_accept_cwr(tp, skb);
=20
-	if (tp->rx_opt.dsack)
-		tp->rx_opt.dsack =3D 0;
+	tp->rx_opt.dsack =3D 0;
=20
 	/*  Queue data for delivery to the user.
 	 *  Packets in sequence go to the receive queue.
@@ -4445,7 +4443,6 @@ drop:
 		/* Initial out of order segment, build 1 SACK. */
 		if (tcp_is_sack(tp)) {
 			tp->rx_opt.num_sacks =3D 1;
-			tp->rx_opt.dsack     =3D 0;
 			tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
 			tp->selective_acks[0].end_seq =3D
 						TCP_SKB_CB(skb)->end_seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index eb285be..3256580 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -441,8 +441,7 @@ static void tcp_options_write(__be32 *ptr, struct t=
cp_sock *tp,
 			*ptr++ =3D htonl(sp[this_sack].end_seq);
 		}
=20
-		if (tp->rx_opt.dsack)
-			tp->rx_opt.dsack =3D 0;
+		tp->rx_opt.dsack =3D 0;
 	}
 }
=20
--=20
1.5.6.5

