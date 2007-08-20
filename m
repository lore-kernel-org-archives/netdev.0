From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/5] [TCP]: Discard fuzzy SACK blocks
Date: Mon, 20 Aug 2007 16:16:32 +0300
Message-ID: <11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi> <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42752 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195AbXHTNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:35 -0400
In-Reply-To: <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

SACK processing code has been a sort of russian roulette as no
validation of SACK blocks is previously attempted. Besides, it
is not very clear what all kinds of broken SACK blocks really
mean (e.g., one that has start and end sequence numbers
reversed). So now close the roulette once and for all.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   82 ++++++++++++++++++++++++++++++++++++++++++=
++++++++
 1 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2bf3d57..102aefa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1001,7 +1001,86 @@ static void tcp_update_reordering(struct sock *s=
k, const int metric,
  *    for retransmitted and already SACKed segment -> reordering..
  * Both of these heuristics are not used in Loss state, when we cannot
  * account for retransmits accurately.
+ *
+ * SACK block validation.
+ * ----------------------
+ *
+ * SACK block range validation checks that the received SACK block fit=
s to
+ * the expected sequence limits, i.e., it is between SND.UNA and SND.N=
XT.
+ * Note that SND.UNA is not included to the range though being valid b=
ecause
+ * it means that the receiver is rather inconsistent with itself (repo=
rts
+ * SACK reneging when it should advance SND.UNA).
+ *
+ * Implements also blockage to start_seq wrap-around. Problem lies in =
the
+ * fact that though start_seq (s) is before end_seq (i.e., not reverse=
d),
+ * there's no guarantee that it will be before snd_nxt (n). The proble=
m
+ * happens when start_seq resides between end_seq wrap (e_w) and snd_n=
xt
+ * wrap (s_w):
+ *
+ *         <- outs wnd ->                          <- wrapzone ->
+ *         u     e      n                         u_w   e_w  s n_w
+ *         |     |      |                          |     |   |  |
+ * |<------------+------+----- TCP seqno space --------------+--------=
-->|
+ * ...-- <2^31 ->|                                           |<-------=
-...
+ * ...---- >2^31 ------>|                                    |<-------=
-...
+ *
+ * Current code wouldn't be vulnerable but it's better still to discar=
d such
+ * crazy SACK blocks. Doing this check for start_seq alone closes some=
what
+ * similar case (end_seq after snd_nxt wrap) as earlier reversed check=
 in
+ * snd_nxt wrap -> snd_una region will then become "well defined", i.e=
=2E,
+ * equal to the ideal case (infinite seqno space without wrap caused i=
ssues).
+ *
+ * With D-SACK the lower bound is extended to cover sequence space bel=
ow
+ * SND.UNA down to undo_marker, which is the last point of interest. Y=
et
+ * again, DSACK block must not to go across snd_una (for the same reas=
on as
+ * for the normal SACK blocks, explained above). But there all simplic=
ity
+ * ends, TCP might receive valid D-SACKs below that. As long as they r=
eside
+ * fully below undo_marker they do not affect behavior in anyway and c=
an
+ * therefore be safely ignored. In rare cases (which are more or less
+ * theoretical ones), the D-SACK will nicely cross that boundary due t=
o skb
+ * fragmentation and packet reordering past skb's retransmission. To c=
onsider
+ * them correctly, the acceptable range must be extended even more tho=
ugh
+ * the exact amount is rather hard to quantify. However, tp->max_windo=
w can
+ * be used as an exaggerated estimate.
  */
+static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
+				  u32 start_seq, u32 end_seq)
+{
+	/* Too far in future, or reversed (interpretation is ambiguous) */
+	if (after(end_seq, tp->snd_nxt) || !before(start_seq, end_seq))
+		return 0;
+
+	/* Nasty start_seq wrap-around check (see comments above) */
+	if (!before(start_seq, tp->snd_nxt))
+		return 0;
+
+	/* In outstanding window? ...This is valid exit for DSACKs too.
+	 * start_seq =3D=3D snd_una is non-sensical (see comments above)
+	 */
+	if (after(start_seq, tp->snd_una))
+		return 1;
+
+	if (!is_dsack || !tp->undo_marker)
+		return 0;
+
+	/* ...Then it's D-SACK, and must reside below snd_una completely */
+	if (!after(end_seq, tp->snd_una))
+		return 0;
+
+	if (!before(start_seq, tp->undo_marker))
+		return 1;
+
+	/* Too old */
+	if (!after(end_seq, tp->undo_marker))
+		return 0;
+
+	/* Undo_marker boundary crossing (overestimates a lot). Known already=
:
+	 *   start_seq < undo_marker and end_seq >=3D undo_marker.
+	 */
+	return !before(start_seq, end_seq - tp->max_window);
+}
+
+
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
@@ -1143,6 +1222,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		int fack_count;
 		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
=20
+		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq))
+			continue;
+
 		skb =3D cached_skb;
 		fack_count =3D cached_fack_count;
=20
--=20
1.5.0.6

