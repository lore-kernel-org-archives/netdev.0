From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 10:26:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B1508D50A0692F42B217C22C02D849727FEDAE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>, "Greg Banks" <gnb@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

The producer index of completed tx packets in the status block will
always be at whole packet boundaries (1 + the index of the completed
packet's last fragment). Even if it is a TSO packet, it will be at the
boundaries of entire TSO packets.

Michael

> -----Original Message-----
> From: David S. Miller [mailto:davem@redhat.com] 
> Sent: Monday, May 24, 2004 10:07 AM
> To: Greg Banks
> Cc: netdev@oss.sgi.com; Michael Chan
> Subject: Re: [PATCH] fix BUG in tg3_tx
> 
> 
> 
> [ Michael, the discussion here is about whether the tigon3 hardware
>   ever partially ACK's completion of a multi-frag TX frame.  I
>   believe it never does, but Greg claims he can trigger such a case
>   and has proposed a patch to the tg3 driver which attempts 
> to handle that. ]
> 
> On Mon, 24 May 2004 18:04:31 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > On Mon, May 24, 2004 at 12:40:45AM -0700, David S. Miller wrote:
> > > On Mon, 24 May 2004 17:26:58 +1000
> > > Greg Banks <gnb@sgi.com> wrote:
> > > 
> > > > The tg3 transmit code assumes that tg3_tx() will never have to 
> > > > clean up part of an skb queued for transmit.  This 
> assumption is 
> > > > wrong;
> > > 
> > > Greg, perhaps my reading of the tg3 chip docs is different from 
> > > yours.  The hardware is NEVER supposed to do this.
> > 
> > I'd like to know where you read that, because neither I nor 
> any of the 
> > other SGI engineers who have read the Broadcom docs can 
> find any such 
> > guarantee.
> 
> The most relevant (and accurate) piece of documentation for 
> the chip is Broadcom's own driver :-) And they do not account 
> at all for such a case of partial-packet TX completion 
> indication.  If the first frag is ACK'd they assume the whole 
> packet has been taken.  Here is the relevant code from the 
> bcm5700 driver in LM_ServiceTxInterrupt():
> 
>     while(SwConIdx != HwConIdx)
>     {
>         pPacket = pDevice->SendRing[SwConIdx];
>         pDevice->SendRing[SwConIdx] = 0;
> 
>         /* Set the return status. */
>         pPacket->PacketStatus = LM_STATUS_SUCCESS;
> 
>         /* Put the packet in the TxPacketXmittedQ for 
> indication later. */
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
> Imagine how badly this piece of code would fail if partial 
> ACK'ing of TX packets actually occurred.  It would loop past 
> HwConIdx and thus ACK really-not-completed packets, 
> potentially colliding with what the chip is transmitting and 
> thus causing massive data corruption and likely a crash.  
> Actually, it would most likely loop past all valid TX packets 
> and dereference a pPacket NULL pointer.
> 
> 
