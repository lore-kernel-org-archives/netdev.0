From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 5/5] r8169: ethtool hardware statistics support
Date: Wed, 09 Mar 2005 14:53:14 -0500
Message-ID: <422F542A.3020907@pobox.com>
References: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add ethtool support for dumping the chip statistics. There aren't lots
> of statistics available, but this is what is available according to the RealTek
> documentation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
> --- a/drivers/net/r8169.c	2005-03-09 11:26:04 -08:00
> +++ b/drivers/net/r8169.c	2005-03-09 11:26:04 -08:00
> @@ -195,6 +195,8 @@
>  enum RTL8169_registers {
>  	MAC0 = 0,		/* Ethernet hardware address. */
>  	MAR0 = 8,		/* Multicast filter. */
> +	CounterAddrLow = 0x10,
> +	CounterAddrHigh = 0x14,
>  	TxDescStartAddrLow = 0x20,
>  	TxDescStartAddrHigh = 0x24,
>  	TxHDescStartAddrLow = 0x28,
> @@ -336,6 +338,9 @@
>  
>  	/* _TBICSRBit */
>  	TBILinkOK = 0x02000000,
> +
> +	/* DumpCounterCommand */
> +	CounterDump = 0x8,
>  };
>  
>  enum _DescStatusBit {
> @@ -897,6 +902,100 @@
>  	tp->msg_enable = value;
>  }
>  
> +static const char rtl8169_gstrings[][ETH_GSTRING_LEN] = {
> +	"tx_packets",
> +	"rx_packets",
> +	"tx_errors",
> +	"rx_errors",
> +	"rx_missed",
> +	"align_errors",
> +	"tx_single_collisions",
> +	"tx_multi_collisions",
> +	"unicast",
> +	"broadcast",
> +	"multicast",
> +	"tx_aborted",
> +	"tx_underrun",
> +};
> +
> +struct rtl8169_counters {
> +	u64	tx_packets;
> +	u64	rx_packets;
> +	u64	tx_errors;
> +	u32	rx_errors;
> +	u16	rx_missed;
> +	u16	align_errors;
> +	u32	tx_one_collision;
> +	u32	tx_multi_collision;
> +	u64	rx_unicast;
> +	u64	rx_broadcast;
> +	u32	rx_multicast;
> +	u16	tx_aborted;
> +	u16	tx_underun;
> +};
> +
> +static int rtl8169_get_stats_count(struct net_device *dev)
> +{
> +	return 13;
> +}

maintenance:  use a constant, not a magic number.


> +static void rtl8169_get_ethtool_stats(struct net_device *dev,
> +				      struct ethtool_stats *stats, u64 *data)
> +{
> +        struct rtl8169_private *tp = netdev_priv(dev);

whitespace breakage


> +	struct rtl8169_counters *counters;
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	int i;
> +	dma_addr_t paddr;
> +	u32 cmd;
> +
> +	ASSERT_RTNL();
> +
> +	counters = pci_alloc_consistent(tp->pci_dev, sizeof(*counters),
> +					&paddr);
> +	if (!counters)
> +		return;
> +	
> +	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
> +	cmd = (u64) paddr & DMA_32BIT_MASK;
> +	RTL_W32(CounterAddrLow, cmd);
> +	RTL_W32(CounterAddrLow, cmd | CounterDump);
> +
> +	for (i = 0; i < 1000; i++) {
> +		if (!RTL_R32(CounterAddrLow) & CounterDump)
> +			break;
> +		udelay(10);
> +	}
> +	RTL_W32(CounterAddrLow, 0);
> +	RTL_W32(CounterAddrHigh, 0);
> +
> +	data[0]	= le64_to_cpu(counters->tx_packets);
> +	data[1] = le64_to_cpu(counters->rx_packets);
> +	data[2] = le64_to_cpu(counters->tx_errors);
> +	data[3] = le32_to_cpu(counters->rx_errors);
> +	data[4] = le16_to_cpu(counters->rx_missed);
> +	data[5] = le16_to_cpu(counters->align_errors);
> +	data[6] = le32_to_cpu(counters->tx_one_collision);
> +	data[7] = le32_to_cpu(counters->tx_multi_collision);
> +	data[8] = le64_to_cpu(counters->rx_unicast);
> +	data[9] = le64_to_cpu(counters->rx_broadcast);
> +	data[10] = le32_to_cpu(counters->rx_multicast);
> +	data[11] = le16_to_cpu(counters->tx_aborted);
> +	data[12] = le16_to_cpu(counters->tx_underun);

use the "i++" indexing method found in other drivers.  The above code 
becomes an immediate PITA when you want to insert a new stat near the 
top (such as a software-generate stat).

Also, it's nice to add a BUG (or WARN_ON) check like the check found in 
other drivers.  That helps you ensure that the R8169_STATS_COUNT equals 
the number of entries you added to the data output.

	Jeff
