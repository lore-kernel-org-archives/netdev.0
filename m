From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS
 invariant
Date: Fri, 2 Mar 2012 22:25:39 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1203022147100.3978@melkinpaasi.cs.helsinki.fi>
References: <1330698449-2969-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50604 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138Ab2CBUZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 15:25:42 -0500
In-Reply-To: <1330698449-2969-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Mar 2012, Neal Cardwell wrote:

> This commit fixes tcp_retransmit_skb() to respect the invariant that
> an skb in the write queue that might be SACKed (that is, that precedes
> tcp_send_head()) is either less than tcp_skb_mss(skb) or an integral
> multiple of tcp_skb_mss(skb).
> 
> Various parts of the TCP code maintain or assume this invariant,
> including at least tcp_write_xmit(), tcp_mss_split_point(),
> tcp_match_skb_to_sack(), and tcp_shifted_skb().

What invariant? We've never had such one you describe?!? It should be 
perfectly ok to have last part of the super-skb to have less than MSS 
bytes. The last one can be of arbitary size and you should be able to 
shift/merge as many of them (the non-full last segments) as you want and 
can fit to a super skb. The only condition which should allow/need 
resplitting  these is the retransmit after reneging and therefore we can 
keep the pcount changes minimal to avoid bogus "window adjustments" while 
nothing was changed on the wire for real. ...One more thought, perhaps
reneging+partial re-sacked case is potentially broken for real but it 
should be solved while reneging is being processed by doing all those 
window affecting pcount tweaks only then, but not too likely scenario 
in the first place (but I suppose this could lead even to negative pcount 
at worst which is certainly bad thing to happen).

Please note though that some SACK(tag) code still needs to maintain the 
sent time decided mss boundaries while shifting partial but even that 
would not be necessary if DSACK code would be more clever than it is at 
the moment. I used to have some plans to fix this too but it would have 
depended on rbtree stuff which wasn't/isn't there because that patchset
is still in rottens-in-some-git state.

> tcp_retransmit_skb() did not maintain this invariant. It checked the
> current MSS and called tcp_fragment() to make sure that the skb we're
> retransmitting is at most cur_mss, but in the process it took the
> excess bytes and created an arbitrary-length skb (one that is not
> necessarily an integral multiple of its MSS) and inserted it in the
> write queue after the skb we're retransmitting.

Also if MSS changes after userspace writes, we'll have the very same 
"problem" (or other "normal behavior" leaves those non-full skbs e.g., due 
to slow application). ...This should be non-issue really if the code is 
properly written.

> One potential indirect effect of this problem is tcp_shifted_skb()
> creating a coalesced SACKed skb that has a pcount that is 1 too large
> for its length. This happened because tcp_shifted_skb() assumed that
> skbs are integral multiples of MSS, so you can just add pcounts of
> input skbs to find the pcount of the output skb.

...It does _not_ assume what you say! ...Instead, it does this on purpose.
Anything else is wrong thing because it affects window calculations just 
to get our clever gso hacks to work.

SACK code should maintain the original pcounts from sent time, not change 
them! So if we sent MSS+1 and MSS+1 we should have (1+1)+(1+1) as pcount 
after shifting instead of 1+1+1. ...This keeping of original pcounts is 
the real invariant I used while writing the new sacktag code with 
shifting.

> Suspected specific
> symtoms of this problem include the WARN_ON(len > skb->len) in
> tcp_fragment() firing, as the 1-too-large pcount ripples though to
> tcp_mark_head_lost() trying to chop off too many bytes to mark as
> lost.

Why would we be splitting SACKed segment there?!? ...Ah, it seems that 
it indeed is possible now after the non-FACK mode fragment, however, it
is totally useless work and seems to be breaking stuff. I think that the 
proper solution is to prevent splitting of already SACKed stuff. ...Nice 
find btw. :-)

> It's also possible this bug is related to recent reports of sacked_out
> becoming negative.

Perhaps, but those are much more likely due to the recent changes 
breaking stuff instead (I haven't seen those reports about sacked_out 
before the three latest fixes, tcp_fragment stuff is reportedly older 
though)...

-- 
 i.
