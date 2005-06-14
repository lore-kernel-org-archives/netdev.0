From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 14 Jun 2005 08:40:21 -0700
Message-ID: <20050614154021.GA24371@esmail.cup.hp.com>
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
> Yes, you're right. rmb() is needed between reading the tag and tg3_has_work()
> to guarantee strict ordering. Otherwise, tg3_has_work() may get ahead and
> read stale information that may be older than the tag.

Ok - thanks for confirming. I just wasn't sure any more.
It's been a year or so since I looked at this last time.

> But the clearing of
> the SD_STATUS_UPDATED bit does not need any additional barriers.
...
> You're right again. The SD_STATUS_UPDATED bit should be cleared right before
> checking for new work. Clearing the SD_STATUS_UPDATED bit tells the non-msi
> irq handler that all work up to the last status block update has been
> processed.
...
> The clearing of the SD_STATUS_UPDATED bit does not have to follow very strict
> ordering for the following reasons:
> 
> 1. It has no hardware significance. It is purely to tell the irq handler that
> the current status block has been processed. For MSI, since we don't even
> check that bit in tg3_msi(), we can skip clearing that bit. But I think it is
> safer to clear it because tg3_cond_int() is checking it.

Ok - I thought the NIC was reading that back for some reason.
If we can ignore SD_STATUS_UPDATED and use a flag not related
to sblk, I think it would be cacheline friendlier. But it's
a minor issue.

> 2. We only clear it when interrupt from the NIC is disabled, either in irq
> handler or tg3_poll(). So there is no potential contention.
> 
> So the current sequence is fine.

ok - thank you for the clarification.

> It is important to read the actual status block with the latest indices to
> determine whether there is new work, especially in the non-tagged case where
> you may have race condition between software and hardware.

Certainly...my point was we should not read them on every iteration
of the RX or TX loop that processes packets - but rather outside that loop.
And I'd think we want to read the three values (status tag, tx_consumer,
and rx_producer) as a set - ie read them and process stuff until
we've exhausted the "work quota" or the driver has caught up
to the HW (status tag stops changing).

I don't see a problem with exiting tg3_poll despite more work
pending if we know we are going to catch it on the next round.
After all, we are polling - latency is going to be semi random
depending on where we are in the sequence anyway.

thanks,
grant
