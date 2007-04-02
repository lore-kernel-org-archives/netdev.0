From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp crash in net-2.6 tree
Date: Mon, 2 Apr 2007 11:38:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704021133220.28337@kivilampi-30.cs.helsinki.fi>
References: <mFVio6um.1175336346.4693300.ijjarvin@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-823902320-1175503131=:28337"
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39582 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbXDBIiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 04:38:54 -0400
In-Reply-To: <mFVio6um.1175336346.4693300.ijjarvin@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-823902320-1175503131=:28337
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 31 Mar 2007, ijjarvin@cs.helsinki.fi wrote:

> On 3/31/2007, "David Miller" <davem@davemloft.net> wrote:
> > From: Thomas Graf <tgraf@suug.ch>
> > Date: Sat, 31 Mar 2007 00:10:54 +0200
> > 
> > > * David Miller <davem@davemloft.net> 2007-03-30 14:43
> > > > Let's not speculate, let's find out for sure if snd_una is
> > > > surpassing high_seq while we're in this state.
> > > >
> > > > Andrew please give this debugging patch a spin, and also what
> > > > is your workload?  I'd like to play with it too.
> > > >
> > > > I've tried to code this patch so that if the bug triggers your
> > > > machine shouldn't crash and burn completely, just spit out the
> > > > log message.
> > >
> > > I'm running into the same bug as Andew, i was able to reproduce
> > > using Dave's patch within minutes:
> > >
> > > TCP BUG: high_seq==NULL [c3c9cc54] q[c3c94edc] t[c3c9cc54]
> > >
> > > The after(snd_una, high_seq) check is not triggered.
> > 
> > So tp->high_seq points to the tail packet end sequence.
> > 
> > Ilpo does this clear things up?
> 
> Thanks for the info.
> 
> I think that the if condition before the write_queue_find should check if
> skb is valid before doing after(TCP_SKB_CB(skb)->seq, tp->high_seq), it
> is pointing to sk_write_queue rather than a valid skb when the previous
> loop exits (there might be a similar problem later in the code too). I
> apologize I cannot provide a good patch at this point of time because I
> moved on Thursday and the ISP hasn't yet activated the access link
> (writing this from a library machine).

So here it is, finally, I'm sorry for the delay (the length of the 
lines this fix is causing does not please me though)...:

[PATCH] [TCP]: Fix invalid skb referencing in LOST marker code

The after() referenced an invalid skb if loop exited when skb had
reached sk_write_queue. I chose to move this part inside the loop
where the skb is valid (so no need to check for that like I first
suggested), which also allows dropping of couple of conditions
from the if.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea196de..211bb1f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1933,26 +1933,25 @@ static void tcp_update_scoreboard_fack(s
 				if (IsFack(tp) ||
 				    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 					reord_count += tcp_skb_pcount(skb);
-				if (reord_count > tp->reordering)
+				if (reord_count > tp->reordering) {
+					if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+						/* RFC: should we have find_below? */
+						skb = tcp_write_queue_find(sk, tp->high_seq);
+						not_marked_skb = skb;
+						skb = tcp_write_queue_prev(sk, skb);
+						/* Timedout top is again uncertain? */
+						if (tcp_skb_timedout(sk, skb))
+							timedout_continue = 1;
+					}
+					/* TODO?: do skb fragmentation if necessary */
 					break;
+				}
 
 				if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 					holes_seen += tcp_skb_pcount(skb);
 			}
 		}
 
-		if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
-		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
-			/* RFC: should we have find_below? */
-			skb = tcp_write_queue_find(sk, tp->high_seq);
-			not_marked_skb = skb;
-			skb = tcp_write_queue_prev(sk, skb);
-			/* Timedout top is again uncertain? */
-			if (tcp_skb_timedout(sk, skb))
-				timedout_continue = 1;
-		}
-		/* RFC: ...else if (!tcp_skb_timedout) do skb fragmentation? */
-
 		/* Phase II: Marker */
 		tcp_for_write_queue_backwards_from(skb, sk) {
 			if ((tp->fackets_out <= tp->sacked_out + tp->lost_out +
-- 
1.4.2

---696243703-823902320-1175503131=:28337--
