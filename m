From: Joe Buehler <aspam@cox.net>
Subject: kernel panic in =?utf-8?b?ZmliX3J1bGVzX2xvb2t1cA==?= [2.6.27.7 vendor-patched]
Date: Tue, 12 Oct 2010 17:14:34 +0000 (UTC)
Message-ID: <loom.20101012T185411-307@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46097 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173Ab0JLRUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 13:20:06 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1P5iWB-0000Jn-Cr
	for netdev@vger.kernel.org; Tue, 12 Oct 2010 19:20:03 +0200
Received: from netrokpix001.spirentcom.com ([96.241.21.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 19:20:03 +0200
Received: from aspam by netrokpix001.spirentcom.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 19:20:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing a kernel panic (NULL pointer) in fib_rules_lookup.  There
were some other reports for 2.6.32 back in March and May.  It looks to
me as though "rules_list" is not in a good state when fib_rules_lookup
traverses it.

My application is bringing TAP interfaces up and down and making
changes to associated routing tables at a fairly good clip (say, a few
times a second).  That use case seems to be similar to a previously
reported crash case.

This is a MIPS kernel (Cavium Octeon) running two CPUs SMP.  I am
using 2.6.27.7 patched by Cavium for hardware support reasons.  I
cannot upgrade because the vendor patches are non-trivial to
forward-port.

Here is one stack trace:

[<ffffffff814671ec>] fib_rules_lookup+0x11c/0x1a8
[<ffffffff814bd144>] fib_lookup+0x2c/0x48
[<ffffffff814788d8>] __ip_route_output_key+0x918/0xf38
[<ffffffff81478f30>] ip_route_output_flow+0x38/0x2e8
[<ffffffff8149fd1c>] tcp_v4_connect+0x134/0x498
[<ffffffff814aef80>] inet_stream_connect+0xf8/0x2f0
[<ffffffff81442680>] sys_connect+0xe0/0xf8
[<ffffffff8114528c>] handle_sys+0x12c/0x148

Here is another:

[<ffffffff814671ec>] fib_rules_lookup+0x11c/0x1a8
[<ffffffff814bd144>] fib_lookup+0x2c/0x48
[<ffffffff814b6550>] fib_validate_source+0xb0/0x4c0
[<ffffffff8147a524>] ip_route_input+0x11a4/0x13c0
[<ffffffff8147c304>] ip_rcv_finish+0x2f4/0x4c0
[<ffffffff81454220>] process_backlog+0xa8/0x160
[<ffffffff81451ea8>] net_rx_action+0x190/0x2e0
[<ffffffff81166978>] __do_softirq+0xf0/0x218
[<ffffffff81166b18>] do_softirq+0x78/0x80
[<ffffffff81100e30>] plat_irq_dispatch+0x130/0x1e0
[<ffffffff81130948>] ret_from_irq+0x0/0x4
[<ffffffff8151167c>] _cond_resched+0x34/0x50
[<ffffffff81148b60>] fpu_emulator_cop1Handler+0x90/0x1c80
[<ffffffff81136f4c>] do_cpu+0x24c/0x360
[<ffffffff81130940>] ret_from_exception+0x0/0x8

*IF* my reading of the disassembled code at point of panic is correct,
 the "pos" pointer in list_for_each_entry_rcu appears to be NULL.

Looking at the code in net/core/fib_rules.c I see some uses of the
"rules_list" using rcu and some apparently not.  Has something simple
been overlooked?

I need this fixed so will try adding a spinlock to protect rules_list
if necessary.

Joe Buehler


