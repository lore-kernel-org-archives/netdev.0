From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/16] DMA-API debugging facility v2
Date: Sun, 11 Jan 2009 00:54:35 +0100
Message-ID: <20090110235435.GD20843@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44504 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbZAJXzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:55:10 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> Hi,
> 
> this is version 2 of the patchset which introduces code to debug drivers 
> usage of the DMA-API. Many thanks to all the reviewers and the useful 
> comments on the fist version of this patchset. Tests with hardware 
> IOMMUs have shown several bugs in drivers regarding the usage of that 
> API.  Problems were found especially in network card drivers.
> 
> These bugs often don't show up or have any negative impact if there is 
> no hardware IOMMU in use in the system. But with an hardware IOMMU these 
> bugs turn the hardware unusable or, in the worst case, cause data 
> corruption on devices which are managed by other (good) drivers.
> 
> With the code these patches introduce driver developers can find several 
> bugs of misusing the DMA-API in their drivers. But be aware, it can not 
> find all possible bugs. If it finds a problem it prints out messages 
> like
> 
> ------------[ cut here ]------------
> WARNING: at /data2/repos/linux.trees.git/lib/dma-debug.c:231 check_unmap+0xab/0x3d9()
> Hardware name: Toonie
> bnx2 0000:01:00.0: DMA-API: device driver tries to free DMA memory it has not allocated [device address=0x00000000011]
> Modules linked in:
> Pid: 0, comm: swapper Not tainted 2.6.28 #174
> Call Trace:
>  <IRQ>  [<ffffffff8105af3a>] warn_slowpath+0xd3/0xf2
>  [<ffffffff8107c36f>] ? find_usage_backwards+0xe2/0x116
>  [<ffffffff8107c36f>] ? find_usage_backwards+0xe2/0x116
>  [<ffffffff812efd16>] ? usb_hcd_link_urb_to_ep+0x94/0xa0
>  [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
>  [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
>  [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
>  [<ffffffff811e2b4b>] ? get_hash_bucket+0x28/0x33
>  [<ffffffff814b25a5>] ? _spin_lock_irqsave+0x69/0x75
>  [<ffffffff811e2b4b>] ? get_hash_bucket+0x28/0x33
>  [<ffffffff811e2ff2>] check_unmap+0xab/0x3d9
>  [<ffffffff8107c9ed>] ? trace_hardirqs_on_caller+0x108/0x14a
>  [<ffffffff8107ca3c>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff811e3433>] debug_unmap_single+0x3e/0x40
>  [<ffffffff8128d2d8>] dma_unmap_single+0x3d/0x60
>  [<ffffffff8128d335>] pci_unmap_page+0x1c/0x1e
>  [<ffffffff81290759>] bnx2_poll_work+0x626/0x8cb
>  [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
>  [<ffffffff81070100>] ? run_posix_cpu_timers+0x49c/0x603
>  [<ffffffff81070000>] ? run_posix_cpu_timers+0x39c/0x603
>  [<ffffffff8107c52b>] ? mark_lock+0x1c/0x364
>  [<ffffffff8107d8f7>] ? __lock_acquire+0xaec/0xb55
>  [<ffffffff81292804>] bnx2_poll_msix+0x33/0x81
>  [<ffffffff813b6478>] net_rx_action+0x8a/0x139
>  [<ffffffff8105ff39>] __do_softirq+0x8b/0x147
>  [<ffffffff8102933c>] call_softirq+0x1c/0x34
>  [<ffffffff8102a611>] do_softirq+0x39/0x90
>  [<ffffffff8105fde8>] irq_exit+0x4e/0x98
>  [<ffffffff8102a5c2>] do_IRQ+0x11f/0x135
>  [<ffffffff81028b93>] ret_from_intr+0x0/0xf
>  <EOI> <4>---[ end trace 4339d58302097423 ]---
> 
> This way driver developers get an idea where the problem is in their
> code.
> 
> I hope I addressed most of the review comments and objections from the
> first version. Please give this version also a good review and send me
> your comments.

Looks pretty good in general - modulo the few observations i just made in 
reply to the patches. (Note, the comments apply to all the patches - 
there's similar small issues in other places as well.)

Did you have a chance to look at debugobjects and see whether it could be 
reused as the dma-debug-entry object management code?

One request: could you please git-base it on the changes in tip/core/iommu 
(i only have looked at the patches in email - i presume the current ones 
are based on -git)?

That way we'll have it on top of Fujita's very nice DMA-mapping 
consolidation code.

	Ingo
