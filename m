From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH tcp-2.6 1/2] [TCP]: Discard fuzzy SACK blocks
Date: Tue, 19 Jun 2007 01:25:57 +0300
Message-ID: <1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762556AbXFRW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 18:26:01 -0400
In-Reply-To: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

SACK processing code has been sort of russian roulette as no
validation of SACK blocks is previously attempted. It is not
very clear what all kinds of broken SACK blocks really mean
(e.g., one that has start and end sequence numbers reversed).

This fixes also one remote triggerable NULL-ptr access:
start_seq was trusted as a valid mark_lost_entry_seq but
without validation it is relatively easy to inject an invalid
sequence number there that will cause a crash in the lost
marker code. Other SACK processing code seems safe so this could
have been fixed locally but that would leave SACK processing
hazardous in case of future modifications. IMHO, it's just
better to close the whole roulette rather than disarming just
one bullet.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4c8882e..ebd9739 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -977,6 +977,27 @@ static void tcp_update_reordering(struct sock *sk,=
 const int metric,
  * so that we are allowed not to be bothered by order of our actions,
  * when multiple events arrive simultaneously. (see the function below=
).
  *
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
+ * With D-SACK the lower bound is extended to cover sequence space bel=
ow
+ * SND.UNA down to undo_marker, which is the last point of interest. B=
ut
+ * there all simplicity ends, TCP might receive valid D-SACKs below th=
at.
+ * As long as they reside fully below undo_marker they do not affect
+ * behavior in anyway and can therefore be safely ignored. In rare cas=
es
+ * (which are really theoretical ones), the D-SACK will nicely cross t=
hat
+ * boundary due to skb fragmentation and packet reordering past skb's
+ * retransmission. To consider them correctly, the acceptable range mu=
st
+ * be extended even more though the exact amount is rather hard to
+ * quantify (from the state TCP has?), so in boundary crossing case
+ * simply adjust start_seq to undo_marker.
+ *
  * Reordering detection.
  * --------------------
  * Reordering metric is maximal distance, which a packet can be displa=
ced
@@ -1243,9 +1264,28 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 		struct sk_buff *skb;
 		__u32 start_seq =3D ntohl(sp->start_seq);
 		__u32 end_seq =3D ntohl(sp->end_seq);
+		u32 valid_range_start;
 		int fack_count;
 		state.dup_sack =3D (found_dup_sack && (i =3D=3D state.first_sack_ind=
ex));
=20
+		/* SACK validation: start_seq =3D=3D snd_una is non-sensical */
+		valid_range_start =3D tp->snd_una + 1;
+
+		if (state.dup_sack && tp->undo_marker) {
+			valid_range_start =3D tp->undo_marker;
+
+			/* Undo_marker boundary crossing, see comments above */
+			if (before(start_seq, tp->undo_marker) &&
+			    after(end_seq, tp->undo_marker))
+			    	start_seq =3D tp->undo_marker;
+		}
+
+		/* Discard SACK blocks that are seemingly bad */
+		if (before(start_seq, valid_range_start) ||
+		    after(end_seq, tp->snd_nxt) ||
+		    !before(start_seq, end_seq))
+			continue;
+
 		skb =3D cached_skb;
 		fack_count =3D cached_fack_count;
=20
--=20
1.5.0.6

