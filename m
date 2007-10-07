From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/5] forcedeth: interrupt handling cleanup
Date: Sun, 07 Oct 2007 16:07:22 -0400
Message-ID: <47093C7A.1030203@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org>	 <20071006151400.GB17488@havoc.gtf.org>	 <86802c440710062143x3bb801c3obb91292208073588@mail.gmail.com>	 <4708C5BD.8090402@garzik.org> <86802c440710071236h137a5331i78f795d7a04c69e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43283 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754AbXJGUH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 16:07:28 -0400
In-Reply-To: <86802c440710071236h137a5331i78f795d7a04c69e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On 10/7/07, Jeff Garzik <jeff@garzik.org> wrote:
>> Yinghai Lu wrote:
>>> On 10/6/07, Jeff Garzik <jeff@garzik.org> wrote:
>>>> commit a606d2a111cdf948da5d69eb1de5526c5c2dafef
>>>> Author: Jeff Garzik <jeff@garzik.org>
>>>> Date:   Fri Oct 5 22:56:05 2007 -0400
>>>>
>>>>     [netdrvr] forcedeth: interrupt handling cleanup
>>>>
>>>>     * nv_nic_irq_optimized() and nv_nic_irq_other() were complete duplicates
>>>>       of nv_nic_irq(), with the exception of one function call.  Consolidate
>>>>       all three into a single interrupt handler, deleting a lot of redundant
>>>>       code.
>>>>
>>>>     * greatly simplify irq handler locking.
>>>>
>>>>       Prior to this change, the irq handler(s) would acquire and release
>>>>       np->lock for each action (RX, TX, other events).
>>>>
>>>>       For the common case -- RX or TX work -- the lock is always acquired,
>>>>       making all successive acquire/release combinations largely redundant.
>>>>
>>>>       Acquire the lock at the beginning of the irq handler, and release it at
>>>>       the end of the irq handler.  This is simple, easy, and obvious.
>>>>
>>>>     * remove irq handler work loop.
>>>>
>>>>       All interesting events emanating from the irq handler either have
>>>>       their own work loops, or they poke a timer into action.
>>>>
>>>>       Therefore, delete the pointless master interrupt handler work loop.
>>>>
>>>>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>>>>
>> Do you have ideas/suggestions for a different method?
> 
> in the e1000 driver, it has seperate handler for msi and ioapic.
> 
> but in forcedeth, the nv_nic_irq_optimized keep check msi_flags...,
> with num of msi interrupt number, that could cause cpu loading get a
> little bit high..., even the network performance is ok.

With all the activity in the interrupt handler, a few in-cache branches 
are definitely going to be lost in the noise.

Separating the interrupt handlers between MSI and non-MSI tends to be of 
more benefit when the separation is accompanied by more efficient 
locking in the MSI interrupt handler, or a different mode of interrupt 
clear, or some other attribute.

Though CPU usage would be a good thing to measure, with these patches.

	Jeff




