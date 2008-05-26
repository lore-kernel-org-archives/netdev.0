From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Mon, 26 May 2008 14:24:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261349510.16829@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
 <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
 <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
 <Pine.LNX.4.64.0805231302410.16829@wrl-59.cs.helsinki.fi>
 <cf4145200805230906k34a0452at773e840b791e6b0a@mail.gmail.com>
 <cf4145200805231024w2e735fb8ifecf7e2e1bab5957@mail.gmail.com>
 <Pine.LNX.4.64.0805232043030.25097@wrl-59.cs.helsinki.fi>
 <cf4145200805231126y401c2454w97e5305346aa8acd@mail.gmail.com>
 <Pine.LNX.4.64.0805241156120.27780@wrl-59.cs.helsinki.fi>
 <cf4145200805240706p2eb54e9ei51bc33f782ff5aef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1600733143-1211801073=:16829"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33827 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbYEZLYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 07:24:37 -0400
In-Reply-To: <cf4145200805240706p2eb54e9ei51bc33f782ff5aef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1600733143-1211801073=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 24 May 2008, Brian Vowell wrote:

> Here are more traces.  They all are warnings at 3297.

Hmm, likely fix to that included below (you might not be able to 
reproduce it anymore though because it's very sensitive to network 
behavior, ie., in case the peer you were communicating with isn't
there any more the necessary events simply won't happen). 

There seems to be yet another candidate in tcp_fastretrans_alert() that 
could cause it but it's extremely unlikely to occur in practice. ...I'll 
fix this one separately later on.

And this isn't exactly there problem we were tracking for but it's nice 
that it showed up as well (so you might want to keep the debug patch 
still applied too)... :-)

-- 
 i.


--
[PATCH] [TCP]: Fix inconsistency source (CA_Open only when !tcp_left_out(tp))

It is possible that this skip path causes TCP to end up into an
invalid state where ca_state was left to CA_Open while some
segments already came into sacked_out. If next valid ACK doesn't
contain new SACK information TCP fails to enter into
tcp_fastretrans_alert(). Thus at least high_seq is set
incorrectly to a too high seqno because some new data segments
could be sent in between (and also, limited transmit is not
being correctly invoked there). Reordering in both directions
can easily cause this situation to occur.

I guess we would want to use tcp_moderate_cwnd(tp) there as well
as it may be possible to use this to trigger oversized burst to
network by sending an old ACK with huge amount of SACK info, but
I'm a bit unsure about its effects (mainly to FlightSize), so to
be on the safe side I just currently fixed it minimally to keep
TCP's state consistent (obviously, such nasty ACKs have been
possible this far). Though it seems that FlightSize is already
underestimated by some amount, so probably on the long term we
might want to trigger recovery there too, if appropriate, to make
FlightSize calculation to resemble reality at the time when the
losses where discovered (but such change scares me too much now
and requires some more thinking anyway how to do that as it
likely involves some code shuffling).

This bug was found by Brian Vowell while running my TCP debug
patch to find cause of another TCP issue (fackets_out
miscount).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   29 +++++++++++++++++++----------
 1 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d9936a2..be53021 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2483,6 +2483,20 @@ static inline void tcp_complete_cwr(struct sock *sk)
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
 
+static void tcp_try_keep_open(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int state = TCP_CA_Open;
+
+	if (tcp_left_out(tp) || tp->retrans_out || tp->undo_marker)
+		state = TCP_CA_Disorder;
+
+	if (inet_csk(sk)->icsk_ca_state != state) {
+		tcp_set_ca_state(sk, state);
+		tp->high_seq = tp->snd_nxt;
+	}
+}
+
 static void tcp_try_to_open(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2496,15 +2510,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 		tcp_enter_cwr(sk, 1);
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
-		int state = TCP_CA_Open;
-
-		if (tcp_left_out(tp) || tp->retrans_out || tp->undo_marker)
-			state = TCP_CA_Disorder;
-
-		if (inet_csk(sk)->icsk_ca_state != state) {
-			tcp_set_ca_state(sk, state);
-			tp->high_seq = tp->snd_nxt;
-		}
+		tcp_try_keep_open(sk);
 		tcp_moderate_cwnd(tp);
 	} else {
 		tcp_cwnd_down(sk, flag);
@@ -3312,8 +3318,11 @@ no_queue:
 	return 1;
 
 old_ack:
-	if (TCP_SKB_CB(skb)->sacked)
+	if (TCP_SKB_CB(skb)->sacked) {
 		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+		if (icsk->icsk_ca_state == TCP_CA_Open)
+			tcp_try_keep_open(sk);
+	}
 
 uninteresting_ack:
 	SOCK_DEBUG(sk, "Ack %u out of %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
1.5.2.2

---696208474-1600733143-1211801073=:16829--
