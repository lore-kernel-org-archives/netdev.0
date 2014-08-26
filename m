From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: support skb->xmit_more in netdev_ops->ndo_start_xmit()
Date: Tue, 26 Aug 2014 09:36:01 -0700
Message-ID: <53FCB771.4060605@intel.com>
References: <20140825.163505.1969688661687017343.davem@davemloft.net>	<53FCA0FA.20600@intel.com>	<1409067657.22108.7.camel@localhost> <CA+mtBx_phCQDd=nS4Wfe=9R=FXpQ3xqfnBrYuPwzqRNaybcc6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Daniel Borkmann <dborkman@redhat.com>, brouer@redhat.com
To: Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27723 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbaHZQgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:36:03 -0400
In-Reply-To: <CA+mtBx_phCQDd=nS4Wfe=9R=FXpQ3xqfnBrYuPwzqRNaybcc6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 09:20 AM, Tom Herbert wrote:
> On Tue, Aug 26, 2014 at 8:40 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On Di, 2014-08-26 at 08:00 -0700, Alexander Duyck wrote:
>>> On 08/25/2014 04:35 PM, David Miller wrote:
>>>>
>>>> From: Daniel Borkmann <dborkman@redhat.com>
>>>>
>>>> This implements the deferred tail pointer flush API for the ixgbe
>>>> driver. Similar version also proposed longer time ago by Alexander Duyck.
>>>>
>>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>>> ---
>>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
>>>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> index 87bd53f..ba9ceaa 100644
>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>>> @@ -6958,9 +6958,10 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
>>>>
>>>>     tx_ring->next_to_use = i;
>>>>
>>>> -   /* notify HW of packet */
>>>> -   ixgbe_write_tail(tx_ring, i);
>>>> -
>>>> +   if (!skb->xmit_more) {
>>>> +           /* notify HW of packet */
>>>> +           ixgbe_write_tail(tx_ring, i);
>>>> +   }
>>>>     return;
>>>>  dma_error:
>>>>     dev_err(tx_ring->dev, "TX DMA map failed\n");
>>>>
>>>
>>> It might help to add some handling for the case where xmit_more is set,
>>> but the ring has become full.  This current implementation introduces
>>> the risk of triggering a Tx hang.
>>
>> IMHO this should be done before the patch lands in the driver.
>>
>>> My advice would be to pull the ixgbe_maybe_stop_tx code at the end of
>>> xmit_frame into the if check here, and perhaps look into adding an
>>> additional check to see if BQL has stopped the ring as well.
>>
>> I would like to have the BQL check not in the driver but in the generic
>> code steering xmit_more.
>>
> 
> BQL stops the queue from netdev_tx_sent_queue, we could change that to
> return indication queue was stopped and use that as another check to
> flush.

Either that or we could just add it as state check.

Maybe change the code to something like:
  ixgbe_maybe_stop_tx(tx_ring, DESC_UNUSED);

  /* notify HW of packet */
  if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more)
         ixgbe_write_tail(tx_ring, i)

Then we could catch both the driver or stack stopping the ring and
identifying it as an indication that we should flush the ring.

Thanks,

Alex
