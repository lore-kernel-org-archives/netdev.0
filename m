From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Mon, 15 Jul 2013 18:17:39 -0700
Message-ID: <CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
References: <20130712180116.21176.qmail@science.horizon.com>
	<1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: George Spelvin <linux@horizon.com>, eric.dumazet@gmail.com,
	Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:38830 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab3GPBRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 21:17:40 -0400
Received: by mail-oa0-f50.google.com with SMTP id k7so117570oag.23
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 18:17:39 -0700 (PDT)
In-Reply-To: <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 15, 2013 at 4:58 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2013-07-12 at 14:01 -0400, George Spelvin wrote:
>> > Hi George,
>> > While you are right that functionally it doesn't matter, my preference
>> > would be to have nothing between the wmb() and iowrite() that kicks
>> > off the TX. This marginally helps kick off the TX process consistently
>> > slightly sooner. On modern HW, probably irrelevant, but not on the HW
>> > these chips are used on.
>>
>> I'll revise it.  It just made sense to me to put it next to the other
>> bookkeeping line of tp->cur_tx++.  Should I move them both below the
>> iowrite()?  As in:
>>
>> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
>> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
>> @@ -702,11 +702,11 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>       tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
>>       wmb();
>>
>> -     tp->cur_tx++;
>> -
>>       /* Trigger an immediate transmit demand. */
>>       iowrite32(0, tp->base_addr + CSR1);
>>
>> +     tp->cur_tx++;
>> +     netdev_sent_queue(dev, skb->len);
>
> This is not good practice, because once you start DMA you have
> effectively passed ownership of the skb to the TX completion handler.

Is the problem the reference to skb->len?
By passing ownership,  are you suggesting the device can change this value?

AFAIK, tulip device only knows about the contents of tx_ring[] and not skb's.
Would you like to see a comment added to that effect?

>>       spin_unlock_irqrestore(&tp->lock, flags);
>
> Presumably the TX completion handler will hold this spinlock and
> therefore cannot free the skb before you use skb->len above.  So this
> will be safe now.

Correct.

> But one day someone may want to get rid of this lock,
> so this is a trap waiting to spring.

Even for tulip driver?  Sorry, I just can't imagine anyone taking
enough interest in tulip driver to implement that.  I'm not even sure
it would be possible.

thanks!
grant
