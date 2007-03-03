From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Sat, 3 Mar 2007 13:45:54 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703031145110.18827@kivilampi-30.cs.helsinki.fi>
References: <20070228.114949.18302561.davem@davemloft.net>
 <20070301181340.GD25760@galon.ev-en.org> <20070302.222250.41632359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41775 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbXCCLp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 06:45:56 -0500
In-Reply-To: <20070302.222250.41632359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Mar 2007, David Miller wrote:

> From: Baruch Even <baruch@ev-en.org>
> Date: Thu, 1 Mar 2007 20:13:40 +0200

> > One drawback for this approach is that you now walk the entire sack
> > block when you advance one packet. If you consider a 10,000 packet queue
> > which had several losses at the beginning and a large sack block that
> > advances from the middle to the end you'll walk a lot of packets for
> > that one last stretch of a sack block.

Maybe this information in the last ACK could be even used as advantage to 
speed up the startpoint lookup, since the last ACK very likely contains 
the highest SACK block (could not hold under attack though), no matter how 
big it is, and it's not necessary to process it ever if we know for sure 
that it was the global highest rather than a local one. Using that, it's 
trivial to find the starting point below the SACK block and that could be 
passed to the head_lost marking on-the-fly using stack rather than in the
structs. Sort of fastpath too :-)... Maybe even some auto-tuning thingie 
which enables conditionally skipping of large SACK-blocks to reuse all of 
this last ACK information in mark_head but that would get rather 
complicated I think.

> > One way to handle that is to use the still existing sack fast path to
> > detect this case and calculate what is the sequence number to search
> > for. Since you know what was the end_seq that was handled last, you can
> > search for it as the start_seq and go on from there. Does it make sense?
> 
> BTW, I think I figured out a way to get rid of
> lost_{skb,cnt}_hint.  The fact of the matter in this case is that
> the setting of the tag bits always propagates from front of the queue
> onward.  We don't get holes mid-way.
> 
> So what we can do is search the RB-tree for high_seq and walk
> backwards.  Once we hit something with TCPCB_TAGBITS set, we
> stop processing as there are no earlier SKBs which we'd need
> to do anything with.

If TCP knows the highest SACK block skb (or its seq) and high_seq, finding 
the starting point is really trivial as you can always take min of them 
without any walking. Then walk backwards skipping first reordering, until 
the first LOST one is encountered. ...Only overhead then comes from the 
skipped which depends on the current reordering (of course that was not 
overhead if they were timedout). This would not even require knowledge 
about per skb fack_count because the skipping servers for its purpose and 
it can be done on the fly.

> scoreboard_skb_hint is a little bit trickier, but it is a similar
> case to the tcp_lost_skb_hint case.  Except here the termination
> condition is a relative timeout instead of a sequence number and
> packet count test.
> 
> Perhaps for that we can remember some state from the
> tcp_mark_head_lost() we do first.  In fact, we can start
> the queue walk from the latest packet which tcp_mark_head_lost()
> marked with a tag bit.

Yes, the problem with this case compared to head_lost seems to be that
we don't know whether the first skb (in backwards walk) must be marked 
until we have walked past it (actually to the point where the first 
SACKED_RETRANS is encountered, timestamps should be in order except for 
the discontinuity that occurs at SACKED_RETRANS edge). So it seems to me 
that any backwards walk could be a bit problematic in this case exactly 
because of this discontinuity? Armed with this knowledge, however, 
backwards walk could start checking for timedout marking right at the 
first SACKED_RETRANS skb. And continue later from that point forward if 
the skb at the edge was also marked due to timeout. ...Actually, I think 
that other discontinuity can exists at the EVER_RETRANS edge but that 
suffers from the same problem as non-RETRANS skbs before SACKED_RETRANS 
edge when first encountered and therefore is probably pretty useless.

> Basically these two algorithms are saying:
> 
> 1) Mark up to smallest of 'lost' or tp->high_seq.
> 2) Mark packets after those processed in #1 which have
>    timed out.
> 
> Right?

So I would take another angle to this problem (basically combine the 
lost calculation from tcp_update_scoreboard and mark_head lost stuff and 
ignore this lost altogether). Basically what I propose is something like 
this (hopefully I don't stomp your feet by coding it this much as
pseudish approach seemed to get almost as complex :-)):

void tcp_update_scoreboard_fack(struct sock *sk)
{
	struct tcp_sock *tp = tcp_sk(sk);
	int reord_count = 0;
	int had_retrans = 0;
	struct sk_buff *timedout_reentry_skb = NULL;
	
	/* How to get this highest_sack? */
	skb = get_min_skb_wrapsafe(tp->high_seq, highest_sack);

	walk_backwards_from(sk, skb) {
		if (TCP_CB_SKB(skb)->sacked & TCPCB_LOST)
			break;
		
		if (TCP_CB_SKB(skb)->sacked & TCPCB_SACKED_RETRANS) {
			had_retrans = 1;
			if (tcp_skb_timedout(skb))
				timedout_reentry_skb = skb;
		}
		reord_count += tcp_skb_pcount(skb);
		if (((reord_count > tp->reordering) || /* check off-by-one?*/
		     (had_retrans && tcp_skb_timedout(skb))) &&
		    !(TCP_CB_SKB(skb)->sacked & TCPCB_SACKED_ACKED)) {
			/* Might have to handle skb fragmentation here if the
			 * pcount > 1? Original does not handle it, btw.
			 */
			TCP_CB_SKB(skb)->sacked |= TCPCB_LOST;
			tp->lost_out += tcp_skb_pcount(skb);
		}			
	}
	/* Might have to handle the lost <= 0 condition here if nothing
	 * got marked in the loop (might be a good thing to have a reference
	 * to last non-SACKed and non-LOST skb from the loop to avoid extra
	 * walking for it.
	 */

	/* ...continue timeout work if necessary */
	if (timedout_reentry_skb != NULL) {
		skb = next_skb(timedout_reentry_skb);
		walk_forward_from(sk, skb) {
			if (!tcp_skb_timedout(skb))
				break;
			if (!(TCP_CB_SKB(skb)->sacked & TCPCB_SACKED_ACKED)) {
				TCP_CB_SKB(skb)->sacked |= TCPCB_LOST;
				tp->lost_out += tcp_skb_pcount(skb);
			}
		}
	}
}

...I considered only FACK, NewReno operates only right after snd_una 
anyway except for the timedout thing, thus it could be easier to do using 
completely different approach. Also RFC3517 is easy to do by changing 
"reord_count += tcp_skb_pcount(skb)" condition to depend on SACKED_ACKED 
rather than unconditionally doing that.

Yet, I'm not sure that marking due to skb_timedout works very nicely 
at all, this is true especially for the non-FACK SACK which marks only 
first head using mark_head_lost, then when the first cumulative ACK 
arrives, the timestamps will timeout basically all/most of the skbs. I've 
been considering also cleaning up a patch to not only to this problem but 
to make non-FACK SACK to be quite close to RFC3517 (except for 
ratehalving; I've even code for a sysctl to disable ratehalving but I'm 
not too sure that it's currently safe for general use, even though it 
works quite nicely for my purposes). It would also consist disabling of 
non-RFC retransmission things which seem come from FACK paper. Those are 
based on reordering never happens assumption (100% correct guesses as long 
as that assumption holds).


-- 
 i.
