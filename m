From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] tcp: honour SO_BINDTODEVICE for TW_RST case too
Date: Mon, 21 Dec 2015 19:56:20 +0100
Message-ID: <20151221185620.GB9692@breakpoint.cc>
References: <1450714809-2773-1-git-send-email-fw@strlen.de>
 <1450718113.8474.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44880 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbbLUS4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 13:56:22 -0500
Content-Disposition: inline
In-Reply-To: <1450718113.8474.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > -	net = sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
> > +	have_full_sk = sk && sk_fullsock(sk);
> > +	net = have_full_sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
> 
> But the net pointer can be derived from timewait the same, not sure why
> you changed this part ... This makes your patch look more complicated
> than what is needed.

Duh, you're right -- I'll send a V2.

> >  #ifdef CONFIG_TCP_MD5SIG
> >  	hash_location = tcp_parse_md5sig_option(th);
> > -	if (!sk && hash_location) {
> > +	if (have_full_sk) {
> > +		key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
> > +					&ip_hdr(skb)->saddr, AF_INET);
> > +	} else if (hash_location) {
> >  		/*
> >  		 * active side is lost. Try to find listening socket through
> >  		 * source port, and then find md5 key through listening socket.
> > @@ -651,10 +656,6 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
> >  		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, skb);
> >  		if (genhash || memcmp(hash_location, newhash, 16) != 0)
> >  			goto release_sk1;
> > -	} else {
> > -		key = sk ? tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
> > -					     &ip_hdr(skb)->saddr,
> > -					     AF_INET) : NULL;
> >  	}
> >  
> >  	if (key) {
> > @@ -675,7 +676,14 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
> >  				      ip_hdr(skb)->saddr, /* XXX */
> >  				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
> >  	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
> > -	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
> > +	arg.flags = 0;
> > +	if (have_full_sk) {
> > +		if (inet_sk(sk)->transparent)
> > +			arg.flags = IP_REPLY_ARG_NOSRCCHECK;
> > +	} else if (sk && inet_twsk(sk)->tw_transparent) {
> > +		arg.flags = IP_REPLY_ARG_NOSRCCHECK;
> > +	}
> > +
> 
> Maybe a helper to retrieve the transparant status from a generic socket
> (being full, timewait or request sock) would help.
> 
> This could be submitted as a separate patch to ease review.

Makes sense, will do this.

> >  	oif = sk ? sk->sk_bound_dev_if : 0;
> > +	if (!have_full_sk)
> > +		sk = NULL;
> > +
> 
> I have no idea why you need to set sk to NULL here.

Its a followup error.  As sock_net(twsk) is fine this isn't
needed either and I'll remove this part.

> I found this hard to review...

Apologies.  Thanks for reviewing despite this, I will try
to address all of your comments.

> It seems you have multiple logical changes ?

> Splitting into at least 2 patches would be nice.

will do,

Thanks Eric.
