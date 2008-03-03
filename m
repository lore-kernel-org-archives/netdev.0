From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
Date: Mon, 3 Mar 2008 15:53:12 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
 <Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020420ka42319bu1b9888217c869d9d@mail.gmail.com>
 <Pine.LNX.4.64.0803021432200.17919@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020515m1e4af9d9xd37a8912e58a4504@mail.gmail.com>
 <Pine.LNX.4.64.0803022145210.18020@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0803031025210.18640@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-662713104-1204487187=:18020"
Cc: Guillaume Chazarain <guichaz@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ray Lee <ray-lk@madrabbit.org>, Chris Wedgwood <cw@f00f.org>,
	Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56472 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbYCCNxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:53:15 -0500
In-Reply-To: <Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0803031541231.28251@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-662713104-1204487187=:18020
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803022146411.18020@kivilampi-30.cs.helsinki.fi>

On Mon, 3 Mar 2008, Ilpo Järvinen wrote:

> On Mon, 3 Mar 2008, Ilpo Järvinen wrote:
> 
> > On Sun, 2 Mar 2008, Ilpo Järvinen wrote:
> > 
> > > On Sun, 2 Mar 2008, Guillaume Chazarain wrote:
> > > 
> > > >> On Sun, Mar 2, 2008 at 1:38 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > > >>> It does not contain any "KERNEL: assertion (packets <=
> > > >> > tp->packets_out) failed at" line, so I'm afraid it's just noise.
> > > 
> > > Doh, you were right in this one...
> 
> I did some filtering among those and found out that some still point out 
> bug (there might be indication of tcp_mark_head_lost inconsistency as 
> well but it's nearly impossible to track with all the incorporated noise
> which is causing which). ...I'll post the patch separately right after 
> this.

Dave, at least this is needed for TCP packet counter correctness, there 
could be other one hiding still because this only makes fackets_out too 
small (there could be second order effect though), while people are seeing 
a result of too large fackets_out in tcp_mark_head_lost.

It's a bit shame that I didn't notice this when I verified time-seqno 
graphs after that sacktag rewrite (it mostly results just a substle 
difference in the slope).

With this & the debug patch I didn't get anything into my logs but others 
might be more successful if there are other bugs still to solve that 
require more sophisticated network conditions to occur.


-- 
 i.

[PATCH net-2.6] [TCP]: Must count fack_count also when skipping

It makes fackets_out to grow too slowly compared with the
real write queue.

This shouldn't cause those BUG_TRAP(packets <= tp->packets_out)
to trigger but how knows how such inconsistent fackets_out
affects here and there around TCP when everything is nowadays
assuming accurate fackets_out. So lets see if this silences
them all.

Reported by Guillaume Chazarain <guichaz@gmail.com>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..7facdb0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1367,7 +1367,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
  * a normal way
  */
 static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct sock *sk,
-					u32 skip_to_seq)
+					u32 skip_to_seq, int *fack_count)
 {
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
@@ -1375,6 +1375,8 @@ static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct sock *sk,
 
 		if (!before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
 			break;
+
+		*fack_count += tcp_skb_pcount(skb);
 	}
 	return skb;
 }
@@ -1390,7 +1392,7 @@ static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
 		return skb;
 
 	if (before(next_dup->start_seq, skip_to_seq)) {
-		skb = tcp_sacktag_skip(skb, sk, next_dup->start_seq);
+		skb = tcp_sacktag_skip(skb, sk, next_dup->start_seq, fack_count);
 		tcp_sacktag_walk(skb, sk, NULL,
 				 next_dup->start_seq, next_dup->end_seq,
 				 1, fack_count, reord, flag);
@@ -1537,7 +1539,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
-				skb = tcp_sacktag_skip(skb, sk, start_seq);
+				skb = tcp_sacktag_skip(skb, sk, start_seq,
+						       &fack_count);
 				skb = tcp_sacktag_walk(skb, sk, next_dup,
 						       start_seq,
 						       cache->start_seq,
@@ -1565,7 +1568,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 				goto walk;
 			}
 
-			skb = tcp_sacktag_skip(skb, sk, cache->end_seq);
+			skb = tcp_sacktag_skip(skb, sk, cache->end_seq,
+					       &fack_count);
 			/* Check overlap against next cached too (past this one already) */
 			cache++;
 			continue;
@@ -1577,7 +1581,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 				break;
 			fack_count = tp->fackets_out;
 		}
-		skb = tcp_sacktag_skip(skb, sk, start_seq);
+		skb = tcp_sacktag_skip(skb, sk, start_seq, &fack_count);
 
 walk:
 		skb = tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
-- 
1.5.2.2

---696243703-662713104-1204487187=:18020--
