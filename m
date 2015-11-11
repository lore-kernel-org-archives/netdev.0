From: Dave Jones <davej@codemonkey.org.uk>
Subject: kasan r8169 use-after-free trace.
Date: Tue, 10 Nov 2015 22:30:28 -0500
Message-ID: <20151111033028.GA25018@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:51018 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbKKDai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 22:30:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This happens during boot, (and then there's a flood of traces that happen so fast
afterwards it completely overwhelms serial console; not sure if they're the
same/related or not).


==================================================================
BUG: KASAN: use-after-free in rtl8169_poll+0x4b6/0xb70 at addr ffff8801d43b3288
Read of size 1 by task kworker/0:3/188
=============================================================================
BUG kmalloc-256 (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Slab 0xffffea000750ecc0 objects=16 used=16 fp=0x          (null) flags=0x8000000000000080
INFO: Object 0xffff8801d43b3200 @offset=512 fp=0xffff8801d43b3800

Bytes b4 ffff8801d43b31f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b3200: 00 38 3b d4 01 88 ff ff 00 00 00 00 00 00 00 00  .8;.............
Object ffff8801d43b3210: 0d 17 8e 3c 8b 87 15 14 00 00 00 00 00 00 00 00  ...<............
Object ffff8801d43b3220: 00 80 bb 37 00 88 ff ff 00 00 00 00 00 00 00 00  ...7............
Object ffff8801d43b3230: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b3240: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b3250: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b3260: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b3270: 00 00 00 00 00 00 00 00 2e 00 00 00 00 00 00 00  ................
Object ffff8801d43b3280: 0e 00 00 00 00 00 21 00 01 00 00 00 00 00 00 00  ......!.........
Object ffff8801d43b3290: 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00  ................
Object ffff8801d43b32a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Object ffff8801d43b32b0: 00 00 00 00 08 06 4e 00 4e 00 40 00 7c 00 00 00  ......N.N.@.|...
Object ffff8801d43b32c0: 80 00 00 00 00 00 00 00 40 7e 60 d5 01 88 ff ff  ........@~`.....
Object ffff8801d43b32d0: 8e 7e 60 d5 01 88 ff ff c0 02 00 00 01 00 00 00  .~`.............
Object ffff8801d43b32e0: 40 82 c5 d3 01 88 ff ff 00 00 00 00 00 00 00 00  @...............
Object ffff8801d43b32f0: a8 1c 2d d5 00 88 ff ff 00 00 00 00 00 00 00 00  ..-.............
CPU: 0 PID: 188 Comm: kworker/0:3 Tainted: G    B           4.3.0-firewall+ #15
Workqueue: events linkwatch_event
 ffff880037bb89d8 ffff8801d7a07bc8 ffffffff93489155 ffff8801d6801900
 ffff8801d7a07bf8 ffffffff932295de ffff8801d6801900 ffffea000750ecc0
 ffff8801d43b3200 ffff8800d442a000 ffff8801d7a07c20 ffffffff9322ce06
Call Trace:
 <IRQ>  [<ffffffff93489155>] dump_stack+0x4e/0x79
 [<ffffffff932295de>] print_trailer+0xfe/0x160
 [<ffffffff9322ce06>] object_err+0x36/0x40
 [<ffffffff93230bb0>] kasan_report_error+0x220/0x550
 [<ffffffff9393224b>] ? dev_gro_receive+0xbb/0x7f0
 [<ffffffff93932449>] ? dev_gro_receive+0x2b9/0x7f0
 [<ffffffff93230f1b>] kasan_report+0x3b/0x40
 [<ffffffff93812146>] ? rtl8169_poll+0x4b6/0xb70
 [<ffffffff93230198>] __asan_load1+0x48/0x50
 [<ffffffff93812146>] rtl8169_poll+0x4b6/0xb70
 [<ffffffff93c0afb3>] ? _raw_spin_unlock_irqrestore+0x43/0x70
 [<ffffffff9393adeb>] net_rx_action+0x41b/0x6a0
 [<ffffffff9393a9d0>] ? napi_complete_done+0x100/0x100
 [<ffffffff93077f32>] __do_softirq+0x1b2/0x5c0
 [<ffffffff9307858c>] irq_exit+0xfc/0x110
 [<ffffffff93c0ddf2>] do_IRQ+0x82/0x160
 [<ffffffff93c0c4c6>] common_interrupt+0x86/0x86
 <EOI>  [<ffffffff930f712d>] ? console_unlock+0x3bd/0x620
 [<ffffffff930f775e>] vprintk_emit+0x3ce/0x6d0
