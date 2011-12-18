From: Marek Vasut <marek.vasut@gmail.com>
Subject: ipv6/addrconf_dad_failure printk() in interrupt context
Date: Sun, 18 Dec 2011 03:28:00 +0100
Message-ID: <201112180328.00422.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Denk <wd@denx.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44755 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab1LRC2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 21:28:04 -0500
Received: by eekc4 with SMTP id c4so4342729eek.19
        for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 18:28:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just recently hit the following issue. I might actually be wrong with my 
conclusions so bear with me. The events that led to the issue:

1) Duplicate IPv6 address on the network
2) console driver that locks a mutex when printk() is called

The problem is the following backtrace:

[    4.870000] eth0: IPv6 duplicate address XXXX::YYYY:ZZZZ:WWWW:0 detected!
[    4.870000] ------------[ cut here ]------------
[    4.870000] WARNING: at kernel/mutex.c:198 mutex_lock_nested+0x284/0x2c0()
[    4.870000] Modules linked in:
[    4.870000] [<c0013ab8>] (unwind_backtrace+0x0/0xf0) from [<c001d934>] 
(warn_slowpath_common+0x4c/0x64)
[    4.870000] [<c001d934>] (warn_slowpath_common+0x4c/0x64) from [<c001d968>] 
(warn_slowpath_null+0x1c/0x24)
[    4.870000] [<c001d968>] (warn_slowpath_null+0x1c/0x24) from [<c033a4f4>] 
(mutex_lock_nested+0x284/0x2c0)
[    4.870000] [<c033a4f4>] (mutex_lock_nested+0x284/0x2c0) from [<c0017d88>] 
(clk_enable+0x20/0x48)
[    4.870000] [<c0017d88>] (clk_enable+0x20/0x48) from [<c01dfbf0>] 
(pl011_console_write+0x20/0x74)
[    4.870000] [<c01dfbf0>] (pl011_console_write+0x20/0x74) from [<c001da98>] 
(__call_console_drivers+0x7c/0x94)
[    4.870000] [<c001da98>] (__call_console_drivers+0x7c/0x94) from [<c001df20>] 
(console_unlock+0xf8/0x244)
[    4.870000] [<c001df20>] (console_unlock+0xf8/0x244) from [<c001e308>] 
(vprintk+0x29c/0x484)
[    4.870000] [<c001e308>] (vprintk+0x29c/0x484) from [<c03355a8>] 
(printk+0x20/0x30)
[    4.870000] [<c03355a8>] (printk+0x20/0x30) from [<c02df600>] 
(addrconf_dad_failure+0x148/0x158)
[    4.870000] [<c02df600>] (addrconf_dad_failure+0x148/0x158) from [<c02ebde0>] 
(ndisc_rcv+0xb38/0xdb0)
[    4.870000] [<c02ebde0>] (ndisc_rcv+0xb38/0xdb0) from [<c02f1b28>] 
(icmpv6_rcv+0x6ec/0x9c4)
[    4.870000] [<c02f1b28>] (icmpv6_rcv+0x6ec/0x9c4) from [<c02da9a4>] 
(ip6_input_finish+0x144/0x4e0)
[    4.870000] [<c02da9a4>] (ip6_input_finish+0x144/0x4e0) from [<c02db424>] 
(ip6_mc_input+0xb8/0x154)
[    4.870000] [<c02db424>] (ip6_mc_input+0xb8/0x154) from [<c02db12c>] 
(ipv6_rcv+0x300/0x53c)
[    4.870000] [<c02db12c>] (ipv6_rcv+0x300/0x53c) from [<c0267b78>] 
(__netif_receive_skb+0x240/0x420)
[    4.870000] [<c0267b78>] (__netif_receive_skb+0x240/0x420) from [<c0267de8>] 
(process_backlog+0x90/0x150)
[    4.870000] [<c0267de8>] (process_backlog+0x90/0x150) from [<c026a5f8>] 
(net_rx_action+0xc0/0x264)
[    4.870000] [<c026a5f8>] (net_rx_action+0xc0/0x264) from [<c0023cfc>] 
(__do_softirq+0xa8/0x214)
[    4.870000] [<c0023cfc>] (__do_softirq+0xa8/0x214) from [<c00242c0>] 
(irq_exit+0x8c/0x94)
[    4.870000] [<c00242c0>] (irq_exit+0x8c/0x94) from [<c000f6d0>] 
(handle_IRQ+0x34/0x84)
[    4.870000] [<c000f6d0>] (handle_IRQ+0x34/0x84) from [<c000e5d8>] 
(__irq_usr+0x38/0x80)
[    4.870000] ---[ end trace 32eab6a8dcdca9c0 ]---

So basically what I see here is the following order of events:

Packet received -> IRQ generated -> ipv6 packet received (still in interrupt 
context ... why not in tasklet ... or am I wrong here ?) -> icmpv6 packet 
processing -> addrconf_dad_failure() called -> printk() called in there -> 
mutex_lock() called in printk(), causing the warning.

Can printk() be actually called in interrupt context?

What direction of solving this shall I take?

Thanks in advance!

M
