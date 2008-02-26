From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 26 Feb 2008 12:14:26 +0000
Message-ID: <47C402A2.8040401@katalix.com>
References: <20080225215837.GA3281@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:52765 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbYBZMOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 07:14:37 -0500
In-Reply-To: <20080225215837.GA3281@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 02/25/2008 02:39 PM:
> ...
>> Hmm... Wait a minute! But on the other hand David has written about
>> his cons here, and it looks reasonable: this place would be fixed,
>> but some others can start reports like this. Maybe, it's better to
>> analyze yet if it's really so hard to eliminate taking this lock
>> on the xmit path?
> 
> James, I wonder if you could try to test this patch below?
> ip_queue_xmit() seems to do proper things with __sk_dst_check(), and
> if some other functions don't behave similarly lockdep should tell.
> I think, you could test it with your "locks to _bh" patch (without
> pppol2tp_xmit() part), and maybe with my sock.c lockdep patch (it
> should help lockdep to see these locks a bit more distinctly).

I found the same thing and was running a variant of your patch last 
night; rather than set skb->dst to NULL though, I use __sk_dst_get() and 
let ip_queue_xmit() do the route lookup if it returns NULL. But this has 
the same symptoms as the code I tried a few days ago - no lockdep errors 
but a system lockup after up to several hours. Nothing is logged in the 
syslog.

Luckily, I'm in the lab where my two borrowed servers are today so I 
have access to their consoles. Hopefully I'll be able to find out why 
there are hanging. Btw, they don't hang if I disable irqs around the 
ppp_input() call.

Will update you later.

/james

> PS: Since ppp_generic isn't endangered for now I removed Paul from CC.
> 
> ---
> 
> diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> index e0b072d..b94659a 100644
> --- a/drivers/net/pppol2tp.c
> +++ b/drivers/net/pppol2tp.c
> @@ -1058,7 +1058,7 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>  
>  	/* Get routing info from the tunnel socket */
>  	dst_release(skb->dst);
> -	skb->dst = sk_dst_get(sk_tun);
> +	skb->dst = NULL;
>  	skb_orphan(skb);
>  	skb->sk = sk_tun;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

