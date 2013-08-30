From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Fri, 30 Aug 2013 11:02:08 +0800
Message-ID: <52200B30.40305@redhat.com>
References: <1377304192.8828.43.camel@edumazet-glaptop>   <1377491162.8828.116.camel@edumazet-glaptop>  <1377607592.8828.149.camel@edumazet-glaptop> <521DA8BE.3060709@redhat.com> <1377686084.8828.175.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab3H3DCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 23:02:23 -0400
In-Reply-To: <1377686084.8828.175.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2013 06:34 PM, Eric Dumazet wrote:
> On Wed, 2013-08-28 at 15:37 +0800, Jason Wang wrote:
>
>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>> index 884efff..e63ae4c 100644
>>> --- a/net/ipv4/tcp_output.c
>>> +++ b/net/ipv4/tcp_output.c
>>> @@ -1631,7 +1631,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
>>>  
>>>  	/* If a full-sized TSO skb can be sent, do it. */
>>>  	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
>>> -			   sk->sk_gso_max_segs * tp->mss_cache))
>>> +			   tp->xmit_size_goal_segs * tp->mss_cache))
>>>  		goto send_now;
>> A question is: Does this really guarantee the minimal TSO segments
>> excluding the case of small available window? The skb->len may be much
>> smaller and can still be sent here. Maybe we should check skb->len also?
> tcp_tso_should_defer() is all about hoping the application will
> 'complete' the last skb in write queue with more payload in the near
> future.
>
> skb->len might therefore change because sendmsg()/sendpage() will add
> new stuff in the skb.

Ture, but sometimes the application may be slow to fill the bytes into
skb. Especially the application run in virt guest with multiqueue. In
the case, the application in guest tends to be slower than the
nic(virtio-net) which does the transmission through a host thread
(vhost). Looks like current defer algorithm could not do this very well
and if we want to force the batching of 64K packet, tcp_min_tso_segs
could not works well also.
> We try hard to not remove tcp_tso_should_defer() and take the best of
> it. We have not yet decided to add a real timer instead of relying on
> upcoming ACKS.
>
> Neal has an idea/patch to avoid a defer depending on
> the expected time of following ACKS.
>
> By making the TSO sizes smaller for low rates, we avoid these stalls
> from tcp_tso_should_defer(), because an incoming ACK has normally freed
> enough window to send the next packet in write queue without the need to
> split it into two parts.
>
> These changes are fundamental to use delay based congestion modules like
> Vegas/Westwood and experimental new ones, without having to disable TSO.
>
>
>
