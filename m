From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 13:02:46 -0500
Message-ID: <4220B9C6.1010106@pobox.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <200502261132.29261.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200502261132.29261.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> On Saturday 26 February 2005 08:53 am, Richard Dawe wrote:
> 
>>Hi Francois and Jon!
>>
>>Please find attached a patch that adds the hardware statistics ethtool 
>>operations to the r8169 driver. It's against 2.6.11-rc5.
> 
> 
> Good Work!  I'll give it a try here in a little bit.
> 
> [...]
> 
>>If I then bring the interface up ("ifconfig eth0 up"), I get valid stats.
>>
>>Any suggestions on how to fix this? I tried a couple of things:
>>
>>* Return in get_ethtool_stats if !netif_running(). Made no difference.
>>
>>* Zero the stats after creating the DMA mapping with 
>>pci_alloc_consistent(). Made no difference.
> 
> 
> Can you confirm that the registers are outputting these bogus values?
> 
> See comments below. 
> 
> <paste from attachment>
> 
> --- linux-2.6.11-rc5/drivers/net/r8169.c.orig   2005-02-24 16:40:30.000000000 +0000
> +++ linux-2.6.11-rc5/drivers/net/r8169.c        2005-02-26 14:28:37.000000000 +0000
> @@ -128,6 +128,7 @@ static int multicast_filter_limit = 32;
>  #define RX_BUF_SIZE    1536    /* Rx Buffer size */
>  #define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
>  #define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))
> +#define R8169_STATS_BYTES      64
>  
>  #define RTL8169_TX_TIMEOUT     (6*HZ)
>  #define RTL8169_PHY_TIMEOUT    (10*HZ)
> @@ -187,6 +188,8 @@ static int use_dac;
>  enum RTL8169_registers {
>         MAC0 = 0,               /* Ethernet hardware address. */
>         MAR0 = 8,               /* Multicast filter. */
> +       StatsAddrLow = 0x10,
> +       StatsAddrHigh = 0x14,
>         TxDescStartAddrLow = 0x20,
>         TxDescStartAddrHigh = 0x24,
>         TxHDescStartAddrLow = 0x28,
> @@ -255,6 +258,9 @@ enum RTL8169_register_content {
>         Cfg9346_Lock = 0x00,
>         Cfg9346_Unlock = 0xC0,
>  
> +       /* StatsAddr register */
> +       DumpStats = (1 << 3),
> +
> 
> Wouldn't this be better as "0x08"?  Also, RTL8169_register_content could do with a bit of tidying (values are expressed in decimal and hex, some are aligned and others not, etc).  I'll try and come-up with a patch here in a bit.

The form "(1 << n)" is preferred, since that form makes plain the bit 
number, with zero neural transformation required.

Use the more readable form.  Cleanup patches accepted.


>         /* rx_mode_bits */
>         AcceptErr = 0x20,
>         AcceptRunt = 0x10,
> @@ -380,6 +386,22 @@ struct ring_info {
>         u8              __pad[sizeof(void *) - sizeof(u32)];
>  };
>  
> +struct rtl8169_stats {
> +       u64 tx_ok;
> +       u64 rx_ok;
> +       u64 tx_err;
> +       u32 rx_err;
> +       u16 rx_fifo;
> +       u16 frame_align;
> +       u32 tx_ok_1col;
> +       u32 tx_ok_mcol;
> +       u64 rx_ok_phys;
> +       u64 rx_ok_bcast;
> +       u32 rx_ok_mcast;
> +       u16 tx_abort;
> +       u16 tx_underrun;
> +} __attribute__((packed));
> +
> 
> 
> These could all be u64's.  It would take-up more memory (and a bit more code in the register dump), but the values would be more accurate.  Just an idea.

No, this is the representation of the hardware DMA structure.

It is defined by the hardware, not the programmer.


> +static void rtl8169_get_ethtool_stats(struct net_device *netdev,
> +       struct ethtool_stats *stats, u64 *data)
> +{
> +       struct rtl8169_private *tp = netdev_priv(netdev);
> +       void __iomem *ioaddr = tp->mmio_addr;
> +       int work = 100;
> +       int i;
> +
> +       /* begin NIC statistics dump */
> +       RTL_W32(StatsAddrHigh, tp->nic_stats_addr >> 32);
> +       RTL_W32(StatsAddrLow, (tp->nic_stats_addr & 0xffffffff) | DumpStats);
> +       RTL_R32(StatsAddrLow);
> +
> +       while (work-- > 0) {
> +               if ((RTL_R32(StatsAddrLow) & DumpStats) == 0)
> +                       break;
> +               cpu_relax();
> +       }
> +
> +       if (RTL_R32(StatsAddrLow) & DumpStats)
> +               return; /* no stats - took too long */
> +
> +       i = 0;
> +       data[i++] = le64_to_cpu(tp->nic_stats->tx_ok);
> +       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok);
> +       data[i++] = le64_to_cpu(tp->nic_stats->tx_err);
> +       data[i++] = le32_to_cpu(tp->nic_stats->rx_err);
> +       data[i++] = le16_to_cpu(tp->nic_stats->rx_fifo);
> +       data[i++] = le16_to_cpu(tp->nic_stats->frame_align);
> +       data[i++] = le32_to_cpu(tp->nic_stats->tx_ok_1col);
> +       data[i++] = le32_to_cpu(tp->nic_stats->tx_ok_mcol);
> +       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok_phys);
> +       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok_bcast);
> +       data[i++] = le32_to_cpu(tp->nic_stats->rx_ok_mcast);
> +       data[i++] = le16_to_cpu(tp->nic_stats->tx_abort);
> +       data[i++] = le16_to_cpu(tp->nic_stats->tx_underrun);
> +       if (i != RTL8169_STATS_LEN)
> +               BUG();
> +}
> +
> 
> It seems to me that 'i' could be re-used, instead of having both 'i' and 'work'.

No.  That's a completely useless pseudo-optimization.  Write readable 
code, and let the compiler do the rest.

Any modern compiler will see where the live range of 'work' ends, and 
'i' begins.


   Also,  'u32' or 'unsigned int' is prefered to int  (see 
http://www.kroah.com/linux/talks/portable_kernel_code_talk_2001_10_02/mgp00022.html). 
  Also, changes will need to be made if it is decided to use u64 (see above)

True, but irrelevant in this case.  The code generated by the compiler 
is the same.

	Jeff
