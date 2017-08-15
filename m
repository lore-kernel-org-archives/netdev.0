From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] ipv6: Prevent unexpected sk->sk_prot
 changes
Date: Tue, 15 Aug 2017 04:59:17 -0700
Message-ID: <1502798357.4936.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502795320-22538-1-git-send-email-ilyal@mellanox.com>
         <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davejwatson@fb.com,
        aviadye@mellanox.com, Boris Pismenny <borisp@mellanox.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36809 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdHOL7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 07:59:19 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so1196116pgy.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 04:59:18 -0700 (PDT)
In-Reply-To: <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 14:08 +0300, Ilya Lesokhin wrote:
> With this patch IPV6 code ensure that only sockets with the
> expected sk->sk_prot are converted to IPV4.
> 
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> ---
>  net/ipv6/ipv6_sockglue.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 02d795f..318cd344 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -174,6 +174,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  		if (val == PF_INET) {
>  			struct ipv6_txoptions *opt;
>  			struct sk_buff *pktopt;
> +			struct proto *expected_prot;
>  
>  			if (sk->sk_type == SOCK_RAW)
>  				break;
> @@ -199,6 +200,17 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  				break;
>  			}
>  
> +			if (sk->sk_protocol == IPPROTO_TCP &&
> +			    sk->sk_prot != &tcpv6_prot)
> +				break;
> +
> +			expected_prot = &udpv6_prot;
> +			if (sk->sk_protocol == IPPROTO_UDPLITE)
> +				expected_prot = &udplitev6_prot;
> +
> +			if (sk->sk_prot != expected_prot)
> +				break;
> +
>  			fl6_free_socklist(sk);
>  			__ipv6_sock_mc_close(sk);
>  

I am afraid I do not understand this patch at all.

Direct references to tcpv6_prot, udpv6_prot, and udplitev6_prot in
net/ipv6/ipv6_sockglue.c looks completely broken.

Please provide something cleaner, maybe by adding a new method
(implementation would then be provided in TCP / UDP code )
