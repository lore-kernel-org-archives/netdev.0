From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/1] tcp: fix spurious undos in CA_Open
Date: Mon, 12 Dec 2011 14:05:28 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1112121359470.15137@wel-95.cs.helsinki.fi>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi> <CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com> <alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi> <20111127.185857.475440859115872225.davem@davemloft.net>
 <CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-724256886-1323691528=:15137"
Cc: Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	Yuchung Cheng <ycheng@google.com>, therbert@google.com
To: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58421 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab1LLMFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:05:31 -0500
In-Reply-To: <CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-724256886-1323691528=:15137
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 28 Nov 2011, Neal Cardwell wrote:

> On Sun, Nov 27, 2011 at 6:58 PM, David Miller <davem@davemloft.net> wrote:
>
> >> Also, one (serious) word of caution! This change, by its extending of
> >> CA_Open state, is somewhat similar to what I made FRTO years ago, and
> >> managed to introduces subtle breaking to the state machine. Please check
> >> that the problem similar to what was fixed by
> >> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possibly in
> >> some other form causing spurious undos). ...To me it seems that
> >> tcp_packet_delayed might be similarly confused after the given patch.
> >
> > Neil, please look into this so we can have any such issues fixed
> > in time for the next merge window.
> 
> Absolutely. I will look into the areas that Ilpo mentioned.

Unfortunately nothing has happened? So I finally had to come up something 
myself. ...Compile tested only.

--
[PATCH 1/1] tcp: fix spurious undos in CA_Open

There's a landmine in tcp_packet_delayed. In CA_Open the
retrans_stamp is very eagerly cleared which falsely triggers
packet-delayed detection. Therefore this code cannot be used
in CA_Open if the retrans_stamp was already cleared.

This became issue once DSACK detection was extended to happen
in CA_Open state too (f698204bd0b, tcp: allow undo from
reordered DSACKs). Essentially the whole congestion control
is disabled because the undos now always restore the previous
window. I wonder if this was already in production... ...at
least the Internet didn't melt ;-).

Compile tested only.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..7d8934d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2640,8 +2640,14 @@ static void tcp_cwnd_down(struct sock *sk, int flag)
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
-static inline int tcp_packet_delayed(const struct tcp_sock *tp)
+static inline int tcp_packet_delayed(const struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (icsk->icsk_ca_state == TCP_CA_Open && !tp->retrans_stamp)
+		return 0;
+
 	return !tp->retrans_stamp ||
 		(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 		 before(tp->rx_opt.rcv_tsecr, tp->retrans_stamp));
@@ -2701,9 +2707,11 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static inline int tcp_may_undo(const struct tcp_sock *tp)
+static inline int tcp_may_undo(const struct sock *sk)
 {
-	return tp->undo_marker && (!tp->undo_retrans || tcp_packet_delayed(tp));
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	return tp->undo_marker && (!tp->undo_retrans || tcp_packet_delayed(sk));
 }
 
 /* People celebrate: "We love our President!" */
@@ -2711,7 +2719,7 @@ static int tcp_try_undo_recovery(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tcp_may_undo(tp)) {
+	if (tcp_may_undo(sk)) {
 		int mib_idx;
 
 		/* Happy end! We did not retransmit anything
@@ -2788,7 +2796,7 @@ static int tcp_try_undo_partial(struct sock *sk, int acked)
 	/* Partial ACK arrived. Force Hoe's retransmit. */
 	int failed = tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reordering);
 
-	if (tcp_may_undo(tp)) {
+	if (tcp_may_undo(sk)) {
 		/* Plain luck! Hole if filled with delayed
 		 * packet, rather than with a retransmit.
 		 */
@@ -2815,7 +2823,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tcp_may_undo(tp)) {
+	if (tcp_may_undo(sk)) {
 		struct sk_buff *skb;
 		tcp_for_write_queue(skb, sk) {
 			if (skb == tcp_send_head(sk))
-- 
1.7.0.4

--8323329-724256886-1323691528=:15137--
