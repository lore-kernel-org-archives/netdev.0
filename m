From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC net-next] net: core: Pass XPS select queue decision to
 skb_tx_hash
Date: Wed, 30 Mar 2016 10:04:35 -0700
Message-ID: <56FC0723.4040003@gmail.com>
References: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
 <56FB1B64.40301@gmail.com> <56FBD35D.4090805@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35782 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093AbcC3REu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 13:04:50 -0400
Received: by mail-pa0-f53.google.com with SMTP id td3so45056489pab.2
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 10:04:50 -0700 (PDT)
In-Reply-To: <56FBD35D.4090805@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-30 06:23 AM, Saeed Mahameed wrote:
> 
> 
> On 3/30/2016 3:18 AM, John Fastabend wrote:
>> I would prefer to not have another strange quirk users have to
>> remember in order to do tx classification. So with this change
>> depending on the driver the queue selection precedence changes. 

> This change doesn't depend on the driver it affects all drivers that
> implement the select queue ndo and use the default fallback
> "pick_tx_queue" which this patch came to fix, or any driver that doesn't
> implement the ndo (the fallback is the default in this case).

Yep, sorry I read the patch to quickly and without coffee thanks!

>> In short I agree with the problem statement but think we can find a
>> better solution. One idea that comes to mind is we can have a tc
>> action to force the queue selection? Now that we have the egress tc
>> hook it would probably be fairly cheap to implement and if users want
>> this behavior they can ask for it explicitly. If your thinking about
>> tc stuff we could fix the tooling to set this action when ever dcb is
>> turned on or hardware rate limiting is enabled, etc. And even if we
>> wanted we could have the driver add the rule in the cases where
>> firmware protocols are configuring the QOS/etc. 

> Why would you ask for a bug fix explicitly ? IMHO this how I expect the
> pick _tx_queue routine to behave, why would I disable XPS in order for
> select queue to choose according TC QoS ?
> as this patch suggests we can benefit from both without any additional
> tooling !
> 

OK, so let me see if I get this right now. This was the precedence
before the patch in the normal no select queue case,

	(1) socket mapping sk_tx_queue_mapping iff !ooo_okay
	(2) xps
	(3) skb->queue_mapping
	(4) qoffset/qcount (hash over tc queues)
	(5) hash over num_tx_queues

With this patch the precedence is a bit changed because
skb_tx_hash is always called.

	(1) socket mapping sk_tx_queue_mapping iff !ooo_okay
	(2) skb->queue_mapping
	(3) qoffset/qcount
	   (hash over tc queues if xps choice is > qcount)
	(4) xps
	(5) hash over num_tx_queues

Sound right? Nice thing about this with correct configuration
of tc with qcount = xps_queues it sort of works as at least
I expect it to. I think the question is are people OK with
letting skb->queue_mapping take precedence. I am at least
because it makes the skb edit queue_mapping action from tc
easier to use.

And just a comment on the code why not just move get_xps_queue
into skb_tx_hash at this point if its always being called as the
"hint". Then we avoid calling it in the case queue_mapping is
set.

>>>       if (skb_vlan_tag_present(skb))
>>>           up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index cb0d5d0..ad81ffe 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -3130,16 +3130,16 @@ static inline int netif_set_xps_queue(struct
>>> net_device *dev,
>>>   #endif
>>>     u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
>>> -          unsigned int num_tx_queues);
>>> +          unsigned int num_tx_queues, int txq_hint);
>>>   
>> [...]
>>
>> And all this seems like it would only ever be called by drivers select
>> queue routines which I really wish we could kill off one of these days
>> instead of add to. Now if the signal is something higher in the stack
>> and not the driver I think it is OK.
> I agree, drivers shouldn't call this function, the only reason drivers
> call this function is to bypass get_xps_queue
> and after this patch i don't think driver will need to call it, since it
> will be called even if XPS is configured.
> 

yep.
