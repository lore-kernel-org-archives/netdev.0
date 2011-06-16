From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: rfs: enable RFS before first data
 packet is received
Date: Fri, 17 Jun 2011 00:50:46 +0100
Message-ID: <1308268246.2925.37.camel@bwh-desktop>
References: <1308104128.4578.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36969 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756792Ab1FPXut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 19:50:49 -0400
In-Reply-To: <1308104128.4578.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-15 at 04:15 +0200, Eric Dumazet wrote:
> First packet received on a passive tcp flow is not correctly RFS
> steered.
> 
> One sock_rps_record_flow() call is missing in inet_accept()
> 
> But before that, we also must record rxhash when child socket is setup.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: Jamal Hadi Salim <hadi@cyberus.ca>
> ---
> Netconf2011 workshop ;)
> 
>  net/ipv4/af_inet.c  |    1 +
>  net/ipv4/tcp_ipv4.c |    1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 83673d2..0600f0f 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -676,6 +676,7 @@ int inet_accept(struct socket *sock, struct socket *newsock, int flags)
>  
>  	lock_sock(sk2);
>  
> +	sock_rps_record_flow(sk2);
>  	WARN_ON(!((1 << sk2->sk_state) &
>  		  (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)));
>  
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 617dee3..955b8e6 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1594,6 +1594,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
>  			goto discard;
>  
>  		if (nsk != sk) {
> +			sock_rps_save_rxhash(nsk, skb->rxhash);
>  			if (tcp_child_process(sk, nsk, skb)) {
>  				rsk = nsk;
>  				goto reset;
> 

I haven't tried this, but it looks reasonable to me.

What about IPv6?  The logic in tcp_v6_do_rcv() looks very similar.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

