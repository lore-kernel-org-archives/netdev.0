From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] net: fix infinite loop in __skb_recv_datagram()
Date: Tue, 12 Feb 2013 20:18:13 +0400
Message-ID: <511A6B45.3090504@parallels.com>
References: <CA+ydwtphWsC-B9Y2WwWOPEWtPPj62Wf6Pt2iZ+tAGaTvg_7gCg@mail.gmail.com>  <1360628371.20362.28.camel@edumazet-glaptop>  <1360638903.20362.32.camel@edumazet-glaptop>  <CA+ydwtoBttwiVz+oy0hnetUTQMi7XHyS9bfGzjuP1L41srBk=g@mail.gmail.com> <1360685813.13993.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tommi Rantala <tt.rantala@gmail.com>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20468 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758297Ab3BLQSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 11:18:38 -0500
In-Reply-To: <1360685813.13993.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 08:16 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Tommi was fuzzing with trinity and reported the following problem :
> 
> commit 3f518bf745 (datagram: Add offset argument to __skb_recv_datagram)
> missed that a raw socket receive queue can contain skbs with no payload.
> 
> We can loop in __skb_recv_datagram() with MSG_PEEK mode, because
> wait_for_packet() is not prepared to skip these skbs.
> 
> [   83.541011] INFO: rcu_sched detected stalls on CPUs/tasks: {}
> (detected by 0, t=26002 jiffies, g=27673, c=27672, q=75)
> [   83.541011] INFO: Stall ended before state dump start
> [  108.067010] BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child31:2847]
> ...
> [  108.067010] Call Trace:
> [  108.067010]  [<ffffffff818cc103>] __skb_recv_datagram+0x1a3/0x3b0
> [  108.067010]  [<ffffffff818cc33d>] skb_recv_datagram+0x2d/0x30
> [  108.067010]  [<ffffffff819ed43d>] rawv6_recvmsg+0xad/0x240
> [  108.067010]  [<ffffffff818c4b04>] sock_common_recvmsg+0x34/0x50
> [  108.067010]  [<ffffffff818bc8ec>] sock_recvmsg+0xbc/0xf0
> [  108.067010]  [<ffffffff818bf31e>] sys_recvfrom+0xde/0x150
> [  108.067010]  [<ffffffff81ca4329>] system_call_fastpath+0x16/0x1b
> 
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Tested-by: Tommi Rantala <tt.rantala@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

Thanks!

> ---
>  net/core/datagram.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 0337e2b..368f9c3 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -187,7 +187,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>  		skb_queue_walk(queue, skb) {
>  			*peeked = skb->peeked;
>  			if (flags & MSG_PEEK) {
> -				if (*off >= skb->len) {
> +				if (*off >= skb->len && skb->len) {
>  					*off -= skb->len;
>  					continue;
>  				}
> 
> 
> .
> 
