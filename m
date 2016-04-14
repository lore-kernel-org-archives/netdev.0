From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 15:19:55 -0500
Message-ID: <570FFB6B.5060305@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <570EC541.6080603@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> On 13/04/16 10:59, Timur Tabi wrote:
>> From: Gilad Avidov <gavidov@codeaurora.org>
>>
>> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
>> This driver supports the following features:
>> 1) Checksum offload.
>> 2) Runtime power management support.
>> 3) Interrupt coalescing support.
>> 4) SGMII phy.
>> 5) SGMII direct connection without external phy.
>
> I think you should shoot for more simple for an initial submission:
>
> - no offload
> - no timestamping
>
> get that accepted, and then add features one by one, it sure is more
> work, but it helps with the review, and makes you work off a solid base.

Unfortunately, I didn't write this driver initially, so I'm not sure how 
to remove these features from it.  Variants of this driver have been 
bouncing around Qualcomm for years, and even the author of this patch 
(Gilad) is no longer around.

So although I have a lot of experience upstreaming code, I have little 
experience and knowledge with network drivers.  I'm going to need a lot 
of hand-holding.  I hope you will be patient with me.

Timestamping support seems to be just a few lines of code, so I can 
probably remove that.  I don't know where offloading is in the driver, 
however.  I don't know how offloading in netdev drivers works.

> You will see below, but a pet peeve of mine is authors reimplementing
> code that exists in PHYLIB.

I can understand that, but the PHYs on these SOCs are non-standard.  The 
"internal PHY" (for lack of a better name) is part of the EMAC itself, 
and it acts as a middle-man for the external PHY.  There is an MDIO bus, 
but it's hard-wired to the EMAC, and most of the time you don't touch it 
directly.  Instead you let the EMAC and/or the internal PHY send/receive 
commands/data to the external PHY on your behalf.  The internal phy 
talks to the external phy via SGMII only.  Only the EMAC uses the mdio bus.

I will look at PHYLIB, but I can't tell you whether it will work with 
this hardware (Gilad previously claim that it wouldn't work well).

>> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
>> new file mode 100644
>> index 0000000..df5e7c0
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
>> @@ -0,0 +1,65 @@
>> +Qualcomm EMAC Gigabit Ethernet Controller
>> +
>> +Required properties:
>> +- compatible : Should be "qcom,emac".
>> +- reg : Offset and length of the register regions for the device
>> +- reg-names : Register region names referenced in 'reg' above.
>> +	Required register resource entries are:
>> +	"base"   : EMAC controller base register block.
>> +	"csr"    : EMAC wrapper register block.
>> +	Optional register resource entries are:
>> +	"ptp"    : EMAC PTP (1588) register block.
>> +		   Required if 'qcom,emac-tstamp-en' is present.
>> +	"sgmii"  : EMAC SGMII PHY register block.
>> +- interrupts : Interrupt numbers used by this controller
>> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
>> +	Required interrupt resource entries are:
>> +	"emac_core0"   : EMAC core0 interrupt.
>> +	"sgmii_irq"   : EMAC SGMII interrupt.
>> +- phy-addr            : Specifies phy address on MDIO bus.
>> +			Required if the optional property "qcom,no-external-phy"
>> +			is not specified.
>
> This is not the standard way to represent an Ethernet PHY hanging off a
> MDIO bus see ethernet.txt and phy.txt in D/dt/bindings/net/

The MDIO bus on these chips is not accessible as a separate entity.  It 
is melded (for lack of a better word) into the EMAC itself.  That's why 
there is a "qcom,no-external-phy" property.  You could, in theory, wire 
the internal phy of one SOC directly to the internal phy of another SOC, 
and use that as in interconnect between SOCs.  I don't know of any such 
use-cases however.

>> +Optional properties:
>> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
>> +			      Include this only if PTP (1588) timestamping
>> +			      feature is needed. If included, "ptp" register
>> +			      base should be specified.
>
> If the "ptp" register range is not specified, then PTP gets disabled, so
> is a boolean really required here, considering that this looks like a
> policy decision more than anything.

It is, and I forget to remove it, since this is apparently handled via 
ethtool (which the driver does not currently support).

>> +- mac-address               : The 6-byte MAC address. If present, it is the
>> +			      default MAC address.
>
> This property is pretty much mandatory

Ok.

>> +- qcom,no-external-phy      : Indicates there is no external PHY connected to
>> +			      EMAC. Include this only if the EMAC is directly
>> +			      connected to the peer end without EPHY.
>
> How is the internal PHY accessed, is it responding on the MDIO bus at a
> particular address?

There is a set of memory-mapped registers.  It's not connected via MDIO 
at all.  It's mapped via the "sgmii" addresses in the device tree (see 
function emac_sgmii_config).

 > If so, standard MDIO scanning/probing works, and you
> can have your PHY driver flag this device has internal. Worst case, you
> can do what BCMGENET does, and have a special "phy-mode" value set to
> "internal" when this knowledge needs to exist prior to MDIO bus scanning
> (e.g: to power on the PHY).

So the internal phy is not a real phy.  It's not capable of driving an 
RJ45 port (there's no analog part).  It's an SGMII-like device that is 
hard-wired to the EMAC itself.

In theory, the internal PHY is optional.  You could design an SOC that 
has just the EMAC connected via normal MDIO to an external phy.  I 
really wish our hardware designers has done that.  But unfortunately, 
there are no SOCs like that, and so we have to treat the internal phy as 
an extension of the EMAC.

My preference would be to get rid of the "qcom,no-external-phy" property 
and have an external phy be required, at least until Qualcomm creates an 
SOC without the internal phy (which may never happen, for all I know).

>> +/* Config MAC modes */
>> +void emac_mac_mode_config(struct emac_adapter *adpt)
>> +{
>> +	u32 mac;
>> +
>> +	mac = readl(adpt->base + EMAC_MAC_CTRL);
>> +
>> +	if (test_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status))
>> +		mac |= VLAN_STRIP;
>> +	else
>> +		mac &= ~VLAN_STRIP;
>> +
>> +	if (test_bit(EMAC_STATUS_PROMISC_EN, &adpt->status))
>> +		mac |= PROM_MODE;
>> +	else
>> +		mac &= ~PROM_MODE;
>> +
>> +	if (test_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status))
>> +		mac |= MULTI_ALL;
>> +	else
>> +		mac &= ~MULTI_ALL;
>> +
>> +	if (test_bit(EMAC_STATUS_LOOPBACK_EN, &adpt->status))
>> +		mac |= MAC_LP_EN;
>> +	else
>> +		mac &= ~MAC_LP_EN;
>
> Do you need to maintain these flags when most, if not all of them
> already exist in dev->flags or dev->features?

So you're saying that, for example, in emac_set_features() I should 
remove this:

	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
		set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
	else
		clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);

and then in emac_mac_mode_config(), I should do this instead:

void emac_mac_mode_config(struct emac_adapter *adpt)
{
	struct net_device *netdev = adpt->netdev;

	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
		mac |= VLAN_STRIP;
	else
		mac &= ~VLAN_STRIP;


If so, then what do I do in emac_rx_mode_set()?  Should I delete this 
entire block:

	/* Check for Promiscuous and All Multicast modes */
	if (netdev->flags & IFF_PROMISC) {
		set_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
	} else if (netdev->flags & IFF_ALLMULTI) {
		set_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
		clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
	} else {
		clear_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
		clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
	}

It does look like Gilad is just mirroring the flags/features variable 
into adpt->status.  What I can't figure out is why.  It seems completely 
redundant, but I have a nagging feeling that there is a good reason.

>> +	/* setup link speed */
>> +	mac &= ~SPEED_BMSK;
>> +	switch (phy->link_speed) {
>> +	case EMAC_LINK_SPEED_1GB_FULL:
>> +		mac |= ((emac_mac_speed_1000 << SPEED_SHFT) & SPEED_BMSK);
>> +		csr1 |= FREQ_MODE;
>> +		break;
>> +	default:
>> +		mac |= ((emac_mac_speed_10_100 << SPEED_SHFT) & SPEED_BMSK);
>> +		csr1 &= ~FREQ_MODE;
>> +		break;
>> +	}
>
> If you implement the driver using PHYLIB, which you should in order to
> support arbitrary or internal PHYs, then this function gets invoked
> whenever there is a link parameter change (auto-neg, forcing,
> duplex/speed/no link etc.).

Ok, I'll probably understand this better once I figure out how to 
implement phylib.

>> +	napi_enable(&adpt->rx_q.napi);
>> +
>> +	/* enable mac irq */
>> +	writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
>> +	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
>> +
>> +	netif_start_queue(netdev);
>
> Starting the TX queue is typically the last ting you want to do, to
> avoid a transient state where the TX queue is enabled, and the link is
> not (which is okay if your driver is properly implemented and reflects
> carrier changes anyway).

So I should move the netif_start_queue() to the end of this function? 
Sorry if that's a stupid question, but I know little about the MAC side 
of network drivers.

>> +	clear_bit(EMAC_STATUS_DOWN, &adpt->status);
>> +
>> +	/* check link status */
>> +	set_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
>> +	adpt->link_chk_timeout = jiffies + EMAC_TRY_LINK_TIMEOUT;
>> +	mod_timer(&adpt->timers, jiffies);
>
> Please implement a PHYLIB driver and use phy_start() here.

Ok, I'll try it.

>
>> +
>> +	return 0;
>> +}
>> +
>> +/* Bring down the interface/HW */
>> +void emac_mac_down(struct emac_adapter *adpt, bool reset)
>> +{
>> +	struct net_device *netdev = adpt->netdev;
>> +	struct emac_phy *phy = &adpt->phy;
>> +	unsigned long flags;
>> +
>> +	set_bit(EMAC_STATUS_DOWN, &adpt->status);
>
> Do you need to maintain that? Would not netif_running() tell you what
> you want if you reflect the carrier state properly?

I think that emac_work_thread_link_check() handles this.  It's a timer 
thread that polls the link state and calls netif_carrier_off() if the 
link is down.  Is that sufficient?

>> +
>> +	netif_stop_queue(netdev);
>> +	netif_carrier_off(netdev);
>
> phy_stop() would take care of the latter.

I'm beginning to see how phylib support would be useful.

>> +/* Process transmit event */
>> +void emac_mac_tx_process(struct emac_adapter *adpt, struct emac_tx_queue *tx_q)
>> +{
>> +	struct emac_buffer *tpbuf;
>> +	u32 hw_consume_idx;
>> +	u32 pkts_compl = 0, bytes_compl = 0;
>> +	u32 reg = readl_relaxed(adpt->base + tx_q->consume_reg);
>> +
>> +	hw_consume_idx = (reg & tx_q->consume_mask) >> tx_q->consume_shift;
>> +
>> +	while (tx_q->tpd.consume_idx != hw_consume_idx) {
>> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.consume_idx);
>> +		if (tpbuf->dma_addr) {
>> +			dma_unmap_single(adpt->netdev->dev.parent,
>> +					 tpbuf->dma_addr, tpbuf->length,
>> +					 DMA_TO_DEVICE);
>> +			tpbuf->dma_addr = 0;
>> +		}
>> +
>> +		if (tpbuf->skb) {
>> +			pkts_compl++;
>> +			bytes_compl += tpbuf->skb->len;
>> +			dev_kfree_skb_irq(tpbuf->skb);
>> +			tpbuf->skb = NULL;
>> +		}
>> +
>> +		if (++tx_q->tpd.consume_idx == tx_q->tpd.count)
>> +			tx_q->tpd.consume_idx = 0;
>> +	}
>> +
>> +	if (pkts_compl || bytes_compl)
>> +		netdev_completed_queue(adpt->netdev, pkts_compl, bytes_compl);
>
> The condition can be eliminated.

Ok.

>> +	if (skb_network_offset(skb) != ETH_HLEN)
>> +		TPD_TYP_SET(&tpd, 1);
>> +
>> +	emac_tx_fill_tpd(adpt, tx_q, skb, &tpd);
>> +
>> +	netdev_sent_queue(adpt->netdev, skb->len);
>> +
>> +	/* update produce idx */
>> +	prod_idx = (tx_q->tpd.produce_idx << tx_q->produce_shift) &
>> +		    tx_q->produce_mask;
>> +	emac_reg_update32(adpt->base + tx_q->produce_reg,
>> +			  tx_q->produce_mask, prod_idx);
>
> Since you have a producer index, you should consider checking
> skb->xmit_more to know whether you can update the register now, or
> later, which could save some expensive operation and batch TX.

I'll have to figure out what means and get back to you.  When would 
"later" be?

>> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
>> new file mode 100644
>> index 0000000..7d18de3
>> --- /dev/null
>> +++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
>
> This file is really really ugly, and duplicates a lot of functionality
> provided by PHYLIB, you really need to implement a PHYLIB MDIO driver
> and eventually a small PHY driver for your internal PHY if it needs some
> baby sitting.

I'll try.

>> diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
>> new file mode 100644
>> index 0000000..ce328f5
>> --- /dev/null
>> +++ b/drivers/net/ethernet/qualcomm/emac/emac.c
>> @@ -0,0 +1,1206 @@
>> +/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 and
>> + * only version 2 as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + */
>> +
>> +/* Qualcomm Technologies, Inc. EMAC Gigabit Ethernet Driver
>> + * The EMAC driver supports following features:
>> + * 1) Receive Side Scaling (RSS).
>> + * 2) Checksum offload.
>> + * 3) Multiple PHY support on MDIO bus.
>> + * 4) Runtime power management support.
>> + * 5) Interrupt coalescing support.
>> + * 6) SGMII phy.
>> + * 7) SGMII direct connection (without external phy).
>> + */
>> +
>> +#include <linux/if_ether.h>
>> +#include <linux/if_vlan.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/io.h>
>> +#include <linux/module.h>
>> +#include <linux/of.h>
>> +#include <linux/of_net.h>
>> +#include <linux/phy.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/pm_runtime.h>
>> +#include "emac.h"
>> +#include "emac-mac.h"
>> +#include "emac-phy.h"
>> +#include "emac-sgmii.h"
>> +
>> +#define DRV_VERSION "1.3.0.0"
>> +
>> +static int debug = -1;
>> +module_param(debug, int, S_IRUGO | S_IWUSR | S_IWGRP);
>
> ethtool -s <iface> msglvl provides you with that already.

I'll remove it.  There's no ethtool support in this driver anyway, but 
there's no code that uses this parameter.

>
>> +
>> +static int emac_irq_use_extended;
>> +module_param(emac_irq_use_extended, int, S_IRUGO | S_IWUSR | S_IWGRP);
>
> What is that module parameter used for?

Good question.  Apparently it's some IRQ mask.  I'll have to study the 
documentation and get back to you.  We don't ever set the parameter, so 
I think I'll just drop it.

>> +const char emac_drv_name[] = "qcom-emac";
>> +const char emac_drv_description[] =
>> +			"Qualcomm Technologies, Inc. EMAC Ethernet Driver";
>> +const char emac_drv_version[] = DRV_VERSION;
>
> Static all other the place?

Thanks for catching that.  I'll fix it.

>
> [snip]
>
>> +
>> +/* NAPI */
>> +static int emac_napi_rtx(struct napi_struct *napi, int budget)
>> +{
>> +	struct emac_rx_queue *rx_q = container_of(napi, struct emac_rx_queue,
>> +						   napi);
>> +	struct emac_adapter *adpt = netdev_priv(rx_q->netdev);
>> +	struct emac_irq *irq = rx_q->irq;
>> +
>> +	int work_done = 0;
>> +
>> +	/* Keep link state information with original netdev */
>> +	if (!netif_carrier_ok(adpt->netdev))
>> +		goto quit_polling;
>
> I do not think this is a condition that could occur?

I don't know what this code is trying to do.  I'll have to study it and 
get back to you.

>
>> +
>> +	emac_mac_rx_process(adpt, rx_q, &work_done, budget);
>> +
>> +	if (work_done < budget) {
>> +quit_polling:
>> +		napi_complete(napi);
>> +
>> +		irq->mask |= rx_q->intr;
>> +		writel(irq->mask, adpt->base + EMAC_INT_MASK);
>> +	}
>> +
>> +	return work_done;
>> +}
>> +
>> +/* Transmit the packet */
>> +static int emac_start_xmit(struct sk_buff *skb, struct net_device *netdev)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +
>> +	return emac_mac_tx_buf_send(adpt, &adpt->tx_q, skb);
>
> I would inline emac_mac_tx_buf_send()'s body here to make it much easier
> to read and audit...

Ok.

>
>> +}
>> +
>> +irqreturn_t emac_isr(int _irq, void *data)
>> +{
>> +	struct emac_irq *irq = data;
>> +	struct emac_adapter *adpt = container_of(irq, struct emac_adapter, irq);
>> +	struct emac_rx_queue *rx_q = &adpt->rx_q;
>> +
>> +	int max_ints = 1;
>> +	u32 isr, status;
>> +
>> +	/* disable the interrupt */
>> +	writel(0, adpt->base + EMAC_INT_MASK);
>> +
>> +	do {
>
> With max_ints = 1, this is essentially the same as no loop, so just
> inline it to reduce the indentation.

In another internal version of this driver, max_ints is set to 5.  Could 
this be some way of processing multiple packets in one interrupt?  Isn't 
that something that NAPI already takes care of, anyway?

>> +		isr = readl_relaxed(adpt->base + EMAC_INT_STATUS);
>> +		status = isr & irq->mask;
>> +
>> +		if (status == 0)
>> +			break;
>> +
>> +		if (status & ISR_ERROR) {
>> +			netif_warn(adpt,  intr, adpt->netdev,
>> +				   "warning: error irq status 0x%lx\n",
>> +				   status & ISR_ERROR);
>> +			/* reset MAC */
>> +			set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
>> +			emac_work_thread_reschedule(adpt);
>> +		}
>> +
>> +		/* Schedule the napi for receive queue with interrupt
>> +		 * status bit set
>> +		 */
>> +		if ((status & rx_q->intr)) {
>> +			if (napi_schedule_prep(&rx_q->napi)) {
>> +				irq->mask &= ~rx_q->intr;
>> +				__napi_schedule(&rx_q->napi);
>> +			}
>> +		}
>> +
>> +		if (status & TX_PKT_INT)
>> +			emac_mac_tx_process(adpt, &adpt->tx_q);
>
> You should consider using a NAPI instance for reclaiming TX buffers as well.

I'll have to figure out what means and get back to you.

>> +		if (status & ISR_OVER)
>> +			netif_warn(adpt, intr, adpt->netdev,
>> +				   "warning: TX/RX overflow status 0x%lx\n",
>> +				   status & ISR_OVER);
>
> This should be ratelimited presumably

Ok.

>
>> +
>> +		/* link event */
>> +		if (status & (ISR_GPHY_LINK | SW_MAN_INT)) {
>> +			emac_lsc_schedule_check(adpt);
>> +			break;
>> +		}
>> +	} while (--max_ints > 0);
>> +
>> +	/* enable the interrupt */
>> +	writel(irq->mask, adpt->base + EMAC_INT_MASK);
>> +
>> +	return IRQ_HANDLED;
>> +}
>> +
>> +/* Configure VLAN tag strip/insert feature */
>> +static int emac_set_features(struct net_device *netdev,
>> +			     netdev_features_t features)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +
>> +	netdev_features_t changed = features ^ netdev->features;
>> +
>> +	if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX)))
>> +		return 0;
>> +
>> +	netdev->features = features;
>> +	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>> +		set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>> +	else
>> +		clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>
> What about TX vlan offload?

I don't know what that is.

>> +/* Called when the network interface is made active */
>> +static int emac_open(struct net_device *netdev)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +	int ret;
>> +
>> +	netif_carrier_off(netdev);
>
> That seems unnecessary here because your close/down function does that,
> and with PHYLIB you would get it set correctly anyway.

Ok.  I'll see what I can do about it.

>> +/* PHY related IOCTLs */
>> +static int emac_mii_ioctl(struct net_device *netdev,
>> +			  struct ifreq *ifr, int cmd)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +	struct emac_phy *phy = &adpt->phy;
>> +	struct mii_ioctl_data *data = if_mii(ifr);
>> +
>> +	switch (cmd) {
>> +	case SIOCGMIIPHY:
>> +		data->phy_id = phy->addr;
>> +		return 0;
>> +
>> +	case SIOCGMIIREG:
>> +		if (!capable(CAP_NET_ADMIN))
>> +			return -EPERM;
>> +
>> +		if (data->reg_num & ~(0x1F))
>> +			return -EFAULT;
>> +
>> +		if (data->phy_id >= PHY_MAX_ADDR)
>> +			return -EFAULT;
>> +
>> +		if (phy->external && data->phy_id != phy->addr)
>> +			return -EFAULT;
>> +
>> +		return emac_phy_read(adpt, data->phy_id, data->reg_num,
>> +				     &data->val_out);
>> +
>> +	case SIOCSMIIREG:
>> +		if (!capable(CAP_NET_ADMIN))
>> +			return -EPERM;
>> +
>> +		if (data->reg_num & ~(0x1F))
>> +			return -EFAULT;
>> +
>> +		if (data->phy_id >= PHY_MAX_ADDR)
>> +			return -EFAULT;
>> +
>> +		if (phy->external && data->phy_id != phy->addr)
>> +			return -EFAULT;
>> +
>> +		return emac_phy_write(adpt, data->phy_id, data->reg_num,
>> +				      data->val_in);
>> +	default:
>> +		return -EFAULT;
>> +	}
>
> All of that can be eliminated with a PHYLIB implementation too.

Ok.

>
> [snip]
>
>> +/* Provide network statistics info for the interface */
>> +struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
>> +					   struct rtnl_link_stats64 *net_stats)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +	struct emac_stats *stats = &adpt->stats;
>> +	u16 addr = REG_MAC_RX_STATUS_BIN;
>> +	u64 *stats_itr = &adpt->stats.rx_ok;
>> +	u32 val;
>> +
>> +	while (addr <= REG_MAC_RX_STATUS_END) {
>> +		val = readl_relaxed(adpt->base + addr);
>> +		*stats_itr += val;
>> +		++stats_itr;
>> +		addr += sizeof(u32);
>> +	}
>
> There is no reader locking here, what happens if two applications read
> the statistics at the same time?

Ah, even though the readl is atomic, it's reading a bunch of them in a 
row.  I'll add a lock or something.

>> +/* Get the resources */
>> +static int emac_probe_resources(struct platform_device *pdev,
>> +				struct emac_adapter *adpt)
>> +{
>> +	struct net_device *netdev = adpt->netdev;
>> +	struct device_node *node = pdev->dev.of_node;
>> +	struct resource *res;
>> +	const void *maddr;
>> +	int ret = 0;
>> +	int i;
>> +
>> +	/* get time stamp enable flag */
>> +	adpt->timestamp_en = of_property_read_bool(node, "qcom,emac-tstamp-en");
>> +
>> +	/* get mac address */
>> +	maddr = of_get_mac_address(node);
>> +	if (!maddr)
>> +		return -ENODEV;
>
> No, generate a random one, continue, but warn,

Ok.

>
>> +
>> +	memcpy(adpt->mac_perm_addr, maddr, netdev->addr_len);
>> +
>> +	ret = platform_get_irq_byname(pdev, EMAC_MAC_IRQ_RES);
>> +	if (ret < 0) {
>> +		netdev_err(adpt->netdev,
>> +			   "error: missing %s resource\n", EMAC_MAC_IRQ_RES);
>> +		return ret;
>> +	}
>> +	adpt->irq.irq = ret;
>> +
>> +	ret = emac_clks_get(pdev, adpt);
>> +	if (ret)
>> +		return ret;
>> +
>> +	/* get register addresses */
>> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "base");
>> +	if (!res) {
>> +		netdev_err(adpt->netdev, "error: missing 'base' resource\n");
>> +		ret = -ENXIO;
>> +		goto err_reg_res;
>> +	}
>> +
>> +	adpt->base = devm_ioremap_resource(&pdev->dev, res);
>> +	if (!adpt->base) {
>> +		ret = -ENOMEM;
>> +		goto err_reg_res;
>> +	}
>> +
>> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "csr");
>> +	if (!res) {
>> +		netdev_err(adpt->netdev, "error: missing 'csr' resource\n");
>> +		ret = -ENXIO;
>> +		goto err_reg_res;
>> +	}
>
> No need to check that, devm_ioremap_resource() does it too.

Ok.

>> +/* Probe function */
>> +static int emac_probe(struct platform_device *pdev)
>> +{
>> +	struct net_device *netdev;
>> +	struct emac_adapter *adpt;
>> +	struct emac_phy *phy;
>> +	int ret = 0;
>> +	u32 hw_ver;
>> +	u32 extended_irq_mask = emac_irq_use_extended ? IMR_EXTENDED_MASK :
>> +							IMR_NORMAL_MASK;
>> +
>> +	netdev = alloc_etherdev(sizeof(struct emac_adapter));
>> +	if (!netdev)
>> +		return -ENOMEM;
>
> There are references to multiple queues in the code, so why not
> alloc_etherdev_mq() here with the correct number of queues?

That support was removed from the driver, and on our SOC, we hard-code 
the number of queues to 1 anyway.  I'm planning on adding multiple queue 
support (much) later.

>> +	dev_set_drvdata(&pdev->dev, netdev);
>> +	SET_NETDEV_DEV(netdev, &pdev->dev);
>> +
>> +	adpt = netdev_priv(netdev);
>> +	adpt->netdev = netdev;
>> +	phy = &adpt->phy;
>> +	adpt->msg_enable = netif_msg_init(debug, EMAC_MSG_DEFAULT);
>> +
>> +	dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>
> Really, is not that supposed to run on ARM64 servers?

Well, this version of the driver isn't, which is why it supports DT and 
not ACPI.  I'm planning on adding that support in a later patch. 
However, I'll add support for 64-bit masks in the next version of this 
patch.

Would this be okay:

	retval = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
	if (retval) {
		dev_err(&pdev->dev, "failed to set DMA mask err %d\n", retval);
		goto err_res;
	}

I've seen code like this in other drivers:

         ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
         if (ret) {
                 ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
                 if (ret) {
                         dev_err(dev, "failed to set dma mask\n");
                         return ret;
                 }
         }

and I've never understood why it's necessary to fall back to 32-bits if 
64 bits fails.  Isn't 64 bits a superset of 32 bits?  The driver is 
saying that the hardware supports all of DDR.  How could fail, and how 
could 32-bit succeed if 64-bits fails?

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
