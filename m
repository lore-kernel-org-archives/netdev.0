From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: improve truesize tracking
Date: Thu, 20 Dec 2012 15:23:26 +0100
Message-ID: <1457826869.20121220152326@eikelenboom.it>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop> <1797374383.20121220135139@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:34563
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab2LTOXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 09:23:36 -0500
In-Reply-To: <1797374383.20121220135139@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, December 20, 2012, 1:51:39 PM, you wrote:


> Wednesday, December 19, 2012, 5:17:49 PM, you wrote:

>> On Wed, 2012-12-19 at 12:34 +0100, Sander Eikelenboom wrote:

>>> Hi Ian,
>>> 
>>> It ran overnight and i haven't seen the warn_once trigger.
>>> (but i also didn't with the previous patch)
>>> 

>> As I said, the miminum value to not trigger the warning was what Ian
>> patch was doing, but it was still a not accurate estimation.

>> Doing the real accounting might trigger slow transferts, or dropped
>> packets because of socket limits (SNDBUF / RCVBUF) being hit sooner.

>> So the real question was : If accounting for full pages, is your
>> applications run as smooth as before, with no huge performance
>> regression ?

> Ok i have added some extra debug info (see diff's below), the code still uses the old calculation for truesize (in the hope to trigger the warn_on_once again), but also calculates the variants IanC came up with.

> I haven't got a clear test case to trigger the warn_on_once, it happens just every once in a while during my normal usage and i'm not a netperf expert :-)
> So at the moment i haven't been able to trigger the warn_on_once yet, but the results so far do seem to shed some light ..

> - The first variant (current code) seems to be the most effcient and a good estimation *most* of the the, but sometimes triggers the warn_on_once in skb_try_coalesce.
> - The first variant (current code) seems to always substract from the truesize for small packets.
> - The second variant always seems keep the truesize as is for most of the small network traffic, but it also seems to work ok for larger packets.
> - The third variant seems to be a pretty wasteful estimation.

> So the last variant seems to be rather wasteful, and the second one the most accurate so far.

> Eric:
>      From the warn_on_once, delta should be smaller than len, but probably they should be as close together as possible.
>      When you say "accurate estimation", what would be a acceptable difference between DELTA and LEN ?



> [  116.965062] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  117.094538] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.094707] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.094869] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.095058] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.095216] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.096102] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.096311] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.096373] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.150398] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.150459] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
> [  117.536901] eth0: mtu:1500 data_len:53642 len before:0 len after:53642 truesize before:896 truesize after:54282 nr_frags:14 variant1:53386(54282) variant2:53386(54282) variant3:57344(58240)
> [  117.537463] eth0: mtu:1500 data_len:15994 len before:0 len after:15994 truesize before:896 truesize after:16634 nr_frags:5 variant1:15738(16634) variant2:15738(16634) variant3:20480(21376)
> [  117.537915] eth0: mtu:1500 data_len:17442 len before:0 len after:17442 truesize before:896 truesize after:18082 nr_frags:5 variant1:17186(18082) variant2:17186(18082) variant3:20480(21376)
> [  117.538543] eth0: mtu:1500 data_len:18890 len before:0 len after:18890 truesize before:896 truesize after:19530 nr_frags:6 variant1:18634(19530) variant2:18634(19530) variant3:24576(25472)
> [  117.539223] eth0: mtu:1500 data_len:13098 len before:0 len after:13098 truesize before:896 truesize after:13738 nr_frags:4 variant1:12842(13738) variant2:12842(13738) variant3:16384(17280)
> [  117.539283] eth0: mtu:1500 data_len:7306 len before:0 len after:7306 truesize before:896 truesize after:7946 nr_frags:2 variant1:7050(7946) variant2:7050(7946) variant3:8192(9088)
> [  117.539403] skbuff: to: (null) from: (null)  skb_try_coalesce: DELTA - LEN > 100 delta:7690 len:7240 from->truesize:7946 skb_headlen(from):190 skb_shinfo(to)->nr_frags:5 skb_shinfo(from)->nr_frags:2
> [  117.540035] eth0: mtu:1500 data_len:4410 len before:0 len after:4410 truesize before:896 truesize after:5050 nr_frags:3 variant1:4154(5050) variant2:4304(5200) variant3:12288(13184)
> [  117.540153] eth0: mtu:1500 data_len:1018 len before:0 len after:1018 truesize before:896 truesize after:1658 nr_frags:1 variant1:762(1658) variant2:762(1658) variant3:4096(4992)
> [  121.981917] net_ratelimit: 27 callbacks suppressed
> [  121.981960] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  122.985019] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  123.988308] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  124.991961] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  125.995003] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
> [  126.998324] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)



> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index c26e28b..8833e38 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -964,6 +964,7 @@ static int xennet_poll(struct napi_struct *napi, int budget)
>         struct sk_buff_head tmpq;
>         unsigned long flags;
>         int err;
> +       int tsz,len;

>         spin_lock(&np->rx_lock);

> @@ -1037,9 +1038,22 @@ err:
>                  * receive throughout using the standard receive
>                  * buffer size was cut by 25%(!!!).
>                  */
> -               skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
> +
> +
> +
> +
> +                tsz = skb->truesize;
> +                len = skb->len;
> +                /* skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags; */
> +                skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
>                 skb->len += skb->data_len;

> +               net_warn_ratelimited("%s: mtu:%d data_len:%d len before:%d len after:%d truesize before:%d truesize after:%d nr_frags:%d variant1:%d(%d) variant2:%d(%d) variant3:%d(%d) \n",
> +                        skb->dev->name, skb->dev->mtu, skb->data_len, len,  skb->len,tsz, skb->truesize, skb_shinfo(skb)->nr_frags,
> +                        skb->data_len - RX_COPY_THRESHOLD, tsz + skb->data_len - RX_COPY_THRESHOLD ,
> +                        skb->data_len - NETFRONT_SKB_CB(skb)->pull_to, tsz + skb->data_len - NETFRONT_SKB_CB(skb)->pull_to,
> +                        PAGE_SIZE * skb_shinfo(skb)->nr_frags, tsz + (PAGE_SIZE * skb_shinfo(skb)->nr_frags));
> +
>                 if (rx->flags & XEN_NETRXF_csum_blank)
>                         skb->ip_summed = CHECKSUM_PARTIAL;
>                 else if (rx->flags & XEN_NETRXF_data_validated)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3ab989b..6d0cd86 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3471,6 +3471,16 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,

>         WARN_ON_ONCE(delta < len);

> +       if(delta < len) {
> +               net_warn_ratelimited("to: %s from: %s  skb_try_coalesce: DELTA < LEN delta:%d len:%d from->truesize:%d skb_headlen(from):%d skb_shinfo(to)->nr_frags:%d skb_shinfo(from)->nr_frags:%d \n",
> +                        to->dev->name, from->dev->name, delta, len, from->truesize, skb_headlen(from), skb_shinfo(to)->nr_frags, skb_shinfo(from)->nr_frags);
> +       }
> +
+       if (delta >> len && delta - len > 100) {
> +               net_warn_ratelimited("to: %s from: %s  skb_try_coalesce: DELTA - LEN > 100 delta:%d len:%d from->truesize:%d skb_headlen(from):%d skb_shinfo(to)->nr_frags:%d skb_shinfo(from)->nr_frags:%d \n",
> +                        to->dev->name,from->dev->name, delta, len, from->truesize, skb_headlen(from), skb_shinfo(to)->nr_frags, skb_shinfo(from)->nr_frags);
> +       }
> +
>         memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
>                skb_shinfo(from)->frags,
>                skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));



Ok i succeeded in triggering the warn_on_once, but it seems the extra debug info from netfront was just rate limited away for the offending packet :(

Dec 20 15:17:33 media kernel: [  393.464062] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:33 media kernel: [  393.464438] eth0: mtu:1500 data_len:762 len before:0 len after:762 truesize before:896 truesize after:1402 nr_frags:1 variant1:506(1402) variant2:506(1402) variant3:4096(4992)
Dec 20 15:17:33 media kernel: [  393.465083] eth0: mtu:1500 data_len:118 len before:0 len after:118 truesize before:896 truesize after:758 nr_frags:1 variant1:-138(758) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:33 media kernel: [  393.466114] eth0: mtu:1500 data_len:118 len before:0 len after:118 truesize before:896 truesize after:758 nr_frags:1 variant1:-138(758) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:33 media kernel: [  393.467336] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  394.940211] ------------[ cut here ]------------
Dec 20 15:17:35 media kernel: [  394.940259] WARNING: at net/core/skbuff.c:3472 skb_try_coalesce+0x3fc/0x470()
Dec 20 15:17:35 media kernel: [  394.940282] Modules linked in:
Dec 20 15:17:35 media kernel: [  394.940306] Pid: 2632, comm: glusterfs Not tainted 3.7.0-rc0-20121220-netfrontdebug1 #1
Dec 20 15:17:35 media kernel: [  394.940330] Call Trace:
Dec 20 15:17:35 media kernel: [  394.940343]  <IRQ>  [<ffffffff8106889a>] warn_slowpath_common+0x7a/0xb0
Dec 20 15:17:35 media kernel: [  394.940384]  [<ffffffff810688e5>] warn_slowpath_null+0x15/0x20
Dec 20 15:17:35 media kernel: [  394.940409]  [<ffffffff8184298c>] skb_try_coalesce+0x3fc/0x470
Dec 20 15:17:35 media kernel: [  394.940434]  [<ffffffff818fb049>] tcp_try_coalesce+0x69/0xc0
Dec 20 15:17:35 media kernel: [  394.940458]  [<ffffffff818fb0f4>] tcp_queue_rcv+0x54/0x100
Dec 20 15:17:35 media kernel: [  394.940481]  [<ffffffff8190029f>] ? tcp_mtup_init+0x2f/0x90
Dec 20 15:17:35 media kernel: [  394.940504]  [<ffffffff818ffbdb>] tcp_rcv_established+0x2bb/0x6a0
Dec 20 15:17:35 media kernel: [  394.940528]  [<ffffffff8190839f>] ? tcp_v4_rcv+0x6cf/0xb10
Dec 20 15:17:35 media kernel: [  394.940551]  [<ffffffff81907985>] tcp_v4_do_rcv+0x135/0x480
Dec 20 15:17:35 media kernel: [  394.940576]  [<ffffffff819b3532>] ? _raw_spin_lock_nested+0x42/0x50
Dec 20 15:17:35 media kernel: [  394.940600]  [<ffffffff8190839f>] ? tcp_v4_rcv+0x6cf/0xb10
Dec 20 15:17:35 media kernel: [  394.940623]  [<ffffffff8190862d>] tcp_v4_rcv+0x95d/0xb10
Dec 20 15:17:35 media kernel: [  394.940666]  [<ffffffff810b5688>] ? lock_acquire+0xd8/0x100
Dec 20 15:17:35 media kernel: [  394.940694]  [<ffffffff818e4d6a>] ip_local_deliver_finish+0x11a/0x230
Dec 20 15:17:35 media kernel: [  394.940720]  [<ffffffff818e4c95>] ? ip_local_deliver_finish+0x45/0x230
Dec 20 15:17:35 media kernel: [  394.940745]  [<ffffffff818e4eb8>] ip_local_deliver+0x38/0x80
Dec 20 15:17:35 media kernel: [  394.940784]  [<ffffffff818e447a>] ip_rcv_finish+0x15a/0x630
Dec 20 15:17:35 media kernel: [  394.940807]  [<ffffffff818e4b68>] ip_rcv+0x218/0x300
Dec 20 15:17:35 media kernel: [  394.940829]  [<ffffffff8184bf2d>] __netif_receive_skb+0x65d/0x8d0
Dec 20 15:17:35 media kernel: [  394.940853]  [<ffffffff8184ba15>] ? __netif_receive_skb+0x145/0x8d0
Dec 20 15:17:35 media kernel: [  394.940889]  [<ffffffff810b192d>] ? trace_hardirqs_on+0xd/0x10
Dec 20 15:17:35 media kernel: [  394.940914]  [<ffffffff810fecbb>] ? free_hot_cold_page+0x1ab/0x1e0
Dec 20 15:17:35 media kernel: [  394.940939]  [<ffffffff8184e4f8>] netif_receive_skb+0x28/0xf0
Dec 20 15:17:35 media kernel: [  394.940964]  [<ffffffff81843e83>] ? __pskb_pull_tail+0x253/0x340
Dec 20 15:17:35 media kernel: [  394.941000]  [<ffffffff8164fbb5>] xennet_poll+0xae5/0xed0
Dec 20 15:17:35 media kernel: [  394.941024]  [<ffffffff81080081>] ? wake_up_worker+0x1/0x30
Dec 20 15:17:35 media kernel: [  394.941046]  [<ffffffff810b2fbc>] ? validate_chain+0x13c/0x1300
Dec 20 15:17:35 media kernel: [  394.941075]  [<ffffffff8184ed66>] net_rx_action+0x136/0x260
Dec 20 15:17:35 media kernel: [  394.941098]  [<ffffffff81070551>] ? __do_softirq+0x71/0x1a0
Dec 20 15:17:35 media kernel: [  394.941133]  [<ffffffff810705a9>] __do_softirq+0xc9/0x1a0
Dec 20 15:17:35 media kernel: [  394.941157]  [<ffffffff819b623c>] call_softirq+0x1c/0x30
Dec 20 15:17:35 media kernel: [  394.941179]  [<ffffffff8100fdc5>] do_softirq+0x85/0xf0
Dec 20 15:17:35 media kernel: [  394.941201]  [<ffffffff8107041e>] irq_exit+0x9e/0xd0
Dec 20 15:17:35 media kernel: [  394.941235]  [<ffffffff81430b1f>] xen_evtchn_do_upcall+0x2f/0x40
Dec 20 15:17:35 media kernel: [  394.941259]  [<ffffffff819b629e>] xen_do_hypervisor_callback+0x1e/0x30
Dec 20 15:17:35 media kernel: [  394.941279]  <EOI>  [<ffffffff8100122a>] ? xen_hypercall_xen_version+0xa/0x20
Dec 20 15:17:35 media kernel: [  394.941318]  [<ffffffff8100122a>] ? xen_hypercall_xen_version+0xa/0x20
Dec 20 15:17:35 media kernel: [  394.941356]  [<ffffffff8100890d>] ? xen_force_evtchn_callback+0xd/0x10
Dec 20 15:17:35 media kernel: [  394.941381]  [<ffffffff810092b2>] ? check_events+0x12/0x20
Dec 20 15:17:35 media kernel: [  394.941405]  [<ffffffff81009259>] ? xen_irq_enable_direct_reloc+0x4/0x4
Dec 20 15:17:35 media kernel: [  394.941432]  [<ffffffff819b3f6c>] ? _raw_spin_unlock_irq+0x3c/0x70
Dec 20 15:17:35 media kernel: [  394.941473]  [<ffffffff81095f83>] ? finish_task_switch+0x83/0xe0
Dec 20 15:17:35 media kernel: [  394.941507]  [<ffffffff81095f46>] ? finish_task_switch+0x46/0xe0
Dec 20 15:17:35 media kernel: [  394.941533]  [<ffffffff819b2434>] ? __schedule+0x444/0x880
Dec 20 15:17:35 media kernel: [  394.941555]  [<ffffffff810b2fbc>] ? validate_chain+0x13c/0x1300
Dec 20 15:17:35 media kernel: [  394.941580]  [<ffffffff810b4c4b>] ? __lock_acquire+0x46b/0xdd0
Dec 20 15:17:35 media kernel: [  394.941614]  [<ffffffff810b4c4b>] ? __lock_acquire+0x46b/0xdd0
Dec 20 15:17:35 media kernel: [  394.941638]  [<ffffffff819aff95>] ? __mutex_unlock_slowpath+0x135/0x1d0
Dec 20 15:17:35 media kernel: [  394.941663]  [<ffffffff819b2904>] ? schedule+0x24/0x70
Dec 20 15:17:35 media kernel: [  394.941697]  [<ffffffff819b179d>] ? schedule_hrtimeout_range_clock+0x11d/0x140
Dec 20 15:17:35 media kernel: [  394.941725]  [<ffffffff810b5688>] ? lock_acquire+0xd8/0x100
Dec 20 15:17:35 media kernel: [  394.941748]  [<ffffffff8118a558>] ? ep_poll+0xf8/0x3a0
Dec 20 15:17:35 media kernel: [  394.941770]  [<ffffffff819b4015>] ? _raw_spin_unlock_irqrestore+0x75/0xa0
Dec 20 15:17:35 media kernel: [  394.941808]  [<ffffffff810b1818>] ? trace_hardirqs_on_caller+0xf8/0x200
Dec 20 15:17:35 media kernel: [  394.941833]  [<ffffffff819b17ce>] ? schedule_hrtimeout_range+0xe/0x10
Dec 20 15:17:35 media kernel: [  394.941856]  [<ffffffff8118a75a>] ? ep_poll+0x2fa/0x3a0
Dec 20 15:17:35 media kernel: [  394.941878]  [<ffffffff81098630>] ? try_to_wake_up+0x310/0x310
Dec 20 15:17:35 media kernel: [  394.941913]  [<ffffffff810b5b17>] ? lock_release+0x117/0x250
Dec 20 15:17:35 media kernel: [  394.941938]  [<ffffffff81165fd7>] ? fget_light+0xd7/0x140
Dec 20 15:17:35 media kernel: [  394.941959]  [<ffffffff81165f3a>] ? fget_light+0x3a/0x140
Dec 20 15:17:35 media kernel: [  394.941981]  [<ffffffff8118a8ce>] ? sys_epoll_wait+0xce/0xe0
Dec 20 15:17:35 media kernel: [  394.942015]  [<ffffffff819b4e69>] ? system_call_fastpath+0x16/0x1b
Dec 20 15:17:35 media kernel: [  394.942036] ---[ end trace 6f3a832c9e91c8af ]---
Dec 20 15:17:35 media kernel: [  394.942056] to: (null) from: (null)  skb_try_coalesce: DELTA < LEN delta:22978 len:23168 from->truesize:23874 skb_headlen(from):0 skb_shinfo(to)->nr_frags:4 skb_shinfo(from)->nr_frags:6
Dec 20 15:17:35 media kernel: [  394.968199] to: (null) from: (null)  skb_try_coalesce: DELTA < LEN delta:14290 len:14480 from->truesize:15186 skb_headlen(from):0 skb_shinfo(to)->nr_frags:13 skb_shinfo(from)->nr_frags:4
Dec 20 15:17:35 media kernel: [  395.262814] net_ratelimit: 371 callbacks suppressed
Dec 20 15:17:35 media kernel: [  395.262858] eth0: mtu:1500 data_len:90 len before:0 len after:90 truesize before:896 truesize after:730 nr_frags:1 variant1:-166(730) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.264767] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.266193] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.268422] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.271617] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.274794] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.278104] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.281319] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.284454] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.287797] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
Dec 20 15:17:35 media kernel: [  395.291121] eth0: mtu:1500 data_len:66 len before:0 len after:66 truesize before:896 truesize after:706 nr_frags:1 variant1:-190(706) variant2:0(896) variant3:4096(4992)
