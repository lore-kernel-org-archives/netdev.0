From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sun, 20 Feb 2005 22:54:23 -0600
Message-ID: <200502202254.23511.jdmason@us.ibm.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502201204.23468.jdmason@us.ibm.com> <20050220233405.GA14268@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050220233405.GA14268@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 20 February 2005 05:34 pm, Francois Romieu wrote:
[...]
> > True, but this problem existed before I made the jumbo frames changes.  The 
> 
> AFAIKS, if the rx_copybreak fails, be it because the packet is too big or
> because the allocation failed, the current skb is sent to the upper layers.

You are correct, I misunderstood the error path of the previous rx_copy routine.  

> > static inline int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
> >                               struct RxDesc *desc, struct rtl8169_private *tp)
> > {
> >         u32 status = le32_to_cpu(desc->opts1);
> > 
> >         if ((pkt_size > rx_copybreak) &&
> >                         ((status & FirstFrag) && (status & LastFrag)))
> >                 return -1;
> > 
> >         if (status & FirstFrag) {
> >                 struct sk_buff *skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
> >                 u32 len = (pkt_size > rx_copybreak) ? tp->desc_part : pkt_size;
> > 
> >                 if (skb) {
> >                         skb_reserve(skb, NET_IP_ALIGN);
> >                         memcpy(skb->data, sk_buff[0]->tail, len);
> >                         skb_put(skb, len);
> >                 } else {
> >                         printk(KERN_INFO "no rx skb allocated\n");
> >                         if (pkt_size <= rx_copybreak) 
> >                                 return -1;
> >                 }
> > 
> >                 tp->new_skb = skb;
> >         }
> > 
> > Is this acceptable?
> 
> I'll think more until I can figure I got the whole picture (only copy the
> first frament ?). I would have expected something like the mess below:
> 
> static int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
>       struct RxDesc *desc, struct rtl8169_private *tp)
> {
>  u32 status = le32_to_cpu(desc->opts1);
>  struct sk_buff *skb;
>  int ret = -1;
> 
>  if ((pkt_size > rx_copybreak) && (status & FirstFrag) &&
>      (status & LastFrag)) {
>   goto out;
>  }
> 
>  if (pkt_size < rx_copybreak) {
>   skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
>   if (!skb)
>    goto out;
>   skb_reserve(skb, NET_IP_ALIGN);
>  } else if (status & FirstFrag)
>   skb = tp->new_skb = sk_buff[0];
> 
>  if ((pkt_size < rx_copybreak) || !(status & FirstFrag)) {
>   memcpy(skb->data, sk_buff[0]->tail, pkt_size);
>   rtl8169_return_to_asic(desc, tp->rx_buf_sz);
>   *sk_buff = skb;
>   ret = 0;
>  }
> 
>  skb_put(skb, pkt_size);
> 
> out:
>  return ret;
> }
> 
> At this point I'd expect "How do you handle rtl8169_rx_copy() return ?" 
> (or "yuck").

My main problem with the above patch is that is assumes that there will be a maximum of 2 descriptors per jumbo frame (which isn't the case).  This might have been caused by my incomplete patch given above.  This is what I currently have:
static inline int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
                                struct RxDesc *desc, struct rtl8169_private *tp)
{
        u32 status = le32_to_cpu(desc->opts1);

        if ((pkt_size > rx_copybreak) &&
                        ((status & FirstFrag) && (status & LastFrag)))
                return -1;

        if (status & FirstFrag) {
                u32 len = (pkt_size > rx_copybreak) ? tp->desc_part : pkt_size;
                struct sk_buff *skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
                if (skb) {
                        skb_reserve(skb, NET_IP_ALIGN);
                        memcpy(skb->data, sk_buff[0]->tail, len);
                        skb_put(skb, len);
                } else {
                        printk(KERN_INFO "no rx skb allocated\n");
                        if (pkt_size <= rx_copybreak)
                                return -1;
                }

                tp->new_skb = skb;
        }

        if (!(status & FirstFrag) && !(status & LastFrag) && tp->new_skb) {
                memcpy(tp->new_skb->tail, sk_buff[0]->tail, tp->desc_part);
                skb_put(tp->new_skb, tp->desc_part);
        }

        if (status & LastFrag) {
                if (pkt_size > rx_copybreak && tp->new_skb) {
                        memcpy(tp->new_skb->tail, sk_buff[0]->tail,
                                        pkt_size - tp->new_skb->len);

                        skb_put(tp->new_skb, pkt_size - tp->new_skb->len);
                }

                *sk_buff = tp->new_skb;
        }

        rtl8169_return_to_asic(desc, tp->rx_buf_sz);

        return 0;
}



> [...]
> > If I am still not making sense, I can be more verbose.
> 
> Enlight me with the code, just to be sure.

Working (but still hackish) patch:
--- drivers/net/r8169.c.0220    2005-02-20 22:45:07.000000000 -0600
+++ drivers/net/r8169.c 2005-02-20 22:43:27.000000000 -0600
@@ -1663,7 +1663,8 @@ static void rtl8169_free_rx_skb(struct r
 {
        struct pci_dev *pdev = tp->pci_dev;

-       pci_unmap_single(pdev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
+       //pci_unmap_single(pdev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
+       pci_unmap_single(pdev, le64_to_cpu(desc->addr), tp->desc_part+ETH_HLEN,
                         PCI_DMA_FROMDEVICE);
        dev_kfree_skb(*sk_buff);
        *sk_buff = NULL;
@@ -1694,14 +1695,14 @@ static int rtl8169_alloc_rx_skb(struct r
        dma_addr_t mapping;
        int ret = 0;

-       skb = dev_alloc_skb(rx_buf_sz + NET_IP_ALIGN);
+       skb = dev_alloc_skb(tp->desc_part + ETH_HLEN + NET_IP_ALIGN);
        if (!skb)
                goto err_out;

        skb_reserve(skb, NET_IP_ALIGN);
        *sk_buff = skb;

-       mapping = pci_map_single(tp->pci_dev, skb->tail, rx_buf_sz,
+       mapping = pci_map_single(tp->pci_dev, skb->tail, tp->desc_part+ETH_HLEN,
                                 PCI_DMA_FROMDEVICE);

        rtl8169_give_to_asic(desc, mapping, rx_buf_sz);
@@ -2225,7 +2226,7 @@ rtl8169_rx_interrupt(struct net_device *
                        rtl8169_rx_csum(skb, desc);

                        pci_dma_sync_single_for_cpu(tp->pci_dev,
-                               le64_to_cpu(desc->addr), tp->rx_buf_sz,
+                               le64_to_cpu(desc->addr), tp->desc_part+ETH_HLEN,
                                PCI_DMA_FROMDEVICE);

                        if (rtl8169_rx_copy(&skb, pkt_size, desc, tp)) {
@@ -2235,7 +2236,7 @@ rtl8169_rx_interrupt(struct net_device *
                        }

                        pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
-                                  tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+                                  tp->desc_part+ETH_HLEN, PCI_DMA_FROMDEVICE);

                        if (skb && (status & LastFrag)) {
                                skb->dev = dev;


A more complete patch to follow shortly (as I want to try and fix my tabs problem).
