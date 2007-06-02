From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 02 Jun 2007 21:58:31 +0200
Message-ID: <4661CBE7.7040901@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net> <46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:61160 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbXFBT6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 15:58:39 -0400
In-Reply-To: <46613DBE.3010602@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The more i was thinking about my own suggested solution the more it
turned out to be ugly for me ...

Summarizing we have two problems to solve:

1. Identify the originating sk to potentially trash my own sent messages.
2. Indicate a requested local loopback to the lower (driver) layer.

Regarding point 1.:
skb->sk is intentionally set to NULL, when ever skb_orphan() or
skb_clone() is invoked to cut the reference to the sk. Performing a
loopback this is a reasonable thing to do as also skb->destructor(skb)
is called in skb_orphan().

Indeed skb->sk is completely unused in the rx path, so we just would
have to 'preserve' skb->sk the way 'up' whenever we make use of
skb_orphan() or skb_clone().

E.g. in af_can.c the deliver() function would be changed like this:

static inline void deliver(struct sk_buff *skb, struct receiver *r)
{
+	struct sock *sk = skb->sk;
	struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);

	DBG("skbuff %p cloned to %p\n", skb, clone);
	if (clone) {
+		clone->sk = sk;
		r->func(clone, r->data);
		r->matches++;
	}
}

So there is a proper way to make the originating sk avaliable when the
skb reaches the receiving socket.

Regarding point 2.:
To indicate an outgoing skb to be looped back it would just be enough to
set skb->tstamp at skb creation time. This would be similar to set the
timestamp at netdev receive time. skb->tstamp is also completely unused
in the tx path. In the case of local loopback setting the timestamp at
this creation stage is not even a wrong semantic behaviour.

Assuming some clarifying comments in the source code this looks like a
simple to use and clearly arranged implementation to me. I'll make a
test implementation tomorrow to see how if it smells as good as i
expected ;-)

Best  regards,
Oliver


Oliver Hartkopp wrote:
> Patrick McHardy wrote:
>   
>> Oliver Hartkopp wrote:
>>   
>>     
>>> Patrick McHardy wrote:
>>>     
>>>       
>> Yes, its working, but only in certain combinations and you're breaking
>> the rules for skb->cb, making it impossible for other layers to use.
>> skb->sk is "stable" at the output path, the regular loopback device
>> orphans the skb in hard_start_xmit. So you can at least use it there.
>>
>>   
>>     
>>> Would therefore skb->cb left unchanged in my skb's? Or is there any flag
>>> that can be set in the skb to keep the packet scheduler's hands off?
>>>     
>>>       
>> No, and I don't think we want a flag to signal that something is
>> violating the rules for skb->cb, there are other users of this
>> besides qdiscs.
>>   
>>     
>
> Hm - regarding Patricks and Urs' last mails i just had the idea to put
> the sk-reference that's needed for this special
> CAN-only-loopback-functionality into the data section of the skb, e.g.
> by introducing a new struct can_skb_data:
>
> struct can_skb_data {
>     struct can_frame cf;
>     sock *txsk;
> };
>
> So instead of allocating the space of struct can_frame the alloc_skb()
> would allocate the size of struct can_skb_data.
> The needed txsk would be stable in any case and could be used like the
> currently missused skb->cb. This would also lead to a type proof(!)
> implementation.
>
> In raw_rcv() in raw.c there could be a check for the size of struct
> can_skb_data first before checking the txsk - this would also guarantee
> the backward compatibility for current CAN drivers that allocate only
> the size of struct can_frame. For me this looks like a safe and
> compatible (Kernel & CAN) solution.
>
> Any objections/comments for this approach?
>
> Best regards,
> Oliver
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   


