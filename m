From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: Current Git: BUG: unable to handle kernel paging request at 0000000001a40ca0
Date: Wed, 23 Jul 2008 19:46:12 +0200
Message-ID: <19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com>
References: <488750AA.20707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, "Pekka Enberg" <penberg@cs.helsinki.fi>
To: "Dieter Ries" <clip2@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:40419 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbYGWRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 13:46:14 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1090579ywe.1
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 10:46:12 -0700 (PDT)
In-Reply-To: <488750AA.20707@gmx.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2008 at 5:39 PM, Dieter Ries <clip2@gmx.de> wrote:
> Hi,
>
> I just encountered a Bug in latest git:
>
> As this is my first bugreport, I am not sure who to cc and which information
> to provide, so please advise me. Some information is below.

Hi,

Thanks for the report!

> BUG: unable to handle kernel paging request at 0000000001a40ca0
> IP: [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
> PGD 79d33067 PUD 79cf7067 PMD 0
> Oops: 0000 [1] SMP
> CPU 0
> Modules linked in: radeon drm uinput snd_hda_intel iwl3945 snd_pcm snd_timer
> rfkill snd led_class snd_page_alloc
> Pid: 3516, comm: ifconfig Not tainted 2.6.26-06077-gc010b2f #23
> RIP: 0010:[<ffffffff80290632>]  [<ffffffff80290632>]
> kmem_cache_alloc+0x50/0x81
> RSP: 0000:ffff880079d079e8  EFLAGS: 00010006
> RAX: 0000000000000000 RBX: 0000000000000296 RCX: ffffffff802704ae
> RDX: ffff880001016700 RSI: 0000000001a40ca0 RDI: ffffffff808b5fa0
> RBP: ffff880079d07a08 R08: 000000000000000c R09: 0000000000000001

[snip]

> Code: 98 48 8b 94 c7 e0 00 00 00 48 8b 32 44 8b 6a 18 48 85 f6 75 13 49 89
> d0 44 89 e6 83 ca ff e8 b3 f8 ff ff 48 89 c6 eb 0a 8b 42 14 <48> 8b 04 c6 48
> 89 02 53 9d 31 c0 41 c1 ec 0f 48 85 f6 0f 95 c0

The code decodes to:

    mov    0x14(%rdx),%eax
    mov    (%rsi,%rax,8),%rax <--- HERE!

which corresponds to this code in mm/slub.c:

                c->freelist = object[c->offset];

So the mov 0x14(%rdx) is the loading of c->offset, which means that
the pointer "c" is held in %rdx (= 0xffff880001016700), and the
variable c->offset is held in %eax (= 0).

It also means that the pointer "object" is held in %rsi (= 0x1a40ca0).
Now, clearly the object pointer is bogus. It was loaded on the line
above:

                object = c->freelist;

..and it may look like c->freelist has become corrupted. This one is
again loaded from the line:

        c = get_cpu_slab(s, smp_processor_id());

Everything seems normal, except the c->freelist pointer.

The rest of the messages are from the same function, but from
different code paths:

>  [<ffffffff802704ae>] mempool_alloc_slab+0x16/0x18
>  [<ffffffff802705c2>] mempool_alloc+0x3e/0xfa
>  [<ffffffff802b8db7>] bio_alloc_bioset+0x27/0x94
>  [<ffffffff802b8e7e>] bio_alloc+0x15/0x24
>  [<ffffffff802b4ebb>] submit_bh+0x78/0x119
>  [<ffffffff803129dc>] journal_commit_transaction+0x76d/0xccd
>  [<ffffffff8031596b>] kjournald+0xc8/0x200
>  [<ffffffff80247e6a>] kthread+0x4e/0x7c
>  [<ffffffff8020c289>] child_rip+0xa/0x11

and

>  [<ffffffff804c6b64>] scsi_pool_alloc_command+0x4d/0x73
>  [<ffffffff804c6c72>] __scsi_get_command+0x1e/0x9c
>  [<ffffffff804c6d26>] scsi_get_command+0x36/0xa5
>  [<ffffffff804cb1e8>] scsi_get_cmd_from_req+0x2a/0x5e
>  [<ffffffff804cb5ec>] scsi_setup_fs_cmnd+0x5d/0x87
>  [<ffffffff804ebc53>] sd_prep_fn+0x66/0x449
>  [<ffffffff803ebed1>] elv_next_request+0xe3/0x1a4
>  [<ffffffff804cc490>] scsi_request_fn+0x80/0x334
>  [<ffffffff803edaee>] __generic_unplug_device+0x29/0x2e
>  [<ffffffff803ee5de>] generic_unplug_device+0x2e/0x3c
>  [<ffffffff803ec5e8>] blk_unplug_work+0x19/0x1b
>  [<ffffffff80244890>] run_workqueue+0x81/0x10a
>  [<ffffffff8024529d>] worker_thread+0xdd/0xea
>  [<ffffffff80247e6a>] kthread+0x4e/0x7c
>  [<ffffffff8020c289>] child_rip+0xa/0x11

...this seems to suggest that none of the backtraces may actually give
a good clue as to who caused the corruption to begin with. (In other
words, I have no more clue than you on who to Cc this.)

Does the number 0x1a40ca0 look familiar to anybody?

Dieter: If this is reproducible, it would probably help quite a bit to
configure the kernel with CONFIG_SLUB_DEBUG and boot with
slub_debug=FZPUT (unless you already have CONFIG_SLUB_DEBUG_ON set, in
which case you are already running with the SLUB debugging at boot).
It might catch the corruption before it becomes fatal, or give us some
more clues anyway.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
