From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: [PATCH net-2.6] [TCP]: fix D-SACK cwnd handling
Date: Thu, 25 Oct 2007 17:11:47 +0900 (JST)
Message-ID: <20071025.171147.107738702.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net, y-kodama@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:52579 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbXJYIlS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 04:41:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the current net-2.6 kernel, handling FLAG_DSACKING_ACK is broken.
The flag is cleared to 1 just after FLAG_DSACKING_ACK is set.

        if (found_dup_sack)
                flag |=3D FLAG_DSACKING_ACK;
	:
	flag =3D 1;

To fix it, this patch introduces a part of the tcp_sacktag_state patch:
	http://marc.info/?l=3Dlinux-netdev&m=3D119210560431519&w=3D2

Do you plan to apply the tcp_sacktag_state patch?
Or please apply this patch.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
---
 net/ipv4/tcp_input.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3dbbb44..59e3c9a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1248,6 +1248,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int cached_fack_count;
 	int i;
 	int first_sack_index;
+	int force_one_sack;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1272,18 +1273,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
-	flag =3D 1;
+	force_one_sack =3D 1;
 	for (i =3D 0; i < num_sacks; i++) {
 		__be32 start_seq =3D sp[i].start_seq;
 		__be32 end_seq =3D sp[i].end_seq;
=20
 		if (i =3D=3D 0) {
 			if (tp->recv_sack_cache[i].start_seq !=3D start_seq)
-				flag =3D 0;
+				force_one_sack =3D 0;
 		} else {
 			if ((tp->recv_sack_cache[i].start_seq !=3D start_seq) ||
 			    (tp->recv_sack_cache[i].end_seq !=3D end_seq))
-				flag =3D 0;
+				force_one_sack =3D 0;
 		}
 		tp->recv_sack_cache[i].start_seq =3D start_seq;
 		tp->recv_sack_cache[i].end_seq =3D end_seq;
@@ -1295,7 +1296,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	}
=20
 	first_sack_index =3D 0;
-	if (flag)
+	if (force_one_sack)
 		num_sacks =3D 1;
 	else {
 		int j;
@@ -1321,9 +1322,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		}
 	}
=20
-	/* clear flag as used for different purpose in following code */
-	flag =3D 0;
-
 	/* Use SACK fastpath hint if valid */
 	cached_skb =3D tp->fastpath_skb_hint;
 	cached_fack_count =3D tp->fastpath_cnt_hint;
--=20
1.5.3.4

