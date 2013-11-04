From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC net] ipv6: fix fragmentation bug
Date: Mon, 04 Nov 2013 06:25:42 -0800
Message-ID: <1383575142.4291.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
	 <1383557174-19424-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:64805 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab3KDOZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 09:25:43 -0500
Received: by mail-pa0-f42.google.com with SMTP id kp14so7031649pab.29
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 06:25:43 -0800 (PST)
In-Reply-To: <1383557174-19424-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 10:26 +0100, Alexander Aring wrote:
> In a very poor 6lowpan wireless connection I got this:

> 
> I think we need to drop skb_dst_drop(skb) in ip6_frag_queue because we
> send a icmp6_send in the expire function "ip6_expire_frag_queue":
> 
> icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME,
> 0);
> 
> and it can be that the skb is already freed. This null pointer
> dereference occurs when the timer expires.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/ipv6/reassembly.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index cc85a9b..6463ae0 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -352,7 +352,6 @@ found:
>  		return res;
>  	}
>  
> -	skb_dst_drop(skb);
>  	inet_frag_lru_move(&fq->q);
>  	return -1;
>  

Well, no, this call is needed, please check commit
97599dc792b45b1669c3cdb9a4b365aad0232f65
(" net: drop dst before queueing fragments")

for details.
