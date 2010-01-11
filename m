From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH net-2.6 alt.3] af_packet: Don't use skb after
	dev_queue_xmit()
Date: Mon, 11 Jan 2010 17:30:45 -0500
Message-ID: <4B4BA695.7040803@majjas.com>
References: <20100111080419.GA6061@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752091Ab0AKWb0@vger.kernel.org>
In-reply-to: <20100111080419.GA6061@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/11/2010 3:04 AM, Jarek Poplawski wrote:
> On 10-01-2010 22:51, David Miller wrote:
>    
>> From: Jarek Poplawski<jarkao2@gmail.com>
>> Date: Sat, 9 Jan 2010 13:38:27 +0100
>>
>>      
>>> tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
>>> which is illegal.
>>>
>>> With debugging by: Stephen Hemminger<shemminger@vyatta.com>
>>>
>>> Reported-by: Michael Breuer<mbreuer@majjas.com>
>>> Tested-by: Michael Breuer<mbreuer@majjas.com>
>>> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
>>> Acked-by: Stephen Hemminger<shemminger@vyatta.com>
>>>        
>> Jarek, if this code path triggers, it will deadlock the
>> send ring with your changes.
>>
>> We will now leave the ring packet status in the "SENDING" state.
>>
>> That's not right.
>>
>> Then, if the application calls send again, we will just return
>> immediately since we only make progress if the head ring entry is in
>> SEND_REQUEST state.
>>
>> This is really bogus behavior.  When the qdisc or mid-layer
>> drops the packet, we should at least mark the packet state
>> properly (which is what the current code would does, sans
>> the "reference SKB after dev_queue_xmit()" issue).  And
>> advance the packet ring pointer.
>>
>> This way the user:
>>
>> 1) can see that the packet got dropped and couldn't be sent
>>
>> 2) can call send again to try sending the rest of the ring
>>
>> Fix the use after dev_queue_xmit() issue, but don't change other side
>> effects which are important for correct AF_PACKET TX ring semantics.
>>      
> As I wrote already, I don't think this patch is wrong. Alas, we can't
> both fix this bug and retain exactly current behaviour, at least
> without deeper changes. And I doubt it's worth it if we ignore negative
> dev_queue_xmit() return (drops also) at the same time.
>
> Btw, there was an alternative fix (positively) tested - more radical,
> but IMHO safe and appropriate at least as a temporary solution for
> -stable:
> http://permalink.gmane.org/gmane.linux.kernel/934761
>
> Anyway, here is another try, with even more of the current semantics.
> If you think it's better, I hope Michael can test it (and send his
> Tested-by).
>
> Thanks,
> Jarek P.
> ---------------->  (alternative 3)
>
> Subject: af_packet: Don't use skb after dev_queue_xmit()
>
> tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
> which is illegal.
>
> With debugging by: Stephen Hemminger<shemminger@vyatta.com>
>
> Reported-by: Michael Breuer<mbreuer@majjas.com>
> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
>
> Cc: Stephen Hemminger<shemminger@vyatta.com>
> ---
>
>   net/packet/af_packet.c |   19 ++++++++++++++-----
>   1 files changed, 14 insertions(+), 5 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index e0516a2..f126d18 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1021,8 +1021,20 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>
>   		status = TP_STATUS_SEND_REQUEST;
>   		err = dev_queue_xmit(skb);
> -		if (unlikely(err>  0&&  (err = net_xmit_errno(err)) != 0))
> -			goto out_xmit;
> +		if (unlikely(err>  0)) {
> +			err = net_xmit_errno(err);
> +			if (err&&  __packet_get_status(po, ph) ==
> +				   TP_STATUS_AVAILABLE) {
> +				/* skb was destructed already */
> +				skb = NULL;
> +				goto out_status;
> +			}
> +			/*
> +			 * skb was dropped but not destructed yet;
> +			 * let's treat it like congestion or err<  0
> +			 */
> +			err = 0;
> +		}
>   		packet_increment_head(&po->tx_ring);
>   		len_sum += tp_len;
>   	} while (likely((ph != NULL) ||
> @@ -1033,9 +1045,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>   	err = len_sum;
>   	goto out_put;
>
> -out_xmit:
> -	skb->destructor = sock_wfree;
> -	atomic_dec(&po->tx_ring.pending);
>   out_status:
>   	__packet_set_status(po, ph, status);
>   	kfree_skb(skb);
>    
Tested by: Michael Breuer

Note: This patch is delivering better ethernet throughput (15-20%) and 
no  than the previous two patches. I'm also no longer seeing dropped RX 
packets. Good work!
