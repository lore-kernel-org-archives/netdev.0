From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [BUG 4.4-rc4]: oops around sock_recvmsg
Date: Thu, 7 Jan 2016 09:42:50 +0000
Message-ID: <20160107094249.GD19062@n2100.arm.linux.org.uk>
References: <87d1td6a1l.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Holger Schurig <holgerschurig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:46136 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcAGJm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:42:56 -0500
Content-Disposition: inline
In-Reply-To: <87d1td6a1l.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 09:58:14AM +0100, Holger Schurig wrote:
> This oops with sock_recvmsg() inside it now happened 3 times, just not
> at my test box, only at one very remote from me. That's also the reason
> why the log is truncated, the people that grabbed it from Windows with
> Putty over the serial line just did give this to me ... :-(

It's a little incomplete, but luckily we have some useful information
buried in it.

> BTW, are several places with "???" below. Is this just a "grabbing from
> Windows" artifact? Or an indication that the processor/memory of the
> system got completely insane?

No idea, sorry.

...
> [<c00171c4>] (do_page_fault) from [<c000934c>] (do_PrefetchAbort+0x3c/0xa0)
> r10:c0037790 r9:00000001 r8:00000001 r7:ed9a9bf8 r6:fffffffe r5:c055fbc4
> r4:00000007
> [<c0009310>] (do_PrefetchAbort) from [<c001354c>] (__pabt_svc+0x4c/0x80)
> Exception stack(0xed9a9bf8 to 0xed9a9c40)
> 9be0:?????????????????????????????????????????????????????? ebaa3d18 00000001
> 9c00: 00000001 00000304 ee1c2c04 fffffff3 00000001 00000304 00000001 00000001
> 9c20: c0037790 ed9a9c74 ffffffff ed9a9c48 c004febc fffffffe 800100b3 ffffffff

These are the registers - r0 to pc, cpsr and "orig_r0".  The PC value
triggering the prefetch abort was 0xfffffffe, and the link register
was 0xc004febc - this should be the instruction after the call.

To do any diagnosis, I'd need the disassembly around the link
register - it may be best if you can send me the vmlinux file itself
by private mail in case I need to reference other functions too.

I've left the remainder of the trace in place - please retain it when
you reply with the disassembly so I can refer directly to it in my
next reply without having to find the previous email.  Thanks.

> r7:ed9a9c2c r6:ffffffff r5:800100b3 r4:fffffffe
> [<c004fe68>] (__wake_up_common) from [<c00504ac>] (__wake_up_sync_key+0x4c/0x60)
> r10:00000000 r9:00000010 r8:00000304 r7:00000001 r6:00000001 r5:a0010013
> r4:ee1c2c00 r3:00000001
> [<c0050460>] (__wake_up_sync_key) from [<c03cf9d0>] (unix_write_space+0x60/0x90)
> r8:ed9a9df4 r7:eb9decc0 r6:ed95d5e4 r5:ed95f02c r4:ed95ef80
> [<c03cf970>] (unix_write_space) from [<c0347674>] (sock_wfree+0x4c/0x84)
> r4:ed95ef80 r3:c03cf970
> [<c0347628>] (sock_wfree) from [<c03cf2b8>] (unix_destruct_scm+0x6c/0x74)
> r5:00000000 r4:eb9decc0
> [<c03cf24c>] (unix_destruct_scm) from [<c0348768>] (skb_release_head_state+0x70/0xb0)
> r4:eb9decc0
> [<c03486f8>] (skb_release_head_state) from [<c034b280>] (skb_release_all+0x14/0x2c)
> r4:eb9decc0 r3:00000001
> [<c034b26c>] (skb_release_all) from [<c034b2ac>] (__kfree_skb+0x14/0x94)
> r4:eb9decc0 r3:00000001
> [<c034b298>] (__kfree_skb) from [<c034b610>] (consume_skb+0x58/0x5c)
> r4:ed95d400 r3:00000001
> [<c034b5b8>] (consume_skb) from [<c03d050c>] (unix_stream_read_generic+0x5ec/0x750)
> [<c03cff20>] (unix_stream_read_generic) from [<c03d0754>] (unix_stream_recvmsg+0x50/0x5c)
> r10:ecc13800 r9:ed9a9e88 r8:bee12988 r7:00000040 r6:ecc13800 r5:ed9a9f4c
> r4:00001000
> [<c03d0704>] (unix_stream_recvmsg) from [<c0341250>] (sock_recvmsg+0x18/0x1c)
> r7:bee1296c r6:00000040 r5:00000000 r4:ed9a9f4c
> [<c0341238>] (sock_recvmsg) from [<c0342fa0>] (___sys_recvmsg+0x98/0x170)
> [<c0342f08>] (___sys_recvmsg) from [<c0343d34>] (__sys_recvmsg+0x44/0x68)
> r10:00000000 r9:ed9a8000 r8:c000f1e4 r7:00000129 r6:bee1296c r5:00000000
> r4:ecc13800
> [<c0343cf0>] (__sys_recvmsg) from [<c0343d68>] (SyS_recvmsg+0x10/0x14)
> r6:b6f7df10 r5:81196c08 r4:bee12988
> [<c0343d58>] (SyS_recvmsg) from [<c000f020>] (ret_fast_syscall+0x0/0x3c)

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
