From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: Add Fast Ethernet MAC driver
Date: Mon, 11 Jul 2016 11:44:23 +0800
Message-ID: <57831617.6080506@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <247637090.PhpfAhp4VJ@wuerfel> <5772418F.9040101@hisilicon.com>
 <4787248.HAfgOdBKVY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4787248.HAfgOdBKVY@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 2016/6/28 17:34, Arnd Bergmann wrote:
> On Tuesday, June 28, 2016 5:21:19 PM CEST Dongpo Li wrote:
>> On 2016/6/15 5:20, Arnd Bergmann wrote:
>>> On Tuesday, June 14, 2016 9:17:44 PM CEST Li Dongpo wrote:
>>>> On 2016/6/13 17:06, Arnd Bergmann wrote:
>>>>> On Monday, June 13, 2016 2:07:56 PM CEST Dongpo Li wrote:
>>>>> You tx function uses BQL to optimize the queue length, and that
>>>>> is great. You also check xmit reclaim for rx interrupts, so
>>>>> as long as you have both rx and tx traffic, this should work
>>>>> great.
>>>>>
>>>>> However, I notice that you only have a 'tx fifo empty'
>>>>> interrupt triggering the napi poll, so I guess on a tx-only
>>>>> workload you will always end up pushing packets into the
>>>>> queue until BQL throttles tx, and then get the interrupt
>>>>> after all packets have been sent, which will cause BQL to
>>>>> make the queue longer up to the maximum queue size, and that
>>>>> negates the effect of BQL.
>>>>>
>>>>> Is there any way you can get a tx interrupt earlier than
>>>>> this in order to get a more balanced queue, or is it ok
>>>>> to just rely on rx packets to come in occasionally, and
>>>>> just use the tx fifo empty interrupt as a fallback?
>>>>>
>>>> In tx direction, there are only two kinds of interrupts, 'tx fifo empty'
>>>> and 'tx one packet finish'. I didn't use 'tx one packet finish' because
>>>> it would lead to high hardware interrupts rate. This has been verified in
>>>> our chips. It's ok to just use tx fifo empty interrupt.
>>>
>>> I'm not convinced by the explanation, I don't think that has anything
>>> to do with the hardware design, but instead is about the correctness
>>> of the BQL logic with your driver.
>>>
>>> Maybe your xmit function can do something like
>>>
>>>       if (dql_avail(netdev_get_tx_queue(dev, 0)->dql) < 0)
>>>               enable per-packet interrupt
>>>       else
>>>               use only fifo-empty interrupt
>>>
>>> That way, you don't get a lot of interrupts when the system is
>>> in a state of packets being received and sent continuously,
>>> but if you get to the point where your tx queue fills up
>>> and no rx interrupts arrive, you don't have to wait for it
>>> to become completely empty before adding new packets, and
>>> BQL won't keep growing the queue.
>>>
>> Hi, Arnd
>> I tried enable per-packet interrupt when tx queue full in xmit function
>> and disable it in NAPI poll. But the number of interrupts are a little
>> bigger than only using fifo-empty interrupt.
> 
> Right, I'd expect that to be the case, it basically means that the
> algorithm works as expected.
> 
> Just to be sure you didn't have extra interrupts: you only enable the
> per-packet interrupts if interrupts are currently enabled, not in
> NAPI polling mode, right?
> 
Sorry so long to reply to you. I use the per-packet interrupt like this:
In my xmit function,
	if (hardware tx fifo is full) {
		enable tx per-packet interrupt;
		netif_stop_queue(dev);
		return NETDEV_TX_BUSY;
	}

In interrupt handle function,
	if (interrupt is tx per-packet or tx fifo-empty or rx) {
		disable tx per-packet interrupt;
		napi_schedule(&priv->napi);
	}
We disable tx per-packet interrupt anyway because the NAPI poll will reclaim
the tx fifo.
When the NAPI poll completed, it will only enable the tx fifo-empty interrupt
and rx interrupt except the tx per-packet interrupt.

Is this solution okay?

>> The other hand, this is a fast ethernet MAC. Its maximum speed is 100Mbps.
>> This speed is very easily achived and the efficiency of the BQL is not
>> so important. What we focus on is the lower cpu utilization.
>> So I think it is okay to just use the tx fifo empty interrupt.
> 
> BQL is not about efficiency, it's about keeping the latency down, which
> is at least as important for low-throughput devices as it is for faster
> ones. I don't think that disabling BQL here would be the right answer,
> you'd just end up with the maximum TX queue length all the time.
> 
> Your queue length is 12 packets of 1500 bytes, meaning that you have 1.4ms
> of latency at 100mbit/s rate, or 14ms for 10mbit/s. This is much less
> than most, but it's probably still worth using BQL on it.
> 
I spent some time reading some articles and the goal of BQL is more clear to me.
BQL is designed to get the minimum buffer size that will not make hardware under starvation.
The goal is to reduce latency without the side effect of throughput.
Thanks for your explanation.

> 	Arnd
> 
> .
> 

    Regards,
    Dongpo

.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
