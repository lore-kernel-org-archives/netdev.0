From: Jimmy PERCHET <jimmy.perchet@parrot.com>
Subject: Re: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty descriptors.
Date: Mon, 21 Oct 2013 15:10:54 +0200
Message-ID: <526527DE.5060906@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com> <5264EEE9.8070607@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:58849 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015Ab3JUNKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 09:10:53 -0400
In-Reply-To: <5264EEE9.8070607@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Peppe,

On 21/10/2013 11:07, Giuseppe CAVALLARO wrote:
> Hello Jimmy
> 
> On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
>> On low speed link (10MBit/s), some TX descriptors can remain dirty
>> if the tx coalescence timer expires before they were treated. Re-arm timer
>> in this case.
>>
>> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 0015175..af04b5d 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1284,8 +1284,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>>               p = priv->dma_tx + entry;
>>
>>           /* Check if the descriptor is owned by the DMA. */
>> -        if (priv->hw->desc->get_tx_owner(p))
>> +        if (priv->hw->desc->get_tx_owner(p)) {
>> +            /* Be sure to harvest remaining descriptor. */
>> +            mod_timer(&priv->txtimer,
>> +              STMMAC_COAL_TIMER(priv->tx_coal_timer));
>>               break;
>> +        }
> 
> 
> why should we reload the timer when clean the tx resource?
> This is done in the xmit where as soon as a frame has to be
> transmitted it makes sense to reload the timer.
> 
> Also I have not clear why the problem happens on 10MBit/s speed
>  Maybe there is an hidden problem (lock protection)
> that should be fixed.
> 
> How did you get this problem? Just on low speed and stress the net?
> I have never seen it.

I can reproduce this problem by issuing 9KiB jumbo frames on 10MBit/s link.
If socket's wmemory size is about 500kiB (or less), the transfer stall.
(I guess it is reproducible with 1500o frames by decreasing
socket's wmemory to 90KB)
Re-arming the timer fix this behaviour.

Here my understanding of this issue : 
With 9KiB frames and 500kiB of wmemory, only 60 frames can be
prepared in a row. It is below the tx coalescence threshold,
so there will be no interrupt. When the tx coalescence timer 
expires (40ms after), only five descriptors have to be
freed (9000*5 @ 10Mbit/s = 34ms), it is not enough to reach
the socket's wake-up threshold. We get into a deadlock :
*Socket is waiting for free buffers before performing new transfer.
*Driver is waiting for new transfer before performing cleanup.

Maybe, it is not a real life use-case, and is not worth
a patch. What do you think ?

Best Regards,
Jimmy

> 
> peppe
> 
>>
>>           /* Verify tx error by looking at the last segment. */
>>           last = priv->hw->desc->get_tx_ls(p);
>>
> 
