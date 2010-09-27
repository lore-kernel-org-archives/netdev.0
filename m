From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] fix TSO FACK loss marking in tcp_mark_head_lost
Date: Mon, 27 Sep 2010 22:20:57 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009272155030.15680@melkinpaasi.cs.helsinki.fi>
References: <1285370526-18279-1-git-send-email-ycheng@google.com> <alpine.DEB.2.00.1009271520560.26447@wel-95.cs.helsinki.fi> <20100927.111114.124003889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1591383556-1285614548=:15680"
Cc: ycheng@google.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37463 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760035Ab0I0TU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 15:20:59 -0400
In-Reply-To: <20100927.111114.124003889.davem@davemloft.net>
Content-ID: <alpine.DEB.2.00.1009272209110.15680@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1591383556-1285614548=:15680
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1009272209111.15680@melkinpaasi.cs.helsinki.fi>

On Mon, 27 Sep 2010, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 27 Sep 2010 15:22:09 +0300 (EEST)
> 
> > On Fri, 24 Sep 2010, Yuchung Cheng wrote:
> > 
> >> When TCP uses FACK algorithm to mark lost packets in
> >> tcp_mark_head_lost(), if the number of packets in the (TSO) skb is
> >> greater than the number of packets that should be marked lost, TCP
> >> incorrectly exits the loop and marks no packets lost in the skb. This
> >> underestimates tp->lost_out and affects the recovery/retransmission.
> >> This patch fargments the skb and marks the correct amount of packets
> >> lost.
> >> 
> >> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> >> ---
> >>  net/ipv4/tcp_input.c |    3 ++-
> >>  1 files changed, 2 insertions(+), 1 deletions(-)
> >> 
> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> index 1bc87a0..e4f472e 100644
> >> --- a/net/ipv4/tcp_input.c
> >> +++ b/net/ipv4/tcp_input.c
> >> @@ -2532,7 +2532,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
> >>  			cnt += tcp_skb_pcount(skb);
> >>  
> >>  		if (cnt > packets) {
> >> -			if (tcp_is_sack(tp) || (oldcnt >= packets))
> >> +			if ((tcp_is_sack(tp) && !tcp_is_fack(tp)) ||
> >> +			    (oldcnt >= packets))
> >>  				break;
> >>  
> >>  			mss = skb_shinfo(skb)->gso_size;
> >> 
> > 
> > Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> BTW, the history is that this code was added to fix a bug because
> we didn't handle GSO packets at all at one point.
> 
> But, conservatively, we didn't do splits here for SACK, and it was
> stated in the commit that we would look into it "at some point in the
> future" :-)
>
> --------------------
> commit c137f3dda04b0aee1bc6889cdc69185f53df8a82
> Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> Date:   Mon Apr 7 22:32:38 2008 -0700
> 
>     [TCP]: Fix NewReno's fast rexmit/recovery problems with GSOed skb
>     
>     Fixes a long-standing bug which makes NewReno recovery crippled.
>     With GSO the whole head skb was marked as LOST which is in
>     violation of NewReno procedure that only wants to mark one packet
>     and ended up breaking our TCP code by causing counter overflow
>     because our code was built on top of assumption about valid
>     NewReno procedure. This manifested as triggering a WARN_ON for
>     the overflow in a number of places.
>     
>     It seems relatively safe alternative to just do nothing if
>     tcp_fragment fails due to oom because another duplicate ACK is
>     likely to be received soon and the fragmentation will be retried.
>     
>     Special thanks goes to Soeren Sonnenburg <kernel@nn7.de> who was
>     lucky enough to be able to reproduce this so that the warning
>     for the overflow was hit. It's not as easy task as it seems even
>     if this bug happens quite often because the amount of outstanding
>     data is pretty significant for the mismarkings to lead to an
>     overflow.
>     
>     Because it's very late in 2.6.25-rc cycle (if this even makes in
>     time), I didn't want to touch anything with SACK enabled here.
>     Fragmenting might be useful for it as well but it's more or less
>     a policy decision rather than mandatory fix. Thus there's no need
>     to rush and we can postpone considering tcp_fragment with SACK
>     for 2.6.26.
>     
>     In 2.6.24 and earlier, this very same bug existed but the effect
>     is slightly different because of a small changes in the if
>     conditions that fit to the patch's context. With them nothing
>     got lost marker and thus no retransmissions happened.
>     
>     Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --------------------
> 
> To be honest, we should probably just remove the whole tcp_is_sack()
> test, rather than special case FACK.
> 
> The cost isn't what it was when this code was added.  Back then we
> didn't have Ilpo's restransmit queue coalescing code, so it would make
> retransmit queue packet freeing more expensive.  But since the
> coalescing code is there now, splitting all the time to record
> accurate loss information should be fine.
> 
> Ilpo what do you say?

Removing it would add a bug for non-FACK SACK as lost_cnt_hint is 
calculated a bit differently with it (only SACKed skbs count so 
lost_cnt_hint is not changing over the whole skb with pcount > 1 while 
it does change per each seg for FACK, basically non-FACK is all or 
nothing as only passing by an already SACKed segment increases 
lost_cnt_hint). ...I also fell to this trap once while reviewing this 
change and wondered in my mind why not to d it for all variants :-). So 
Yuchung's patch is fine as is afaict.

I disagree now with myself btw, it's not just "a policy decision" as we 
do not retransmit some segments at all before RTO in some scenarios.

-- 
 i.
--8323329-1591383556-1285614548=:15680--
