From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net] tcp: Update pcount after skb_pull() during mtu
 probing
Date: Fri, 05 Jun 2015 16:45:04 -0700
Message-ID: <1433547904.1895.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433521014-2465771-1-git-send-email-kafai@fb.com>
	 <CANn89iLd1bqCOxbALcDNzi--Hn8A970HmvM2__ryzjwSbOwZ6Q@mail.gmail.com>
	 <20150605180254.GC2951343@devbig242.prn2.facebook.com>
	 <1433539435.1895.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150605230206.GD2951343@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36966 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbFEXpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 19:45:09 -0400
Received: by igbsb11 with SMTP id sb11so25649939igb.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 16:45:09 -0700 (PDT)
In-Reply-To: <20150605230206.GD2951343@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-06-05 at 16:02 -0700, Martin KaFai Lau wrote:
> On Fri, Jun 05, 2015 at 02:23:55PM -0700, Eric Dumazet wrote:
> > On Fri, 2015-06-05 at 11:02 -0700, Martin KaFai Lau wrote:
> > 
> > > tcp_trim_head() does not take the mss_now.
> > > Is it fine to have mss_now <= tcp_skb_mss(skb)? or we can depend on
> > > the tcp_init_tso_segs() in the tcp_write_xmit() to take care of it?
> > 
> > It should be fine : packets not yet sent have tcp_skb_pcount()==0,
> > so that tcp_init_tso_segs() can do the computation at the right time.
> hmm.... From tcp_write_xmit(), tcp_init_tso_segs() makes tcp_skb_pcount(skb) > 0
> but it may not be sent out immediately (like failing tcp_cwnd_test()).  Later,
> this skb is considered for tcp_mtu_probe(), sliced and forgot to update the
> pcount, I think.

Then clear pcount at this point, if this is a requirement.

Or else the test on !tso_segs seems quite lazy to me.

> 
> I am probably missing something.  Hence, I have a side question
> in tcp_init_tso_segs(),  should pcount be also recalculated if
> (tso_segs == 1 && mss_now < skb->len)?  Like this:
> 
> diff --git i/net/ipv4/tcp_output.c w/net/ipv4/tcp_output.c
> index a369e8a..15d1c44 100644
> --- i/net/ipv4/tcp_output.c
> +++ w/net/ipv4/tcp_output.c
> @@ -1624,7 +1624,8 @@ static int tcp_init_tso_segs(const struct sock *sk, struct sk_buff *skb,
>  {
>  	int tso_segs = tcp_skb_pcount(skb);
> 
> -	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
> +	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now) ||
> +	    (tso_segs == 1 && mss_now < skb->len)) {
>  		tcp_set_skb_tso_segs(sk, skb, mss_now);
>  		tso_segs = tcp_skb_pcount(skb);
>  	}


See above. Lets keep fast path as fast as possible ;)
