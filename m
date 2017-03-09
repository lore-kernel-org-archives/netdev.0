From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Thu, 9 Mar 2017 15:50:37 -0800
Message-ID: <20170309155037.07fa7e98@xeon-e3>
References: <1489093758-17731-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34607 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdCIXuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 18:50:40 -0500
Received: by mail-pf0-f170.google.com with SMTP id v190so34476337pfb.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 15:50:40 -0800 (PST)
In-Reply-To: <1489093758-17731-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Mar 2017 14:09:18 -0700
Subash Abhinov Kasiviswanathan <subashab@codeaurora.org> wrote:

> Certain system process significant unconnected UDP workload.
> It would be preferrable to disable UDP early demux for those systems
> and enable it for TCP only.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> ---

This makes sense.

> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index d6feabb..187feae 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -329,7 +329,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  		int protocol = iph->protocol;
>  
>  		ipprot = rcu_dereference(inet_protos[protocol]);
> -		if (ipprot && ipprot->early_demux) {
> +		if (ipprot && ipprot->early_demux && *ipprot->early_demux_enabled) {
>  			ipprot->early_demux(skb);
>  			/* must reload iph, skb->head might have changed */
>  			iph = ip_hdr(skb);

Another possible option would be change the function pointer for early_demux instead of having
an additional conditional test (and cache line read).  The downside of doing it that way
is the code to turn the sysctl on/off gets more complicated than simple standard proc_int_vec.
