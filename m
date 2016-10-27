From: Steve Bennett <steveb@workware.net.au>
Subject: Bug in cadence macb driver
Date: Thu, 27 Oct 2016 17:22:12 +1000
Message-ID: <3DDE7A42-84A6-44DC-9919-C0D9166E87EF@workware.net.au>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36754 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbcJ0HWS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 03:22:18 -0400
Received: by mail-pf0-f176.google.com with SMTP id e6so12254534pfk.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 00:22:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are seeing the following problem in the cadence macb driver.

BUG: scheduling while atomic: kworker/0:1/44/0x00000002
Modules linked in: 8021q of_serial beacon_sigproc io_processor emsattr =
ems_dma_fifo xaxi_dma libgpioreg leds_gpio
CPU: 0 PID: 44 Comm: kworker/0:1 Not tainted 4.4.0 #1
Hardware name: Xilinx Zynq Platform
Workqueue: events macb_tx_error_task
[<c0016a18>] (unwind_backtrace) from [<c0012ad4>] (show_stack+0x10/0x14)
[<c0012ad4>] (show_stack) from [<c01b089c>] (dump_stack+0x88/0xd8)
[<c01b089c>] (dump_stack) from [<c008e94c>] (__schedule_bug+0x48/0x60)
[<c008e94c>] (__schedule_bug) from [<c03592d4>] (__schedule+0x80/0x4c4)
[<c03592d4>] (__schedule) from [<c0359968>] (schedule+0xac/0xd4)
[<c0359968>] (schedule) from [<c035c284>] =
(schedule_hrtimeout_range_clock+0xc0/0xf4)
[<c035c284>] (schedule_hrtimeout_range_clock) from [<c035bebc>] =
(usleep_range+0x44/0x48)
[<c035bebc>] (usleep_range) from [<c025ec48>] =
(macb_tx_error_task+0xa0/0x270)
[<c025ec48>] (macb_tx_error_task) from [<c0035b6c>] =
(process_one_work+0x1b8/0x2f0)
[<c0035b6c>] (process_one_work) from [<c0035fb4>] =
(worker_thread+0x2e4/0x3f0)
[<c0035fb4>] (worker_thread) from [<c003ac94>] (kthread+0xdc/0xf0)
[<c003ac94>] (kthread) from [<c000f698>] (ret_from_fork+0x14/0x3c)

Here we are running at 10M half duplex, so tx is slow.
The problem was introduced in e4bfd971b where a spinlock is taken before
calling macb_halt_tx() which may then sleep waiting for the current =
packet to finish
transmitting.

We don't need the spinlock on our platform since we don't have multiple =
queues, but
this should be fixed properly in the general case.

Cheers,
Steve
