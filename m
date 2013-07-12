From: Florian Westphal <fw@strlen.de>
Subject: Re: updates to syncookies - timestamps not needed any more
 (freebsd)
Date: Fri, 12 Jul 2013 16:25:21 +0200
Message-ID: <20130712142521.GA22686@breakpoint.cc>
References: <20130708160421.GA9763@order.stressinduktion.org>
 <20130711.165726.2168148122875413191.davem@davemloft.net>
 <20130712084145.GJ27468@breakpoint.cc>
 <1373637885.10804.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47205 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964899Ab3GLOZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 10:25:24 -0400
Content-Disposition: inline
In-Reply-To: <1373637885.10804.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-07-12 at 10:41 +0200, Florian Westphal wrote:
> 
> > The main difference to what linux does is to avoid encoding the 'count'
> > value (Linux doesn't reseed secret[], and relies on count to detect old
> > cookies).
> > 
> > Not having the counter frees up space to encode tcp options in the cookie
> > instead of the timestamp.
> 
> But still wscale and sack options are disabled.

Yes, in Linux sack and wscale will be encoded in the timestamp, as
cookie is already restricted to 24 bits due to counter.

Without the counter, that could be changed to allow sack/wscale even
with ts off.

> BTW, following patch allows to test more easily syncookies behavior.
> 
> If sysctl_tcp_syncookies is set to 2, we always use syncookies.

I think this change would be useful.

> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1462,7 +1462,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  	 * limitations, they conserve resources and peer is
>  	 * evidently real one.
>  	 */
> -	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> +	if ((sysctl_tcp_syncookies == 2 ||
> +	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
>  		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
>  		if (!want_cookie)
