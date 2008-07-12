From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: linux-next: Tree for July 11
Date: Sat, 12 Jul 2008 22:26:09 +0200
Message-ID: <200807122226.10699.rjw@sisk.pl>
References: <20080711182557.9b24df1f.sfr@canb.auug.org.au> <200807122051.50909.rjw@sisk.pl> <19f34abd0807121221n75fd7bb8x24fa484239773201@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Stephen Rothwell" <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, "Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Jens Axboe" <jens.axboe@oracle.com>
To: "Vegard Nossum" <vegard.nossum@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <19f34abd0807121221n75fd7bb8x24fa484239773201@mail.gmail.com>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, 12 of July 2008, Vegard Nossum wrote:
> On Sat, Jul 12, 2008 at 8:51 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > and the second one is the following:
> >
> > WARNING: at /home/rafael/src/linux-next/include/linux/blkdev.h:447 blk_plug_device+0x9b/0xb0()
> > Modules linked in: snd_hda_intel ohci1394 ieee1394 snd_pcm rtc_cmos sr_mod rtc_core floppy snd_timer wmi button cdrom rtc_lib serio_raw sky2 snd_page_alloc snd_hwdep snd evdev joydev sg soundcore raid456 async_xor async_memcpy async_tx xor raid0 usbhid ff_memless ehci_hcd ohci_hcd sd_mod edd raid1 ext3 jbd fan pata_marvell pata_atiixp thermal processor
> > Pid: 2244, comm: kjournald Not tainted 2.6.26-rc9-next #44
> >
> > Call Trace:
> >  [<ffffffff8023d37f>] warn_on_slowpath+0x5f/0x80
> >  [<ffffffff80220030>] ? hpet_unregister_irq_handler+0x0/0x30
> >  [<ffffffff8022a8ae>] ? kmemcheck_mark_initialized+0xe/0x10
> >  [<ffffffff802b97fb>] ? kmemcheck_slab_alloc+0x2b/0x50
> >  [<ffffffff802b8610>] ? kmem_cache_alloc+0xc0/0x140
> >  [<ffffffff80291921>] ? mempool_alloc_slab+0x11/0x20
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff803575db>] blk_plug_device+0x9b/0xb0
> >  [<ffffffff80453d9f>] bitmap_startwrite+0xbf/0x1b0
> >  [<ffffffff802e87e4>] ? bio_alloc_bioset+0x54/0xb0
> >  [<ffffffffa004eafa>] make_request+0x39a/0x810 [raid1]
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff8035682d>] generic_make_request+0x17d/0x2b0
> >  [<ffffffff803581dc>] submit_bio+0x6c/0xf0
> >  [<ffffffff802e3c60>] submit_bh+0xf0/0x130
> >  [<ffffffffa001cce0>] journal_commit_transaction+0xa40/0x1000 [jbd]
> >  [<ffffffff80248504>] ? try_to_del_timer_sync+0x44/0x90
> >  [<ffffffffa0020967>] kjournald+0xe7/0x250 [jbd]
> >  [<ffffffff80254350>] ? autoremove_wake_function+0x0/0x40
> >  [<ffffffffa0020880>] ? kjournald+0x0/0x250 [jbd]
> >  [<ffffffff80253efd>] kthread+0x4d/0x80
> >  [<ffffffff8020c6d9>] child_rip+0xa/0x11
> >  [<ffffffff80500f9b>] ? _spin_unlock_irq+0x2b/0x40
> >  [<ffffffff8020bd0f>] ? restore_args+0x0/0x30
> >  [<ffffffff80254052>] ? kthreadd+0x122/0x1a0
> >  [<ffffffff80253eb0>] ? kthread+0x0/0x80
> >  [<ffffffff8020c6cf>] ? child_rip+0x0/0x11
> 
> Hm, even though there's kmemcheck in the stacktrace, I think it's
> unrelated. Probably it's just a call that returned and the addresses
> were left on the stack. You can also see that the warning clearly
> comes from blkdev.h, and since kmemcheck does *not* call into any
> blkdev stuff, those stacktrace entries must be just left-overs, as is
> also indicated by the unreliable mark, so although those are wrong in
> certain circumstances, I don't think they are in this case.
> 
> The warning comes from here:
> 
> static inline int queue_flag_test_and_set(unsigned int flag,
>                                           struct request_queue *q)
> {
>         WARN_ON_ONCE(!queue_is_locked(q));
> 
> I'll add Jens Axboe to Cc.

Yeah, good idea. :-)

It turns out that this happened before, but I've been overlooking it.  This is
a trace from the Friday's linux-next:

------------[ cut here ]------------
WARNING: at /home/rafael/src/linux-next/include/linux/blkdev.h:447 blk_plug_device+0x9b/0xb0()
Modules linked in: rtc_cmos snd_hda_intel rtc_core snd_pcm sr_mod floppy snd_timer snd_page_alloc rtc_lib ohci1394 serio_raw cdrom ieee1394 snd_hwdep snd soundcore sky2 button wmi joydev evdev sg raid456 async_xor async_memcpy async_tx xor raid0 usbhid ff_memless ehci_hcd sd_mod ohci_hcd edd raid1 ext3 jbd fan pata_marvell pata_atiixp thermal processor
Pid: 2275, comm: kjournald Not tainted 2.6.26-rc9-next #40

Call Trace:
 [<ffffffff8023cf9f>] warn_on_slowpath+0x5f/0x80
 [<ffffffff80220030>] ? hpet_rtc_interrupt+0x100/0x380
 [<ffffffff80263327>] ? __lock_acquire+0x8b7/0x1280
 [<ffffffff80291461>] ? mempool_alloc_slab+0x11/0x20
 [<ffffffff8035735b>] blk_plug_device+0x9b/0xb0
 [<ffffffff8045377f>] bitmap_startwrite+0xbf/0x1b0
 [<ffffffff802e8254>] ? bio_alloc_bioset+0x54/0xb0
 [<ffffffffa004eafa>] make_request+0x39a/0x810 [raid1]
 [<ffffffff802915cb>] ? mempool_alloc+0x5b/0x140
 [<ffffffff802915cb>] ? mempool_alloc+0x5b/0x140
 [<ffffffff803565ad>] generic_make_request+0x17d/0x2b0
 [<ffffffff80357f5c>] submit_bio+0x6c/0xf0
 [<ffffffff802e36d0>] submit_bh+0xf0/0x130
 [<ffffffffa001cce0>] journal_commit_transaction+0xa40/0x1000 [jbd]
 [<ffffffff802480d4>] ? try_to_del_timer_sync+0x44/0x90
 [<ffffffffa0020967>] kjournald+0xe7/0x250 [jbd]
 [<ffffffff80253ef0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0020880>] ? kjournald+0x0/0x250 [jbd]
 [<ffffffff80253a9d>] kthread+0x4d/0x80
 [<ffffffff8020c6b9>] child_rip+0xa/0x11
 [<ffffffff8020bcef>] ? restore_args+0x0/0x30
 [<ffffffff80253a50>] ? kthread+0x0/0x80
 [<ffffffff8020c6af>] ? child_rip+0x0/0x11

---[ end trace bd85cedf792d0f08 ]---

and the full dmesg is here: http://www.sisk.pl/kernel/debug/20080709/dmesg-1.log

Thanks,
Rafael
