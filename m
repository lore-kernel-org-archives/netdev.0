From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sat, 19 Feb 2005 11:47:14 -0600
Message-ID: <200502191147.14845.jdmason@us.ibm.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502181918.07859.jdmason@us.ibm.com> <20050219104640.GA31035@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050219104640.GA31035@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 19 February 2005 04:46 am, Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> > Would you like me to rediff with the changes you suggested?
>
> I have done it and separated the changes. The printk stuff will go in
> a separate netif_msg_xxx and friends patch. See below if you have any
> question. Btw, you can Cc: netdev. It's interesting for everyone to know
> what's going on with r8169 devel.

netdev Cc'ed per your suggestion.

I've taken the liberity of removing all the patches, as they take up alot of 
space and look fine to me.  Good work.

[...]
> > Also, how does the jumbo frames patch look?
>
> 1 - Mangled.

I never said it was pretty, simply a working snapshot of my test driver.  I 
figured that I had been promising you this update for so long, I better send 
it out before you get upset with me.  ;-)

> 2 -
>
> @@ -1627,7 +1652,8 @@ out:
>  static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
>  {
>   desc->addr = 0x0badbadbadbadbadull;
> - desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
> + desc->opts1 &= cpu_to_le32(RingEnd);
> + desc->opts2 = 0;
>  }
>
>  static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
>
> Can you describe the scenario related to the change ?

The change to opts1 seems cleaner to me.  As the only the that the adapter 
needs to know is the RingEnd.  I can try removing it and see if it makes any 
difference.

Opts2 is VERY necessary to zero.  Without this zero, the adapter will change 
the partition point randomly of each packet (random because I have yet to 
determine the rhyme or reason).  I didn't want to spend too much time trying 
to determine the bahavior of this since I found out that zeroing it solved 
the problem.  If you can think of a reason why this doesn't work, I can 
always go back and try to figure it out.

> 3 -
>
> @@ -1652,6 +1680,7 @@ static inline void rtl8169_give_to_asic(
>  {
>   desc->addr = cpu_to_le64(mapping);
>   desc->opts1 |= cpu_to_le32(DescOwn + rx_buf_sz);
> + desc->opts2 = 0;
>  }
>
> I am curious to know if it's there because you noticed that the asic did
> not always update this word or because it is a good practice.
>
> Please note that in its current form it is racy: opts2 should be updated
> before opts1 and a memory barrier should be added.

See above for reason.  I can re-order the operations and a mb (rmd I would 
think).  

> 4 -
>
> @@ -2152,37 +2216,38 @@ rtl8169_rx_interrupt(struct net_device *
>    } else {
>     struct RxDesc *desc = tp->RxDescArray + entry;
>     struct sk_buff *skb = tp->Rx_skbuff[entry];
> -   int pkt_size = (status & 0x00001FFF) - 4;
> +   int pkt_size = (status & 0x00003FFF) - 4;
>     void (*pci_action)(struct pci_dev *, dma_addr_t,
>      size_t, int) = pci_dma_sync_single_for_device;
>
> -   rtl8169_rx_csum(skb, desc);
> -
>     pci_dma_sync_single_for_cpu(tp->pci_dev,
>      le64_to_cpu(desc->addr), tp->rx_buf_sz,
>      PCI_DMA_FROMDEVICE);
> -
> -   if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
> -      tp->rx_buf_sz)) {
> +
> +   rtl8169_rx_csum(skb, desc);
>
> Why is rtl8169_rx_csum() moved around ?

Seemed to make more sense to me to have it after the 
pci_dma_sync_single_for_cpu.  If you disagree, I can move it back.  

> 5 -
> +   if (pkt_size > rx_copybreak) {
> +    memcpy(skb->data, sk_buff[0]->tail,
> +      tp->desc_part);
> +    skb_put(skb, tp->desc_part);
> +   } else {
> +    memcpy(skb->data, sk_buff[0]->tail, pkt_size);
> +    skb_put(skb, pkt_size);
> +   }
> +  } else
>
> I'd rather avoid the code duplication.

Me too, but I couldn't think of a better way.  Suggestions welcomed.

> 5 - rtl8169_return_to_asic() in rtl8169_rx_copy() seems suspect
>     when FirstFrag is true and the skb allocation failed.

In this case the desc is only a portion of the whole packet.  I thought it 
best to toss the whole packet if the driver couldn't alloc a skb, and return 
the descriptor so that it can be used again.  

Actually, talking about this gave me an idea.  Since desc_part is the largest 
skb we will ever need (aside from when they are combined), it would be more 
efficient to use that instead of the full size.  I will create a patch for 
this (and the mb changes) and resubmit it.  Let me know if you want me to 
return other things to their original spot.

> 6 - skb_put() ends duplicated. It should be possible to avoid it.

Is it?  I was specifically trying to aviod that.  Where do you see that?

Thanks,
Jon
