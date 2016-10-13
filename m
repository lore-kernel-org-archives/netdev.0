From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Require exact match for TCP socket lookups if dif
 is l3mdev
Date: Thu, 13 Oct 2016 23:29:51 +0200
Message-ID: <1476394191.5650.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476389690-31211-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36010 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755240AbcJMV34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 17:29:56 -0400
Received: by mail-lf0-f67.google.com with SMTP id b75so14545563lfg.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 14:29:54 -0700 (PDT)
In-Reply-To: <1476389690-31211-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-13 at 13:14 -0700, David Ahern wrote:
> Currently, socket lookups for l3mdev (vrf) use cases can match a socket
> that is bound to a port but not a device (ie., a global socket). If the
> sysctl tcp_l3mdev_accept is not set this leads to ack packets going out
> based on the main table even though the packet came in from an L3 domain.
> The end result is that the connection does not establish creating
> confusion for users since the service is running and a socket shows in
> ss output. Fix by requiring an exact dif to sk_bound_dev_if match if the
> dif is an l3mdev device and the tcp_l3mdev_accept is not set.
> 
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/net/inet_sock.h     | 10 ++++++++++
>  net/ipv4/inet_hashtables.c  |  7 ++++---
>  net/ipv6/inet6_hashtables.c |  7 ++++---
>  3 files changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 236a81034fef..abb4e720a769 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -132,6 +132,16 @@ static inline int inet_request_bound_dev_if(const struct sock *sk,
>  	return sk->sk_bound_dev_if;
>  }
>  
> +static inline bool inet_exact_dif_match(struct net *net, int dif)
> +{
> +#ifdef CONFIG_NET_L3_MASTER_DEV
> +	if (netif_index_is_l3_master(net, dif) &&
> +	    !net->ipv4.sysctl_tcp_l3mdev_accept)
> +		return true;

Since netif_index_is_l3_master() is not cheap, can you reorder the
test ?

if (!net->ipv4.sysctl_tcp_l3mdev_accept)
        return netif_index_is_l3_master(net, dif);
