From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Thu, 3 Jan 2008 06:02:49 +0100
Message-ID: <64bb37e0801022102n54d85772p698055dd83b34d7c@mail.gmail.com>
References: <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	 <20071230013021.GA13603@gondor.apana.org.au>
	 <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
	 <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
	 <20080101120406.GA27209@gondor.apana.org.au>
	 <64bb37e0801021029u1735bb9eta53906b123abf577@mail.gmail.com>
	 <20080102215154.GA13911@gondor.apana.org.au>
	 <20080102215706.GB6480@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	netdev@vger.kernel.org, "Tom Tucker" <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:32183 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbYACFCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 00:02:51 -0500
Received: by py-out-1112.google.com with SMTP id u52so10302406pyb.10
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 21:02:50 -0800 (PST)
In-Reply-To: <20080102215706.GB6480@fieldses.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 2, 2008 10:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jan 03, 2008 at 08:51:54AM +1100, Herbert Xu wrote:
> > On Wed, Jan 02, 2008 at 07:29:59PM +0100, Torsten Kaiser wrote:
> > >
> > > Vanilla 2.6.24-rc6 seems stable. I did not see any crash or warnings.
> >
> > OK that's great.  The next step would be to try excluding specific git
> > trees from mm to see if they make a difference.
> >
> > The two specific trees of interest would be git-nfsd and git-net.
>
> Also, if it's git-nfsd, it'd be useful to test with the current git-nfsd
> from the for-mm branch at:
>
>         git://linux-nfs.org/~bfields/linus.git for-mm
>
> and then any bisection results (even partial) from that tree would help
> immensely....

The problem with that is, that triggering the bug is not easy so
marking anything 'good' is questionable.
This time I needed to compile over 50 packages until it triggered.

I was using 2.6.24-rc6-mm1 again, but with a crude hack (see end of
mail) that I hope should catch any double-frees of skbs.
None of my warnings triggered, only a list corruption again in
svc_xprt_enqueue(), but this time with an additional output about
whats wrong with the list:
[17023.029519] list_add corruption. prev->next should be next
(ffff8100d20ec1c8), but was ffff81009c5a6
c28. (prev=ffff81009c5a6c28).
[17023.029537] ------------[ cut here ]------------
[17023.031445] kernel BUG at lib/list_debug.c:33!
[17023.033280] invalid opcode: 0000 [1] SMP
[17023.034967] last sysfs file:
/sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[17023.038209] CPU 3
[17023.039047] Modules linked in: radeon drm w83792d ipv6 tuner
tea5767 tda8290 tuner_xc2028 tda9887 tu
ner_simple mt20xx tea5761 tvaudio msp3400 bttv ir_common
compat_ioctl32 videobuf_dma_sg videobuf_core b
tcx_risc usbhid tveeprom videodev hid v4l2_common v4l1_compat sg
pata_amd i2c_nforce2
[17023.039519] Pid: 20564, comm: nfsv4-svc Not tainted 2.6.24-rc6-mm1 #14
[17023.039519] RIP: 0010:[<ffffffff803bd834>]  [<ffffffff803bd834>]
__list_add+0x54/0x60
[17023.039519] RSP: 0018:ffff8101002c9dc0  EFLAGS: 00010282
[17023.039519] RAX: 0000000000000088 RBX: ffff810110125c00 RCX: 0000000000000000
[17023.039519] RDX: ffff81010067c000 RSI: 0000000000000001 RDI: ffffffff80764140
[17023.039519] RBP: ffff8101002c9dc0 R08: 0000000000000001 R09: 0000000000000000
[17023.039519] R10: ffff81000100a088 R11: 0000000000000001 R12: ffff8100d20ec180
[17023.039519] R13: ffff8100d20ec1b8 R14: ffff8100d20ec1b8 R15: ffff8101188e4600
[17023.039519] FS:  00007ff7a870c6f0(0000) GS:ffff81011ff0cd00(0000)
knlGS:0000000000000000
[17023.039519] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[17023.039519] CR2: 00000000024df510 CR3: 0000000032539000 CR4: 00000000000006e0
[17023.039519] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[17023.039519] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[17023.039519] Process nfsv4-svc (pid: 20564, threadinfo
ffff8101002c8000, task ffff81010067c000)
[17023.039519] Stack:  ffff8101002c9e00 ffffffff805c18ab
ffff8100d20ec188 ffff8101188e4600
[17023.039519]  ffff81009c5a6c00 ffff81010d118000 ffff810110125c00
ffff8101188e4610
[17023.039519]  ffff8101002c9e10 ffffffff805c1997 ffff8101002c9ee0
ffffffff805c2ac4
[17023.039519] Call Trace:
[17023.039519]  [<ffffffff805c18ab>] svc_xprt_enqueue+0x1ab/0x240
[17023.039519]  [<ffffffff805c1997>] svc_xprt_received+0x17/0x20
[17023.039519]  [<ffffffff805c2ac4>] svc_recv+0x394/0x7c0
[17023.039519]  [<ffffffff805c1ece>] svc_send+0xae/0xd0
[17023.039519]  [<ffffffff802305f0>] default_wake_function+0x0/0x10
[17023.039519]  [<ffffffff803178b9>] nfs_callback_svc+0x79/0x130
[17023.039519]  [<ffffffff80232a67>] finish_task_switch+0x67/0xe0
[17023.039519]  [<ffffffff8020c4b8>] child_rip+0xa/0x12
[17023.039519]  [<ffffffff8020bbcf>] restore_args+0x0/0x30
[17023.039519]  [<ffffffff805b69cd>] __svc_create_thread+0xdd/0x200
[17023.039519]  [<ffffffff80317840>] nfs_callback_svc+0x0/0x130
[17023.039519]  [<ffffffff8020c4ae>] child_rip+0x0/0x12
[17023.039519]
[17023.039519]
[17023.039519] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16 48 89 e5 e8
[17023.039519] RIP  [<ffffffff803bd834>] __list_add+0x54/0x60
[17023.039519]  RSP <ffff8101002c9dc0>
[17023.039524] ---[ end trace a9257b24a4b10968 ]---
[17023.041451] Kernel panic - not syncing: Aiee, killing interrupt handler!

I also wonder if this really is only one bug, or two. (One in skb
handling and one in svc_xprt_enqueue's list code)

Summary of what I think is related to this:

* 2.6.24-rc2-mm1 might not have it, but had a bug in the nfsv4 sillyrenames.
* 2.6.24-rc3-mm1 did not work for me at all (IO-APIC problem)
* 2.6.24-rc3-mm2 has the bug
  - I have seen a crash in ether1394_complete_cb
  - I have seen 3 crashes in svc_xprt_enqueue, two with slub_debug=FZP
  - I have seen a crash in tcp_send_ack -> __alloc_skb
  - patched with svc_xprt_received(&svsk->sk_xprt); removed from
svc_create_socket()
    -> still crashed in svc_xprt_enqueue
  - patched "skb_release_all(dst);" back to "skb_release_data(dst);"
in skb_morph() (net/core/skbuff.c).
    -> seemed to work (200+ packages compiled+installed)
* 2.6.24-rc4-mm1 and -rc5-mm1: not tried, was still testing -rc3-mm2
* 2.6.24-rc6 did not crash, but I did not test it for too long
* 2.6.24-rc6-mm1 has the bug
  - I have seen a crash in skb_release_data with vanilla -mm1
  - patched "skb_release_all(dst);" back to "skb_release_data(dst);" in
skb_morph() (net/core/skbuff.c).
    -> crashed in xs_tcp_data_recv, skb_morph() was not called once
  - patched with notfreed-hack
    -> crashed in svc_xprt_enqueue, skb_morph() was not called once

I will see if I have the time to try git-nfsd, but as I'm not able to
trigger the bug reliable, I will not be able to really declare any
tree unrelated...

Torsten

My skb-double-free-hack: I added a new __u8 field to sk_buff after its
cb field and the following warnings:
--- skbuff.c~   2008-01-03 05:29:32.092408637 +0100
+++ skbuff.c    2008-01-02 23:00:14.114535678 +0100
@@ -205,6 +205,7 @@ struct sk_buff *__alloc_skb(unsigned int
        memset(skb, 0, offsetof(struct sk_buff, tail));
        skb->truesize = size + sizeof(struct sk_buff);
        atomic_set(&skb->users, 1);
+       skb->notfreed=1;
        skb->head = data;
        skb->data = data;
        skb_reset_tail_pointer(skb);
@@ -317,13 +318,18 @@ static void kfree_skbmem(struct sk_buff

        switch (skb->fclone) {
        case SKB_FCLONE_UNAVAILABLE:
+               WARN_ON(!skb->notfreed);
+               skb->notfreed=0;
                kmem_cache_free(skbuff_head_cache, skb);
                break;

        case SKB_FCLONE_ORIG:
                fclone_ref = (atomic_t *) (skb + 2);
-               if (atomic_dec_and_test(fclone_ref))
+               if (atomic_dec_and_test(fclone_ref)) {
+                 WARN_ON(!skb->notfreed);
+                 skb->notfreed=0;
                        kmem_cache_free(skbuff_fclone_cache, skb);
+                }
                break;

        case SKB_FCLONE_CLONE:
@@ -335,8 +341,11 @@ static void kfree_skbmem(struct sk_buff
                 */
                skb->fclone = SKB_FCLONE_UNAVAILABLE;

-               if (atomic_dec_and_test(fclone_ref))
+               if (atomic_dec_and_test(fclone_ref)) {
+                 WARN_ON(!other->notfreed);
+                 other->notfreed=0;
                        kmem_cache_free(skbuff_fclone_cache, other);
+                }
                break;
        }
 }
