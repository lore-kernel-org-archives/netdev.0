From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9
 devices only)
Date: Fri, 10 Aug 2007 13:17:21 -0700
Message-ID: <46BCC7D1.9060606@intel.com>
References: <46B79934.8010405@intel.com> <p737io8caai.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	NetDev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9142 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756841AbXHJURY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:17:24 -0400
In-Reply-To: <p737io8caai.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "Kok, Auke" <auke-jan.h.kok@intel.com> writes:
> 
>> All,
>>
>> Another update on e1000e. Many thanks to Jeff for helping out and
>> getting this going forward. The driver is unfortunately still too
>> large to post, so please use the URL's below to review:
> 
> Just some things I noticed; no comprehensive review

OK, I just pushed a bunch of patches to Jeff to address some of this...

> +static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
> +{
> +       u32 temp;
> +
> +       e1000_clear_hw_cntrs_base(hw);
> 
> Would be much nicer with a table and a loop. Same in similar functions.

I'm leaving this for now. We've always done it this way and while I tend to 
agree it could be more organized, it's a low priority for me to do stuff like 
this for now :)

> +               tx_ring->buffer_info[i].dma =
> +                       pci_map_single(pdev, skb->data, skb->len,
> +                                      PCI_DMA_TODEVICE);
> 
> Misses error handling. Multiple occurrences.

I tried to address all of these properly. It's interesting to see how few 
drivers do this properly. I wonder how much it impacts performance and if it is 
really worth it.

> +       rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
> +                                            &rx_ring->dma);
> 
> If you use dma_alloc_coherent and don't hold a lock (I think you do 
> not) you could specify GFP_KERNEL and be more reliable. p_a_c()
> unfortunately defaults to flakey GFP_ATOMIC for historical reasons
> Multiple occurrences.

done, seems like a very good idea indead.

> +               skb = alloc_skb(2048 + NET_IP_ALIGN, GFP_KERNEL);
> 
> alloc_skb already aligns to the next cache line, more might be not needed.
> The allocation is quite wasteful because you'll get a full 4K page with
> most of it unused.
> 
> I remember this being discussed some time ago; it's sad even newer e1000
> problems still have the same issue

not an e1000 problem. All drivers do this as it's a significant gain. See 
original thread from 2004 here:

http://lwn.net/Articles/89770/


> It's unclear why you clear the skbs here.
> 
> +               } while (good_cnt < 64 && jiffies < (time + 20));
> Doesn't handle jiffies wrap; use time_* 
> More occurrences all over.

made it use time_after()

> +       mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
> Should use round_jiffies to avoid wakeups

I don't expect people to have their leds blinking 24/7 while the rtnl lock is 
held, so those 2 extra wakeups per second are nice to have at proper intervals.

> +s32 e1000_get_bus_info_pcie(struct e1000_hw *hw)
> A couple of drivers have similar functions. Should be really put
> into a generic function into the PCI layer instead of reinventing the wheel.
> 
> +       if (ret_val)
> +               goto out;
> ...
> +out:
> +       return ret_val;
> 
> Totally unnecessary goto.  Lots of occurrences.

cleaned up.

> /* Force memory writes to complete before letting h/w
> +                * know there are new descriptors to fetch.  (Only
> +                * applicable for weak-ordered memory model archs,
> +                * such as IA-64). */
> +               wmb();
> 
> That is not what a memory barrier does. It just orders the writes,
> but doesn't actually flush them.
> 
> +               /* Make buffer alignment 2 beyond a 16 byte boundary
> +                * this will result in a 16 byte aligned IP header after
> +                * the 14 byte MAC header is removed
> +                */
> +               skb_reserve(skb, NET_IP_ALIGN);
> At least on x86 (or other architectures with cheap unalignment
> support) it seems like a bad trade off :- it forces the NIC to
> do R-M-W to get these 14 bytes and it doesn't help the CPU
> too much.
> 
> Have you tried if performance improves if the beginning is just
> cache line aligned? 

I'll need to look into that, but as said above and as can be seen in the kernel 
code, on PPC (e.g.) NET_IP_ALIGN is zero due to the expensiveness of this 
alignment, and so we have that problem covered.

> +       /* It must be a TCP or UDP packet with a valid checksum */
> You could set skb->protocol then if you know.
> If the hw also tells you if the packet was unicast for you then
> you could also set skb->pkt_type and avoid an early cache miss.
> 
> In general you don't seem to care about PCI posting too much.
> I guess it's ok on Intel chipsets, but other chipsets do buffer
> a lot.

we've added (over time) some write flushes in problematic areas, I think we're 
OK currently.

>> E1000_SUCCESS everywhere
> It is weird to have an own define for this. How about just 0 as 
> the rest of the kernel?

all gone.


thanks for the comments,

Auke
