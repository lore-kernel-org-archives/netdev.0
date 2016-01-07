From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: [BUG 4.4-rc4]: oops around sock_recvmsg
Date: Thu, 07 Jan 2016 15:47:02 +0100
Message-ID: <87d1td4fbt.fsf@gmail.com>
References: <87d1td6a1l.fsf@gmail.com>
	<20160107094249.GD19062@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34250 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbcAGOrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 09:47:05 -0500
Received: by mail-wm0-f47.google.com with SMTP id u188so101263166wmu.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 06:47:04 -0800 (PST)
In-Reply-To: <20160107094249.GD19062@n2100.arm.linux.org.uk> (Russell King's
	message of "Thu, 7 Jan 2016 09:42:50 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Russell, as asked I've sent the kernel via private mail to you.


For the mailing list:

As I "lost" the vmlinux (I continued working on the kernel) and
scripts/extract-vmlinux didn't liked the vmlinux file, I reverted my
changes and recompiled the kernel. The resulting System.map is identical
to the one on the device, so I'm pretty sure that worked out. I just
note it here as a potential caveat.

I then did run

gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/bin/objdump
-D -S --show-raw-insn --prefix-addresses --line-numbers linux/vmlinux >o

and got this around 0xc004febc:

__wake_up_common():
c004fe68 <__wake_up_common> e1a0c00d    mov     ip, sp
c004fe6c <__wake_up_common+0x4> e92ddff8        push    {r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, lr, pc}
c004fe70 <__wake_up_common+0x8> e24cb004        sub     fp, ip, #4
c004fe74 <__wake_up_common+0xc> e1a04000        mov     r4, r0
c004fe78 <__wake_up_common+0x10> e1a09003       mov     r9, r3
c004fe7c <__wake_up_common+0x14> e1a08001       mov     r8, r1
c004fe80 <__wake_up_common+0x18> e5b43004       ldr     r3, [r4, #4]!
c004fe84 <__wake_up_common+0x1c> e1a06002       mov     r6, r2
c004fe88 <__wake_up_common+0x20> e59b7004       ldr     r7, [fp, #4]
c004fe8c <__wake_up_common+0x24> e5935000       ldr     r5, [r3]
c004fe90 <__wake_up_common+0x28> e243000c       sub     r0, r3, #12
c004fe94 <__wake_up_common+0x2c> e245500c       sub     r5, r5, #12
c004fe98 <__wake_up_common+0x30> e280300c       add     r3, r0, #12
c004fe9c <__wake_up_common+0x34> e1530004       cmp     r3, r4
c004fea0 <__wake_up_common+0x38> 0a00000f       beq     c004fee4 <__wake_up_common+0x7c>
c004fea4 <__wake_up_common+0x3c> e590c008       ldr     ip, [r0, #8]
c004fea8 <__wake_up_common+0x40> e1a01008       mov     r1, r8
c004feac <__wake_up_common+0x44> e1a02009       mov     r2, r9
c004feb0 <__wake_up_common+0x48> e1a03007       mov     r3, r7
c004feb4 <__wake_up_common+0x4c> e590a000       ldr     sl, [r0]
c004feb8 <__wake_up_common+0x50> e12fff3c       blx     ip
c004febc <__wake_up_common+0x54> e3500000       cmp     r0, #0
c004fec0 <__wake_up_common+0x58> 0a000003       beq     c004fed4 <__wake_up_common+0x6c>
c004fec4 <__wake_up_common+0x5c> e31a0001       tst     sl, #1
c004fec8 <__wake_up_common+0x60> 0a000001       beq     c004fed4 <__wake_up_common+0x6c>
c004fecc <__wake_up_common+0x64> e2566001       subs    r6, r6, #1
c004fed0 <__wake_up_common+0x68> 089daff8       ldmeq   sp, {r3, r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
c004fed4 <__wake_up_common+0x6c> e595300c       ldr     r3, [r5, #12]
c004fed8 <__wake_up_common+0x70> e1a00005       mov     r0, r5
c004fedc <__wake_up_common+0x74> e243500c       sub     r5, r3, #12
c004fee0 <__wake_up_common+0x78> eaffffec       b       c004fe98 <__wake_up_common+0x30>
c004fee4 <__wake_up_common+0x7c> e89daff8       ldm     sp, {r3, r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}



>> [<c00171c4>] (do_page_fault) from [<c000934c>] (do_PrefetchAbort+0x3c/0xa0)
>> r10:c0037790 r9:00000001 r8:00000001 r7:ed9a9bf8 r6:fffffffe r5:c055fbc4
>> r4:00000007
>> [<c0009310>] (do_PrefetchAbort) from [<c001354c>] (__pabt_svc+0x4c/0x80)
>> Exception stack(0xed9a9bf8 to 0xed9a9c40)
>> 9be0:?????????????????????????????????????????????????????? ebaa3d18 00000001
>> 9c00: 00000001 00000304 ee1c2c04 fffffff3 00000001 00000304 00000001 00000001
>> 9c20: c0037790 ed9a9c74 ffffffff ed9a9c48 c004febc fffffffe 800100b3 ffffffff
>
> These are the registers - r0 to pc, cpsr and "orig_r0".  The PC value
> triggering the prefetch abort was 0xfffffffe, and the link register
> was 0xc004febc - this should be the instruction after the call.
>
> To do any diagnosis, I'd need the disassembly around the link
> register - it may be best if you can send me the vmlinux file itself
> by private mail in case I need to reference other functions too.
>
> I've left the remainder of the trace in place - please retain it when
> you reply with the disassembly so I can refer directly to it in my
> next reply without having to find the previous email.  Thanks.
>
>> r7:ed9a9c2c r6:ffffffff r5:800100b3 r4:fffffffe
>> [<c004fe68>] (__wake_up_common) from [<c00504ac>] (__wake_up_sync_key+0x4c/0x60)
>> r10:00000000 r9:00000010 r8:00000304 r7:00000001 r6:00000001 r5:a0010013
>> r4:ee1c2c00 r3:00000001
>> [<c0050460>] (__wake_up_sync_key) from [<c03cf9d0>] (unix_write_space+0x60/0x90)
>> r8:ed9a9df4 r7:eb9decc0 r6:ed95d5e4 r5:ed95f02c r4:ed95ef80
>> [<c03cf970>] (unix_write_space) from [<c0347674>] (sock_wfree+0x4c/0x84)
>> r4:ed95ef80 r3:c03cf970
>> [<c0347628>] (sock_wfree) from [<c03cf2b8>] (unix_destruct_scm+0x6c/0x74)
>> r5:00000000 r4:eb9decc0
>> [<c03cf24c>] (unix_destruct_scm) from [<c0348768>] (skb_release_head_state+0x70/0xb0)
>> r4:eb9decc0
>> [<c03486f8>] (skb_release_head_state) from [<c034b280>] (skb_release_all+0x14/0x2c)
>> r4:eb9decc0 r3:00000001
>> [<c034b26c>] (skb_release_all) from [<c034b2ac>] (__kfree_skb+0x14/0x94)
>> r4:eb9decc0 r3:00000001
>> [<c034b298>] (__kfree_skb) from [<c034b610>] (consume_skb+0x58/0x5c)
>> r4:ed95d400 r3:00000001
>> [<c034b5b8>] (consume_skb) from [<c03d050c>] (unix_stream_read_generic+0x5ec/0x750)
>> [<c03cff20>] (unix_stream_read_generic) from [<c03d0754>] (unix_stream_recvmsg+0x50/0x5c)
>> r10:ecc13800 r9:ed9a9e88 r8:bee12988 r7:00000040 r6:ecc13800 r5:ed9a9f4c
>> r4:00001000
>> [<c03d0704>] (unix_stream_recvmsg) from [<c0341250>] (sock_recvmsg+0x18/0x1c)
>> r7:bee1296c r6:00000040 r5:00000000 r4:ed9a9f4c
>> [<c0341238>] (sock_recvmsg) from [<c0342fa0>] (___sys_recvmsg+0x98/0x170)
>> [<c0342f08>] (___sys_recvmsg) from [<c0343d34>] (__sys_recvmsg+0x44/0x68)
>> r10:00000000 r9:ed9a8000 r8:c000f1e4 r7:00000129 r6:bee1296c r5:00000000
>> r4:ecc13800
>> [<c0343cf0>] (__sys_recvmsg) from [<c0343d68>] (SyS_recvmsg+0x10/0x14)
>> r6:b6f7df10 r5:81196c08 r4:bee12988
>> [<c0343d58>] (SyS_recvmsg) from [<c000f020>] (ret_fast_syscall+0x0/0x3c)
