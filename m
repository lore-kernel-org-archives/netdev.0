From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
 <20071219.235450.170670042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-397675333-1198150851=:31652"
Cc: Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54864 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbXLTLky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:40:54 -0500
In-Reply-To: <20071219.235450.170670042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-397675333-1198150851=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 19 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 19 Dec 2007 23:46:33 +0200 (EET)
> 
> > I'm not fully sure what's purpose of this code in tcp_write_xmit:
> > 
> >                        if (skb->len < limit) {
> >                                unsigned int trim = skb->len % mss_now;
> > 
> >                                if (trim)
> >                                        limit = skb->len - trim;
> > 			}
> > 
> > Is it used to make sure we send only multiples of mss_now here and leave 
> > the left-over into another skb?

Yeah, I now understand that this part is correct. I somehow got such 
impression while trying to figure this out that it ends up being dead code 
but that wasn't correct thought from my side. However, it caught my 
attention and after some thinking I'd say there's more to handle here 
(covered by the second question).

Also note that patch I sent earlier is not right either but needs some 
refining to do the right thing.

> > Or does it try to make sure that
> > tso_fragment result honors multiple of mss_now boundaries when snd_wnd
> > is the limitting factor? For latter IMHO this would be necessary:
> > 
> > 			if (skb->len > limit)
> > 				limit -= limit % mss_now;
> 
> The purpose of the test is to make sure we process tail sub-mss chunks
> correctly wrt. Nagle, which most closely matches the first purpose
> you've listed.
> 
> So I think the calculation really does belong where it is.
>
> Because of the way that the sendmsg() super-skb formation logic
> works, we always will tack on more data and grow the tail
> SKB before creating a new one.  So any sub-mss chunk at the
> end of a TSO frame really is at the end of the write queue
> and really should get nagle processing.

Yes, I now agree this is fully correct for this task.

> Actually, there is an exception, which is when we run out of
> skb_frag_list slots.  In that case we'll potentially have breaks at
> odd boundaries in the middle of the queue.  But this can only happen
> in exceptional cases (user does tons of 1-byte sendfile()'s over
> random non-consequetive locations of a file) or outright bugs
> (MAX_SKB_FRAGS is defined incorrectly, for example) and thus this
> situation is not worth coding for.

That's not the only case, IMHO if there's odd boundary due to 
snd_una+snd_wnd - skb->seq limit (done in tcp_window_allows()), we don't 
consider it as odd but break the skb at arbitary point resulting
two small segments to the network, and what's worse, when the later skb 
resulting from the first split is matching skb->len < limit check as well 
causing an unnecessary small skb to be created for nagle purpose too, 
solving it fully requires some thought in case the mss_now != mss_cache 
even if non-odd boundaries are honored in the middle of skb.

Though whether we get there is depending on what tcp_tso_should_defer() 
decided. Hmm, there seems to be an unrelated bug in it as well :-/. A 
patch below. Please consider the fact that enabling TSO deferring may 
have some unpleasant effect to TCP dynamics, considering that I don't find 
stable mandatory for this to avoid breaking, besides things have been 
working quite well without it too... Only compile tested.

-- 
 i.


--
[PATCH] [TCP]: Fix TSO deferring

I'd say that most of what tcp_tso_should_defer had in between
there was dead code because of this.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8dafda9..693b9f6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1217,7 +1217,8 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 		goto send_now;
 
 	/* Defer for less than two clock ticks. */
-	if (!tp->tso_deferred && ((jiffies<<1)>>1) - (tp->tso_deferred>>1) > 1)
+	if (tp->tso_deferred &&
+	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
 		goto send_now;
 
 	in_flight = tcp_packets_in_flight(tp);
-- 
1.5.0.6

---696243703-397675333-1198150851=:31652--
