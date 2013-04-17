From: Dave Jones <davej@redhat.com>
Subject: Re: oops in udpv6_sendmsg
Date: Tue, 16 Apr 2013 21:02:13 -0400
Message-ID: <20130417010213.GA9027@redhat.com>
References: <20130329184006.GA23893@redhat.com>
 <1364582958.5113.49.camel@edumazet-glaptop>
 <1364865839.5113.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756079Ab3DQBCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 21:02:16 -0400
Content-Disposition: inline
In-Reply-To: <1364865839.5113.165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 01, 2013 at 06:23:59PM -0700, Eric Dumazet wrote:
 > On Fri, 2013-03-29 at 11:49 -0700, Eric Dumazet wrote:
 > > On Fri, 2013-03-29 at 14:40 -0400, Dave Jones wrote:
 > > > Just hit this on Linus' current tree.
 > > > 
 > > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000031
 > > > IP: [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
 > > > 
 > > > Looks like the last line of an inlined __ip6_dst_store() call. So line 1243 of net/ipv6/udp.c
 > > > 
 > > > 	Dave
 > > 
 > > Yes, I had the same problem on my lab machine yesterday and was working
 > > on it (Using a linux-3.3.8 code base)
 > > 
 > > In my case, the invalid rt6i_node value was 0x66b579de
 > 
 > I am mystified by this problem, I could not reproduce it...

Still chasing this. It mutated a little..

general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: dlci fuse vmw_vsock_vmci_transport vmw_vmci vsock tun rfcomm cmtp kernelcapi bnep hidp l2tp_ppp l2tp_netlink l2tp_core scsi_transport_iscsi ipt_ULOG can_bcm nfc rds can_raw irda rose caif_socket atm llc2 can caif x25 ipx nfnetlink p8023 p8022 netrom appletalk phonet af_key af_rxrpc af_802154 pppoe crc_ccitt decnet psnap ax25 pppox llc ppp_generic slhc dccp_ipv6 dccp_ipv4 dccp sctp libcrc32c lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables snd_hda_codec_realtek kvm_amd snd_hda_intel raid0 kvm snd_hda_codec snd_pcm btusb bluetooth microcode serio_raw edac_core pcspkr snd_page_alloc snd_timer snd rfkill soundcore r8169 mii radeon backlight drm_kms_helper ttm
CPU 0 
Pid: 483153, comm: trinity-child0 Not tainted 3.9.0-rc7+ #24 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
RIP: 0010:[<ffffffff8164d45f>]  [<ffffffff8164d45f>] ip6_append_data+0x4ff/0xeb0
RSP: 0018:ffff88010cc1b9b8  EFLAGS: 00010286
RAX: 7ae9fffffff2b8ff RBX: 0000000000000000 RCX: ffff88010cc1ba28
RDX: 00000000000000d0 RSI: 0000000000000048 RDI: ffff88010238f000
RBP: ffff88010cc1ba60 R08: 0000000000000030 R09: 0000000000000008
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000008
R13: 0000000000000008 R14: ffff88010238f000 R15: 0000000000000008
FS:  00007fc506daa740(0000) GS:ffff88012a600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc505adc000 CR3: 0000000104a3f000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child0 (pid: 483153, threadinfo ffff88010cc1a000, task ffff88010479a490)
Stack:
 0000000000000002 0000000000000000 000000200479a490 0000003000000010
 ffff880100000000 ffff88010238f2a0 0000002800000008 ffffffff00000000
 ffff88010cc1bdb0 ffffffff815c90e0 ffff880100000008 000000000000fff0
Call Trace:
 [<ffffffff815c90e0>] ? ip_reply_glue_bits+0x60/0x60
 [<ffffffff8166cfa8>] udpv6_sendmsg+0x278/0xa90
 [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
 [<ffffffff810b3358>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff8160798c>] inet_sendmsg+0x10c/0x220
 [<ffffffff81607885>] ? inet_sendmsg+0x5/0x220
 [<ffffffff81567d67>] sock_sendmsg+0xb7/0xe0
 [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
 [<ffffffff810b3472>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b3b9e>] ? put_lock_stats.isra.27+0xe/0x40
 [<ffffffff810b419c>] ? lock_release_holdtime.part.28+0x9c/0x150
 [<ffffffff815784b6>] ? verify_iovec+0x56/0xd0
 [<ffffffff81568a7e>] __sys_sendmsg+0x3ae/0x3c0
 [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
 [<ffffffff810b3472>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b3b9e>] ? put_lock_stats.isra.27+0xe/0x40
 [<ffffffff810b41e5>] ? lock_release_holdtime.part.28+0xe5/0x150
 [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
 [<ffffffff810b3358>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff8156abb9>] sys_sendmsg+0x49/0x90
 [<ffffffff816cdfc2>] system_call_fastpath+0x16/0x1b
Code: 89 83 d4 00 00 00 c7 45 c8 f2 ff ff ff 48 8b 45 28 45 29 be 7c 05 00 00 48 8b 80 48 01 00 00 48 85 c0 74 0c 48 8b 80 18 03 00 00 <65> 48 ff 40 70 49 8b 46 30 48 8b 80 b0 01 00 00 65 48 ff 40 70 
RIP  [<ffffffff8164d45f>] ip6_append_data+0x4ff/0xeb0
 RSP <ffff88010cc1b9b8>
---[ end trace ad33312480976359 ]---

Disassembly looks like..

    1924:       89 83 d4 00 00 00       mov    %eax,0xd4(%rbx)
        }

        return 0;

error_efault:
        err = -EFAULT;
    192a:       c7 45 c8 f2 ff ff ff    movl   $0xfffffff2,-0x38(%rbp)
error:
        cork->length -= length;
        IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
    1931:       48 8b 45 28             mov    0x28(%rbp),%rax
        return 0;

error_efault:
        err = -EFAULT;
error:
        cork->length -= length;
    1935:       45 29 be 7c 05 00 00    sub    %r15d,0x57c(%r14)
        IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
    193c:       48 8b 80 48 01 00 00    mov    0x148(%rax),%rax
    1943:       48 85 c0                test   %rax,%rax
    1946:       74 0c                   je     1954 <ip6_append_data+0x504>
    1948:       48 8b 80 18 03 00 00    mov    0x318(%rax),%rax
->    194f:       65 48 ff 40 70          incq   %gs:0x70(%rax)
    1954:       49 8b 46 30             mov    0x30(%r14),%rax
    1958:       48 8b 80 b0 01 00 00    mov    0x1b0(%rax),%rax
    195f:       65 48 ff 40 70          incq   %gs:0x70(%rax)
        return err;



rax is all kinds of crazy. 7ae9fffffff2b8ff doesn't look anything like an address.

	Dave
