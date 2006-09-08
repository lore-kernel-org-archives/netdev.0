From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000_xmit_frame and e1000_down racing  with next_to_use?
Date: Fri, 08 Sep 2006 08:51:16 -0700
Message-ID: <45019174.6020406@intel.com>
References: <4348.38.114.160.126.1157565495.squirrel@webmail.vranix.com>    <20060906111325.7acab51a@localhost.localdomain> <1127.38.114.160.126.1157588292.squirrel@webmail.vranix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38768 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1750878AbWIHPxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 11:53:03 -0400
To: Shaw Vrana <shaw@vranix.com>
In-Reply-To: <1127.38.114.160.126.1157588292.squirrel@webmail.vranix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shaw Vrana wrote:
>> On Wed, 6 Sep 2006 10:58:15 -0700 (PDT)
>> shaw@vranix.com wrote:
>>
>>> Hello All,
>>>
>>> I have a question about the use of the tx_ring->next_to_use variable in
>>> the e1000.  Specifically, I'm wondering about a race between the use of
>>> next_to_use in e1000_xmit_frame and the clearing of next_to_use in
>>> e1000_down via e1000_clean_tx_ring.
>>>
>>> Thread 1 (_xmit) ->  first = adapter->tx_ring.next_to_use;
>>>                      e1000_tx_map();
>>> Thread 2 (_down) ->  e1000_clean_tx_ring();
>>>                      tx_ring->next_to_use = 0;
>>> Thread 1 (_xmit) -> e1000_tx_queue();
>>>
>>> It seems that tx_ring.next_to_use could change between the time the
>>> skbuff
>>> is mapped in e1000_tx_map and the time it is reported to the hardware in
>>> e1000_tx_queue.  While I don't see any memory leaks or possible oops, it
>>> does seem possible that that an skbuff could be "lost" in the ring as it
>>> will not be queued in the subsequent e1000_queue.
>>>
>>> If the race is possible, perhaps this could be the culprit behind the tx
>>> timeouts we've seen reported in this list?  The watchdog will eventually
>>> find the "lost" skbuff and mistakenly think that the hardware transmit
>>> has
>>> hung and stop the queue.
>>>
>>> Could one of you plese tell me how this race is avoided, if indeed it
>>> is?
>>>
>>> Thanks,
>>> Shaw
>>>
>> e1000_down calls netif_stop_queue() and that stops transmit requests.
>> It doesn't handle the case of a transmit in flight during the e1000_down.
>>
>> Shouldn't clean_tx_ring acquire tx_ring->tx_lock to avoid that?
> 
> Hi Stephen,
> 
> Yes, holding the adapter->tx_lock is all that is needed. e1000_irq_disable
> has been called prior to e1000_clean_tx_ring or the interrupt has never
> been enabled (e1000_open), so a simple spin_lock should suffice. I've
> included a patch against Garzik's netdev git tree.
> 
> Thanks,
> Shaw


Shaw,

Thanks for the patch. We're looking into this and indeed it appears to be a 
race, but as the commit message says - it covers only a transmit in flight in 
case of e1000_down.

I doubt this will fix the majority of tx hang reports that we see or have seen, 
which happen under normal operation (i.e. when the device is not going down at 
all).

This is an extreme corner case and I doubt it would even show up in normal use.

The patch prolly won't affect performance, which is the good part.

I'll give it a test.

Auke


> 
> Protect against the race to modify tx_ring->next_to_use in the case of a
> transmit in flight during e1000_down.
> 
> Signed-off-by: Shaw Vrana <shaw@vranix.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 726f43d..b327976 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1937,6 +1937,8 @@ e1000_clean_tx_ring(struct e1000_adapter
>  	unsigned long size;
>  	unsigned int i;
> 
> +	spin_lock(&tx_ring->tx_lock);
> +
>  	/* Free all the Tx ring sk_buffs */
> 
>  	for (i = 0; i < tx_ring->count; i++) {
> @@ -1957,6 +1959,8 @@ e1000_clean_tx_ring(struct e1000_adapter
> 
>  	writel(0, adapter->hw.hw_addr + tx_ring->tdh);
>  	writel(0, adapter->hw.hw_addr + tx_ring->tdt);
> +
> +	spin_unlock(&tx_ring->tx_lock);
>  }
> 
>  /**
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
