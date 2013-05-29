From: Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH net-next v5 1/2] net: Use 16bits for *_headers
 fields of struct skbuff
Date: Wed, 29 May 2013 14:46:05 -0700
Message-ID: <CAOesGMimq2agyihTHkrGox26QVX_n9MZkcU7XSMWb941-kfg8Q@mail.gmail.com>
References: <1369378295-17779-1-git-send-email-horms@verge.net.au>
	<1369378295-17779-2-git-send-email-horms@verge.net.au>
	<CAOesGMg2-CgJeqFM7K1QBAhG+xOc33t0vV1xR1J_4-iJJ58r8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAOesGMg2-CgJeqFM7K1QBAhG+xOc33t0vV1xR1J_4-iJJ58r8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry, that was not a great bug report.

So, looks like it's the removal of NET_SKBUFF_DATA_USES_OFFSET that
does it for me.

The devices I've seen it with are with asix usb-ethernet adapters (on
Tegra seaboard) and with mv643xx_eth on cubox (dove).

I'll try to get a better stacktrace out of it. Simon, maybe you can
reproduce on shmobile hardware?



On Wed, May 29, 2013 at 2:21 PM, Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org> wrote:
> Simon,
>
> On Thu, May 23, 2013 at 11:51 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> In order to mitigate ongoing incresase in the size of struct skbuff
>> use 16 bit integer offsets rather than pointers for inner_*_headers.
>>
>> This appears to reduce the size of struct skbuff from 0xd0 to 0xc0
>> bytes on x86_64 with the following all unset.
>>
>>         CONFIG_XFRM
>>         CONFIG_NF_CONNTRACK
>>         CONFIG_NF_CONNTRACK_MODULE
>>         NET_SKBUFF_NF_DEFRAG_NEEDED
>>         CONFIG_BRIDGE_NETFILTER
>>         CONFIG_NET_SCHED
>>         CONFIG_IPV6_NDISC_NODETYPE
>>         CONFIG_NET_DMA
>>         CONFIG_NETWORK_SECMARK
>>
>> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>
> I'm getting crashes in csum_partial() on several ARM platforms that I
> bisected down to this patch (and reverting this + "MPLS:
> Add limited GSO support" due to conflicts) results in a working kernel.
>
> The failures started with the 0529 linux-next, didn't exist in 0528.
>
> Unfortunately I'm not getting a useful stack from the crashes:
>
> [    6.495560] Unable to handle kernel paging request at virtual
> address eb000000
> [    6.502769] pgd = e9084000
> [    6.505465] [eb000000] *pgd=00000000
> [    6.509034] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
> [    6.514329] Modules linked in:
> [    6.517378] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 3.10.0-rc2-00483-g1a37e41 #27
> [    6.525015] task: c06e1980 ti: c06d6000 task.ti: c06d6000
> [    6.530402] PC is at csum_partial+0x40/0x130
> [    6.534658] LR is at 0x0
> [    6.537181] pc : [<c01e3150>]    lr : [<00000000>]    psr: 000f0113
> [    6.537181] sp : c06d7d88  ip : e700c060  fp : c06d80c0
> [    6.548631] r10: e90e2140  r9 : e9006050  r8 : 00000001
> [    6.553839] r7 : e9006020  r6 : e9b7e400  r5 : 00000000  r4 : 00000000
> [    6.560348] r3 : 00000000  r2 : 73129f9e  r1 : e900601c  r0 : eb000000
> [    6.566857] Flags: nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
> Segment kernel
> [    6.574146] Control: 10c5387d  Table: 2908404a  DAC: 00000015
> [    6.579874] Process swapper/0 (pid: 0, stack limit = 0xc06d6238)
> [    6.585862] Stack: (0xc06d7d88 to 0xc06d8000)
> [    6.590207] 7d80:                   c0714fc0 e900601c e9006050
> c043a0b8 00000000 e92737b0
> [    6.598365] 7da0: e9273740 c043c1d4 c0010208 c0f83cc0 c06d4cc0
> c0f83cc0 00000000 e9b32000
> [    6.606523] 7dc0: c06d4cc0 00000001 c06d80c0 e9273758 00989680
> 00000000 00000001 e9b7aec0
> [    6.614680] 7de0: 00000000 e90e2140 e9b7af30 e9b7e400 e9b7e490
> 00000000 00000001 c043c5d4
> [    6.622838] 7e00: 00000001 7cdfa980 00000001 e9b7e458 c06d6000
> 00000101 c06d6030 c043c414
> [    6.630995] 7e20: 00200200 00000000 c06d80c0 c002fbe8 00000002
> 7c4716e8 e9b7e458 c073fb80
> [    6.639153] 7e40: c043c414 e9b7e400 c06d7e68 c002fde8 00000000
> c0f82678 00000000 c0740394
> [    6.647310] 7e60: c0740594 c0740794 c06d7e68 c06d7e68 00000006
> 00000001 00000004 c06d8088
> [    6.655468] 7e80: c06d8080 c06d6000 00000001 00000004 00000101
> c002a57c 7c4716e8 00000001
> [    6.663625] 7ea0: c06d37e0 00000000 c073f940 c06d80c0 ffff8d4f
> c06e4970 00200000 c06d6018
> [    6.671783] 7ec0: c02025e8 c06d6028 0000001d 00000000 fe000100
> 00000000 00000000 c06d6000
> [    6.679940] 7ee0: c06de42c c002a9a4 c06d3fac c000eaa0 fe00010c
> c06df074 c06d7f18 c00086f8
> [    6.688098] 7f00: c0061288 c032b560 600f0013 ffffffff c06d7f4c
> c000de60 c06d7f60 00000006
> [    6.696255] 7f20: 7c471300 00000001 7c3bbca8 00000001 c0f83110
> c06e3cd4 00000000 00000000
> [    6.704413] 7f40: c06d6000 c06de42c 00000015 c06d7f60 c0061288
> c032b560 600f0013 ffffffff
> [    6.712571] 7f60: 7c471300 00000001 c0765ac8 c04fe16c c0f83110
> c0765ac8 00000000 c06e3cd4
> [    6.720728] 7f80: 00000000 c032b6b8 00004c9c c071ddc7 c06de490
> c04fe16c c06d6000 c071ddc7
> [    6.728886] 7fa0: c06d6000 c000edb4 00004c9c c0060b3c c04fe5fc
> c0f7f9c0 00000000 c069f828
> [    6.737043] 7fc0: ffffffff ffffffff c069f2e8 00000000 00000000
> c06cbac0 00000000 10c5387d
> [    6.745200] 7fe0: c06de3f4 c06cbabc c06e28e4 0000406a 411fc090
> 00008074 00000000 00000000
> [    6.753359] Code: e0b22003 e0b22004 e0b22005 e0b2200e (e8b04038)
> [    6.759438] ---[ end trace 40c34f89615c2c53 ]---
> [    6.764041] Kernel panic - not syncing: Fatal exception in interrupt
> [    6.770386] CPU1: stopping
> [    6.773086] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D
> 3.10.0-rc2-00483-g1a37e41 #27
>
>
> -Olof
