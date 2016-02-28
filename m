From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sat, 27 Feb 2016 18:10:27 -0800
Message-ID: <56D25713.8050307@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456604037.648.29.camel@edumazet-ThinkPad-T530>
 <56D20733.1000409@hurleysoftware.com>
 <20160227.180403.2101360385050644823.davem@davemloft.net>
 <56D23266.2080306@hurleysoftware.com>
 <1456624766.648.43.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmaengine@vger.kernel.org,
	john.ogness@linutronix.de, bigeasy@linutronix.de,
	akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456624766.648.43.camel@edumazet-ThinkPad-T530>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2016 05:59 PM, Eric Dumazet wrote:
> On sam., 2016-02-27 at 15:33 -0800, Peter Hurley wrote:
>> On 02/27/2016 03:04 PM, David Miller wrote:
>>> From: Peter Hurley <peter@hurleysoftware.com>
>>> Date: Sat, 27 Feb 2016 12:29:39 -0800
>>>
>>>> Not really. softirq raised from interrupt context will always execute
>>>> on this cpu and not in ksoftirqd, unless load forces softirq loop abort.
>>>
>>> That guarantee never was specified.
>>
>> ??
>>
>> Neither is running network socket servers at normal priority as if they're
>> higher priority than softirq.
>>
>>
>>> Or are you saying that by design, on a system under load, your UART
>>> will not function properly?
>>>
>>> Surely you don't mean that.
>>
>> No, that's not what I mean.
>>
>> What I mean is that bypassing the entire SOFTIRQ priority so that
>> sshd can process one network packet makes a mockery of the point of softirq.
>>
>> This hack to workaround NET_RX looping over-and-over-and-over affects every
>> subsystem, not just one uart.
>>
>> HI, TIMER, BLOCK; all of these are skipped: that's straight-up, a bug.
> 
> No idea what you talk about.
> 
> All pending softirq interrupts are processed. _Nothing_ is skipped.

An interrupt that schedules HI softirq while in NET_RX softirq should
still run the HI softirq. But with your patch that won't happen.


> Really, your system stability seems to depend on a completely
> undocumented behavior of linux kernels before linux-3.8
> 
> If I understood, you expect that a tasklet activated from a softirq
> handler is run from the same  __do_softirq() loop. This never has been
> the case.

No.

The *interrupt handler* for DMA goes off while NET_RX softirq is running.
That's what schedules the *DMA tasklet*.

That tasklet should run before any process.

But it doesn't because your patch bails out early from softirq.


> My change simply triggers the bug in your driver earlier. As David
> pointed out, your bug should trigger the same on a loaded machine, even
> if you revert my patch.
> 
> I honestly do not know why you arm a tasklet from NET_RX, why don't you
> simply process this directly, so that you do not rely on some scheduler
> decision ?
