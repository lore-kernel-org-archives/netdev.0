From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: gpf in p9_client_read
Date: Mon, 8 Aug 2016 13:06:24 +0200
Message-ID: <f32f824c-815c-ef07-5522-59b689cbff6a@suse.cz>
References: <fb62f495-7efa-b470-804d-734d71c3fe68@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42246 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbcHHLGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 07:06:47 -0400
In-Reply-To: <fb62f495-7efa-b470-804d-734d71c3fe68@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With merge window gone, ping?

On 07/27/2016 11:21 AM, Vlastimil Babka wrote:
> Hi,
> 
> I was fuzzing with trinity in qemu via the virtme script, i.e. using 
> these opts:
> 
> virtme-run --kdir /home/vbabka/wrk/linus.git --rwdir 
> /home/vbabka/tmp/trinity/ --dry-run --show-command --qemu-opts --smp 8 
> -drive file=/home/vbabka/tmp/trinity.img,if=ide,format=raw,media=disk
> /usr/bin/qemu-system-x86_64 -fsdev 
> local,id=virtfs1,path=/,security_model=none,readonly -device 
> virtio-9p-pci,fsdev=virtfs1,mount_tag=/dev/root -fsdev 
> local,id=virtfs5,path=/usr/local/share/virtme-guest-0,security_model=none,readonly 
> -device virtio-9p-pci,fsdev=virtfs5,mount_tag=virtme.guesttools -fsdev 
> local,id=virtfs9,path=/home/vbabka/tmp/trinity/,security_model=none 
> -device virtio-9p-pci,fsdev=virtfs9,mount_tag=virtme.initmount0 -machine 
> accel=kvm:tcg -watchdog i6300esb -cpu host -parallel none -net none 
> -echr 1 -serial none -chardev stdio,id=console,signal=off,mux=on -serial 
> chardev:console -mon chardev=console -vga none -display none -kernel 
> /home/vbabka/wrk/linus.git/arch/x86/boot/bzImage -append 
> 'virtme_initmount0=home/vbabka/tmp/trinity 
> earlyprintk=serial,ttyS0,115200 console=ttyS0 psmouse.proto=exps 
> "virtme_stty_con=rows 53 cols 189 iutf8" TERM=xterm rootfstype=9p 
> rootflags=version=9p2000.L,trans=virtio,access=any raid=noautodetect ro 
> init=/bin/sh -- -c "mount -t tmpfs run /run;mkdir -p 
> /run/virtme/guesttools;/bin/mount -n -t 9p -o 
> ro,version=9p2000.L,trans=virtio,access=any virtme.guesttools 
> /run/virtme/guesttools;exec /run/virtme/guesttools/virtme-init"' --smp 8 
> -drive file=/home/vbabka/tmp/trinity.img,if=ide,format=raw,media=disk
> 
> So the fuzzer's working directory is on ext4 created on disk backed by 
> trinity.img, but the rest is provided from host via virtio-9p, as virtme 
> does.
> 
> Very deterministically after few minutes of fuzzing, I get OOMs followed 
> by this:
> 
> general protection fault: 0000 [#1] SMP
> CPU: 2 PID: 17712 Comm: trinity-c10 Not tainted 4.7.0 #45
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
> rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
> 0[m )  178.898319] task: ffff880003a67000 ti: ffff880001984000 task.ti: 
> ffff880001984000
> RIP: 0010:[<ffffffff818eb530>]  [<ffffffff818eb530>] 
> p9_client_read+0x70/0x270
> RSP: 0000:ffff880001987c48  EFLAGS: 00010246
> RAX: 559b48bf06527000 RBX: 0000000000001000 RCX: ffff880001987cdc
> RDX: 0000000000001000 RSI: 000000000000c000 RDI: ffff880005e6b7c0
> RBP: ffff880001987cc8 R08: 0000000000001000 R09: 0000000000000020
> R10: ffff880001987cd0 R11: 0000000000000040 R12: ffff880005e6b780
> R13: 000000000000c000 R14: ffff880005e6b240 R15: 00000000024201ca
> FS:  00007fcdb1a74700(0000) GS:ffff880007c80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000000040c840 CR3: 00000000019fb000 CR4: 00000000001406e0
> DR0: 00007fcdb09b3000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000050602
> Stack:
>   ffff880001987c90 ffffffff81130f6f ffff880001987c58 ffff880001987c58
>   ffff880007c91840 ffff880005e6b7c0 ffff880001987cdc ffffea0000000000
>   ffff880001987cf0 0000100001987ce8 ffffffff81131621 ffffea000010abc0
> Call Trace:
>   [<ffffffff812afab3>] v9fs_fid_readpage+0x73/0x180 fs/9p/vfs_addr.c:69
>   [<ffffffff812afbd0>] v9fs_vfs_readpage+0x10/0x20 fs/9p/vfs_addr.c:98
>   [<     inline     >] page_cache_read mm/filemap.c:1908
>   [<ffffffff81124ec5>] filemap_fault+0x335/0x4b0 mm/filemap.c:2087
>   [<ffffffff8114cf91>] __do_fault+0x61/0xe0 mm/memory.c:2839
>   [<     inline     >] do_read_fault mm/memory.c:3030
>   [<     inline     >] do_fault mm/memory.c:3189
>   [<     inline     >] handle_pte_fault mm/memory.c:3364
>   [<     inline     >] __handle_mm_fault mm/memory.c:3488
>   [<ffffffff81150151>] handle_mm_fault+0xd41/0x13d0 mm/memory.c:3517
>   [<ffffffff8104b591>] __do_page_fault+0x1c1/0x490 arch/x86/mm/fault.c:1356
>   [<ffffffff8104b86c>] do_page_fault+0xc/0x10 arch/x86/mm/fault.c:1419
>   [<ffffffff818f9942>] page_fault+0x22/0x30 arch/x86/entry/entry_64.S:920
> Code: 89 c2 89 45 cc 41 8b 5e 20 41 8b 44 24 04 83 e8 18 85 db 0f 84 f8 
> 00 00 00 39 c3 0f 87 f0 00 00 00 49 8b 44 24 10 39 d3 0f 4f da <48> 83 
> 78 50 00 74 0c 81 fb 00 04 00 00 0f 8f ef 00 00 00 41 8b
> RIP  [<ffffffff818eb530>] p9_client_read+0x70/0x270 net/9p/client.c:1562
>   RSP <ffff880001987c48>
> ---[ end trace 0192b39ea4ee4e9b ]---
> Kernel panic - not syncing: Fatal exception
> Kernel Offset: disabled
> ---[ end Kernel panic - not syncing: Fatal exception
> 
> All code
> ========
>     0:   89 c2                   mov    %eax,%edx
>     2:   89 45 cc                mov    %eax,-0x34(%rbp)
>     5:   41 8b 5e 20             mov    0x20(%r14),%ebx
>     9:   41 8b 44 24 04          mov    0x4(%r12),%eax
>     e:   83 e8 18                sub    $0x18,%eax
>    11:   85 db                   test   %ebx,%ebx
>    13:   0f 84 f8 00 00 00       je     0x111
>    19:   39 c3                   cmp    %eax,%ebx
>    1b:   0f 87 f0 00 00 00       ja     0x111
>    21:   49 8b 44 24 10          mov    0x10(%r12),%rax
>    26:   39 d3                   cmp    %edx,%ebx
>    28:   0f 4f da                cmovg  %edx,%ebx
>    2b:*  48 83 78 50 00          cmpq   $0x0,0x50(%rax)          <-- 
> trapping instruction
>    30:   74 0c                   je     0x3e
>    32:   81 fb 00 04 00 00       cmp    $0x400,%ebx
>    38:   0f 8f ef 00 00 00       jg     0x12d
>    3e:   41                      rex.B
>    3f:   8b                      .byte 0x8b
> 
> the line in question is:
> 
>           if (clnt->trans_mod->zc_request && rsize > 1024)
> 
> trans_mod is in rax which is 559b48bf06527000, e.g. clearly bogus
> clnt is in r12 which is ffff880005e6b780, I guess either it's wrong 
> pointer (use-after-free?), or something overwrote the struct?
> 
> Thanks,
> Vlastimil
> 
