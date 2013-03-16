From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: igb_poll - device driver failed to check map error
Date: Sat, 16 Mar 2013 12:07:39 +0100
Message-ID: <3729150.HPUjKjXiGc@cpaasch-mac>
References: <7974689.msj0QTRKPV@cpaasch-mac> <1899985.NhtD8IVCbT@cpaasch-mac> <5143A9EF.6030302@intel.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:38230 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab3CPLHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 07:07:44 -0400
Received: by mail-ee0-f52.google.com with SMTP id b15so1913258eek.11
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 04:07:42 -0700 (PDT)
In-Reply-To: <5143A9EF.6030302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 March 2013 16:08:31 Alexander Duyck wrote:
> On 03/15/2013 12:52 AM, Christoph Paasch wrote:
> > On Thursday 14 March 2013 19:18:18 Alexander Duyck wrote:
> >> On 03/12/2013 02:31 AM, Christoph Paasch wrote:
> >>> Hello,
> >>> 
> >>> I'm seeing a warning while booting my machine when DMA_API_DEBUG is set:
> >>> 
> >>> [   36.402824] ------------[ cut here ]------------
> >>> [   36.458070] WARNING: at
> >>> /home/cpaasch/builder/net-next/lib/dma-debug.c:934
> >>> check_unmap+0x648/0x702()
> >>> [   36.567377] Hardware name: ProLiant DL165 G7
> >>> [   36.618452] igb 0000:04:00.0: DMA-API: device driver failed to check
> >>> map
> >>> error[device address=0x0000000233d9b232] [size=154 bytes] [mapped as
> >>> single] [   36.776640] Modules linked in:
> >>> [   36.815446] Pid: 0, comm: swapper/7 Not tainted 3.9.0-rc1-mptcp+ #101
> >>> [   36.892515] Call Trace:
> >>> [   36.921745]  <IRQ>  [<ffffffff8102ad7f>]
> >>> warn_slowpath_common+0x80/0x9a
> >>> [   37.001023]  [<ffffffff8102ae2d>] warn_slowpath_fmt+0x41/0x43
> >>> [   37.069771]  [<ffffffff811db17f>] check_unmap+0x648/0x702
> >>> [   37.134363]  [<ffffffff811db3e9>] debug_dma_unmap_page+0x50/0x52
> >>> [   37.206234]  [<ffffffff8136676a>] igb_poll+0x144/0xf7c
> >>> [   37.267706]  [<ffffffff8104dd19>] ? sched_clock_cpu+0x46/0xd1
> >>> [   37.336456]  [<ffffffff814458ce>] net_rx_action+0xa7/0x1d0
> >>> [   37.402085]  [<ffffffff81030b65>] __do_softirq+0xb4/0x16f
> >>> [   37.466673]  [<ffffffff81030c90>] irq_exit+0x40/0x87
> >>> [   37.526067]  [<ffffffff81002db1>] do_IRQ+0x98/0xaf
> >>> [   37.583378]  [<ffffffff815210aa>] common_interrupt+0x6a/0x6a
> >>> [   37.651086]  <EOI>  [<ffffffff8105d4be>] ?
> >>> __tick_nohz_idle_enter+0x116/0x31f
> >>> [   37.736595]  [<ffffffff81008a04>] ? default_idle+0x24/0x39
> >>> [   37.802224]  [<ffffffff81008c62>] cpu_idle+0x68/0xa4
> >>> [   37.861616]  [<ffffffff81519f78>] start_secondary+0x1a9/0x1ad
> >>> [   37.930364] ---[ end trace 01b5bb0fd75a464c ]---
> >>> 
> >>> 
> >>> It happens shortly after mounting the NFS-root filesystem.
> >>> 
> >>> I tried to understand what is going on, but I am now at my wit's end.
> >>> 
> >>> By adding some print-statements, here is what I found out (not sure if
> >>> this is anyhow helpful):
> >>> 
> >>> The difference between tx_buffer->time_stamp and the current 'jiffies'
> >>> is
> >>> up to 2000 jiffies (HZ==1000) at the first time the above warning
> >>> happens
> >>> (this seems too much for me). From then on, I see my print 3-4 times
> >>> appear but without such a big difference between the timestamps
> >>> (difference around 1 and 2 jiffies).
> >>> 
> >>> Some other stuff, I printed:
> >>> tx_buffer->skb: ffff880235054c80
> >>> tx_buffer->bytecount: 154
> >>> tx_buffer->gso_segs: 1
> >>> tx_buffer->protocol: 8
> >>> tx_buffer->tx_flags 0x20
> >>> 
> >>> 
> >>> One last thing:
> >>> Am I right that after each call to dma_map_single/page a call to
> >>> dma_mapping_error is needed? If that's the case, I have some patches
> >>> that
> >>> add this statement at missing places in the e1000, e1000e and ixgb
> >>> driver. But these patches do not fix my above problem.
> >>> 
> >>> 
> >>> Thanks for your help,
> >>> Christoph
> >> 
> >> Christoph,
> >> 
> >> One thing that might be useful would be to reproduce this with a
> >> standard 3.9-rc kernel instead of one using the multipath TCP patches.
> >> This will help us to verify that the issue is reproducible with a stock
> >> kernel and is not related to any ongoing work you may have only in your
> >> tree.
> > 
> > Hello,
> > 
> > this is on a clean net-next kernel without any MPTCP-code.
> > 
> > I bisected it down to  787314c35fbb (Merge tag 'iommu-updates-v3.8' of
> > git://git.kernel.org/pub/scm/linux/kernel/git/joro/iommu), which simply
> > introduces the debug_dma_mapping_error-checks.
> > 
> > Am I right with the missing calls to dma_mapping_error in e1000, e1000e
> > and
> > ixgb?
> > 
> > Cheers,
> > Christoph
> 
> Christoph,
> 
> The cause of this issues you are seeing may be due to the fact that the
> buffer triggering the error is being reused.  I was able to reproduce
> this issue occasionally with pktgen if I cloned the skb.  What may be
> happening is that the buffer is being mapped in the transmit path on one
> CPU while on another CPU the buffer is being cleaned.  Since the output
> of each mapping is the physical address there is nothing to make each
> mapping unique and I suspect this is resulting in false hits.
> 
> You should be able to verify this if you were to check the skb->users
> count as well as the dataref value in the skb_shared_info.  I suspect
> either the users count of the dataref will be greater than 1.

Both, users and dataref, are equal to 1. Before the call to dev_kfree_skb_any 
and after dma_unmap_single fails.

> You might also try testing the patch below to see if it has any effect.
>  All it does is reorder the free and the unmap so that the buffer is not
> freed for reuse until after we have checked it in the unmap path.

I tested your patch, and it fixes my issue. Feel free to add a "Tested-by" to 
the official patch.


Cheers,
Christoph

> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index 4dbd629..0f9c324 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5959,15 +5959,15 @@ static bool igb_clean_tx_irq(struct igb_q_vector
> *q_vector)
>  		total_bytes += tx_buffer->bytecount;
>  		total_packets += tx_buffer->gso_segs;
> 
> -		/* free the skb */
> -		dev_kfree_skb_any(tx_buffer->skb);
> -
>  		/* unmap skb header data */
>  		dma_unmap_single(tx_ring->dev,
>  				 dma_unmap_addr(tx_buffer, dma),
>  				 dma_unmap_len(tx_buffer, len),
>  				 DMA_TO_DEVICE);
> 
> +		/* free the skb */
> +		dev_kfree_skb_any(tx_buffer->skb);
> +
>  		/* clear tx_buffer data */
>  		tx_buffer->skb = NULL;
>  		dma_unmap_len_set(tx_buffer, len, 0);
-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
