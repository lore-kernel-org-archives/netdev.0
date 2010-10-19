From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH v6] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 19 Oct 2010 14:30:44 +0900
Message-ID: <000b01cb6f4e$cc555df0$66f8800a@maildom.okisemi.com>
References: <4CA03198.8080802@dsn.okisemi.com> <AANLkTinedgQJq04PHdGmZqs4p6Du4PA16QC2JNTaGhAa@mail.gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Randy Dunlap" <randy.dunlap@oracle.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"Maxime Bizon" <mbizon@freebox.fr>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"ML netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"MeeGo" <meego-dev@meego.com>
To: "seedshope" <bocui107@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:14259 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516Ab0JSFaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 01:30:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi seedshope,

>why it is need to compare the INT_EN bit?
>As general, the pch_gbe_intr function was call,the interrupt is enable.
>In addition to the interrupt generate, what other conditions would call the interrupt function?

PCI devices in Topcliff IOH are connected with external PCI Express through logical PCI bus.
In Topcliff IOH, more PCI devices are sharing interruption.
Gigabit Ethernet device and USB Host are sharing interruption.
The pch_gbe_intr function is called on condition of others.
So, the comparison with INT_EN bit is necessary.

>resently , I fail to test the kgdboe on the gbe driver.
>The pch_gbe_netpoll will call the pch_gbe_intr function.
>The interruption will be disable before enter the  pch_gbe_intr.
>So the pch_gbe_netpoll is fail for ever. Is it a bug?

I think it is not a bug.
The INT_EN bit is a value of Gigabit Ethernet device's register.
The interruption disable processing before pch_gbe_intr() in pch_gbe_netpoll() function is a disable_irq() function.
The disable_irq() function does not change the register of a Gigabit Ethernet device.

Best regards.
Masayuki Otake.

----- 
Date: Mon, 18 Oct 2010 16:48:50 +0800
From: seedshope

Hi Masayuki,

>/**
> * pch_gbe_intr - Interrupt Handler
> * @irq:   Interrupt number
> * @data:  Pointer to a network interface device structure
> * Returns
> *     - IRQ_HANDLED:  Our interrupt
> *     - IRQ_NONE:     Not our interrupt
> */
>static irqreturn_t pch_gbe_intr(int irq, void *data)
>{
>       struct net_device *netdev = data;
>       struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>       struct pch_gbe_hw *hw = &adapter->hw;
>       u32 int_st;
>       u32 int_en;
>
>       /* Check request status */
>       int_st = ioread32(&hw->reg->INT_ST);
>       int_st = int_st & ioread32(&hw->reg->INT_EN);


why it is need to compare the INT_EN bit? As general, the pch_gbe_intr function was call,the interrupt is enable. In
addition to the interrupt generate, what other conditions would call the interrupt function?

resently , I fail to test the kgdboe on the gbe driver.  The pch_gbe_netpoll will call the pch_gbe_intr function. The
interruption will be disable before enter the  pch_gbe_intr.
So the pch_gbe_netpoll is fail for ever. Is it a bug?

>       /* When request status is no interruption factor */
>       if (unlikely(!int_st))
>               return IRQ_NONE;        /* Not our interrupt. End processing. */
>       pr_debug("%s occur int_st = 0x%08x\n", __func__, int_st);
>       if (int_st & PCH_GBE_INT_RX_FRAME_ERR)
>               adapter->stats.intr_rx_frame_err_count++;
>       if (int_st & PCH_GBE_INT_RX_FIFO_ERR)
>               adapter->stats.intr_rx_fifo_err_count++;
>       if (int_st & PCH_GBE_INT_RX_DMA_ERR)
>               adapter->stats.intr_rx_dma_err_count++;
>       if (int_st & PCH_GBE_INT_TX_FIFO_ERR)
>               adapter->stats.intr_tx_fifo_err_count++;
>       if (int_st & PCH_GBE_INT_TX_DMA_ERR)
>               adapter->stats.intr_tx_dma_err_count++;
>       if (int_st & PCH_GBE_INT_TCPIP_ERR)
>               adapter->stats.intr_tcpip_err_count++;
>       /* When Rx descriptor is empty  */
>       if ((int_st & PCH_GBE_INT_RX_DSC_EMP)) {
>               adapter->stats.intr_rx_dsc_empty_count++;
>               pr_err("Rx descriptor is empty\n");
>               int_en = ioread32(&hw->reg->INT_EN);
>               iowrite32((int_en & ~PCH_GBE_INT_RX_DSC_EMP), &hw->reg->INT_EN);
>               if (hw->mac.tx_fc_enable) {
>                       /* Set Pause packet */
>                       pch_gbe_mac_set_pause_packet(hw);
>               }
>               if ((int_en & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))
>                   == 0) {
>                       return IRQ_HANDLED;
>               }
>       }
>
>       /* When request status is Receive interruption */
>       if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))) {
>               if (likely(napi_schedule_prep(&adapter->napi))) {
>                       /* Enable only Rx Descriptor empty */
>                       atomic_inc(&adapter->irq_sem);
>                       int_en = ioread32(&hw->reg->INT_EN);
>                       int_en &=
>                           ~(PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT);
>                       iowrite32(int_en, &hw->reg->INT_EN);
>                       /* Start polling for NAPI */
>                       __napi_schedule(&adapter->napi);
>               }
>       }
>       pr_debug("return = 0x%08x  INT_EN reg = 0x%08x\n",
>                IRQ_HANDLED, ioread32(&hw->reg->INT_EN));
>       return IRQ_HANDLED;
>}



--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


