From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Tue, 25 May 2004 11:04:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525010434.GA31134@sgi.com>
References: <20040524072657.GC27177@sgi.com> <20040524004045.58b3eb44.davem@redhat.com> <20040524080431.GD27177@sgi.com> <20040524100634.1349295d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040524100634.1349295d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 24, 2004 at 10:06:34AM -0700, David S. Miller wrote:
> 
> The most relevant (and accurate) piece of documentation for the chip
> is Broadcom's own driver :-)

The Windows-flavoured driver you decided to replace in Linux?

> And they do not account at all for such
> a case of partial-packet TX completion indication.  If the first frag
> is ACK'd they assume the whole packet has been taken.  Here is the
> relevant code from the bcm5700 driver in LM_ServiceTxInterrupt():
> 
>     while(SwConIdx != HwConIdx)
>     {
>         pPacket = pDevice->SendRing[SwConIdx];
>         pDevice->SendRing[SwConIdx] = 0;
> 
>         /* Set the return status. */
>         pPacket->PacketStatus = LM_STATUS_SUCCESS;
> 
>         /* Put the packet in the TxPacketXmittedQ for indication later. */
>         QQ_PushTail(&pDevice->TxPacketXmittedQ.Container, pPacket);
> 
>         /* Move to the next packet's BD. */
>         SwConIdx = (SwConIdx + pPacket->u.Tx.FragCount) & 
>             T3_SEND_RCB_ENTRY_COUNT_MASK;
> 
>         /* Update the number of unused BDs. */
>         MM_ATOMIC_ADD(&pDevice->SendBdLeft, pPacket->u.Tx.FragCount);
> 
>         /* Get the new updated HwConIdx. */
>         HwConIdx = pDevice->pStatusBlkVirt->Idx[0].SendConIdx;
>     } /* while */
> 
> Imagine how badly this piece of code would fail if partial ACK'ing of
> TX packets actually occurred.  It would loop past HwConIdx and thus
> ACK really-not-completed packets, potentially colliding with what
> the chip is transmitting and thus causing massive data corruption
> and likely a crash.  Actually, it would most likely loop past all
> valid TX packets and dereference a pPacket NULL pointer.

I agree that this code appears to implictly rely on always getting
complete send ring updates.

So has this driver been tested in 2.6?  I did notice that the bug
occurs far more frequently in 2.6 because better zero-copy code
means that the driver actually sees skbs with frags instead of just
the header.  The driver might be accidentally working because
pPacket->u.Tx.FragCount=1 during all its testing.

Also, I'm not familiar with this driver's source (I haven't looked
at it for a long time), but I can see that there are behaviour
differences between this driver and the tg3 driver which might affect
the visibility of the bug.

For one thing, this code fetches a new sample of the hardware consumer
index on every loop iteration.  This may result in accidentally
bumping up HwConIdx to avoid apparent partial completions.  Also note
that the queuing step (QQ_PushTail) might add enough delay to make
a second status block update more likely.

Without looking at the remainder of the driver, I can't say if this
code is called more or less frequently than tg3_tx().  If it's using
any interrupt coalescing at all it will be called much less frequently
and thus have a smaller window to see a partial complete.  On my
hardware I see interrupt rates of 10000-30000 per second per card,
and tracing shows that tg3_tx() is called on most of these interrupts.
It could be the case that the huge interrupt rate in the tg3 driver
is banging hard on a race condition which the bcom driver avoids.

Also, the NAPI code in the tg3 driver will presumably set up the
card's interrupt coalescing engine with different parameters, which
might have an effect on the timing of status block updates.

Finally, the tg3 driver departs from the recommended ISR flow control
diagram and handles a status block update during the ISR by using
the SETINT bit to tell the card to force a new interrupt (instead of
restarting the ISR).  This might also have an effect.

In short, even if the implicit assumptions in the bcom driver are
correct in that driver, I don't see how you can argue that they can
be carried across to the tg3 driver.


BTW, at least one other person has reported what appears to be the
exactly this bug:

http://marc.theaimsgroup.com/?l=linux-kernel&m=102822850329939&w=2

He found the same bug in both bcom and tg3 drivers, and his hardware
has little in common with mine (apart from having >1 fast CPUs).


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
