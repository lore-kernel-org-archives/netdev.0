From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 10:43:48 +0100
Message-ID: <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>, <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202084511.GA32294@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel

On 12/2/2016 9:45 AM, Pavel Machek wrote:
> Hi!
>
>>>> 1 HZ, which is the lowest granularity of non-highres timers in the
>>>> kernel, is variable as well as already too large of a delay for
>>>> effective TX coalescing.
>>>>
>>>> I seriously think that the TX coalescing support should be ripped out
>>>> or disabled entirely until it is implemented properly in this
>>>> driver.
>>>
>>> Ok, I'd disable coalescing, but could not figure it out till. What is
>>> generic way to do that?
>>>
>>> It seems only thing stmmac_tx_timer() does is calling
>>> stmmac_tx_clean(), which reclaims tx_skbuff[] entries. It should be
>>> possible to do that explicitely, without delay, but it stops working
>>> completely if I attempt to do that.
>>>
>>> On a side note, stmmac_poll() does stmmac_enable_dma_irq() while
>>> stmmac_dma_interrupt() disables interrupts. But I don't see any
>>> protection between the two, so IMO it could race and we'd end up
>>> without polling or interrupts...
>>
>>
>> the idea behind the TX mitigation is to mix the interrupt and
>> timer and this approach gave us real benefit in terms
>> of performances and CPU usage (especially on SH4-200/SH4-300 platforms
>> based).
>
> Well, if you have a workload that sends and receive packets, it tends
> to work ok, as you do tx_clean() in stmmac_poll(). My workload is not
> like that -- it is "sending packets at 3MB/sec, receiving none". So
> the stmmac_tx_timer() is rescheduled and rescheduled and rescheduled,
> and then we run out of transmit descriptors, and then 40msec passes,
> and then we clean them. Bad.
>
> And that's why low-res timers do not cut it.

in that case, I expect that the tuning of the driver could help you.
I mean, by using ethtool, it could be enough to set the IC bit on all
the descriptors. You should touch the tx_coal_frames.

Then you can use ethtool -S to monitor the status.

We had experimented this tuning on STB IP where just datagrams
had to send externally. To be honest, although we had seen
better results w/o any timer, we kept this approach enabled
because the timer was fast enough to cover our tests on SH4 boxes.

FYI, stmmac doesn't implement adaptive algo.

>
>> In the ring, some descriptors can raise the irq (according to a
>> threshold) and set the IC bit. In this path, the NAPI  poll will be
>> scheduled.
>
> Not NAPI poll but stmmac_tx_timer(), right?

in the xmit according the the threshold the timer is started or the
interrupt is set inside the descriptor.
Then stmmac_tx_clean will be always called and, if you see the flow,
no irqlock protection is needed!

>
>> But there is a timer that can run (and we experimented that no high
>> resolution is needed) to clear the tx resources.
>> Concerning the lock protection, we had reviewed long time ago and
>> IIRC, no raise condition should be present. Open to review it,
>> again!
>
> Well, I certainly like the fact that we are talking :-).
>
> And yes, I have some questions.
>
> There's nothing that protect stmmac_poll() from running concurently
> with stmmac_dma_interrupt(), right?

This is not necessary.

Best Regards
peppe

>
> Best regards,
> 									Pavel
>
