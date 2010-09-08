From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 08 Sep 2010 16:16:11 +0200
Message-ID: <4C879AAB.6000905@suse.cz>
References: <4C81019E.1010808@dsn.okisemi.com> <4C8123D6.8020001@suse.cz> <003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	ML netdev <netdev@vger.kernel.org>,
	MeeGo <meego-dev@meego.com>, Maxime Bizon <mbizon@freebox.fr>,
	LKML <linux-kernel@vger.kernel.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	John Linn <john.linn@xilinx.com>,
	Joe Perches <joe@perches.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36483 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab0IHOQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 10:16:17 -0400
In-Reply-To: <003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2010 03:52 PM, Masayuki Ohtake wrote:
> I have some questions.
> Please see out inline comments.

Hi, answered below...

>>> --- /dev/null
>>> +++ b/drivers/net/pch_gbe/pch_gbe.h
>>> @@ -0,0 +1,683 @@
>> ...
>>> +/**
>>> + * pch_gbe_regs_mac_adr - Structure holding values of mac address registers
>>> + * @high Denotes the 1st to 4th byte from the initial of MAC address
>>> + * @low Denotes the 5th to 6th byte from the initial of MAC address
>>> + */
>>> +struct pch_gbe_regs_mac_adr {
>>> + u32 high;
>>> + u32 low;
>>> +};
>>> +/**
>>> + * pch_udc_regs - Structure holding values of MAC registers
>>> + */
>>> +struct pch_gbe_regs {
>>> + u32 INT_ST;
>>> + u32 INT_EN;
>>> + u32 MODE;
>>> + u32 RESET;
>>> + u32 TCPIP_ACC;
>>> + u32 EX_LIST;
>>> + u32 INT_ST_HOLD;
>>> + u32 PHY_INT_CTRL;
>>> + u32 MAC_RX_EN;
>>> + u32 RX_FCTRL;
>>> + u32 PAUSE_REQ;
>>> + u32 RX_MODE;
>>> + u32 TX_MODE;
>>> + u32 RX_FIFO_ST;
>>> + u32 TX_FIFO_ST;
>>> + u32 TX_FID;
>>> + u32 TX_RESULT;
>>> + u32 PAUSE_PKT1;
>>> + u32 PAUSE_PKT2;
>>> + u32 PAUSE_PKT3;
>>> + u32 PAUSE_PKT4;
>>> + u32 PAUSE_PKT5;
>>> + u32 reserve[2];
>>> + struct pch_gbe_regs_mac_adr mac_adr[16];
>>> + u32 ADDR_MASK;
>>> + u32 MIIM;
>>> + u32 reserve2;
>>> + u32 RGMII_ST;
>>> + u32 RGMII_CTRL;
>>> + u32 reserve3[3];
>>> + u32 DMA_CTRL;
>>> + u32 reserve4[3];
>>> + u32 RX_DSC_BASE;
>>> + u32 RX_DSC_SIZE;
>>> + u32 RX_DSC_HW_P;
>>> + u32 RX_DSC_HW_P_HLD;
>>> + u32 RX_DSC_SW_P;
>>> + u32 reserve5[3];
>>> + u32 TX_DSC_BASE;
>>> + u32 TX_DSC_SIZE;
>>> + u32 TX_DSC_HW_P;
>>> + u32 TX_DSC_HW_P_HLD;
>>> + u32 TX_DSC_SW_P;
>>> + u32 reserve6[3];
>>> + u32 RX_DMA_ST;
>>> + u32 TX_DMA_ST;
>>> + u32 reserve7[2];
>>> + u32 WOL_ST;
>>> + u32 WOL_CTRL;
>>> + u32 WOL_ADDR_MASK;
>>> +};
>>
>> Shouldn't that be packed? As it is full of u32, probably not, but
>> consider this comment when thinking about all structures you have here.
> 
> [masa]
> packed?
> I am sorry, I can not understand.
> Please let me know details.

attribute((packed)). It ensures that compiler won't add gaps in there
for better alignment. As I wrote I'm not sure whether you need them at
all, since you use u32 here which are aligned naturally. But bear this
in mind while defining the rest of your structures which are transferred
from/to the HW.

>>> + if (!txdr) {
>>> + err = -ENOMEM;
>>> + goto err_alloc_tx;
>>> + }
>>> + rxdr = kzalloc(rx_ring_size, GFP_KERNEL);
>>> + if (!rxdr) {
>>> + err = -ENOMEM;
>>> + goto err_alloc_rx;
>>> + }
>>> + adapter->tx_ring = txdr;
>>> + adapter->rx_ring = rxdr;
>>> +
>>> + rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
>>> + rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);
>>
>> clamp()
>> And why you need the cast?
> 
> [masa]
> Since warning appears at the time of a make.

OK, then you have type error which you should fix instead. Perhaps
define the constnts with U suffix?

>>> +void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
>>> +{
>>> + u32 mar_low, mar_high, adrmask;
>>> +
>>> + FUNC_ENTER();
>>> + pr_debug("index : 0x%x\n", index);
>>> +
>>> + /*
>>> + * HW expects these in little endian so we reverse the byte order
>>> + * from network order (big endian) to little endian
>>> + */
>>> + mar_high = ((u32) addr[0] | ((u32) addr[1] << 8) |
>>> +    ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
>>> + mar_low = ((u32) addr[4] | ((u32) addr[5] << 8));
>>> + /* Stop the MAC Address of index. */
>>> + adrmask = ioread32(&hw->reg->ADDR_MASK);
>>> + iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
>>> + /* wait busy */
>>> + while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
>>> + cpu_relax();
>>
>> There should be probably some time limit. Nobody trusts hardware.
> 
> [masa]
> How should it modify?

Similarly to other busy waiting code you have in other places. Some
udelay with a loop bound.

>>> + return 0;
>>> +}
>> ...
>>> +static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
>>> +{
>>> + struct net_device *netdev = adapter->netdev;
>>> +
>>> + FUNC_ENTER();
>>> + free_irq(adapter->pdev->irq, netdev);
>>> + if (adapter->have_msi) {
>>> + pci_disable_msi(adapter->pdev);
>>> + pr_debug("call pci_disable_msi\n");
>>> + }
>>> +}
>>> +
>>> +/**
>>> + * pch_gbe_irq_disable - Mask off interrupt generation on the NIC
>>> + * @adapter:  Board private structure
>>> + */
>>> +static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter)
>>> +{
>>> + struct pch_gbe_hw *hw = &adapter->hw;
>>> +
>>> + FUNC_ENTER();
>>> + atomic_inc(&adapter->irq_sem);
>>> + iowrite32(0, &hw->reg->INT_EN);
>>
>> You should flush posted writes here.
> 
> [masa]
> This will be modified
> 
> Reading of a register is added after iowrite.
> OK?

Yes, that will do the job.

>>> +static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>>> +{
>>> + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>>> + struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
>>> + unsigned long flags;
>>> +
>>> + FUNC_ENTER();
>>> + if (unlikely(skb->len <= 0)) {
>>> + dev_kfree_skb_any(skb);
>>> + pr_debug("Return : OK  skb len : %d\n", skb->len);
>>> + return NETDEV_TX_OK;
>>> + }
>>> + if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
>>> + pr_err("Transfer length Error: skb len: %d > max: %d\n",
>>> +        skb->len, adapter->hw.mac.max_frame_size);
>>> + dev_kfree_skb_any(skb);
>>> + adapter->stats.tx_length_errors++;
>>> + return NETDEV_TX_BUSY;
>>
>> Not nice. ndev layer will reuse the freed skb now.
> 
> [masa]
> How should it modify?

Remove dev_kfree_skb_any(skb) to not free the skb so that ndev layer can
requeue the buffer.

>>> + }
>> ...
>>> +static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state)
>>> +{
>>> + struct net_device *netdev = pci_get_drvdata(pdev);
>>> + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>>> + struct pch_gbe_hw *hw = &adapter->hw;
>>> + u32 wufc = adapter->wake_up_evt;
>>> + int retval = 0;
>>> +
>>> + FUNC_ENTER();
>>> + netif_device_detach(netdev);
>>> + if (netif_running(netdev))
>>> + pch_gbe_down(adapter);
>>> +#ifdef CONFIG_PM
>>> + /* Implement our own version of pci_save_state(pdev) because pci-
>>> + * express adapters have 256-byte config spaces. */
>>> + retval = pci_save_state(pdev);
>>
>> But PCIe saves all caps, why you need this?
> 
> [masa]
> I can not understand.
> Please let me know details.

What exactly do you need the state of pcie for? The core should do it
fine on its own...

>>> +static int pch_gbe_probe(struct pci_dev *pdev,
>>> +   const struct pci_device_id *pci_id)
>>> +{
>>> + struct net_device *netdev;
>>> + struct pch_gbe_adapter *adapter;
>>> + unsigned long mmio_start;
>>> + unsigned long mmio_len;
>>> + int ret;
>>> +
>>> + FUNC_ENTER();
>>> + ret = pci_enable_device(pdev);
>>> + if (ret)
>>> + return ret;
>>> +
>>> + if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
>>> + && !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
>>> + ;
>>> + } else {
>>
>> You should invert the logic. And use pci_ variants.
> 
> [masa]
> This will be modified like
> if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
>  || dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> 
> What is pci_ variants?

No, don't use them, they used to be pci specific intended for dma
setting/mapping but are deprecated now which I didn't realize.

>>> + pci_set_drvdata(pdev, netdev);
>>> + adapter = netdev_priv(netdev);
>>> + adapter->netdev = netdev;
>>> + adapter->pdev = pdev;
>>> + adapter->hw.back = adapter;
>>> + mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
>>> + mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
>>> + adapter->hw.reg = ioremap_nocache(mmio_start, mmio_len);
>>
>> pci_ioremap_bar()
>>
>> Anyway you should not use ioread/iowrite* on an ioremapped space. It is
>> intended for iomapped space (pci_iomap) and is slower.
> 
> [masa]
> This will be modified like
> pci_iomap(pdev, PCH_GBE_PCI_BAR, 0) is used.

If you don't mind one extra branching in each read/write, then OK :).
Here you know it's MMIO space I think, so pci_ioremap_map+readl/writel
would be more appropriate and faster. But it's your call.

regards,
-- 
js
suse labs
