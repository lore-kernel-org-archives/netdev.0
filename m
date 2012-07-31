From: Alan Ott <alan@signal11.us>
Subject: 802.15.4 Issues
Date: Tue, 31 Jul 2012 12:04:39 -0400
Message-ID: <50180217.8040706@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51985 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753818Ab2GaQEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 12:04:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm trying to follow the directions at linux-wsn[1] and am not having
much luck. Since I don't have the at91sam9g20ek board, I'm trying this
on my desktop PC with an Econotag[2] (using the serial.c driver I pulled
from [3]) and on a BeagleBone with an MRF24J40 (using a driver I made [4]).

I know this sounds like a big mess, and it is, but let me first start by
staying that all this worked with the code in the linux-zigbee repo at
[3]. With the code in that repo I could run the steps at [5] and
communicate between devices using izchat. (Yes, I know that izchat and
the workflow at [5] are not supported in the -next code yet, which is
why I'm using [1])

Currently, I'm trying to follow the steps at [1] to start using the
latest mainline functionality and I'm not having very much success. I'm
using linux-next, which in looking at the log should currently be the
same as net-next with respect to ieee802154 and 6lowpan.

On the destkop PC, there are several issues. The first is that I'm
getting __schedule_bug errors caused by lowpan_header_create() calling
kzalloc(..., GFP_KERNEL) from interrupt context (see [schedule_log]
below). Replacing kzalloc() calls in lowpan_header_create() and in
ieee802154_header_create() with stack arrays (since they were small
static lengths anyway), I'm able to run the commands at [1] without
stack dumps in the log. This is good, I suppose. The issue now is, once
I've set up the lowpan0 device on the Econotag, when I issue a ping, I
don't see its .xmit() function getting called at all
(ieee802154_serial_xmit() in this case).

I can certainly investigate further, but before doing so, I'd like to
know if what I'm doing, the way I'm doing it, is even _expected_ to
work, or if there's something fundamental that I'm missing.

Also, the instructions at [1] say:
   "no platform data merged to the mainline, please apply the last patch
from wpan series manually"

Those instructions[1] were updated July 4, which is before the most
recent 802.15.4 related commits made it into -next. Is that sentence
still valid? If so, where is this wpan series of which it speaks? I'm
assuming platform data may mean for the at91sam9g20ek and that it
doesn't affect me since I'm not using that hardware. Please correct me
if I'm wrong.

Also, interestingly, on my embedded configuration (Beagle Bone +
MRF24J40), ping6 _will_ cause packets to get sent. The kernel I have on
that system is mainline (linux.git) still, and I haven't moved it to
-next yet because of the issues on the desktop PC.

Like I said, I feel like there's something fundamental I'm doing wrong.
Please let me know if you see it.

Alan.

[1] http://code.google.com/p/linux-wsn/wiki/Mainline
[2] http://www.redwirellc.com/store/node/1
[3]
http://linux-zigbee.git.sourceforge.net/git/gitweb.cgi?p=linux-zigbee/kernel;a=summary
[4] http://permalink.gmane.org/gmane.linux.network.zigbee.devel/1135
[5] http://sourceforge.net/apps/trac/linux-zigbee/wiki/GettingStarted-0.2

[schedule_log]

[   87.605763] Call Trace:
[   87.605764]  <IRQ>  [<ffffffff81084992>] __schedule_bug+0x52/0x60
[   87.605772]  [<ffffffff815e303d>] __schedule+0x6cd/0x7c0
[   87.605774]  [<ffffffff8108875a>] __cond_resched+0x2a/0x40
[   87.605776]  [<ffffffff815e31c0>] _cond_resched+0x30/0x40
[   87.605779]  [<ffffffff81159740>] __kmalloc+0x60/0x170
[   87.605781]  [<ffffffffa02fe28f>] ? kzalloc+0xf/0x20 [6lowpan]
[   87.605783]  [<ffffffffa02fe28f>] kzalloc+0xf/0x20 [6lowpan]
[   87.605785]  [<ffffffffa02fe50e>] lowpan_header_create+0x7e/0x570
[6lowpan]
[   87.605788]  [<ffffffff814de84b>] ? __kmalloc_reserve+0x3b/0xa0
[   87.605790]  [<ffffffff811597d5>] ? __kmalloc+0xf5/0x170
[   87.605792]  [<ffffffff814f711d>] neigh_connected_output+0xad/0x110
[   87.605795]  [<ffffffff8158438d>] ip6_finish_output2+0xfd/0x310
[   87.605797]  [<ffffffff8159041b>] ? rt6_bind_peer+0x4b/0x90
[   87.605799]  [<ffffffff81584638>] ip6_finish_output+0x98/0xc0
[   87.605801]  [<ffffffff815846d8>] ip6_output+0x78/0xb0
[   87.605803]  [<ffffffff8159843e>] ndisc_send_skb+0x1be/0x1f0
[   87.605805]  [<ffffffff815984d1>] __ndisc_send+0x61/0x80
[   87.605807]  [<ffffffff81598d89>] ndisc_send_rs+0x39/0x40
[   87.605809]  [<ffffffff81589df3>] ? ipv6_ifa_notify+0x43/0x50
[   87.605810]  [<ffffffff81589ea0>] addrconf_dad_completed+0xa0/0xf0
[   87.605812]  [<ffffffff8158a08f>] addrconf_dad_timer+0x19f/0x1c0
[   87.605814]  [<ffffffff81064338>] run_timer_softirq+0x178/0x3a0
[   87.605816]  [<ffffffff81589ef0>] ? addrconf_dad_completed+0xf0/0xf0
[   87.605818]  [<ffffffff8101a639>] ? read_tsc+0x9/0x20
[   87.605819]  [<ffffffff8105bfff>] __do_softirq+0xcf/0x250
[   87.605822]  [<ffffffff810a6b34>] ? clockevents_program_event+0x74/0xf0
[   87.605824]  [<ffffffff8107be9e>] ? hrtimer_interrupt+0x13e/0x240
[   87.605826]  [<ffffffff815ed5bc>] call_softirq+0x1c/0x30
[   87.605829]  [<ffffffff810152d5>] do_softirq+0x65/0xa0
[   87.605830]  [<ffffffff8105bded>] irq_exit+0xbd/0xe0
[   87.605832]  [<ffffffff815edefe>] smp_apic_timer_interrupt+0x6e/0x99
[   87.605833]  [<ffffffff815ececa>] apic_timer_interrupt+0x6a/0x70
[   87.605834]  <EOI>  [<ffffffff81041436>] ? native_safe_halt+0x6/0x10
[   87.605838]  [<ffffffff8101c54d>] default_idle+0x5d/0x1b0
[   87.605840]  [<ffffffff8101bb98>] cpu_idle+0xd8/0x120
[   87.605842]  [<ffffffff815dcc1e>] start_secondary+0x1cf/0x1d6 
