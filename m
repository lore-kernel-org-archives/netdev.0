From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Sat, 17 May 2008 22:34:28 +0200
Message-ID: <20080517203428.GA16915@duo.random>
References: <fa.LFS/TATb5YijFetLw6A+gczrVAQ@ifi.uio.no> <482E3B1B.9070400@shaw.ca> <20080517141235.GA13130@duo> <482EF256.8030305@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Hancock <hancockr@shaw.ca>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Axboe <jens.axboe@oracle.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host36-195-149-62.serverdedicati.aruba.it ([62.149.195.36]:47595
	"EHLO mx.cpushare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758414AbYEQUeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 16:34:37 -0400
Content-Disposition: inline
In-Reply-To: <482EF256.8030305@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 17, 2008 at 07:57:26AM -0700, Arjan van de Ven wrote:
> Andrea Arcangeli wrote:
>> The reason I touched that code, is that a change introduced during
>> 2.6.25-rc initialized the isa dma pool even if not necessary and that
>> broke the reserved-ram patch that requires no __GFP_DMA
>> allocations. There was no crash in 2.6.24 based kernels, the
>> regression started in 2.6.25-rc.
>
> I'd not really call "breaks external patch" a regression ;)

The external patch only allowed me to notice the regression when
nobody else noticed it. For mainline the regression was to put ram
into the bounce buffer pool even if no dma could ever require the
bounce buffering. There's no point to initialize the pool when total
ram < highest dma address. That is the regression. My patch turned the
regression from a waste of ram, to a kernel crash at boot. That's the
only relation between the reserved-ram patch this bug.

I assume Robert has a similar issue with some debugging code checking
for GFP_KERNEL allocations inside atomic context or similar, I assume
his driver has a bug and calls that function in the wrong context. But
if this didn't happen in 2.4.24, it means such bug has nothing to do
with the bug in blk-settings.c. It's just that such a bug or the
reserved-ram patches are required to notice the regression in
blk-settings.c.

rolling back to the code before this commit solves the problem for
me. The weird thing is that I'm quite sure I verified my patch
incremental with the below solved the crash at boot when run in qemu
but I also noticed later that sata didn't fix it.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=419c434c35614609fd0c79d335c134bf4b88b30b

So there are two possibilities:

1) the current code in blk-settings is just fine after my last fix,
but there's yet another bug in this area in sata code unrelated to my
last fix

2) my last fix only fixed part of the problem and it only solved the
issue for ata or similar (my kvm setup where I tested my fix didn't
have any sata, but without my fix not even ata was working correctly)
and another fix is needed

> What we really ought to be doing is always initialize the pool, from
> the right process context. However, we need to make it such that we

Yes, that's the bug that probably Robert found, and that's also what
allowed him to notice we still have some regression in blk-settings.c
compared to 2.6.24, just like I could notice it thanks to the
reserved-ram patch.

> can detect that there is zero __GFP_DMA memory in the system, and bail
> out in that case. Doing it on-demand is just not going to fly; by that
> time it's just too late (the pool may have been eaten already, the context
> might be nasty to do allocations from etc etc).

That surely sounds nice, and it's yet another problem. But let's say
this last problem is low priority to solve because on any system where
we want to reserve the ram for the guest to run pci-passthrough dma on
hardware without VT-d, we can assume all devices are pci64 capable and
the current reserved-ram patch doesn't allow to reserve more than 2G
of the guest anyway because the host kernel has to run between -2GUL
and -1UL (included) so running on hosts with >4G of ram with pci32
devices attached isn't a top priority at the moment. Infact if
something there should also be a pool from the 32bit zone and not only
from the 24bit one.

> the sata_nv driver has to do it on finding a cdrom; afaik it has something
> like a different DMA mask for disks and cdroms, and it scales down once you
> insert a CD.

So that would surely give problems with reserved-ram. We'll sort this
out later. So for sata_nv it would be right to call the bounce
buffering, but in my hardware test the value was like 1000 and 1001,
with driver claiming 1001 required and b_pfn set to 1000 or similar,
so it was an off by one thing again with sata, and not a cdrom real
low dma mask.
