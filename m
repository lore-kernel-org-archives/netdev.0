From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sat, 29 Dec 2007 21:41:17 -0800
Message-ID: <20071229214117.3797d9c2.randy.dunlap@oracle.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	<64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	<64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	<20071228150746.42b3bbc0.akpm@linux-foundation.org>
	<64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	<20071230013021.GA13603@gondor.apana.org.au>
	<64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21832 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbXL3Foo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 00:44:44 -0500
In-Reply-To: <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Dec 2007 04:34:36 +0100 Torsten Kaiser wrote:

> On Dec 30, 2007 2:30 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Sat, Dec 29, 2007 at 05:51:13PM +0100, Torsten Kaiser wrote:
> > >
> > > > > The cause, why I am resending this: I just got a crash with
> > > > > 2.6.24-rc6-mm1, again looking network related:
> > > > >
> > > > > [93436.933356] WARNING: at include/net/dst.h:165 dst_release()
> > > > > [93436.936685] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> > > > > [93436.939292]
> > > > > [93436.939293] Call Trace:
> > > > > [93436.939304]  [<ffffffff80531d2d>] skb_release_all+0xdd/0x110
> > > > > [93436.939307]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> > > > > [93436.939309]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> > > > > [93436.939312]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> > > > > [93436.939315]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> > > > > [93436.939318]  [<ffffffff8052b144>] sock_release+0x24/0x90
> > > > > [93436.939320]  [<ffffffff8052b656>] sock_close+0x26/0x50
> > > > > [93436.939324]  [<ffffffff8029f921>] __fput+0xc1/0x230
> > > > > [93436.939327]  [<ffffffff8029fe46>] fput+0x16/0x20
> > > > > [93436.939329]  [<ffffffff8029c576>] filp_close+0x56/0x90
> > > > > [93436.939331]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> > > > > [93436.939335]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> > >
> > > >From code inspection I would blame the patch "[SKBUFF]: Free old skb
> > > properly in skb_morph" from Herbert Xu. (CC added)
> >
> > I doubt it.  skb_morph is only used on IP fragments so I don't see how
> > you could attribute an error from a Unix domain socket to this patch.
> 
> That's why I wrote that I do not know much about the network core...
> 
> > In any case, Unix socket packets should not have a dst at all so the
> > very fact that you're in that path means that you have some sort of
> > memory corruption.
> 
> ... I did not know about the fact that there should not have been an dst.
> 
> Its just that this warning was the first nice clue about the memory
> corruption related to networking that I see since 2.6.24-rc3-mm2.
> The time of the patch (Mon, 26 Nov 2007 15:11:19) even fits into the
> window between -rc3-mm1 and -rc3-mm2.
> 
> I doubt that the memory corruption is a hardware problem, because the
> system in question is using ECC ram and I did not see any messages
> about corrected/detected errors.
> 
> > Is this the very first OOPS/warning that you see? If not you should
> > ignore all but the very first one as that may have left your system
> > in an inconsistent state which may render all subsequent OOPSes and
> > warnings useless.
> 
> I looked into the log in question and the only other warning was a
> circular locking dependency that lockdep detected around 1.5 hour
> before this warning.
> 
> As reported in my original mail immeadeatly after the warning the
> system OOPSed and hang:
> [93436.947241] general protection fault: 0000 [1] SMP
> -> first OOPS                                  ^
	FYI, that's what this counter is... -----^

> [93436.947243] last sysfs file:
> /sys/devices/pci0000:00/0000:00:0f.0/0000:01:00.1/irq
> [93436.947245] CPU 1
> [93436.947246] Modules linked in: radeon drm nfsd exportfs w83792d
> ipv6 tuner tea5767 tda8290 tuner_xc2
> 028 tda9887 tuner_simple mt20xx tea5761 tvaudio msp3400 bttv ir_common
> compat_ioctl32 videobuf_dma_sg v
> ideobuf_core btcx_risc tveeprom usbhid videodev v4l2_common hid
> v4l1_compat pata_amd sg i2c_nforce2
> [93436.947257] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> -> not tainted by a previous OOPS
> [93436.947259] RIP: 0010:[<ffffffff80531438>]  [<ffffffff80531438>]
> skb_drop_list+0x18/0x30
> [93436.947262] RSP: 0018:ffff810005f4fda8  EFLAGS: 00010286
> [93436.947263] RAX: ab1ed5ca5b74e7de RBX: ab1ed5ca5b74e7de RCX: 000000000000d135
> [93436.947265] RDX: ffff81011d089a80 RSI: 0000000000000001 RDI: ffff81011d089a88
> [93436.947266] RBP: ffff810005f4fdb8 R08: 0000000000000001 R09: 0000000000000006
> [93436.947268] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8100de02c500
> [93436.947269] R13: ffff81011c188a00 R14: 0000000000000001 R15: ffff81011c189198
> [93436.947271] FS:  00007fb5bde0d700(0000) GS:ffff81007ff22000(0000)
> knlGS:0000000000000000
> [93436.947273] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [93436.947274] CR2: 00007fb5bdd76000 CR3: 00000000664d5000 CR4: 00000000000006e0
> [93436.947276] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [93436.947277] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [93436.947279] Process konqueror (pid: 8079, threadinfo
> ffff810005f4e000, task ffff8100a1dec000)
> [93436.947281] Stack:  ffff810005f4fdd8 ffff810116c86140
> ffff810005f4fdd8 ffffffff805314ae
> [93436.947284]  ffff810116c86140 ffff8100de02c500 ffff810005f4fdf8
> ffffffff80531cf0
> [93436.947286]  ffff8100de02c500 ffff81011c188b48 ffff810005f4fe18
> ffffffff80531311
> [93436.947288] Call Trace:
> [93436.947290]  [<ffffffff805314ae>] skb_release_data+0x5e/0xa0
> [93436.947293]  [<ffffffff80531cf0>] skb_release_all+0xa0/0x110
> [93436.947295]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> [93436.947297]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> [93436.947299]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> [93436.947302]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> [93436.947304]  [<ffffffff8052b144>] sock_release+0x24/0x90
> [93436.947307]  [<ffffffff8052b656>] sock_close+0x26/0x50
> [93436.947309]  [<ffffffff8029f921>] __fput+0xc1/0x230
> [93436.947312]  [<ffffffff8029fe46>] fput+0x16/0x20
> [93436.947314]  [<ffffffff8029c576>] filp_close+0x56/0x90
> [93436.947316]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> [93436.947319]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> [93436.947322]
> [93436.947322]
> [93436.947323] Code: 48 8b 18 48 89 c7 e8 5d ff ff ff 48 85 db 75 ed 48 83 c4 08
> [93436.947328] RIP  [<ffffffff80531438>] skb_drop_list+0x18/0x30
> [93436.947330]  RSP <ffff810005f4fda8>
> [93436.947332] ---[ end trace befb7cc3528ab3b1 ]---
> 
> Your patch just fit so "good" to my problems:
> * it had the correct time frame for 2.6.24-rc3-mm2
> * it looked guilty at changing the refcounting of __refcnt because of
> the added dst_release()
> * it added other release / freeing operations so that a use-after-free
> memory corruption seemed possible
> 
> I just have no better idea to what caused this OOPS and the other
> hangs in -rc3-mm2.

---
~Randy
desserts:  http://www.xenotime.net/linux/recipes/
