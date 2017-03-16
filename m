From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same
 sk_rx_dst.
Date: Thu, 16 Mar 2017 14:33:16 -0700
Message-ID: <1489699996.28631.237.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Kevin Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34773 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752051AbdCPVeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 17:34:11 -0400
Received: by mail-pf0-f194.google.com with SMTP id o126so6996231pfb.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 14:33:19 -0700 (PDT)
In-Reply-To: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-16 at 01:08 -0700, Kevin Xu wrote:
> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> on the same dst, causing reference count leakage. Eventually, it
> prevents net_device to be destroyed. The bug then manifested as
> 
> unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> in the kernel log, preventing new network namespace creation.
> 
> The patch works around the issue by checking whether the socket already
> has the same dst set.
> 
> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
> ---
>  net/ipv4/tcp_ipv4.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 575e19d..f425c14 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1807,9 +1807,14 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
>  {
>  	struct dst_entry *dst = skb_dst(skb);
>  
> -	if (dst && dst_hold_safe(dst)) {
> -		sk->sk_rx_dst = dst;
> -		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
> +	if (dst) {
> +		if (unlikely(dst == sk->sk_rx_dst))
> +			return;
> +
> +		if (dst_hold_safe(dst)) {
> +			sk->sk_rx_dst = dst;
> +			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
> +		}


That should not be needed.

Have you backported the redirect fix ?

commit 45caeaa5ac0b4b11784ac6f932c0ad4c6b67cda0

Or other fixes that went very recently (pick David Miller net tree)
