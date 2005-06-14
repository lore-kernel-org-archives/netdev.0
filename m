From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 14 Jun 2005 10:55:41 -0700
Message-ID: <20050614175541.GD24371@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972067F0804@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <iod00d@hp.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D84972067F0804@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 11:46:47PM -0700, Michael Chan wrote:
> rmb() is needed between reading the tag and tg3_has_work()
> to guarantee strict ordering.

Thinking about this more... tg3_has_work() could be reduced to 
comparing status tag with last_tag (vs each of the TX/RX indices).
That assumes all the tg3 NICs support status tags...if not, then we
have to keep checking indices.

[ BTW, I noticed spin_lock*(&tp->lock) calls are nested in tg3_poll.
That's a bug, right? I'm still looking at v3.29 ]

The current implementation of tg3_poll() processes TX and then RX.
The status tag we read afterwards and the TX/RX indices checked 
could be newer than the TX/RX indices used during processing.
Is tg3 then roughly rate limited to the TX and RX queue depth
per poll interval?
(I'm still thinking during-ints limits how much DMA can occur)

Given TG3_TX_RING_SIZE is 512, then I would max out at ~500Kpps
if there is any RX traffic that causes tg3_has_work() to come
back true. While this might be normally ok, I'm looking to
maximize pktgen output w/o disabling/enabling interrupts
for each "batch" of TX packets.


> > 2) tg3_poll() and tg3_msi() are not consistent on how they clear
> >    the SD_STATUS_UPDATED bit. tg3_poll() does not clear SD_STATUS_UPDATED
> >    bit after reading status_tag. I think everytime the driver discovers
> >    the status_tag changed, it should to clear SD_STATUS_UPDATED.
> >    Michael, can you confirm/deny that offhand?
> 
> You're right again. The SD_STATUS_UPDATED bit should be cleared right before
> checking for new work. Clearing the SD_STATUS_UPDATED bit tells the non-msi
> irq handler that all work up to the last status block update has been
> processed.

If I understood this correctly, tg3 may already have new work pending
when tg3_has_work() is called from tg3_poll().  tg3_poll() does not tell
the card anything but promises to pick up where it left off the
next time tg3_poll() is called. If we don't tell the card anything,
it means at some point it's going to stop doing DMA....this might be
one of the things preventing tg3 from doing link rate with pktgen
pushing 64byte packets.

...
> It is important to read the actual status block with the latest indices to
> determine whether there is new work, especially in the non-tagged case where
> you may have race condition between software and hardware.

Yes - I think I understand were several of the races can occur. 
Probably not seeing all of them though.

thanks again,
grant
