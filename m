From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Sat, 21 Feb 2009 13:44:27 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902211324460.20284@wrl-59.cs.helsinki.fi>
References: <200902192304.35547.denys@visp.net.lb> <200902201349.47984.denys@visp.net.lb>
 <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
 <200902201812.47205.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1050259020-1235216667=:20284"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55183 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbZBULob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 06:44:31 -0500
In-Reply-To: <200902201812.47205.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1050259020-1235216667=:20284
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 20 Feb 2009, Denys Fedoryschenko wrote:

> On Friday 20 February 2009 18:09:54 Ilpo Järvinen wrote:
> > > [45853.641072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk
> > > window 1905466446:1905480750 (repaired)
> >
> > Hmm, we might have sent past our allowed window due to some bug. ...Or
> > combined some segments in the new shifting code incorrectly past the
> > right edge of the window though I quickly checked and we do check for
> > tcp_send_head there so it should be right.
> 
> 
> This message (about window), i have tons of them, and had before a lot. 
> 
> I think it is not related, just i paste whole dmesg part where i see 
> more "Leak" messages. I'm sure i have more of them now.

Indeed, there's a possiblity that tcp_sacktag_one didn't behave
as expected wrt. retrans_out. You shouldn't have had any Leak in or
before 2.6.28 (except perhaps in some ancient dev kernels).

I also noticed that end_seq usage in tcp_sacktag_one is a bit
suspicious too but found out that it mostly works. It would be
safer to make partial end_seq available there though it's not
too easy to find a sane scenario where the wrong end_seq makes
any difference though. No need to do that in mainline for sure
considering how small the worst case effect is.

...What a can of worms that tcp_sacktag_one is...

-- 
 i.


[PATCH] tcp: fix retrans_out leaks in shifting code

There's conflicting assumptions in shifting, the caller assumes
that dupsack results in S'ed skbs (or a part of it) for sure but
never gave a hint to tcp_sacktag_one when dsack is actually in
use. Thus DSACK retrans_out -= pcount was not taken and the
counter became out of sync. Remove obstacle from that information
flow to get DSACKs accounted in tcp_sacktag_one as expected.

Compile tested only.

In general the call to tcp_sacktag_one with the later full shift
from already SACKed skb should not be there, it's just doing
duplicating work already done earlier so it just wastes cycles and
also seems to duplicate small amount of code unnecessarily :-/.
However, moving tcp_sacktag_one call one level up is not what I want
to do in mainline -rc5, the counting & seqno state manipulation that
is going on there is just too hairy to get right in a hurry (order
is very significant there as the state transition is in progress
making normal invariants are not to be trusted). Luckily
tcp_sacktag_one is effectively a no-op atm with dup_sack set to 0
for already SACKed skb.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a6961d7..c28976a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1374,7 +1374,8 @@ static u8 tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 
 static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 			   struct tcp_sacktag_state *state,
-			   unsigned int pcount, int shifted, int mss)
+			   unsigned int pcount, int shifted, int mss,
+			   int dup_sack)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
@@ -1410,7 +1411,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* We discard results */
-	tcp_sacktag_one(skb, sk, state, 0, pcount);
+	tcp_sacktag_one(skb, sk, state, dup_sack, pcount);
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
 	TCP_SKB_CB(prev)->sacked |= (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS);
@@ -1561,7 +1562,7 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 
 	if (!skb_shift(prev, skb, len))
 		goto fallback;
-	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss))
+	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss, dup_sack))
 		goto out;
 
 	/* Hole filled allows collapsing with the next as well, this is very
@@ -1580,7 +1581,7 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	len = skb->len;
 	if (skb_shift(prev, skb, len)) {
 		pcount += tcp_skb_pcount(skb);
-		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss);
+		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss, 0);
 	}
 
 out:
-- 
1.5.6.5
---696208474-1050259020-1235216667=:20284--
