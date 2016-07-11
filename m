From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: [PATCH 3/3] net: hisilicon: Add Fast Ethernet MAC driver
Date: Mon, 11 Jul 2016 16:33:46 +0800
Message-ID: <578359EA.3060407@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <4787248.HAfgOdBKVY@wuerfel> <57831617.6080506@hisilicon.com>
 <6408034.HDp0l1gLKO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <davem@davemloft.net>,
	<xuejiancheng@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6408034.HDp0l1gLKO@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/7/11 16:16, Arnd Bergmann wrote:
> On Monday, July 11, 2016 11:44:23 AM CEST Dongpo Li wrote:
>> Hi Arnd,
>>
>> On 2016/6/28 17:34, Arnd Bergmann wrote:
>>> On Tuesday, June 28, 2016 5:21:19 PM CEST Dongpo Li wrote:
>>>> On 2016/6/15 5:20, Arnd Bergmann wrote:
>>>>> On Tuesday, June 14, 2016 9:17:44 PM CEST Li Dongpo wrote:
>>>>>> On 2016/6/13 17:06, Arnd Bergmann wrote:
>>>>>>> On Monday, June 13, 2016 2:07:56 PM CEST Dongpo Li wrote:
>>>>>>> You tx function uses BQL to optimize the queue length, and that
>>>>>>> is great. You also check xmit reclaim for rx interrupts, so
>>>>>>> as long as you have both rx and tx traffic, this should work
>>>>>>> great.
>>>>>>>
>>>>>>> However, I notice that you only have a 'tx fifo empty'
>>>>>>> interrupt triggering the napi poll, so I guess on a tx-only
>>>>>>> workload you will always end up pushing packets into the
>>>>>>> queue until BQL throttles tx, and then get the interrupt
>>>>>>> after all packets have been sent, which will cause BQL to
>>>>>>> make the queue longer up to the maximum queue size, and that
>>>>>>> negates the effect of BQL.
>>>>>>>
>>>>>>> Is there any way you can get a tx interrupt earlier than
>>>>>>> this in order to get a more balanced queue, or is it ok
>>>>>>> to just rely on rx packets to come in occasionally, and
>>>>>>> just use the tx fifo empty interrupt as a fallback?
>>>>>>>
>>>>>> In tx direction, there are only two kinds of interrupts, 'tx fifo empty'
>>>>>> and 'tx one packet finish'. I didn't use 'tx one packet finish' because
>>>>>> it would lead to high hardware interrupts rate. This has been verified in
>>>>>> our chips. It's ok to just use tx fifo empty interrupt.
>>>>>
>>>>> I'm not convinced by the explanation, I don't think that has anything
>>>>> to do with the hardware design, but instead is about the correctness
>>>>> of the BQL logic with your driver.
>>>>>
>>>>> Maybe your xmit function can do something like
>>>>>
>>>>>       if (dql_avail(netdev_get_tx_queue(dev, 0)->dql) < 0)
>>>>>               enable per-packet interrupt
>>>>>       else
>>>>>               use only fifo-empty interrupt
>>>>>
>>>>> That way, you don't get a lot of interrupts when the system is
>>>>> in a state of packets being received and sent continuously,
>>>>> but if you get to the point where your tx queue fills up
>>>>> and no rx interrupts arrive, you don't have to wait for it
>>>>> to become completely empty before adding new packets, and
>>>>> BQL won't keep growing the queue.
>>>>>
>>>> Hi, Arnd
>>>> I tried enable per-packet interrupt when tx queue full in xmit function
>>>> and disable it in NAPI poll. But the number of interrupts are a little
>>>> bigger than only using fifo-empty interrupt.
>>>
>>> Right, I'd expect that to be the case, it basically means that the
>>> algorithm works as expected.
>>>
>>> Just to be sure you didn't have extra interrupts: you only enable the
>>> per-packet interrupts if interrupts are currently enabled, not in
>>> NAPI polling mode, right?
>>>
>> Sorry so long to reply to you. I use the per-packet interrupt like this:
>> In my xmit function,
>> 	if (hardware tx fifo is full) {
>> 		enable tx per-packet interrupt;
>> 		netif_stop_queue(dev);
>> 		return NETDEV_TX_BUSY;
>> 	}
>>
>> In interrupt handle function,
>> 	if (interrupt is tx per-packet or tx fifo-empty or rx) {
>> 		disable tx per-packet interrupt;
>> 		napi_schedule(&priv->napi);
>> 	}
>> We disable tx per-packet interrupt anyway because the NAPI poll will reclaim
>> the tx fifo.
>> When the NAPI poll completed, it will only enable the tx fifo-empty interrupt
>> and rx interrupt except the tx per-packet interrupt.
>>
>> Is this solution okay?
> 
> Yes, this looks good to me.
> 
Okay, many thanks for your review.

> 	Arnd
> 
> .
> 

    Regards,
    Dongpo

.
