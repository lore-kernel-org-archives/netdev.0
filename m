From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Tue, 02 Jul 2013 20:21:36 -0700
Message-ID: <51D398C0.5060802@candelatech.com>
References: <51BF50B3.1080403@candelatech.com>  <1371493059.3252.200.camel@edumazet-glaptop>  <51D1C620.8030007@candelatech.com> <1372813467.4979.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36391 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab3GCDVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 23:21:38 -0400
In-Reply-To: <1372813467.4979.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 06:04 PM, Eric Dumazet wrote:
> On Mon, 2013-07-01 at 11:10 -0700, Ben Greear wrote:
>
>> offset: -1459  start: -1146162927 seq: -1146161468 size: 16047 copy: 3576
>> ...
>>
>> There were 80 total splats of this nature grouped together, and then
>> the system recovered and continue to function normally as far as I
>> can tell.  The later splats are a bit farther apart...maybe the
>> TCP connection is dying.
>>
>> It appears my 'work-around' is poor at best, but I'd rather kill
>> a TCP connection and spam the logs than crash the OS.
>>
>> I'd be more than happy to add more/different debugging code.
>
> It would be nice to pinpoint the origin of the bug. Really.
>
> This BUG_ON() is at least 7 years old. I do not think invariant has
> changed ?
>
> Sure we can avoid crashes but it looks like we could randomly corrupt
> tcp payload or whatever kernel memory, if it turns out its caused by a
> buggy driver.
>
> Is it happening while collapsing the receive queue, or the ofo queue ?

What kinds of things could a driver do to cause this.  Maybe modify an
skb after it has sent it up the stack, or something like that?

We haven't been able to reproduce on a clean 3.10 yet...but it often takes days,
so we'll leave the test up through end of this week if we don't hit it
sooner...

I'll add your patch to my 3.9 tree.

Thanks,
Ben


> In receive queue, all skbs skb2 following skb1 must have
>
> TCP_SKB_CB(skb1)->end_seq >= TCP_SKB_CB(skb2)->seq
>
> Only on ofo, we could have this not respected, and it should be handled
> properly in tcp_collapse_ofo_queue()
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 28af45a..d77f1f0 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4457,7 +4457,12 @@ restart:
>   			int offset = start - TCP_SKB_CB(skb)->seq;
>   			int size = TCP_SKB_CB(skb)->end_seq - start;
>
> -			BUG_ON(offset < 0);
> +			if (unlikely(offset < 0)) {
> +				pr_err("tcp_collapse() bug on %s offset:%d size:%d copy:%d skb->len %u truesize %u, nskb->len %u\n",
> +					list == &sk->sk_receive_queue ? "receive_queue" : "ofo_queue",
> +					offset, size, copy, skb->len, skb->truesize, nskb->len);
> +				return;
> +			}
>   			if (size > 0) {
>   				size = min(copy, size);
>   				if (skb_copy_bits(skb, offset, skb_put(nskb, size), size))
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
