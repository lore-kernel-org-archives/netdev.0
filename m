From: Stefan Agner <stefan@agner.ch>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Wed, 03 May 2017 18:21:32 -0700
Message-ID: <e366479239b66ba80415b5594def2369@agner.ch>
References: <c6b66956c48f981a952048da6b2ddd54@agner.ch>
 <ed24e51d-499f-597b-0c9f-7f180e257acb@nxp.com>
 <e99d7c93b7819507c6448842015bf836@agner.ch>
 <AM4PR0401MB2260EBCD552219D3402B68FEFF180@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
 <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: fugang.duan@freescale.com, festevam@gmail.com,
        netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:47316 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752678AbdEDBV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 21:21:59 -0400
In-Reply-To: <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On 2017-04-20 19:48, Andy Duan wrote:
> On 2017年04月20日 07:15, Stefan Agner wrote:
>> I tested again with imx6sx-fec compatible string. I could reproduce it
>> on a Colibri with i.MX 7Dual. But not always: It really depends whether
>> queue 2 is counting up or not. Just after boot, I check /proc/interrupts
>> twice, if queue 2 is counting it will happen!
>>
>> But if only queue 0 is mostly in use, then it seems to work just fine.
> If your case is only running best effort like tcp/udp, you can re-set 
> the "fsl,num-tx-queues" and "fsl,num-rx-queues" to 1 in board dts file.
> Other two queues are for AVB audio/video queues, they have high priority 
> than queue 0. If running iperf tcp test on the three queues, then
> the tcp segment may be out-of-order that cause net watchdog timeout.
>>
>> I also tried i.MX 7Dual SabreSD here, and the same thing. I had to
>> reboot 3 times, then queue 2 was counting:
>>   57:          8     GIC-0 150 Level     30be0000.ethernet
>>   58:      20137     GIC-0 151 Level     30be0000.ethernet
>>   59:       9269     GIC-0 152 Level     30be0000.ethernet
>>
>> It took me about 40 minutes on Sabre until it happened, and I had to
>> force it using iperf, but then I got the ring dumps:
> My board had ran more than 47 hours with nfs rootfs in 4.11.0-rc6, but 
> not running iperf.
> I am testing with iperf.

Any update on this issue?

When using iperf (server) on the board with Linux 4.11 the issue appears
within a few iperf iterations on a Sabre (TO 1.2, Board Rev C, if that
matters)...

root@colibri-imx7:~# iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 192.168.10.70 port 5001 connected with 192.168.10.1 port
60524
random: crng init done
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  1.06 GBytes   909 Mbits/sec
[  5] local 192.168.10.70 port 5001 connected with 192.168.10.1 port
60528
[  5]  0.0-10.0 sec  1.07 GBytes   919 Mbits/sec
[  4] local 192.168.10.70 port 5001 connected with 192.168.10.1 port
60562
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316
dev_watchdog+0x248/0x24c
NETDEV WATCHDOG: eth0 (fec): transmit queue 1 timed out
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.11.0 #360
Hardware name: Freescale i.MX7 Dual (Device Tree)
[<c0226930>] (unwind_backtrace) from [<c0222ffc>] (show_stack+0x10/0x14)
[<c0222ffc>] (show_stack) from [<c04d4f78>] (dump_stack+0x78/0x8c)
[<c04d4f78>] (dump_stack) from [<c0236b38>] (__warn+0xe8/0x100)
[<c0236b38>] (__warn) from [<c0236b88>] (warn_slowpath_fmt+0x38/0x48)
[<c0236b88>] (warn_slowpath_fmt) from [<c0806154>]
(dev_watchdog+0x248/0x24c)
[<c0806154>] (dev_watchdog) from [<c028a9a0>] (call_timer_fn+0x28/0x98)
[<c028a9a0>] (call_timer_fn) from [<c028aab0>] (expire_timers+0xa0/0xac)
[<c028aab0>] (expire_timers) from [<c028ab58>]
(run_timer_softirq+0x9c/0x194)
[<c028ab58>] (run_timer_softirq) from [<c023b110>]
(__do_softirq+0x114/0x234)
[<c023b110>] (__do_softirq) from [<c023b4fc>] (irq_exit+0xcc/0x108)
[<c023b4fc>] (irq_exit) from [<c027a1a0>]
(__handle_domain_irq+0x80/0xec)
[<c027a1a0>] (__handle_domain_irq) from [<c0201544>]
(gic_handle_irq+0x48/0x8c)
[<c0201544>] (gic_handle_irq) from [<c0223ab8>] (__irq_svc+0x58/0x8c)
Exception stack(0xc1001f28 to 0xc1001f70)
1f20:                   00000001 00000000 00000000 c0230060 c1000000
c1003d80
1f40: c1003d34 c0e72f50 c0bd9a04 c1001f80 00000000 00000000 0000320a
c1001f78
1f60: c022070c c0220710 600e0013 ffffffff
[<c0223ab8>] (__irq_svc) from [<c0220710>] (arch_cpu_idle+0x38/0x3c)
[<c0220710>] (arch_cpu_idle) from [<c026f4e0>] (do_idle+0x170/0x204)
[<c026f4e0>] (do_idle) from [<c026f82c>] (cpu_startup_entry+0x18/0x1c)
[<c026f82c>] (cpu_startup_entry) from [<c0e00c88>]
(start_kernel+0x394/0x3a0)
---[ end trace 86a38600d1b9e2a5 ]---
fec 30be0000.ethernet eth0: TX ring dump
Nr     SC     addr       len  SKB
  0    0x1c00 0x00000000   42   (null)
  1  H 0x1c00 0x00000000   86   (null)
