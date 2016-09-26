From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] ath10k: fix system hang at qca99x0 probe on x86 platform
 (DMA32 issue)
Date: Mon, 26 Sep 2016 09:53:24 -0700
Message-ID: <e69cb7ba-dff6-f676-f63e-bebca6b59c0a@candelatech.com>
References: <20160614061728.570-1-rmanohar@qti.qualcomm.com>
 <e05dcb58-1cb1-a33a-31bb-b8ba1edf1363@dd-wrt.com>
 <fa3eab06-28f0-e5d4-2e92-770134b49dfa@dd-wrt.com>
 <1467218124941.40575@qti.qualcomm.com>
 <CA+BoTQkepLz55Vdr7OuMnPQPLKq_+vjZi=m2Y9rHLRgBZPsWOw@mail.gmail.com>
 <1468941948774.87860@qti.qualcomm.com>
 <CAJ-Vmon1duBNcWhjaNdANYFfd3hwQUYYHrmx7LRZvT-Ec2x1Cg@mail.gmail.com>
 <578E5AFA.4000908@candelatech.com>
 <CA+BoTQ=QMPUtY64ELCToZLcSrCPQdG=2Eg4FrsULeeDg9sFPYA@mail.gmail.com>
 <CAJ-Vmok95tiLzmnfiBnnOLQK9hXW2DfjPPVGy9yqucq32PBwJw@mail.gmail.com>
 <CA+BoTQ=ehuXpcJUOeSscLKzX9T=hZyp5i2G9GoxTVX=LAg_4hA@mail.gmail.com>
 <CAJ-Vmo=d=PgUu_AYT1C82AJcnUxKUo_VYMn_b1QF8M_T+5KpkA@mail.gmail.com>
 <CA+BoTQnN1EVGBu0J5Y7-z2=uqsG8rXS0Lvs7VAoeawv9MGuFyQ@mail.gmail.com>
 <CAJ-VmomcD8FgA34z3OFKZvc5yq8EsHOTqP=Lg-6gFOAcWys8og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Manoharan, Rajkumar" <rmanohar@qti.qualcomm.com>,
        Rajkumar Manoharan <rmanohar@codeaurora.org>,
        Sebastian Gottschall <s.gottschall@dd-wrt.com>,
        "Valo, Kalle" <kvalo@qca.qualcomm.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "nbd@nbd.name" <nbd@nbd.name>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Adrian Chadd <adrian@freebsd.org>,
        Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40858 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422915AbcIZQx0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 12:53:26 -0400
In-Reply-To: <CAJ-VmomcD8FgA34z3OFKZvc5yq8EsHOTqP=Lg-6gFOAcWys8og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2016 10:02 AM, Adrian Chadd wrote:
> Hi,
>
> The "right" way for the target CPU to interact with host CPU memory
> (and vice versa, for mostly what it's worth) is to have the copy
> engine copy (ie, "DMA") the pieces between them. This may be for
> diagnostic purposes, but it's not supposed to be used like this for
> doing wifi data exchange, right? :-P
>
> Now, there /may/ be some alignment hilarity in various bits of code
> and/or hardware. Eg, Merlin (AR9280) requires its descriptors to be
> within a 4k block - the code to iterate through the descriptor
> physical address space didn't do a "val = val + offset", it did
> something in verilog like "val = (val & 0xffffc000) | (offset &
> 0x3fff)". This meant if you allocated a descriptor that started just
> before the end of a 4k physmem aligned block, you'd end up with
> exciting results. I don't know if there are any situations like this
> in the ath10k hardware, but I'm sure there will be some gotchas
> somewhere.
>
> In any case, if ath10k is consuming too much bounce buffers, the calls
> to allocate memory aren't working right and should be restricted to 32
> bit addresses. Whether that's by using the DMA memory API (before it's
> mapped) or passing in GFP_DMA32 is a fun debate.
>
> (My test hardware arrived, so I'll test this all out today on
> Peregrine-v2 and see if the driver works.)

I have been running this patch for a while:

     ath10k:  Use GPF_DMA32 for firmware swap memory.

     This fixes OS crash when using QCA 9984 NIC on x86-64 system
     without vt-d enabled.

     Also tested on ea8500 with 9980, and x86-64 with 9980 and 9880.

     All tests were with CT firmware.

     Signed-off-by: Ben Greear <greearb@candelatech.com>

-------------------- drivers/net/wireless/ath/ath10k/wmi.c --------------------
index e20aa39..727b3aa 100644
@@ -4491,7 +4491,7 @@ static int ath10k_wmi_alloc_chunk(struct ath10k *ar, u32 req_id,
  		if (!pool_size)
  			return -EINVAL;

-		vaddr = kzalloc(pool_size, GFP_KERNEL | __GFP_NOWARN);
+		vaddr = kzalloc(pool_size, GFP_KERNEL | __GFP_NOWARN | GFP_DMA32);
  		if (!vaddr)
  			num_units /= 2;
  	}


It mostly seems to work, but then sometimes I get a splat like this below.  It appears
it is invalid to actually do kzalloc with GFP_DMA32 (based on that BUG_ON that
hit in the new_slab method)??

Any idea for a more proper way to do this?



gfp: 4
------------[ cut here ]------------
kernel BUG at /home/greearb/git/linux-4.7.dev.y/mm/slub.c:1508!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: coretemp hwmon ath9k intel_rapl ath10k_pci x86_pkg_temp_thermal ath9k_common ath10k_core intel_powerclamp ath9k_hw ath kvm iTCO_wdt mac80211 
iTCO_vendor_support irqbypass snd_hda_codec_hdmi 6
CPU: 2 PID: 268 Comm: kworker/u8:5 Not tainted 4.7.2+ #16
Hardware name: To be filled by O.E.M. To be filled by O.E.M./ChiefRiver, BIOS 4.6.5 06/07/2013
Workqueue: ath10k_aux_wq ath10k_wmi_event_service_ready_work [ath10k_core]
task: ffff880036433a00 ti: ffff880036440000 task.ti: ffff880036440000
RIP: 0010:[<ffffffff8124592a>]  [<ffffffff8124592a>] new_slab+0x39a/0x410
RSP: 0018:ffff880036443b58  EFLAGS: 00010092
RAX: 0000000000000006 RBX: 00000000024082c4 RCX: 0000000000000000
RDX: 0000000000000006 RSI: ffff88021e30dd08 RDI: ffff88021e30dd08
RBP: ffff880036443b90 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000372 R12: ffff88021dc01200
R13: ffff88021dc00cc0 R14: ffff88021dc01200 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88021e300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f3e65c1c730 CR3: 0000000001e06000 CR4: 00000000001406e0
Stack:
  ffffffff8127a4fc ffff0a01ffffff10 00000000024082c4 ffff88021dc01200
  ffff88021dc00cc0 ffff88021dc01200 0000000000000001 ffff880036443c58
  ffffffff81247ac6 ffff88021e31b360 ffff880036433a00 ffff880036433a00
Call Trace:
  [<ffffffff8127a4fc>] ? __d_lookup+0x9c/0x160
  [<ffffffff81247ac6>] ___slab_alloc+0x396/0x4a0
  [<ffffffffa0f8e14d>] ? ath10k_wmi_event_service_ready_work+0x5ad/0x800 [ath10k_core]
  [<ffffffff811f5279>] ? alloc_kmem_pages+0x9/0x10
  [<ffffffff8120f203>] ? kmalloc_order+0x13/0x40
  [<ffffffffa0f8e14d>] ? ath10k_wmi_event_service_ready_work+0x5ad/0x800 [ath10k_core]
  [<ffffffff81247bf6>] __slab_alloc.isra.72+0x26/0x40
  [<ffffffff81248767>] __kmalloc+0x147/0x1b0
  [<ffffffffa0f8e14d>] ath10k_wmi_event_service_ready_work+0x5ad/0x800 [ath10k_core]
  [<ffffffff811370a1>] ? dequeue_entity+0x261/0xac0
  [<ffffffff8111c2d8>] process_one_work+0x148/0x420
  [<ffffffff8111c929>] worker_thread+0x49/0x480
  [<ffffffff8111c8e0>] ? rescuer_thread+0x330/0x330
  [<ffffffff81121984>] kthread+0xc4/0xe0
  [<ffffffff8184d75f>] ret_from_fork+0x1f/0x40
  [<ffffffff811218c0>] ? kthread_create_on_node+0x170/0x170
Code: e9 65 fd ff ff 49 8b 57 20 48 8d 42 ff 83 e2 01 49 0f 44 c7 f0 80 08 40 e9 6f fd ff ff 89 c6 48 c7 c7 01 36 c7 81 e8 e8 40 fa ff <0f> 0b ba 00 10 00 00 be 
5a 00 00 00 48 89 c7 48 d3 e2 e8 bf 18
RIP  [<ffffffff8124592a>] new_slab+0x39a/0x410
  RSP <ffff880036443b58>
---[ end trace ea3b0043b2911d93 ]---


static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
{
         if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
                 pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
                 BUG();
         }

         return allocate_slab(s,
                 flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
}


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
