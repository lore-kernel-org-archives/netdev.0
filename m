From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 10:54:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526005429.GC2689@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2004 at 01:04:24PM -0700, Michael Chan wrote:
> > Greg, did you see Micahel Chan's response?  A Broadcom 
> > engineer is telling us "the hardware does not ACK partial TX packets."
> > 
> That's right. The hw is designed to always complete tx packets on packet
> boundaries and not BD boundaries. The send data completion state machine
> will create 1 single dma descriptor and 1 host coalescing descriptor for
> the entire packet. All of our drivers do not handle individual BD
> completions and I'm not aware of any problems caused by this. Actually
> we did see some partial packet completions during the early
> implementions of TSO/LSO. But those were firmware issues and have been
> fixed long time ago. tg3 is not using those early TSO firmware.

I believe the SGI-branded cards ship with firmware fixes beyond simply
changing the PCI ids.  Also, AFAIK it dates from about the time of the
TSO experiments.  Can you check if that firmware has the issue you
describe?

> > I don't argue that you aren't seeing something strange, but 
> > perhaps that is due to corruption occuring elsewhere, or 
> > perhaps something peculiar about your system hardware 
> > (perhaps the PCI controller mis-orders PCI transactions or 
> > something silly like that)?
> Good point. A few years ago we saw cases where there were tx completions
> on BDs that had not been sent. It turned out that on that machine, the
> chipset was re-ordering the posted mmio writes to the send mailbox
> register from 2 CPUs. For example, CPU 1 wrote index 1 and CPU wrote
> index 2 a little later. On the PCI bus, we saw memory write of 2
> followed by 1. When the chip saw 2, it would send both packets. When it
> later saw 1, it thought that there were 512 new tx BDs and went ahead to
> send them. The only effective workaround for this chipset problem was a
> read of the send mailbox after the write to flush it.

The tg3 driver already does this if the TG3_FLAG_MBOX_WRITE_REORDER
flag is set in tp->tg3_flags.  There's been some discussion inside
SGI about that behaviour.  In short, our PCI hardware is susceptible
to PIO write reordering, but experiment has shown that enabling that
flag results in an unacceptable throughput degradation (about 10%).

I have also noticed that under significant load the softirq portion
of the driver gets scheduled on other CPUs than the interrupt CPU,
including CPUs in other NUMA nodes.

This sounds like a theory I can test.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
