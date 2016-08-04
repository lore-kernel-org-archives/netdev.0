From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: Hitting WARN_ON_ONCE on skb_try_coalesce
Date: Thu, 4 Aug 2016 11:07:38 -0300
Message-ID: <215693ed-3873-428d-3258-a0684f1e4015@gmail.com>
References: <20160803233605.GF2967@localhost.localdomain>
 <1470290142.13693.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35827 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933841AbcHDOHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 10:07:50 -0400
Received: by mail-qk0-f194.google.com with SMTP id q62so20667627qkf.2
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 07:07:44 -0700 (PDT)
In-Reply-To: <1470290142.13693.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 04-08-2016 02:55, Eric Dumazet escreveu:
> On Wed, 2016-08-03 at 20:36 -0300, Marcelo Ricardo Leitner wrote:
>> Hi,
>>
>> I have two namespaces linked with a veth and netem in one of them adding 20ms
>> latency, and doing netperf from one to another. I'm on commit
>> 7cf210dc267861360cf6968b69bf512475aca985, net updated today, and I'm hitting
>> this:
>>
>> [ 1043.024555] WARNING: CPU: 3 PID: 19902 at ...../linux/net/core/skbuff.c:4289 skb_try_coalesce+0x414/0x430
>> [ 1043.024556] Kernel panic - not syncing: panic_on_warn set ...
>>
>> [ 1043.024601] CPU: 3 PID: 19902 Comm: netserver Not tainted 4.7.0-standard+ #20
>> [ 1043.024631] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
>> [ 1043.024667]  0000000000000086 00000000db033d46 ffff880035733ad8 ffffffff813d630d
>> [ 1043.024705]  0000000000000000 ffffffff81a35655 ffff880035733b60 ffffffff811b5e3d
>> [ 1043.024741]  ffff880000000008 ffff880035733b70 ffff880035733b08 00000000db033d46
>> [ 1043.024777] Call Trace:
>> [ 1043.024794]  [<ffffffff813d630d>] dump_stack+0x63/0x86
>> [ 1043.024818]  [<ffffffff811b5e3d>] panic+0xe4/0x226
>> [ 1043.024842]  [<ffffffff816ae244>] ? skb_try_coalesce+0x414/0x430
>> [ 1043.024870]  [<ffffffff810a5f13>] __warn+0xe3/0xf0
>> [ 1043.024892]  [<ffffffff810a602d>] warn_slowpath_null+0x1d/0x20
>> [ 1043.024919]  [<ffffffff816ae244>] skb_try_coalesce+0x414/0x430
>> [ 1043.024945]  [<ffffffff817165f3>] tcp_try_coalesce+0x63/0xd0
>> [ 1043.024977]  [<ffffffff81718497>] tcp_queue_rcv+0x57/0x140
>> [ 1043.025003]  [<ffffffff8171e132>] tcp_rcv_established+0x3f2/0x6f0
>> [ 1043.025029]  [<ffffffff81728815>] tcp_v4_do_rcv+0x145/0x200
>> [ 1043.025054]  [<ffffffff816a4387>] __release_sock+0x87/0xf0
>> [ 1043.025078]  [<ffffffff816a4420>] release_sock+0x30/0xa0
>> [ 1043.025102]  [<ffffffff81711d8c>] tcp_recvmsg+0x5fc/0xb70
>> [ 1043.025126]  [<ffffffff8174051e>] inet_recvmsg+0x7e/0xb0
>> [ 1043.025151]  [<ffffffff8169f61d>] sock_recvmsg+0x3d/0x50
>> [ 1043.025175]  [<ffffffff8169f85a>] SYSC_recvfrom+0xda/0x150
>> [ 1043.025201]  [<ffffffff811157df>] ? do_setitimer+0x1bf/0x220
>> [ 1043.025226]  [<ffffffff81115891>] ? alarm_setitimer+0x51/0x90
>> [ 1043.025252]  [<ffffffff816a0bbe>] SyS_recvfrom+0xe/0x10
>> [ 1043.025277]  [<ffffffff817df132>] entry_SYSCALL_64_fastpath+0x1a/0xa4
>>
>> That's:
>>         WARN_ON_ONCE(delta < len);
>>
>> Netperf command line is:
>> netperf -cC -l 10 -t TCP_STREAM \
>> 		-H 192.168.10.1 -L 192.168.10.2
>>
>> netem is added on netperf/client side.
>>
>> It triggers it right at the beginning of the test.
>>
>> I can reproduce it 100% of the times with above setup.
>> - Removing netem made it stop reproducing.
>> - Reducing netem latency to 10ms, still warns
>> - Reducing netem latency to 1ms, still warns
>> - Reducing netem latency to 0ms, it stops reproducing it
>>
>> This system is not generating a kdump, I'm looking into it.
>
> This is caused by the skb_orphan_partial() call from netem.

That also explains why I couldn't trigger it with sctp then.

>
> This breaks if packet is re-injected instead of being sent to a physical
> NIC.
>

This truesize change will also break rx buffer accounting, as delta will 
become negative and propagated to the merged skb.

I'm trying to save it on netem cb and restore it before pushing it forward.
