From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v3] Gigabit Ethernet driver of Topcliff PCH
Date: Fri, 10 Sep 2010 10:19:30 +0200
Message-ID: <4C89EA12.3000409@suse.cz>
References: <4C89C23A.6090707@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, MeeGo <meego-dev@meego.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Arjan <arjan@linux.intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C89C23A.6090707@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ccing Rafael (please find pch_gbe_resume here)

On 09/10/2010 07:29 AM, Masayuki Ohtake wrote:
> Hi Fujita, Jili and Stephen

Hi, Jili sounds funny :D.

> --- /dev/null
> +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> @@ -0,0 +1,587 @@
...
> +static void pch_gbe_get_regs(struct net_device *netdev,
> +				struct ethtool_regs *regs, void *p)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	struct pci_dev *pdev = adapter->pdev;
> +	u32 *regs_buff = p;
> +	u16 i, reg, tmp;
> +
> +	regs->version = pdev->revision;
> +	regs->version = 0x1000000 | (regs->version << 16) | pdev->device;
> +	memset(p, 0, PCH_GBE_REGS_LEN * (int)sizeof(u32));
> +	for (i = 0; i < PCH_GBE_MAC_REGS_LEN; i++)
> +		regs_buff[i] = ioread32(&hw->reg->INT_ST + i);

Well, you switched to ioremap, but left ioread/iowrite*. I wrote you
either use pci_iomap+ioread/iowrite32 or pci_ioremap_bar+readl/writel
which is faster. (But can be used iff you know it is an MMIO space).

> +static void pch_gbe_get_ethtool_stats(struct net_device *netdev,
> +				  struct ethtool_stats *stats, u64 *data)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	int i;
> +	const struct pch_gbe_stats *gstats = pch_gbe_gstrings_stats;
> +	char *hw_stats = (char *)&adapter->stats;
> +
> +	pch_gbe_update_stats(adapter);
> +	for (i = 0; i < PCH_GBE_GLOBAL_STATS_LEN; i++) {
> +		char *p = hw_stats + gstats->offset;
> +		data[i] = gstats->size == sizeof(u64) ? *(u64 *)p:(*(u32 *)p);

Actually, how you protect 64-bit stat numbers on 32-bit to be atomic?
You change adapter->stats from the irq context and it may need to update
2 words on 32-bit. So instead of having 0x100000000 you can get here
0x1ffffffff or 0x0 since read/write of u64 on 32bit are not atomic and
both words may not reach the memory yet. I don't know if that matters --
what are the stats from ethtool used for, but returning invalid values
is not nice. Do you need 64bit stats on 32-bit at all? Wouldn't be
netdev_stats (they are ulong) enough?

Example:
Given stat = 0xffffffff; on 32-bit stat is composed of stat_hi|stat_lo,
compiler generates for instance:
stat_lo++;
if (overflow)    (1)
  stat_hi++

Then if you read stat from this ethtool function at point (1), you will
get 0x0.

> +		gstats++;
> +	}
> +}
...
> --- /dev/null
> +++ b/drivers/net/pch_gbe/pch_gbe_main.c
> @@ -0,0 +1,2526 @@
...
> +void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
> +{
> +	u32 mar_low, mar_high, adrmask;
> +
> +	pr_debug("index : 0x%x\n", index);
> +
> +	/*
> +	 * HW expects these in little endian so we reverse the byte order
> +	 * from network order (big endian) to little endian
> +	 */
> +	mar_high = ((u32) addr[0] | ((u32) addr[1] << 8) |
> +		   ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
> +	mar_low = ((u32) addr[4] | ((u32) addr[5] << 8));
> +	/* Stop the MAC Address of index. */
> +	adrmask = ioread32(&hw->reg->ADDR_MASK);
> +	iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
> +	/* wait busy */
> +	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY)) {
> +		int tmp = 0;
> +		udelay(20);
> +		tmp++;
> +		if (tmp == 1000) {
> +			pr_err("Address mask bit is not cleared\n");
> +			break;
> +		}
> +	}

Maybe it would make sense to create a helper for that.

> +static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
> +			      struct pch_gbe_tx_ring *tx_ring,
> +			      struct sk_buff *skb)
> +{
...
> +	buffer_info->kernel_skb = skb;

Just curious, why you need ->kernel_skb and ->skb in that structure?
Can't you use just ->skb?

> +int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
> +				struct pch_gbe_tx_ring *tx_ring)
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> +	struct pch_gbe_tx_desc *tx_desc;
> +	int size;
> +	int desNo;
> +
> +	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
> +	tx_ring->buffer_info = vmalloc(size);
> +	if (!tx_ring->buffer_info) {
> +		pr_err("Unable to allocate memory for the buffer infomation\n");
> +		return -ENOMEM;
> +	}
> +	memset(tx_ring->buffer_info, 0, size);
> +
> +	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
> +
> +	tx_ring->desc =
> +		pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);

As you can sleep here now, you may use dma_alloc_coherent(..., GFP_KERNEL)
which allows for better memory reclaim and will fail in less cases.
For two reasons:
1) pci_alloc_consistent is deprecated AFAIK
2) pci_alloc_consistent calls page allocator with GFP_ATOMIC and may
fail for huge allocations early. And as I computed last time, you
allocate up to order-4 pages here.

The same for RX dir.

> +static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
> +	unsigned long flags;
> +
> +	if (unlikely(skb->len <= 0)) {

Can this happen at all? ndev people should tell you better...

> +		dev_kfree_skb_any(skb);
> +		pr_debug("Return : OK  skb len : %d\n", skb->len);
> +		return NETDEV_TX_OK;
> +	}
> +	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
> +		pr_err("Transfer length Error: skb len: %d > max: %d\n",
> +		       skb->len, adapter->hw.mac.max_frame_size);
> +		adapter->stats.tx_length_errors++;
> +		return NETDEV_TX_BUSY;

Ok, then it's not busy (it will try to send the skb in a loop forever).
You should free it and return OK, I think. Anyway, properly set MTU
should gurantee that, but it is my guess.

> +static struct net_device_stats *pch_gbe_get_stats(
> +						struct net_device *netdev)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +
> +	/* only return the current stats */
> +	return &adapter->net_stats;

Ah, you have your own copy of netstats. You may use netdev->stats all
over the code.

> +#ifdef CONFIG_PM
> +static int pch_gbe_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	u32 err;
> +
> +	pci_enable_wake(pdev, PCI_D0, 0);
> +	pci_set_power_state(pdev, PCI_D0);
> +	pci_restore_state(pdev);
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		pr_err("Cannot enable PCI device from suspend\n");
> +		return err;
> +	}
> +	pci_set_master(pdev);

Not sure which of those you need. Rafael may tell you more. You should
not set power state and restore state, but I might be wrong.

The same you need not to save state from ->suspend.

> +	pch_gbe_hal_power_up_phy(hw);
> +	pch_gbe_reset(adapter);
> +	/* Clear wake on lan control and status */
> +	pch_gbe_mac_set_wol_event(hw, 0);
> +
> +	if (netif_running(netdev))
> +		pch_gbe_up(adapter);
> +	netif_device_attach(netdev);
> +
> +	return 0;
> +}
> +#endif /* CONFIG_PM */
...
> --- /dev/null
> +++ b/drivers/net/pch_gbe/pch_gbe_param.c
> @@ -0,0 +1,501 @@
...
> +const struct pch_gbe_opt_list speed_list[] = {

static? And all below...

> +	{ 0, "" },
> +	{ SPEED_10, "" },
> +	{ SPEED_100, "" },
> +	{ SPEED_1000, "" }
> +};
...
> +static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
> +{
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	int speed, dplx;
> +
> +	{ /* Speed */
> +		struct pch_gbe_option opt = {

So may be this static const? And all below...

> +			.type = list_option,
> +			.name = "Speed",
> +			.err  = "parameter ignored",
> +			.def  = 0,
> +			.arg  = { .l = { .nr = (int)ARRAY_SIZE(speed_list),
> +					 .p = speed_list } }
> +		};
> +		speed = Speed;
> +		pch_gbe_validate_option(&speed, &opt, adapter);
> +	}

regards,
-- 
js
suse labs
