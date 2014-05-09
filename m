From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: support marking accepting TCP sockets
Date: Fri, 09 May 2014 11:05:31 -0700
Message-ID: <1399658731.7973.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
	 <1399657021-26082-4-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpa@google.com, davem@davemloft.net,
	ja@ssi.bg, hannes@stressinduktion.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33435 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbaEISFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 14:05:36 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so4630515pab.40
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 11:05:36 -0700 (PDT)
In-Reply-To: <1399657021-26082-4-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-10 at 02:37 +0900, Lorenzo Colitti wrote:
> When using mark-based routing, sockets returned from accept()
> may need to be marked differently depending on the incoming
> connection request.
> 
> This is the case, for example, if different socket marks identify
> different networks: a listening socket may want to accept
> connections from all networks, but each connection should be
> marked with the network that the request came in on, so that
> subsequent packets are sent on the correct network.
> 
> This patch adds a sysctl to mark TCP sockets based on the fwmark
> of the incoming SYN packet. If enabled, and an unmarked socket
> receives a SYN, then the SYN packet's fwmark is written to the
> connection's inet_request_sock, and later written back to the
> accepted socket when the connection is established.  If the
> socket already has a nonzero mark, then the behaviour is the same
> as it is today, i.e., the listening socket's fwmark is used.
> 
> Black-box tested using user-mode linux:
> 
> - IPv4/IPv6 SYN+ACK, FIN, etc. packets are routed based on the
>   mark of the incoming SYN packet.
> - The socket returned by accept() is marked with the mark of the
>   incoming SYN packet.
> - Tested with syncookies=1 and syncookies=2.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/net/inet_sock.h          | 10 ++++++++++
>  include/net/netns/ipv4.h         |  1 +
>  net/ipv4/inet_connection_sock.c  |  6 ++++--
>  net/ipv4/syncookies.c            |  3 ++-
>  net/ipv4/sysctl_net_ipv4.c       |  7 +++++++
>  net/ipv4/tcp_ipv4.c              |  1 +
>  net/ipv6/inet6_connection_sock.c |  2 +-
>  net/ipv6/syncookies.c            |  4 +++-
>  net/ipv6/tcp_ipv6.c              |  1 +
>  9 files changed, 30 insertions(+), 5 deletions(-)
> 

Patch looks mostly OK.

> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 1833c3f..b1edf17 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -90,6 +90,7 @@ struct inet_request_sock {
>  	kmemcheck_bitfield_end(flags);
>  	struct ip_options_rcu	*opt;
>  	struct sk_buff		*pktopts;
> +	u32                     ir_mark;

Move this before the *opt field to avoid an extra 4byte hole on 64bit
arches.

>  };
>  
>  static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
> @@ -97,6 +98,15 @@ static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
>  	return (struct inet_request_sock *)sk;
>  }
>  
> +static inline u32 inet_request_mark(struct sock *sk, struct sk_buff *skb)
> +{
> +	if (!sk->sk_mark && sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept) {
> +		return skb->mark;
> +	} else {
> +		return sk->sk_mark;
> +	}

No need for {} blocks :

	if (!sk->sk_mark && sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
		return skb->mark;

	return sk->sk_mark;

>  struct inet_cork {
>  	unsigned int		flags;
>  	__be32			addr;

...
> index e40a738..6480281 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -845,6 +845,13 @@ static struct ctl_table ipv4_net_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> +	{
> +		.procname	= "tcp_fwmark_accept",
> +		.data		= &init_net.ipv4.sysctl_tcp_fwmark_accept,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  	{ }
>  };
>  

Please add relevant section in Documentation/networking/ip-sysctl.txt

Thanks
