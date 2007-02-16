From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Fri, 16 Feb 2007 15:23:00 -0500
Message-ID: <20070216202300.GD7585@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:51653 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946127AbXBPUXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 15:23:01 -0500
Content-Disposition: inline
In-Reply-To: <20070216172110.GC7582@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 12:21:10PM -0500, Lennart Sorensen wrote:
> On Fri, Feb 16, 2007 at 10:21:24AM -0600, pcnet32@verizon.net wrote:
> > Are there any messages in the log about timeouts, or anything else from the driver? When it gets in this state, can you communicate with another system, and does it have the same slow behavior?
> 
> Nope no timeouts or messages.  As far as the system looks, cpu and ram and
> logs show nothing unusual.  Just very slow reception on the ethernet port
> going towards the server providing the data for the transfer.  Messages do
> get through eventually, but very very late (when a ping reply arives at
> the port and takes 5 to 10 seconds to make it to the network stack, then
> something isn't right, at least when there is no other traffic waiting).
> 
> I did have NAPI in the driver even in 2.6.8 (I was adding that at the
> time).  I am now testing with 2.6.8 without NAPI (so no mask/unmask of
> receive interrupts taking place), and so far it has run for over an hour
> without failing, although that doens't prove it won't, just that it has
> lasted longer.
> 
> I think I will try compiling 2.6.18 again with NAPI disabled on the
> pcnet32 and see what that does.  There is a chance that something in the
> NAPI implementation is breaking the chip's receive somehow although I
> can't currently imagine what it could be or how.

So I have determined that when the port gets "stuck/slow" it is hitting
this problem:

(in pcnet32_rx):
        while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
                if (netif_msg_intr(lp)) printk(KERN_DEBUG "%s: pcnet32_rx npackets %d\n", dev->name, npackets);
                pcnet32_rx_entry(dev, lp, rxp, entry);
                npackets += 1;
                /*
                 * The docs say that the buffer length isn't touched, but Andrew
                 * Boyd of QNX reports that some revs of the 79C965 clear it.
                 */
                rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
                wmb();  /* Make sure owner changes after others are visible */
                rxp->status = le16_to_cpu(0x8000);
                entry = (++lp->cur_rx) & lp->rx_mod_mask;
                rxp = &lp->rx_ring[entry];
        }

Unfortunately rxp->status reads as 0x8000 for a long time, and then
eventually changes to 0x0310 at which point the receive happens.  Until
that happens, the poll is called about once per second and each time
returns that 0 packets were received but that more packets are waiting.

I can't figure out why it would get a status of 0x8000 which means that
the MAC hasn't changed the ownership flag on the packet yet, even though
it generated a receive interrupt multiple seconds ago.  Could it be some
caching issue that makes the cpu not realize that the memory has in fact
been changed by DMA?  Any way to force a cache update for a memory
location?

The CPU is a Geode SC1200 (Geode GX1 + Companion in one).  So far I have
seen __memcpy from system ram to device memory get data out of order, so
I have no reason to believe the cpu doesn't have more stupid bugs
related to doing I/O.

--
Len Sorensen
