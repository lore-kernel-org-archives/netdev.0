From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC net-next] net: core: Pass XPS select queue decision to
 skb_tx_hash
Date: Thu, 31 Mar 2016 20:49:09 -0700
Message-ID: <56FDEFB5.8090207@gmail.com>
References: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
 <56FB1B64.40301@gmail.com> <56FBD35D.4090805@dev.mellanox.co.il>
 <56FC0723.4040003@gmail.com>
 <CALzJLG-xJe6_-2a=djpLxBR5xQY562m06eLLCP04GdTrzmWJuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33273 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbcDADt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:49:27 -0400
Received: by mail-pa0-f51.google.com with SMTP id zm5so80964479pac.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:49:27 -0700 (PDT)
In-Reply-To: <CALzJLG-xJe6_-2a=djpLxBR5xQY562m06eLLCP04GdTrzmWJuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-30 11:30 AM, Saeed Mahameed wrote:
> On Wed, Mar 30, 2016 at 8:04 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>> OK, so let me see if I get this right now. This was the precedence
>> before the patch in the normal no select queue case,
>>
>>         (1) socket mapping sk_tx_queue_mapping iff !ooo_okay
>>         (2) xps
>>         (3) skb->queue_mapping
>>         (4) qoffset/qcount (hash over tc queues)
>>         (5) hash over num_tx_queues
>>
>> With this patch the precedence is a bit changed because
>> skb_tx_hash is always called.
>>
>>         (1) socket mapping sk_tx_queue_mapping iff !ooo_okay
>>         (2) skb->queue_mapping
>>         (3) qoffset/qcount
>>            (hash over tc queues if xps choice is > qcount)
>>         (4) xps
>>         (5) hash over num_tx_queues
>>
>> Sound right? Nice thing about this with correct configuration
>> of tc with qcount = xps_queues it sort of works as at least
> 
> Yes !
> for qcount = xps_queues which almost all drivers default
> configurations goes this way, it works like charm, xps selects the
> exact TC TX queue at the correct offset without any need for further
> SKB hashing.
> and even if by mistake XPS was also configured on TC TX queue then
> this patch will detect that the xps hash is out of this TC
> offset/qcount range and will re-hash. But i don't see why would user
> or driver do such strange configuration.
> 
>> I expect it to. I think the question is are people OK with
>> letting skb->queue_mapping take precedence. I am at least
>> because it makes the skb edit queue_mapping action from tc
>> easier to use.
>>
> 
> skb->queue_mapping toke precedence also before this patch, the only
> thing this patch came to change is how to compute the txq when
> skb->queue_mapping is not present, so we don't need to worry about
> this.
> 

I don't believe that is correct in the general case. Perhaps
in the ndo_select_queue path though. See this line,

        if (queue_index < 0 || skb->ooo_okay ||
            queue_index >= dev->real_num_tx_queues) {
                int new_index = get_xps_queue(dev, skb);
                if (new_index < 0)
                        new_index = skb_tx_hash(dev, skb);

The skb_tx_hash() routine is never called if xps is enabled.
And so we never get into the call to do this,

        if (skb_rx_queue_recorded(skb)) {
                hash = skb_get_rx_queue(skb);
                while (unlikely(hash >= num_tx_queues))
                        hash -= num_tx_queues;
                return hash;
        }

Right? FWIW I think that using queue_mapping before xps is better
because we can use tc to pick the queue_mapping them programmatically
if we want for these special cases instead if wanted.

>> And just a comment on the code why not just move get_xps_queue
>> into skb_tx_hash at this point if its always being called as the
>> "hint". Then we avoid calling it in the case queue_mapping is
>> set.
>>
> 
> Very good point, the only place that calls skb_tx_hash(dev, skb) other
> than __netdev_pick_tx is mlx4 driver and they did it there just
> because they wanted to bypass XPS configuration if TC QoS is
> configured, with this fix we don't have to bypass XPS at all for when
> TC is configured.
> 
> I will change it.
> 

Great thanks.
