From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9 devices only)
Date: 07 Aug 2007 05:07:17 +0200
Message-ID: <p737io8caai.fsf@bingen.suse.de>
References: <46B79934.8010405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50992 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765213AbXHGCM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 22:12:56 -0400
In-Reply-To: <46B79934.8010405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Kok, Auke" <auke-jan.h.kok@intel.com> writes:

> All,
> 
> Another update on e1000e. Many thanks to Jeff for helping out and
> getting this going forward. The driver is unfortunately still too
> large to post, so please use the URL's below to review:

Just some things I noticed; no comprehensive review

+static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
+{
+       u32 temp;
+
+       e1000_clear_hw_cntrs_base(hw);

Would be much nicer with a table and a loop. Same in similar functions.

+               tx_ring->buffer_info[i].dma =
+                       pci_map_single(pdev, skb->data, skb->len,
+                                      PCI_DMA_TODEVICE);

Misses error handling. Multiple occurrences.

+       rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
+                                            &rx_ring->dma);

If you use dma_alloc_coherent and don't hold a lock (I think you do 
not) you could specify GFP_KERNEL and be more reliable. p_a_c()
unfortunately defaults to flakey GFP_ATOMIC for historical reasons
Multiple occurrences.

+               skb = alloc_skb(2048 + NET_IP_ALIGN, GFP_KERNEL);

alloc_skb already aligns to the next cache line, more might be not needed.
The allocation is quite wasteful because you'll get a full 4K page with
most of it unused.

I remember this being discussed some time ago; it's sad even newer e1000
problems still have the same issue

It's unclear why you clear the skbs here.

+               } while (good_cnt < 64 && jiffies < (time + 20));
Doesn't handle jiffies wrap; use time_* 
More occurrences all over.


+       mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
Should use round_jiffies to avoid wakeups

+s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
A couple of drivers have similar functions. Should be really put
into a generic function into the PCI layer instead of reinventing the wheel.

+       if (ret_val)
+               goto out;
...
+out:
+       return ret_val;

Totally unnecessary goto.  Lots of occurrences.

/* Force memory writes to complete before letting h/w
+                * know there are new descriptors to fetch.  (Only
+                * applicable for weak-ordered memory model archs,
+                * such as IA-64). */
+               wmb();

That is not what a memory barrier does. It just orders the writes,
but doesn't actually flush them.

+               /* Make buffer alignment 2 beyond a 16 byte boundary
+                * this will result in a 16 byte aligned IP header after
+                * the 14 byte MAC header is removed
+                */
+               skb_reserve(skb, NET_IP_ALIGN);
At least on x86 (or other architectures with cheap unalignment
support) it seems like a bad trade off :- it forces the NIC to
do R-M-W to get these 14 bytes and it doesn't help the CPU
too much.

Have you tried if performance improves if the beginning is just
cache line aligned? 

+       /* It must be a TCP or UDP packet with a valid checksum */
You could set skb->protocol then if you know.
If the hw also tells you if the packet was unicast for you then
you could also set skb->pkt_type and avoid an early cache miss.

In general you don't seem to care about PCI posting too much.
I guess it's ok on Intel chipsets, but other chipsets do buffer
a lot.

>E1000_SUCCESS everywhere
It is weird to have an own define for this. How about just 0 as 
the rest of the kernel?

+               prefetch(skb->data - NET_IP_ALIGN);

The minus is useless.

+               prefetch(next_rxd);

Should be probably prefetchw

+                               skb_reserve(new_skb, NET_IP_ALIGN);
+                               memcpy(new_skb->data - NET_IP_ALIGN,
+                                      skb->data - NET_IP_ALIGN,
+                                      length + NET_IP_ALIGN);

Lots of effort to copy useless padding.

-Andi

