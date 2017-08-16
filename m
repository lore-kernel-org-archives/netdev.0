From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] tap: use build_skb() for small packet
Date: Tue, 15 Aug 2017 20:45:20 -0700
Message-ID: <1502855120.4936.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
         <1502451678-17358-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502451678-17358-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-08-11 at 19:41 +0800, Jason Wang wrote:
> We use tun_alloc_skb() which calls sock_alloc_send_pskb() to allocate
> skb in the past. This socket based method is not suitable for high
> speed userspace like virtualization which usually:
> 
> - ignore sk_sndbuf (INT_MAX) and expect to receive the packet as fast as
>   possible
> - don't want to be block at sendmsg()
> 
> To eliminate the above overheads, this patch tries to use build_skb()
> for small packet. We will do this only when the following conditions
> are all met:
> 
> - TAP instead of TUN
> - sk_sndbuf is INT_MAX
> - caller don't want to be blocked
> - zerocopy is not used
> - packet size is smaller enough to use build_skb()
> 
> Pktgen from guest to host shows ~11% improvement for rx pps of tap:
> 
> Before: ~1.70Mpps
> After : ~1.88Mpps
> 
> What's more important, this makes it possible to implement XDP for tap
> before creating skbs.


Well well well.

You do realize that tun_build_skb() is not thread safe ?

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 3982 Comm: syz-executor0 Not tainted 4.13.0-rc5-next-20170815+ #3
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880069f265c0 task.stack: ffff880067688000
RIP: 0010:__read_once_size include/linux/compiler.h:276 [inline]
RIP: 0010:compound_head include/linux/page-flags.h:146 [inline]
RIP: 0010:put_page include/linux/mm.h:811 [inline]
RIP: 0010:__skb_frag_unref include/linux/skbuff.h:2743 [inline]
RIP: 0010:skb_release_data+0x26c/0x790 net/core/skbuff.c:568
RSP: 0018:ffff88006768ef20 EFLAGS: 00010206
RAX: 00d70cb5b39acdeb RBX: dffffc0000000000 RCX: 1ffff1000ced1e13
RDX: 0000000000000000 RSI: ffff88003ec28c38 RDI: 06b865ad9cd66f59
RBP: ffff88006768f040 R08: ffffea0000ee74a0 R09: ffffed0007ab4200
R10: 0000000000028c28 R11: 0000000000000010 R12: ffff88003c5581b0
R13: ffffed000ced1dfb R14: 1ffff1000ced1df3 R15: 06b865ad9cd66f39
FS:  00007ffbc9ef7700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000002001aff0 CR3: 000000003d623000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 skb_release_all+0x4a/0x60 net/core/skbuff.c:631
 __kfree_skb net/core/skbuff.c:645 [inline]
 kfree_skb+0x15d/0x4c0 net/core/skbuff.c:663
 __netif_receive_skb_core+0x10f8/0x33d0 net/core/dev.c:4425
 __netif_receive_skb+0x2c/0x1b0 net/core/dev.c:4456
 netif_receive_skb_internal+0x10b/0x5e0 net/core/dev.c:4527
 netif_receive_skb+0xae/0x390 net/core/dev.c:4551
 tun_rx_batched.isra.43+0x5e7/0x860 drivers/net/tun.c:1221
 tun_get_user+0x11dd/0x2150 drivers/net/tun.c:1542
 tun_chr_write_iter+0xd8/0x190 drivers/net/tun.c:1568
 call_write_iter include/linux/fs.h:1742 [inline]
 new_sync_write fs/read_write.c:457 [inline]
 __vfs_write+0x684/0x970 fs/read_write.c:470
 vfs_write+0x189/0x510 fs/read_write.c:518
 SYSC_write fs/read_write.c:565 [inline]
 SyS_write+0xef/0x220 fs/read_write.c:557
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x40bab1
RSP: 002b:00007ffbc9ef6c00 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000036 RCX: 000000000040bab1
RDX: 0000000000000036 RSI: 0000000020002000 RDI: 0000000000000003
RBP: 0000000000a5f870 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000000
R13: 0000000000000000 R14: 00007ffbc9ef79c0 R15: 00007ffbc9ef7700
Code: c6 e8 c9 78 8d fd 4c 89 e0 48 c1 e8 03 80 3c 18 00 0f 85 93 04 00 00 4d 8b 3c 24 41 c6 45 00 00 49 8d 7f 20 48 89 f8 48 c1 e8 03 <80> 3c 18 00 0f 85 6b 04 00 00 41 80 7d 00 00 49 8b 47 20 0f 85 
RIP: __read_once_size include/linux/compiler.h:276 [inline] RSP: ffff88006768ef20
RIP: compound_head include/linux/page-flags.h:146 [inline] RSP: ffff88006768ef20
RIP: put_page include/linux/mm.h:811 [inline] RSP: ffff88006768ef20
RIP: __skb_frag_unref include/linux/skbuff.h:2743 [inline] RSP: ffff88006768ef20
RIP: skb_release_data+0x26c/0x790 net/core/skbuff.c:568 RSP: ffff88006768ef20
---[ end trace 54050eb1ec52ff83 ]---
