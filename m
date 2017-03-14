From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 08/29] drivers, md: convert mddev.active from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 23:11:53 +1100
Message-ID: <87lgs8ukfq.fsf@concordia.ellerman.id.au>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com> <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
        linux-bcache@vger.kernel.org, linux-raid@vger.kernel.org,
        linux-media@vger.kernel.org, devel@linuxdriverproject.org,
        linux-pci@vger.kernel.org, linux-s390@vger.kernel.org,
        fcoe-devel@open-fcoe.org, linux-scsi@vger.kernel.org,
        open-iscsi@googlegroups.com, devel@driverdev.osuosl.org,
        target-devel@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-usb@vger.kernel.org, peterz@infradead.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        David Windsor <dwindsor@gmail.com>,
        linuxppc-dev@lists.ozlabs.org
To: Elena Reshetova <elena.reshetova@intel.com>,
        gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:50453 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750829AbdCNMME (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 08:12:04 -0400
In-Reply-To: <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Elena Reshetova <elena.reshetova@intel.com> writes:

> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
>  drivers/md/md.c | 6 +++---
>  drivers/md/md.h | 3 ++-
>  2 files changed, 5 insertions(+), 4 deletions(-)

When booting linux-next (specifically 5be4921c9958ec) I'm seeing the
backtrace below. I suspect this patch is just exposing an existing
issue?

cheers


[    0.230738] md: Waiting for all devices to be available before autodetect
[    0.230742] md: If you don't use raid, use raid=noautodetect
[    0.230962] refcount_t: increment on 0; use-after-free.
[    0.230988] ------------[ cut here ]------------
[    0.230996] WARNING: CPU: 0 PID: 1 at lib/refcount.c:114 .refcount_inc+0x5c/0x70
[    0.231001] Modules linked in:
[    0.231006] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc1-gccN-next-20170310-g5be4921 #1
[    0.231012] task: c000000049400000 task.stack: c000000049440000
[    0.231016] NIP: c0000000005ac6bc LR: c0000000005ac6b8 CTR: c000000000743390
[    0.231021] REGS: c000000049443160 TRAP: 0700   Not tainted  (4.11.0-rc1-gccN-next-20170310-g5be4921)
[    0.231026] MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>
[    0.231033]   CR: 24024422  XER: 0000000c
[    0.231038] CFAR: c000000000a5356c SOFTE: 1 
[    0.231038] GPR00: c0000000005ac6b8 c0000000494433e0 c000000001079d00 000000000000002b 
[    0.231038] GPR04: 0000000000000000 00000000000000ef 0000000000000000 c0000000010418a0 
[    0.231038] GPR08: 000000004af80000 c000000000ecc9a8 c000000000ecc9a8 0000000000000000 
[    0.231038] GPR12: 0000000028024824 c000000006bb0000 0000000000000000 c000000049443a00 
[    0.231038] GPR16: 0000000000000000 c000000049443a10 0000000000000000 0000000000000000 
[    0.231038] GPR20: 0000000000000000 0000000000000000 c000000000f7dd20 0000000000000000 
[    0.231038] GPR24: 00000000014080c0 c0000000012060b8 c000000001206080 0000000000000009 
[    0.231038] GPR28: c000000000f7dde0 0000000000900000 0000000000000000 c0000000461ae800 
[    0.231100] NIP [c0000000005ac6bc] .refcount_inc+0x5c/0x70
[    0.231104] LR [c0000000005ac6b8] .refcount_inc+0x58/0x70
[    0.231108] Call Trace:
[    0.231112] [c0000000494433e0] [c0000000005ac6b8] .refcount_inc+0x58/0x70 (unreliable)
[    0.231120] [c000000049443450] [c00000000086c008] .mddev_find+0x1e8/0x430
[    0.231125] [c000000049443530] [c000000000872b6c] .md_open+0x2c/0x140
[    0.231132] [c0000000494435c0] [c0000000003962a4] .__blkdev_get+0xd4/0x520
[    0.231138] [c000000049443690] [c000000000396cc0] .blkdev_get+0x1c0/0x4f0
[    0.231145] [c000000049443790] [c000000000336d64] .do_dentry_open.isra.1+0x2a4/0x410
[    0.231152] [c000000049443830] [c0000000003523f4] .path_openat+0x624/0x1580
[    0.231157] [c000000049443990] [c000000000354ce4] .do_filp_open+0x84/0x120
[    0.231163] [c000000049443b10] [c000000000338d74] .do_sys_open+0x214/0x300
[    0.231170] [c000000049443be0] [c000000000da69ac] .md_run_setup+0xa0/0xec
[    0.231176] [c000000049443c60] [c000000000da4fbc] .prepare_namespace+0x60/0x240
[    0.231182] [c000000049443ce0] [c000000000da47a8] .kernel_init_freeable+0x330/0x36c
[    0.231190] [c000000049443db0] [c00000000000dc44] .kernel_init+0x24/0x160
[    0.231197] [c000000049443e30] [c00000000000badc] .ret_from_kernel_thread+0x58/0x7c
[    0.231202] Instruction dump:
[    0.231206] 60000000 3d22ffee 89296bfb 2f890000 409effdc 3c62ffc6 39200001 3d42ffee 
[    0.231216] 38630928 992a6bfb 484a6e79 60000000 <0fe00000> 4bffffb8 60000000 60000000 
[    0.231226] ---[ end trace 8c51f269ad91ffc2 ]---
[    0.231233] md: Autodetecting RAID arrays.
[    0.231236] md: autorun ...
[    0.231239] md: ... autorun DONE.
[    0.234188] EXT4-fs (sda4): mounting ext3 file system using the ext4 subsystem
[    0.250506] refcount_t: underflow; use-after-free.
[    0.250531] ------------[ cut here ]------------
[    0.250537] WARNING: CPU: 0 PID: 3 at lib/refcount.c:207 .refcount_dec_not_one+0x104/0x120
[    0.250542] Modules linked in:
[    0.250546] CPU: 0 PID: 3 Comm: kworker/0:0 Tainted: G        W       4.11.0-rc1-gccN-next-20170310-g5be4921 #1
[    0.250553] Workqueue: events .delayed_fput
[    0.250557] task: c000000049404900 task.stack: c000000049448000
[    0.250562] NIP: c0000000005ac964 LR: c0000000005ac960 CTR: c000000000743390
[    0.250567] REGS: c00000004944b530 TRAP: 0700   Tainted: G        W        (4.11.0-rc1-gccN-next-20170310-g5be4921)
[    0.250572] MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>
[    0.250578]   CR: 24002422  XER: 00000007
[    0.250584] CFAR: c000000000a5356c SOFTE: 1 
[    0.250584] GPR00: c0000000005ac960 c00000004944b7b0 c000000001079d00 0000000000000026 
[    0.250584] GPR04: 0000000000000000 0000000000000113 0000000000000000 c0000000010418a0 
[    0.250584] GPR08: 000000004af80000 c000000000ecc9a8 c000000000ecc9a8 0000000000000000 
[    0.250584] GPR12: 0000000022002824 c000000006bb0000 c0000000001116d0 c000000049050200 
[    0.250584] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
[    0.250584] GPR20: 0000000000000001 0000000000000000 c000000048030a98 0000000000000001 
[    0.250584] GPR24: 000000000002001d 0000000000000000 0000000000000000 c0000000461af000 
[    0.250584] GPR28: 0000000000000000 c000000048030bd8 c0000000461aea08 c0000000012060b8 
[    0.250645] NIP [c0000000005ac964] .refcount_dec_not_one+0x104/0x120
[    0.250650] LR [c0000000005ac960] .refcount_dec_not_one+0x100/0x120
[    0.250654] Call Trace:
[    0.250658] [c00000004944b7b0] [c0000000005ac960] .refcount_dec_not_one+0x100/0x120 (unreliable)
[    0.250665] [c00000004944b820] [c0000000005ac9a0] .refcount_dec_and_lock+0x20/0xc0
[    0.250671] [c00000004944b8a0] [c000000000870fa4] .mddev_put+0x34/0x180
[    0.250677] [c00000004944b930] [c000000000396108] .__blkdev_put+0x288/0x350
[    0.250683] [c00000004944ba30] [c0000000003968f0] .blkdev_close+0x30/0x50
[    0.250689] [c00000004944bab0] [c00000000033e7d8] .__fput+0xc8/0x2a0
[    0.250695] [c00000004944bb60] [c00000000033ea08] .delayed_fput+0x58/0x80
[    0.250701] [c00000004944bbe0] [c000000000107ea0] .process_one_work+0x2a0/0x630
[    0.250707] [c00000004944bc80] [c0000000001082c8] .worker_thread+0x98/0x6a0
[    0.250713] [c00000004944bd70] [c000000000111868] .kthread+0x198/0x1a0
[    0.250719] [c00000004944be30] [c00000000000badc] .ret_from_kernel_thread+0x58/0x7c
[    0.250724] Instruction dump:
[    0.250728] 419e000c 38210070 4e800020 7c0802a6 3c62ffc6 39200001 3d42ffee 38630958 
[    0.250738] 992a6bfe f8010080 484a6bd1 60000000 <0fe00000> e8010080 38600001 7c0803a6 
[    0.250748] ---[ end trace 8c51f269ad91ffc3 ]---
[    0.262454] EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
