From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 14:07:30 -0400 (EDT)
Message-ID: <20140321.140730.1007660405690890605.davem@davemloft.net>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, herbert@gondor.apana.org.au, hkchu@google.com,
	mwdalton@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbaCUSHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 14:07:36 -0400
In-Reply-To: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Mar 2014 11:49:01 -0700

> csum_replace2() uses about 29 cycles, while a plain ip_send_check() is
> way faster (16 cycles)
> 
> csum_partial() is not really meant for doing checksums over 8 bytes !
> 
> Any idea how to make the thing really fast as intended ?
> 
> I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> is insane...
> 
> Following patch might be the fastest thing ?
> 
> (At this point we already have validated IP checksum)
 ...
> @@ -1434,8 +1434,8 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
>  	int proto = iph->protocol;
>  	int err = -ENOSYS;
>  
> -	csum_replace2(&iph->check, iph->tot_len, newlen);
>  	iph->tot_len = newlen;
> +	ip_send_check(&iph);

Yeah the csum_replace*() are extremely suboptimal.

We should be able to cons up something cheap like the trick that
ip_decrease_ttl() uses.

https://tools.ietf.org/html/rfc1624
https://tools.ietf.org/html/rfc1141
