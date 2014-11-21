From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 08:31:09 -0800
Message-ID: <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:54391 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084AbaKUQbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:31:12 -0500
Received: by mail-ig0-f171.google.com with SMTP id uq10so6866832igb.10
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 08:31:11 -0800 (PST)
In-Reply-To: <20141121160937.GA32608@ret.masoncoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 11:16 -0500, Chris Mason wrote:
> Hi everyone,
> 
> I've hit this a few times today while hammering on my btrfs queue for
> the next merge window.  It's plain v3.18-rc5 plus a few btrfs patches,
> so it isn't impossible a btrfs double free is causing trouble.
> 
> But, that should also show up in places outside the networking stack and I've
> gotten this exact stack trace twice now:
> 
> [ 2255.152925] BUG: unable to handle kernel paging request at ffff880fa1f91f96
> [ 2255.185251]  [<ffffffff81595f68>] __kfree_skb+0x58/0xc0
> [ 2255.196223] PGD 2be4067 PUD 10783cb067 PMD 10782bb067 PTE 8000000fa1f91060
> [ 2255.210163] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> [ 2255.219394] Modules linked in: btrfs raid6_pq zlib_deflate lzo_compress xor xfs exportfs libcrc32c nfsv4 fuse k10temp coretemp hwmon tcp_diag inet_diag loop ip6table_filter ip6_tables xt_NFLOG nfnetlink_log nfnetlink xt_comment xt_statistic iptable_filter ip_tables x_tables nfsv3 nfs lockd grace mptctl netconsole autofs4 rpcsec_gss_krb5 auth_rpcgss oid_registry sunrpc ipv6 ext3 jbd dm_mod iTCO_wdt iTCO_vendor_support rtc_cmos ipmi_si ipmi_msghandler pcspkr i2c_i801 lpc_ich mfd_core shpchp ehci_pci ehci_hcd mlx4_en ptp pps_core mlx4_core ses enclosure sg button megaraid_sas
> [ 2255.323468] CPU: 14 PID: 8517 Comm: scribe-event Not tainted 3.18.0-rc5-mason+ #62
> [ 2255.338754] Hardware name: ZTSYSTEMS Echo Ridge T4  /A9DRPF-10D, BIOS 1.07 05/10/2012
> [ 2255.354557] task: ffff881018b61d10 ti: ffff880ff6ae4000 task.ti: ffff880ff6ae4000
> [ 2255.369680] RIP: 0010:[<ffffffff81595f68>]  [<ffffffff81595f68>] __kfree_skb+0x58/0xc0
> [ 2255.385709] RSP: 0018:ffff880ff6ae7b98  EFLAGS: 00010202
> [ 2255.396398] RAX: 0000000000000002 RBX: ffff880fa1f91f18 RCX: ffffffff81cd5d80
> [ 2255.410728] RDX: 00000000ffffffff RSI: ffff880fa1f91e40 RDI: ffff880fa1f91f18
> [ 2255.425062] RBP: ffff880ff6ae7ba8 R08: 000000000000001b R09: 0000000000000000
> [ 2255.439379] R10: ffff8810385ef640 R11: ffff8810385ef758 R12: 0000000000000000
> [ 2255.453702] R13: ffff880fa1f91f40 R14: 0000000000000000 R15: ffff8810385efd4c
> [ 2255.468024] FS:  00007ff18ebff700(0000) GS:ffff881077cc0000(0000) knlGS:0000000000000000
> [ 2255.484321] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 2255.495864] CR2: ffff880fa1f91f96 CR3: 0000000850174000 CR4: 00000000000407e0
> [ 2255.510188] Stack:
> [ 2255.514279]  0000000000000000 ffff880fa1f91f18 ffff880ff6ae7ca8 ffffffff815f27aa
> [ 2255.529306]  ffff881018b61d10 0000000000000001 000000000000001b ffff8810385ef640
> [ 2255.544337]  ffff8810385ef758 ffff8810385ef7a8 ffff881018b61d10 0000000000000000
> [ 2255.559369] Call Trace:
> [ 2255.564332]  [<ffffffff815f27aa>] tcp_recvmsg+0xa2a/0xd10
> [ 2255.575198]  [<ffffffff8161dcb1>] inet_recvmsg+0xe1/0x110
> [ 2255.586056]  [<ffffffff8158c573>] sock_recvmsg+0xa3/0xd0
> [ 2255.596740]  [<ffffffff811c9e65>] ? __fget_light+0x25/0x60
> [ 2255.607768]  [<ffffffff8158c664>] SYSC_recvfrom+0xc4/0x130
> [ 2255.618801]  [<ffffffff810e987c>] ? __audit_syscall_entry+0xac/0x110
> [ 2255.631566]  [<ffffffff810b6635>] ? current_kernel_time+0x95/0xb0
> [ 2255.643826]  [<ffffffff8109537d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
> [ 2255.657122]  [<ffffffff8158c6de>] SyS_recvfrom+0xe/0x10
> [ 2255.667632]  [<ffffffff81670b92>] system_call_fastpath+0x12/0x17
> [ 2255.679699] Code: 0f 48 89 de 48 8b 3d 58 08 76 00 e8 33 a6 bf ff 48 83 c4 08 5b c9 c3 0f 1f 40 00 48 8d b3 28 ff ff ff f0 ff 8e b0 01 00 00 74 48 <80> 4b 7e 0c 48 83 c4 08 5b c9 c3 0f 1f 44 00 00 f0 ff 8b b0 01 
> [ 2255.719771] RIP  [<ffffffff81595f68>] __kfree_skb+0x58/0xc0
> [ 2255.731019]  RSP <ffff880ff6ae7b98>
> [ 2255.738081] CR2: ffff880fa1f91f96
> [ 2255.745371] ---[ end trace 982fb6dd92d9b65b ]---
> 
> Which translates to:
> 
> 0xffffffff81595f68 is in __kfree_skb (net/core/skbuff.c:567).
> 562				kmem_cache_free(skbuff_fclone_cache, fclones);
> 563			} else {
> 564				/* The clone portion is available for
> 565				 * fast-cloning again.
> 566				 */
> 567				skb->fclone = SKB_FCLONE_FREE;
> 568			}
> 569			break;
> 570		}
> 571	}
> 
> Just looking for related code in the changelog, this one might be
> related:
> 
> commit c8753d55afb436fd6a25c8bbe8d783f6dcf1c9f8
> Author: Vijay Subramanian <subramanian.vijay@gmail.com>
> Date:   Thu Oct 2 10:00:43 2014 -0700
> 
>     net: Cleanup skb cloning by adding SKB_FCLONE_FREE
> 
> I'm not hitting this consistently enough for a revert or a bisect to
> prove anything.

Hi Chris

Can you double check, or send whole __kfree_skb() disassembly ?

I do not understand how skb->fclone could possibly trap _at_ this point.
