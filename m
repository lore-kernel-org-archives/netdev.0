From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sat, 29 Dec 2007 17:51:13 +0100
Message-ID: <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	 <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:21638 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbXL2QvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 11:51:17 -0500
Received: by py-out-1112.google.com with SMTP id u52so8256143pyb.10
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2007 08:51:16 -0800 (PST)
In-Reply-To: <20071228150746.42b3bbc0.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 29, 2007 12:07 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 28 Dec 2007 23:53:49 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > On Dec 23, 2007 5:27 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
[snip]
> > [ 7620.708561] Pid: 5698, comm: nfsv4-svc Not tainted 2.6.24-rc3-mm2 #2
[snip]
> That looks like a sunrpc bug.  git-nfsd has bene mucking around in there a
> bit.

Please note, that this report is still against 2.6.24-rc3-mm2. The
only new thing about that was, that slub_debug=FZP does not catch the
cause...

> > The cause, why I am resending this: I just got a crash with
> > 2.6.24-rc6-mm1, again looking network related:
> >
> > [93436.933356] WARNING: at include/net/dst.h:165 dst_release()
> > [93436.936685] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> > [93436.939292]
> > [93436.939293] Call Trace:
> > [93436.939304]  [<ffffffff80531d2d>] skb_release_all+0xdd/0x110
> > [93436.939307]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> > [93436.939309]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> > [93436.939312]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> > [93436.939315]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> > [93436.939318]  [<ffffffff8052b144>] sock_release+0x24/0x90
> > [93436.939320]  [<ffffffff8052b656>] sock_close+0x26/0x50
> > [93436.939324]  [<ffffffff8029f921>] __fput+0xc1/0x230
> > [93436.939327]  [<ffffffff8029fe46>] fput+0x16/0x20
> > [93436.939329]  [<ffffffff8029c576>] filp_close+0x56/0x90
> > [93436.939331]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> > [93436.939335]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80

>From code inspection I would blame the patch "[SKBUFF]: Free old skb
properly in skb_morph" from Herbert Xu. (CC added)

Mostly it only shuffles code around, the only real change seems to be this hunk:
@@ -441,7 +446,7 @@ static struct sk_buff *__skb_clone(struct sk_buff
*n, struct sk_buff *skb)
  */
 struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 {
-	skb_release_data(dst);
+	skb_release_all(dst);
 	return __skb_clone(dst, src);
 }
 EXPORT_SYMBOL_GPL(skb_morph);

Using sbk_release_all instead only skb_release_data (with is called
automatically from the new sbk_release_all) will add a new call to
dst_release(skb->dst); (first line in sbk_release_all)
Could that explain the above underflow warning?

(I do not have any clue about the inner workings of the network core,
I just looked for code changes, that might be relevant...)

> > [93436.947241] general protection fault: 0000 [1] SMP
> > [93436.947243] last sysfs file:
> > /sys/devices/pci0000:00/0000:00:0f.0/0000:01:00.1/irq
> > [93436.947245] CPU 1
> > [93436.947246] Modules linked in: radeon drm nfsd exportfs w83792d
> > ipv6 tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
> > tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
> > videobuf_core btcx_risc tveeprom usbhid videodev v4l2_common hid
> > v4l1_compat pata_amd sg i2c_nforce2
> > [93436.947257] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> > [93436.947259] RIP: 0010:[<ffffffff80531438>]  [<ffffffff80531438>]
> > skb_drop_list+0x18/0x30
> > [93436.947262] RSP: 0018:ffff810005f4fda8  EFLAGS: 00010286
> > [93436.947263] RAX: ab1ed5ca5b74e7de RBX: ab1ed5ca5b74e7de RCX: 000000000000d135
> > [93436.947265] RDX: ffff81011d089a80 RSI: 0000000000000001 RDI: ffff81011d089a88
> > [93436.947266] RBP: ffff810005f4fdb8 R08: 0000000000000001 R09: 0000000000000006
> > [93436.947268] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8100de02c500
> > [93436.947269] R13: ffff81011c188a00 R14: 0000000000000001 R15: ffff81011c189198
> > [93436.947271] FS:  00007fb5bde0d700(0000) GS:ffff81007ff22000(0000)
> > knlGS:0000000000000000
> > [93436.947273] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [93436.947274] CR2: 00007fb5bdd76000 CR3: 00000000664d5000 CR4: 00000000000006e0
> > [93436.947276] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [93436.947277] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [93436.947279] Process konqueror (pid: 8079, threadinfo
> > ffff810005f4e000, task ffff8100a1dec000)
> > [93436.947281] Stack:  ffff810005f4fdd8 ffff810116c86140
> > ffff810005f4fdd8 ffffffff805314ae
> > [93436.947284]  ffff810116c86140 ffff8100de02c500 ffff810005f4fdf8
> > ffffffff80531cf0
> > [93436.947286]  ffff8100de02c500 ffff81011c188b48 ffff810005f4fe18
> > ffffffff80531311
> > [93436.947288] Call Trace:
> > [93436.947290]  [<ffffffff805314ae>] skb_release_data+0x5e/0xa0
> > [93436.947293]  [<ffffffff80531cf0>] skb_release_all+0xa0/0x110
> > [93436.947295]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> > [93436.947297]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> > [93436.947299]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> > [93436.947302]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> > [93436.947304]  [<ffffffff8052b144>] sock_release+0x24/0x90
> > [93436.947307]  [<ffffffff8052b656>] sock_close+0x26/0x50
> > [93436.947309]  [<ffffffff8029f921>] __fput+0xc1/0x230
> > [93436.947312]  [<ffffffff8029fe46>] fput+0x16/0x20
> > [93436.947314]  [<ffffffff8029c576>] filp_close+0x56/0x90
> > [93436.947316]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> > [93436.947319]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> > [93436.947322]
> > [93436.947322]
> > [93436.947323] Code: 48 8b 18 48 89 c7 e8 5d ff ff ff 48 85 db 75 ed
> > 48 83 c4 08
> > [93436.947328] RIP  [<ffffffff80531438>] skb_drop_list+0x18/0x30
> > [93436.947330]  RSP <ffff810005f4fda8>
> > [93436.947332] ---[ end trace befb7cc3528ab3b1 ]---
>
> Yes, that looks more networking-related.

I would hope this OOPS was caused by the same error, trying to release
the same list twice.

Torsten
