From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/8] tcp: Fix conditions to determine checksum
 offload
Date: Mon, 14 Dec 2015 11:39:04 -0800
Message-ID: <1450121944.8474.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
	 <1450120787-1773171-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34520 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbbLNTjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:39:07 -0500
Received: by pfbo64 with SMTP id o64so31747480pfb.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:39:05 -0800 (PST)
In-Reply-To: <1450120787-1773171-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-14 at 11:19 -0800, Tom Herbert wrote:
> In tcp_send_sendpage and tcp_sendmsg we check the route capabilities to
> determine if checksum offload can be performed. This check currently
> does not take the IP protocol into account for devices that advertise
> only one of NETIF_F_IPV6_CSUM or NETIF_F_IP_CSUM. This patch adds a
> function to check capabilities for checksum offload with a socket
> called sk_check_csum_caps. This function checks for specific IPv4 or
> IPv6 offload support based on the family of the socket.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/sock.h | 9 +++++++++
>  net/ipv4/tcp.c     | 4 ++--
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 0ca22b0..ab0269f 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1791,6 +1791,15 @@ static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
>  	sk->sk_route_caps &= ~flags;
>  }
>  
> +static inline bool sk_check_csum_caps(struct sock *sk)
> +{
> +	return (sk->sk_route_caps & NETIF_F_HW_CSUM) ||
> +	       (sk->sk_family == PF_INET &&
> +		(sk->sk_route_caps & NETIF_F_IP_CSUM)) ||
> +	       (sk->sk_family == PF_INET6 &&
> +		(sk->sk_route_caps & NETIF_F_IPV6_CSUM));
> +}
> +

Not sure this handles ipv6_mapped correctly ?

Since this is going to be called quite often, we might set a single bit
in sk_setup_caps() or elsewhere and test it here as fast as possible.
