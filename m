From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 10:06:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524100634.1349295d.davem@redhat.com>
References: <20040524072657.GC27177@sgi.com>
	<20040524004045.58b3eb44.davem@redhat.com>
	<20040524080431.GD27177@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040524080431.GD27177@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ Michael, the discussion here is about whether the tigon3 hardware
  ever partially ACK's completion of a multi-frag TX frame.  I
  believe it never does, but Greg claims he can trigger such a case
  and has proposed a patch to the tg3 driver which attempts to handle that. ]

On Mon, 24 May 2004 18:04:31 +1000
Greg Banks <gnb@sgi.com> wrote:

> On Mon, May 24, 2004 at 12:40:45AM -0700, David S. Miller wrote:
> > On Mon, 24 May 2004 17:26:58 +1000
> > Greg Banks <gnb@sgi.com> wrote:
> > 
> > > The tg3 transmit code assumes that tg3_tx() will never have to clean
> > > up part of an skb queued for transmit.  This assumption is wrong;
> > 
> > Greg, perhaps my reading of the tg3 chip docs is different
> > from yours.  The hardware is NEVER supposed to do this.
> 
> I'd like to know where you read that, because neither I nor any of
> the other SGI engineers who have read the Broadcom docs can find any
> such guarantee.

The most relevant (and accurate) piece of documentation for the chip
is Broadcom's own driver :-) And they do not account at all for such
a case of partial-packet TX completion indication.  If the first frag
is ACK'd they assume the whole packet has been taken.  Here is the
relevant code from the bcm5700 driver in LM_ServiceTxInterrupt():

    while(SwConIdx != HwConIdx)
    {
        pPacket = pDevice->SendRing[SwConIdx];
        pDevice->SendRing[SwConIdx] = 0;

        /* Set the return status. */
        pPacket->PacketStatus = LM_STATUS_SUCCESS;

        /* Put the packet in the TxPacketXmittedQ for indication later. */
        QQ_PushTail(&pDevice->TxPacketXmittedQ.Container, pPacket);

        /* Move to the next packet's BD. */
        SwConIdx = (SwConIdx + pPacket->u.Tx.FragCount) & 
            T3_SEND_RCB_ENTRY_COUNT_MASK;

        /* Update the number of unused BDs. */
        MM_ATOMIC_ADD(&pDevice->SendBdLeft, pPacket->u.Tx.FragCount);

        /* Get the new updated HwConIdx. */
        HwConIdx = pDevice->pStatusBlkVirt->Idx[0].SendConIdx;
    } /* while */

Imagine how badly this piece of code would fail if partial ACK'ing of
TX packets actually occurred.  It would loop past HwConIdx and thus
ACK really-not-completed packets, potentially colliding with what
the chip is transmitting and thus causing massive data corruption
and likely a crash.  Actually, it would most likely loop past all
valid TX packets and dereference a pPacket NULL pointer.
