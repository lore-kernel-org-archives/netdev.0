From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [patch linux-2.6.11-bk10 1/1] r8169: incoming frame length check
Date: Wed, 16 Mar 2005 14:30:17 -0600
Message-ID: <200503161430.17943.jdmason@us.ibm.com>
References: <20050314233103.GC16072@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Stephen Hemminger <shemminger@osdl.org>, mark@kiora.ath.cx
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050314233103.GC16072@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 14 March 2005 05:31 pm, Francois Romieu wrote:
> The size of the incoming frame is not correctly checked.
>
> The RxMaxSize register (0xDA) does not work as expected and incoming
> frames whose size exceeds the MTU actually end spanning multiple
> descriptors. The first Rx descriptor contains the size of the whole
> frame (or some garbage in its place). The driver does not expect
> something above the space allocated to the current skb and crashes
> loudly when it issues a skb_put.
>
> The fix contains two parts:
> - disable hardware Rx size filtering: so far it only proved to be able
>   to trigger some new fancy errors;
> - drop multi-descriptors frame: as the driver allocates MTU sized Rx
>   buffers, it provides an adequate filtering.
>
> As a bonus, wrong descriptors were not returned to the asic after their
> processing.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applies cleanly and lightly tested on amd64 (kernel version 2.6.11.3).

> diff -puN drivers/net/r8169.c~r8169-570 drivers/net/r8169.c
> --- linux-2.6.11/drivers/net/r8169.c~r8169-570 2005-03-13
> 23:35:37.000000000 +0100 +++ linux-2.6.11-fr/drivers/net/r8169.c 2005-03-14
> 23:47:56.529014957 +0100 @@ -1585,8 +1585,8 @@ rtl8169_hw_start(struct
> net_device *dev)
>   RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
>   RTL_W8(EarlyTxThres, EarlyTxThld);
>
> - /* For gigabit rtl8169, MTU + header + CRC + VLAN */
> - RTL_W16(RxMaxSize, tp->rx_buf_sz);
> + /* Low hurts. Let's disable the filtering. */
> + RTL_W16(RxMaxSize, 16383);

Wouldn't a #define be better than 16k-1?  Perhaps, RxPacketMaxSize could be 
used.

>
>   /* Set Rx Config register */
>   i = rtl8169_rx_config |
> @@ -2127,6 +2127,11 @@ rtl8169_tx_interrupt(struct net_device *
>   }
>  }
>
> +static inline int rtl8169_fragmented_frame(u32 status)
> +{
> + return (status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag);
> +}
> +
>  static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc
> *desc) {
>   u32 opts1 = le32_to_cpu(desc->opts1);
> @@ -2177,27 +2182,41 @@ rtl8169_rx_interrupt(struct net_device *
>
>   while (rx_left > 0) {
>    unsigned int entry = cur_rx % NUM_RX_DESC;
> +  struct RxDesc *desc = tp->RxDescArray + entry;
>    u32 status;
>
>    rmb();
> -  status = le32_to_cpu(tp->RxDescArray[entry].opts1);
> +  status = le32_to_cpu(desc->opts1);
>
>    if (status & DescOwn)
>     break;
>    if (status & RxRES) {
> -   printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
> +   printk(KERN_INFO "%s: Rx ERROR. status = %08x\n",
> +          dev->name, status);
>     tp->stats.rx_errors++;
>     if (status & (RxRWT | RxRUNT))
>      tp->stats.rx_length_errors++;
>     if (status & RxCRC)
>      tp->stats.rx_crc_errors++;
> +   rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>    } else {
> -   struct RxDesc *desc = tp->RxDescArray + entry;
>     struct sk_buff *skb = tp->Rx_skbuff[entry];
>     int pkt_size = (status & 0x00001FFF) - 4;
>     void (*pci_action)(struct pci_dev *, dma_addr_t,
>      size_t, int) = pci_dma_sync_single_for_device;
>
> +   /*
> +    * The driver does not support incoming fragmented
> +    * frames. They are seen as a symptom of over-mtu
> +    * sized frames.
> +    */
> +   if (unlikely(rtl8169_fragmented_frame(status))) {
> +    tp->stats.rx_dropped++;
> +    tp->stats.rx_length_errors++;
> +    rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
> +    goto move_on;
> +   }
> +
>     rtl8169_rx_csum(skb, desc);
>
>     pci_dma_sync_single_for_cpu(tp->pci_dev,
> @@ -2224,7 +2243,7 @@ rtl8169_rx_interrupt(struct net_device *
>     tp->stats.rx_bytes += pkt_size;
>     tp->stats.rx_packets++;
>    }
> -
> +move_on:
>    cur_rx++;
>    rx_left--;
>   }
>
> _

Looks similar to some of the > 8k Jumbo Frames changes.  Should make the diff 
for next patch much cleaner.  Thanks.

-- 
Jon Mason
jdmason@us.ibm.com
