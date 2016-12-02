From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 09:41:56 +0100
Message-ID: <afe5354c-42f5-d218-5b15-e9fbdfe86b13@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <lsanfil@marvell.com>
To: Pavel Machek <pavel@ucw.cz>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ Lino

On 12/2/2016 9:24 AM, Giuseppe CAVALLARO wrote:
>
> Hello
>
>
> On 11/24/2016 10:25 PM, Pavel Machek wrote:
>> Hi!
>>
>>>>> I'm debugging strange delays during transmit in stmmac driver. They
>>>>> seem to be present in 4.4 kernel (and older kernels, too). Workload is
>>>>> burst of udp packets being sent, pause, burst of udp packets, ...
>> ...
>>>> 4.9-rc6 still has the delays. With the
>>>>
>>>> #define STMMAC_COAL_TX_TIMER 1000
>>>> #define STMMAC_TX_MAX_FRAMES 2
>>>>
>>>> settings, delays go away, and driver still works. (It fails fairly
>>>> fast in 4.4). Good news. But the question still is: what is going on
>>>> there?
>>>
>>> 256 packets looks way too large for being a trigger for aborting the
>>> TX coalescing timer.
>>>
>>> Looking more deeply into this, the driver is using non-highres timers
>>> to implement the TX coalescing.  This simply cannot work.
>>>
>>> 1 HZ, which is the lowest granularity of non-highres timers in the
>>> kernel, is variable as well as already too large of a delay for
>>> effective TX coalescing.
>>>
>>> I seriously think that the TX coalescing support should be ripped out
>>> or disabled entirely until it is implemented properly in this
>>> driver.
>>
>> Ok, I'd disable coalescing, but could not figure it out till. What is
>> generic way to do that?
>>
>> It seems only thing stmmac_tx_timer() does is calling
>> stmmac_tx_clean(), which reclaims tx_skbuff[] entries. It should be
>> possible to do that explicitely, without delay, but it stops working
>> completely if I attempt to do that.
>>
>> On a side note, stmmac_poll() does stmmac_enable_dma_irq() while
>> stmmac_dma_interrupt() disables interrupts. But I don't see any
>> protection between the two, so IMO it could race and we'd end up
>> without polling or interrupts...
>
>
> the idea behind the TX mitigation is to mix the interrupt and
> timer and this approach gave us real benefit in terms
> of performances and CPU usage (especially on SH4-200/SH4-300 platforms
> based).
> In the ring, some descriptors can raise the irq (according to a
> threshold) and set the IC bit. In this path, the NAPI  poll will be
> scheduled.
> But there is a timer that can run (and we experimented that no high
> resolution is needed) to clear the tx resources.
> Concerning the lock protection, we had reviewed long time ago and
> IIRC, no raise condition should be present. Open to review it, again!
>
> So, welcome any other schema and testing on platforms supported.
>
>
> Hoping this summary can help.
>
> Peppe
>
>
>>
>> Thanks and best regards,
>>                                     Pavel
>>
>
>
