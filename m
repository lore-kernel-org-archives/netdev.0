From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] Add support for ethtool operations and statistics to
 RDC-R6040.
Date: Wed, 12 Oct 2016 02:36:44 -0700
Message-ID: <6193884d-b3d0-9e3a-9209-f3d7c2ba10cd@gmail.com>
References: <1476254164-3552-1-git-send-email-venkat.prashanth2498@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: VENKAT PRASHANTH B U <venkat.prashanth2498@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35611 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932485AbcJLJhe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 05:37:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id 123so1488008wmb.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 02:36:52 -0700 (PDT)
In-Reply-To: <1476254164-3552-1-git-send-email-venkat.prashanth2498@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2016 11:36 PM, VENKAT PRASHANTH B U wrote:
> This is a patch to add support for ethtool operations and keeping
> up to date statistics for RDC R6040 fast ethernet MAC driver.
> 
> Signed-off-by: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>
> ---
> changelog v3:
> -Made the commit message more clear.
> -Modified the locking interface used in r6040_get_regs().
> -Verified the tabs vs space indentation.

The tabs vs. spaces still look odd in this submission, please run
scripts/checkpatch.pl on the patch file to make sure the script is also
happy.

> -code cleanup on r6040_get_regs()
> -Implemented a get_ethtool_stats callback that fills the shadow copy
>  of statistics obtained in the software.
> 
> changelog v2:
> -Made the commit message more clear
> -Add enumeration data type RTL_FLAG_MAX
> -Modified the locking interface used in r6040_get_regs()
> -Initialized mutex dynamically in a function r6040_get_regs()
> -Declared u32 msg_enable in struct r6040_private.
> ---
> ---
> drivers/net/ethernet/rdc/r6040.c | 229 +++++++++++++++++++++++++++++++++++++++
> 1 file changed, 229 insertions(+)
> 
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
> index cb29ee2..83478b1 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -44,6 +44,7 @@
> #include <linux/irq.h>
> #include <linux/uaccess.h>
> #include <linux/phy.h>
> +#include <linux/pm_runtime.h>
>  
> #include <asm/processor.h>
>  
> @@ -172,6 +173,62 @@ MODULE_VERSION(DRV_VERSION " " DRV_RELDATE);
> #define TX_INTS			(TX_FINISH)
> #define INT_MASK		(RX_INTS | TX_INTS)
>  
> +/* write/read MMIO register */
> +#define R6040_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
> +#define R6040_W16(reg, val16)	writew ((val16), ioaddr + (reg))
> +#define R6040_W32(reg, val32)	writel ((val32), ioaddr + (reg))
> +#define R6040_R8(reg)		readb (ioaddr + (reg))
> +#define R6040_R16(reg)		readw (ioaddr + (reg))
> +#define R6040_R32(reg)		readl (ioaddr + (reg))
> +
> +enum r6040_flag
> +{
> +  RTL_FLAG_MAX
> +};
> +
> +enum r6040_registers {
> +	CounterAddrLow		= 0x10,
> +	CounterAddrHigh		= 0x14,
> +	ChipCmd			= 0x37,
> +};
> +
> +enum r6040_register_content {
> +	/* ChipCmdBits */
> +	StopReq			= 0x80,
> +	CmdReset		= 0x10,
> +	CmdRxEnb		= 0x08,
> +	CmdTxEnb		= 0x04,
> +	RxBufEmpty		= 0x01,
> +	/* ResetCounterCommand */
> +	CounterReset	= 0x1,
> +
> +	/* DumpCounterCommand */
> +	CounterDump		= 0x8,
> +};

No CamelCase style please, this is not the realtek drivers.

> +
> +struct r6040_counters {
> +	__le64	tx_packets;
> +	__le64	rx_packets;
> +	__le64	tx_errors;
> +	__le32	rx_errors;
> +	__le16	rx_missed;
> +	__le16	align_errors;
> +	__le32	tx_one_collision;
> +	__le32	tx_multi_collision;
> +	__le64	rx_unicast;
> +	__le64	rx_broadcast;
> +	__le32	rx_multicast;
> +	__le16	tx_aborted;
> +	__le16	tx_underun;
> +};
> +
> +struct r6040_tc_offsets {
> +	bool	inited;

initialized maybe?

> +	__le64	tx_errors;
> +	__le32	tx_multi_collision;
> +	__le16	tx_aborted;
> +};
> +
> struct r6040_descriptor {
> 	u16	status, len;		/* 0-3 */
> 	__le32	buf;			/* 4-7 */
> @@ -192,10 +249,14 @@ struct r6040_private {
> 	struct r6040_descriptor *tx_remove_ptr;
> 	struct r6040_descriptor *rx_ring;
> 	struct r6040_descriptor *tx_ring;
> +	struct r6040_counters *counters;
> +	struct r6040_tc_offsets tc_offset;
> 	dma_addr_t rx_ring_dma;
> 	dma_addr_t tx_ring_dma;
> +	dma_addr_t counters_phys_addr;
> 	u16	tx_free_desc;
> 	u16	mcr0;
> +	u32 msg_enable;
> 	struct net_device *dev;
> 	struct mii_bus *mii_bus;
> 	struct napi_struct napi;
> @@ -955,12 +1016,180 @@ static void netdev_get_drvinfo(struct net_device *dev,
> 	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
> }
>  
> +static int
> +r6040_get_regs_len (struct net_device *dev)
> +{
> +  return R6040_IO_SIZE;
> +}

Tabs vs. spaces here.

> +
> +static void
> +r6040_get_regs (struct net_device *dev, struct ethtool_regs *regs, void *p)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +  u32 __iomem *data = tp->base;
> +  u32 *dw = p;
> +  int i;
> +
> +  spin_lock (&tp->lock);
> +  for (i = 0; i < R6040_IO_SIZE; i += 4)
> +    memcpy_fromio (dw++, data++, 4);
> +  spin_unlock (&tp->lock);

What part of my last comment was not clear when I indicated that
registers are typically (exclusively actually) 16-bit wide?

> +}
> +
> +static u32
> +r6040_get_msglevel (struct net_device *dev)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +
> +  return tp->msg_enable;
> +}

Tabs vs. spaces here.

> +
> +static void
> +r6040_set_msglevel (struct net_device *dev, u32 value)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +
> +  tp->msg_enable = value;
> +}

Same thing, this is not used for anything unless you start using
netif_msg_* print functions, which this patch is not doing... and also
tabs vs. spaces here.

> +
> +static const char r6040_gstrings[][ETH_GSTRING_LEN] = {
> +  "tx_packets",
> +  "rx_packets",
> +  "tx_errors",
> +  "rx_errors",
> +  "rx_missed",
> +  "align_errors",
> +  "tx_single_collisions",
> +  "tx_multi_collisions",
> +  "unicast",
> +  "broadcast",
> +  "multicast",
> +  "tx_aborted",
> +  "tx_underrun",
> +};

Tabs vs. spaces here.

> +
> +static int
> +r6040_get_sset_count (struct net_device *dev, int sset)
> +{
> +  switch (sset)
> +    {
> +    case ETH_SS_STATS:
> +      return ARRAY_SIZE (r6040_gstrings);
> +    default:
> +      return -EOPNOTSUPP;
> +    }
> +}

This function's indentation is off.

> +
> +static bool r6040_do_counters(struct net_device *dev, u32 counter_cmd)
> +{
> +	struct r6040_private *tp = netdev_priv(dev);
> +	void __iomem *ioaddr = tp->base;
> +	dma_addr_t paddr = tp->counters_phys_addr;
> +	u32 cmd;
> +
> +	R6040_W32(CounterAddrHigh, (u64)paddr >> 32);
> +	cmd = (u64)paddr & DMA_BIT_MASK(32);
> +	R6040_W32(CounterAddrLow, cmd);
> +	R6040_W32(CounterAddrLow, cmd | counter_cmd);
> +
> +
> +	R6040_W32(CounterAddrLow, 0);
> +	R6040_W32(CounterAddrHigh, 0);
> +	return 0;

I will have to check the datasheet for the correctness of that code, but
there are bigger issues in your patch submission to fix first.

> +}
> +
> +static bool r6040_reset_counters(struct net_device *dev)
> +{
> +	return r6040_do_counters(dev, CounterReset);
> +}
> +
> +static bool r6040_update_counters(struct net_device *dev)
> +{
> +	struct r6040_private *tp = netdev_priv(dev);
> +	void __iomem *ioaddr = tp->base;
> +
> +	if ((R6040_R8(ChipCmd) & CmdRxEnb) == 0)
> +		return true;
> +
> +	return r6040_do_counters(dev, CounterDump);
> +}
> +
> +static bool r6040_init_counter_offsets(struct net_device *dev)
> +{
> +	struct r6040_private *tp = netdev_priv(dev);
> +	struct r6040_counters *counters = tp->counters;
> +	bool ret = false;
> +
> +	if (tp->tc_offset.inited)
> +		return true;
> +
> +	/* If both, reset and update fail, propagate to caller. */
> +	if (r6040_reset_counters(dev))
> +		ret = true;
> +
> +	if (r6040_update_counters(dev))
> +		ret = true;
> +
> +	tp->tc_offset.tx_errors = counters->tx_errors;
> +	tp->tc_offset.tx_multi_collision = counters->tx_multi_collision;
> +	tp->tc_offset.tx_aborted = counters->tx_aborted;
> +	tp->tc_offset.inited = true;
> +
> +	return ret;
> +}
> +
> +static void r6040_get_ethtool_stats(struct net_device *dev,
> +				      struct ethtool_stats *stats, u64 *data)
> +{
> +	struct r6040_private *tp = netdev_priv(dev);
> +	struct device *d = &tp->pdev->dev;
> +	struct r6040_counters *counters = tp->counters;
> +
> +	pm_runtime_get_noresume(d);
> +
> +	if (pm_runtime_active(d))
> +		r6040_update_counters(dev);
> +	pm_runtime_put_noidle(d);
> +
> +	data[0] = le64_to_cpu(counters->tx_packets);
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
> +}
> +
> +static void
> +r6040_get_strings (struct net_device *dev, u32 stringset, u8 * data)
> +{
> +  switch (stringset)
> +    {
> +    case ETH_SS_STATS:
> +      memcpy (data, *r6040_gstrings, sizeof (r6040_gstrings));
> +      break;
> +    }
> +}
> +
> static const struct ethtool_ops netdev_ethtool_ops = {
> 	.get_drvinfo		= netdev_get_drvinfo,
> 	.get_link		= ethtool_op_get_link,
> 	.get_ts_info		= ethtool_op_get_ts_info,
> 	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
> 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
> +	.get_regs_len = r6040_get_regs_len,
> +	.get_msglevel = r6040_get_msglevel,
> +	.set_msglevel = r6040_set_msglevel,
> +	.get_regs = r6040_get_regs,
> +	.get_strings = r6040_get_strings,
> +	.get_sset_count = r6040_get_sset_count,
> +	.get_ethtool_stats=r6040_get_ethtool_stats,
> };
>  
> static const struct net_device_ops r6040_netdev_ops = {
> 

-- 
Florian
