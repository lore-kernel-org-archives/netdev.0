From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Fri, 4 Jan 2008 16:21:26 +0100
Message-ID: <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:64345 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbYADPVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 10:21:30 -0500
Received: by py-out-1112.google.com with SMTP id u52so11126274pyb.10
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2008 07:21:27 -0800 (PST)
In-Reply-To: <20080104133031.GA3329@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 4, 2008 2:30 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On 04-01-2008 11:23, Torsten Kaiser wrote:
> > On Jan 2, 2008 10:51 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >> On Wed, Jan 02, 2008 at 07:29:59PM +0100, Torsten Kaiser wrote:
> >>> Vanilla 2.6.24-rc6 seems stable. I did not see any crash or warnings.
> >> OK that's great.  The next step would be to try excluding specific git
> >> trees from mm to see if they make a difference.
> >>
> >> The two specific trees of interest would be git-nfsd and git-net.
> >
> > git-nfsd from git://git.linux-nfs.org/projects/bfields/linux.git#for-mm
> > -> compiling and installing 54 packages worked without crashes.
> >
> > git-net from git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git
> > -> compiling and installing 95 packages worked without crashes.
> ...
> > I will enable CONFIG_IOMMU_DEBUG in -rc6-mm1 and see, as otherwise I
> > have no clue where to look...
>
> Hi,
>
> A few questions/suggestions:

I'm open for any suggestions and will try to answer any questions.
The only thing that is sadly not practical is bisecting the borkenout
mm-patches, as triggering this error is to unreliable /
time-consuming.

> - is it still vanilla -rc6-mm1; I've seen on kernel list you tried
> some fixes around raid?

Yes, without these fixes I can't boot.
But they should only be run during starting the arrays, so I doubt
that this is that cause.
(Also -rc3-mm2 did not need this fix)

My skbuff-double-free-detector is still in there, but was never triggered.

> - could you remind this lockdep warning; is it always and the same,
> always before crash, or no rules?

???
I see no lockdep warning before the crashes.
I have seen a warning about the dst->__refcnt in dst_release and
different warnings about list operations.

I think I have always posted everything I have seen before the
crashes. (captured via serial console)

(If you mean the lockdep-problem in -rc6: That is more or less a
missing annotation during early bootup. The only problem with that is,
that it will causes lockdep to be turned off and so it can not be used
to find any real problem. A fix for that is in -mm so I do have
lockdep on the mm-kernels)

> - I've seen you looked after double freeing, but this last debug list
> warning could suggest locking problems during list modification too.

Yes, but Herbert mentioned double freeing a skb explicit and so I
tried to catch this.
I do not know enough about the network core to verify the locking of
the involved lists.

> - above git-nfsd and git-net tests should be probably repeated with
> -rc6-mm1 git versions: so vanilla rc6 plus both these -mm patches
> only, and if bug triggers, with one reversed; btw., since in previous
> message you mentioned that 50 packages could be not enough to trigger
> this, these 54 above could make too little margin yet.

Yes, I think I really need to redo the git-nfsd-test.
With IOMMU_DEBUG enabled rc6-mm1worked for 52 packages, only a secound
run of kde-packages triggered it after only 5 packages.
I don't know what this bug hates about kdeartwork-wallpaper (triggered
it this time) or kdeartwork-styles.

Output from the crash with IOMMU_DEBUG (lockdep was enabled, but did
not trigger):
[15593.236374] Unable to handle kernel NULL pointer
dereference<3>list_add corruption. prev->next should be next
(ffffffff8078a410), but was ffff81011ec01e68. (prev=ffff81011ec01e68).
[15593.236374]  at 0000000000000000 RIP:
[15593.236374]  [<0000000000000000>]
[15593.236374] PGD 79d22067 PUD 7acd7067 PMD 0
[15593.236374] Oops: 0010 [1] SMP
[15593.236374] last sysfs file:
/sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[15593.236374] CPU 2
[15593.236374] Modules linked in: radeon drm w83792d ipv6 tuner
tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx tea5761
tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
videobuf_core btcx_risc tveeprom videodev usbhid v4l2_common
v4l1_compat sg hid pata_amd i2c_nforce2
[15593.236374] Pid: 510, comm: khpsbpkt Not tainted 2.6.24-rc6-mm1 #15
[15593.236374] RIP: 0010:[<0000000000000000>]  [<0000000000000000>]
[15593.236374] RSP: 0018:ffff81007eed3ee8  EFLAGS: 00010206
[15593.236374] RAX: ffff81007eed3ef0 RBX: ffff81011ec01e40 RCX: ffff81011ec01e40
[15593.236374] RDX: ffff81011ec01e68 RSI: ffff81011ec01e68 RDI: 0000000000000000
[15593.236374] RBP: ffff81007eed3f10 R08: 0000000000000000 R09: 0000000000000001
[15593.236374] R10: 0000000000000001 R11: 0000000000000058 R12: ffff81007eed3ef0
[15593.236374] R13: ffffffff80470e50 R14: 0000000000000000 R15: 0000000000000000
[15593.236374] FS:  00007f76e6c98700(0000) GS:ffff81011ff1f000(0000)
knlGS:00000000556f46c0
[15593.236374] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[15593.236374] CR2: 0000000000000000 CR3: 0000000079d29000 CR4: 00000000000006e0
[15593.236374] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[15593.236374] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[15593.236374] Process khpsbpkt (pid: 510, threadinfo
ffff81007eed2000, task ffff81007eed0000)
[15593.236374] Stack:  ffffffff80470f0b ffff81011ec01e68
ffff81011ec014a8 00000000fffffffc
[15593.236374]  0000000000000000 ffff81007eed3f40 ffffffff8024d72d
00000000000001fb
[15593.236374]  ffff81007ff2bd98 00000000000001fb ffff81007ff2bcf0
ffff81007ff2df40
[15593.236374] Call Trace:
[15593.236374]  [<ffffffff80470f0b>] hpsbpkt_thread+0xbb/0x140
[15593.236374]  [<ffffffff8024d72d>] kthread+0x4d/0x80
[15593.236374]  [<ffffffff8020c4b8>] child_rip+0xa/0x12
[15593.236374]  [<ffffffff8020bbcf>] restore_args+0x0/0x30
[15593.236374]  [<ffffffff8024d6e0>] kthread+0x0/0x80
[15593.236374]  [<ffffffff8020c4ae>] child_rip+0x0/0x12
[15593.236374]
[15593.236374]
[15593.236374] Code:  Bad RIP value.
[15593.236374] RIP  [<0000000000000000>]
[15593.236374]  RSP <ffff81007eed3ee8>
[15593.236374] CR2: 0000000000000000
[15593.236377] ---[ end trace 11d2dc0fdbe1651f ]---
[15627.875963] ------------[ cut here ]------------
[15627.875963] kernel BUG at lib/list_debug.c:33!
[15627.875963] invalid opcode: 0000 [2] SMP
[15627.875963] last sysfs file:
/sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[15627.875963] CPU 3
[15627.875963] Modules linked in: radeon drm w83792d ipv6 tuner
tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx tea5761
tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
videobuf_core btcx_risc tveeprom videodev usbhid v4l2_common
v4l1_compat sg hid pata_amd i2c_nforce2
[15627.875963] Pid: 6258, comm: nxssh Tainted: G      D 2.6.24-rc6-mm1 #15
[15627.875963] RIP: 0010:[<ffffffff803bd954>]  [<ffffffff803bd954>]
__list_add+0x54/0x60
[15627.875963] RSP: 0000:ffff81007ffb3c80  EFLAGS: 00010082
[15627.875963] RAX: 0000000000000079 RBX: 0000000000000082 RCX: 000000000000b9f1
[15627.875963] RDX: 0000000000001514 RSI: 0000000000000001 RDI: ffffffff807641c0
[15627.875963] RBP: ffff81007ffb3c80 R08: 0000000000000001 R09: 0000000000000010
[15627.875963] R10: 0000000000000000 R11: 0000000000000020 R12: ffff81011ec01e40
[15627.875963] R13: ffff81011ec01e68 R14: 0000000000000002 R15: ffff81007eee2000
[15627.875963] FS:  00007f3531da2700(0000) GS:ffff81011ff1f280(0000)
knlGS:00000000556f46c0
[15627.875963] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[15627.875963] CR2: 00007ff643d49fe0 CR3: 0000000079c37000 CR4: 00000000000006e0
[15627.875963] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[15627.875963] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[15627.875963] Process nxssh (pid: 6258, threadinfo ffff810079d50000,
task ffff810079d4e000)
[15627.875963] Stack:  ffff81007ffb3ca0 ffffffff8046f9e8
ffff81011ec01e40 000000000000000c
[15627.875963]  ffff81007ffb3d40 ffffffff8047027c ffff81007ddd8000
ffff81007ddd8048
[15627.875963]  ffff81007ffb3ce0 ffffffff805d4366 ffff81007ddd8000
000000000000000c
[15627.875963] Call Trace:
[15627.875963]  <IRQ>  [<ffffffff8046f9e8>] queue_packet_complete+0x48/0x80
[15627.875963]  [<ffffffff8047027c>] hpsb_packet_received+0x51c/0x6d0
[15627.875963]  [<ffffffff805d4366>] _spin_unlock+0x26/0x30
[15627.875963]  [<ffffffff8047cc3d>] dma_rcv_tasklet+0x22d/0x430
[15627.875963]  [<ffffffff8021273e>] read_hpet+0xe/0x10
[15627.875963]  [<ffffffff805d48f2>] _spin_unlock_irqrestore+0x42/0x60
[15627.875963]  [<ffffffff8023d8b3>] tasklet_action+0x53/0xd0
[15627.875963]  [<ffffffff8023d754>] __do_softirq+0x84/0x110
[15627.875963]  [<ffffffff8020c82c>] call_softirq+0x1c/0x30
[15627.875963]  [<ffffffff8020eaa5>] do_softirq+0x65/0xc0
[15627.875963]  [<ffffffff8023d6c5>] irq_exit+0x95/0xa0
[15627.875963]  [<ffffffff8020ebbf>] do_IRQ+0x8f/0x100
[15627.875963]  [<ffffffff8020bb26>] ret_from_intr+0x0/0xf
[15627.875963]  <EOI>
[15627.875963]
[15627.875963] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16
48 89 e5 e8
[15627.875963] RIP  [<ffffffff803bd954>] __list_add+0x54/0x60
[15627.875963]  RSP <ffff81007ffb3c80>
[15627.875963] ---[ end trace 11d2dc0fdbe1651f ]---
[15627.875963] Kernel panic - not syncing: Aiee, killing interrupt handler!

first oops:
(gdb) list *0xffffffff80470f0b
0xffffffff80470f0b is in hpsbpkt_thread (drivers/ieee1394/ieee1394_core.c:1139).
1134                    INIT_LIST_HEAD(&tmp);
1135                    spin_lock_irq(&pending_packets_lock);
1136                    list_splice_init(&hpsbpkt_queue, &tmp);
1137                    spin_unlock_irq(&pending_packets_lock);
1138
1139                    list_for_each_entry_safe(packet, p, &tmp, queue) {
1140                            list_del_init(&packet->queue);
1141                            packet->complete_routine(packet->complete_data);
1142                    }
1143

second oops:
(gdb) list *0xffffffff8046f9e8
0xffffffff8046f9e8 is in queue_packet_complete
(drivers/ieee1394/ieee1394_core.c:1115).
1110                    return;
1111            }
1112            if (packet->complete_routine != NULL) {
1113                    spin_lock_irqsave(&pending_packets_lock, flags);
1114                    list_add_tail(&packet->queue, &hpsbpkt_queue);
1115                    spin_unlock_irqrestore(&pending_packets_lock, flags);
1116                    wake_up_process(khpsbpkt_thread);
1117            }
1118            return;
1119    }

Torsten
