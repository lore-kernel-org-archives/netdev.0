From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 3 Dec 2008 13:22:53 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1763972722-1228303373=:31282"
Cc: Netdev <netdev@vger.kernel.org>, Petr Tesarik <ptesarik@suse.cz>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46039 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbYLCLWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 06:22:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1763972722-1228303373=:31282
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


I should have noticed this earlier... :-) The previous solution
to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
patterns, or even worse, a steep downward slope into packet
counting because each skb pcount would be truncated to pcount
of 2 and then the following fragments of the later portion would
restore the window again.

Basically this reverts "tcp: Do not use TSO/GSO when there is
urgent data" (33cf71cee1). It also removes some unnecessary code
from tcp_current_mss that didn't work as intented either (could
be that something was changed down the road, or it might have
been broken since the dawn of time) because it only works once
urg is already written while this bug shows up starting from
~64k before the urg point.

The retransmissions already are split to mss sized chunks, so
only new data sending paths need splitting in case they have
a segment otherwise suitable for gso/tso. The actually check
can be improved to be more narrow but since this is late -rc
already, I'll postpone thinking the more fine-grained things.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: Petr Tesarik <ptesarik@suse.cz>
---
 net/ipv4/tcp_output.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 76f8409..0744b9f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -722,8 +722,7 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
-	if (skb->len <= mss_now || !sk_can_gso(sk) ||
-	    tcp_urg_mode(tcp_sk(sk))) {
+	if (skb->len <= mss_now || !sk_can_gso(sk)) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
@@ -1029,10 +1028,6 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 
 /* Compute the current effective MSS, taking SACKs and IP options,
  * and even PMTU discovery events into account.
- *
- * LARGESEND note: !tcp_urg_mode is overkill, only frames up to snd_up
- * cannot be large. However, taking into account rare use of URG, this
- * is not a big flaw.
  */
 unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 {
@@ -1047,7 +1042,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 
 	mss_now = tp->mss_cache;
 
-	if (large_allowed && sk_can_gso(sk) && !tcp_urg_mode(tp))
+	if (large_allowed && sk_can_gso(sk))
 		doing_tso = 1;
 
 	if (dst) {
@@ -1164,9 +1159,7 @@ static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
 {
 	int tso_segs = tcp_skb_pcount(skb);
 
-	if (!tso_segs ||
-	    (tso_segs > 1 && (tcp_skb_mss(skb) != mss_now ||
-			      tcp_urg_mode(tcp_sk(sk))))) {
+	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
 		tcp_set_skb_tso_segs(sk, skb, mss_now);
 		tso_segs = tcp_skb_pcount(skb);
 	}
@@ -1519,6 +1512,10 @@ static int tcp_mtu_probe(struct sock *sk)
  * send_head.  This happens as incoming acks open up the remote
  * window for us.
  *
+ * LARGESEND note: !tcp_urg_mode is overkill, only frames between
+ * snd_up-64k-mss .. snd_up cannot be large. However, taking into
+ * account rare use of URG, this is not a big flaw.
+ *
  * Returns 1, if no segments are in flight and we have queued segments, but
  * cannot send anything now because of SWS or another problem.
  */
@@ -1570,7 +1567,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 		}
 
 		limit = mss_now;
-		if (tso_segs > 1)
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    cwnd_quota);
 
@@ -1619,6 +1616,7 @@ void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
  */
 void tcp_push_one(struct sock *sk, unsigned int mss_now)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = tcp_send_head(sk);
 	unsigned int tso_segs, cwnd_quota;
 
@@ -1633,7 +1631,7 @@ void tcp_push_one(struct sock *sk, unsigned int mss_now)
 		BUG_ON(!tso_segs);
 
 		limit = mss_now;
-		if (tso_segs > 1)
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    cwnd_quota);
 
-- 
1.5.2.2

---696208474-1763972722-1228303373=:31282--
