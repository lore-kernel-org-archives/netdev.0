From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Mon, 14 Oct 2013 18:11:15 +0300
Message-ID: <525C0993.70503@freescale.com>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com> <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:48902
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750837Ab3JNPLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 11:11:31 -0400
In-Reply-To: <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2013 5:34 PM, Eric Dumazet wrote:
> On Mon, 2013-10-14 at 17:05 +0300, Claudiu Manoil wrote:
>> Under certain low traffic conditions, the single core
>> devices with multiple Rx/Tx queues (MQ mode) may reach
>> soft lockup due to gfar_poll not returning in proper time.
>> The following exception was obtained using iperf on a 100Mbit
>> half-duplex link, for a p1010 single core device:
>>
>> BUG: soft lockup - CPU#0 stuck for 23s! [iperf:2847]
>> Modules linked in:
>> CPU: 0 PID: 2847 Comm: iperf Not tainted 3.12.0-rc3 #16
>> task: e8bf8000 ti: eeb16000 task.ti: ee646000
>> NIP: c0255b6c LR: c0367ae8 CTR: c0461c18
>> REGS: eeb17e70 TRAP: 0901   Not tainted  (3.12.0-rc3)
>> MSR: 00029000 <CE,EE,ME>  CR: 44228428  XER: 20000000
>>
>> GPR00: c0367ad4 eeb17f20 e8bf8000 ee01f4b4 00000008 ffffffff ffffffff
>> 00000000
>> GPR08: 000000c0 00000008 000000ff ffffffc0 000193fe
>> NIP [c0255b6c] find_next_bit+0xb8/0xc4
>> LR [c0367ae8] gfar_poll+0xc8/0x1d8
>> Call Trace:
>> [eeb17f20] [c0367ad4] gfar_poll+0xb4/0x1d8 (unreliable)
>> [eeb17f70] [c0422100] net_rx_action+0xa4/0x158
>> [eeb17fa0] [c003ec6c] __do_softirq+0xcc/0x17c
>> [eeb17ff0] [c000c28c] call_do_softirq+0x24/0x3c
>> [ee647cc0] [c0004660] do_softirq+0x6c/0x94
>> [ee647ce0] [c003eb9c] local_bh_enable+0x9c/0xa0
>> [ee647cf0] [c0454fe8] tcp_prequeue_process+0xa4/0xdc
>> [ee647d10] [c0457e44] tcp_recvmsg+0x498/0x96c
>> [ee647d80] [c047b630] inet_recvmsg+0x40/0x64
>> [ee647da0] [c040ca8c] sock_recvmsg+0x90/0xc0
>> [ee647e30] [c040edb8] SyS_recvfrom+0x98/0xfc
>>
>> To prevent this, the outer while() loop has been removed
>> allowing gfar_poll() to return faster even if there's
>> still budget left.  Also, there's no need to recompute
>> the budget per Rx queue anymore.
>
> It seems there is a race condition, and this patch only makes it happen
> less often ?
>
> return faster means what exactly ?
>

Hi Eric,
Because of the outer while loop, gfar_poll may not return due
to continuous tx work. The later implementation of gfar_poll
allows only one iteration of the Tx queues before returning
control to net_rx_action(), that's what I meant with "returns faster".
I tested this fix with different loads, and the soft lockup
didn't trigger (without the fix it triggers right away).

Besides, isn't this a more appropriate napi poll implementation
than the former one with the outer while() loop?

Thanks,
Claudiu
