From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 14:19:30 -0700
Message-ID: <57100962.40404@gmail.com>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
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
In-Reply-To: <570FFB6B.5060305@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/04/16 13:19, Timur Tabi wrote:
> Florian Fainelli wrote:
>> On 13/04/16 10:59, Timur Tabi wrote:
>>> From: Gilad Avidov <gavidov@codeaurora.org>
>>>
>>> Add supports for ethernet controller HW on Qualcomm Technologies,
>>> Inc. SoC.
>>> This driver supports the following features:
>>> 1) Checksum offload.
>>> 2) Runtime power management support.
>>> 3) Interrupt coalescing support.
>>> 4) SGMII phy.
>>> 5) SGMII direct connection without external phy.
>>
>> I think you should shoot for more simple for an initial submission:
>>
>> - no offload
>> - no timestamping
>>
>> get that accepted, and then add features one by one, it sure is more
>> work, but it helps with the review, and makes you work off a solid base.
> 
> Unfortunately, I didn't write this driver initially, so I'm not sure how
> to remove these features from it.  Variants of this driver have been
> bouncing around Qualcomm for years, and even the author of this patch
> (Gilad) is no longer around.

Well, good luck :)

> 
> So although I have a lot of experience upstreaming code, I have little
> experience and knowledge with network drivers.  I'm going to need a lot
> of hand-holding.  I hope you will be patient with me.
> 
> Timestamping support seems to be just a few lines of code, so I can
> probably remove that.  I don't know where offloading is in the driver,
> however.  I don't know how offloading in netdev drivers works.

Based on what the driver seems to do right now, it would be located in
the transmit and receive paths, and would have to access
mac/network/transport offsets and deal with checksums, so anything that
deals with checksums, provided that the HW does not require that to
transmit/receive packets, could be eliminated entirely for now and be
added later.

It is not the biggest part that needs to be slightly re-architected
though, the SGMII/PHY/MDIO stuff is more important as it impacts the
Device Tree binding, see below.

> 
>> You will see below, but a pet peeve of mine is authors reimplementing
>> code that exists in PHYLIB.
> 
> I can understand that, but the PHYs on these SOCs are non-standard.  The
> "internal PHY" (for lack of a better name) is part of the EMAC itself,
> and it acts as a middle-man for the external PHY.  There is an MDIO bus,
> but it's hard-wired to the EMAC, and most of the time you don't touch it
> directly.  Instead you let the EMAC and/or the internal PHY send/receive
> commands/data to the external PHY on your behalf.  The internal phy
> talks to the external phy via SGMII only.  Only the EMAC uses the mdio bus.

Humm OK, this PHY proxy, provided that this is really how it works,
seems a bit unusual, but, is not necessarily a roadblock to having a
proper MDIO implementation here which is standard and will allow you to
utilize re-usable drivers and facilities that are already there.

> 
> I will look at PHYLIB, but I can't tell you whether it will work with
> this hardware (Gilad previously claim that it wouldn't work well).

Well, PHYLIB does prefer using MDIO accesses to "speak" to PHYs,
built-in or external, but there is always the option of investing into
some custom development with the subsystem to make it play nicely with
your HW.

> 
>>> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> b/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> new file mode 100644
>>> index 0000000..df5e7c0
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> @@ -0,0 +1,65 @@
>>> +Qualcomm EMAC Gigabit Ethernet Controller
>>> +
>>> +Required properties:
>>> +- compatible : Should be "qcom,emac".
>>> +- reg : Offset and length of the register regions for the device
>>> +- reg-names : Register region names referenced in 'reg' above.
>>> +    Required register resource entries are:
>>> +    "base"   : EMAC controller base register block.
>>> +    "csr"    : EMAC wrapper register block.
>>> +    Optional register resource entries are:
>>> +    "ptp"    : EMAC PTP (1588) register block.
>>> +           Required if 'qcom,emac-tstamp-en' is present.
>>> +    "sgmii"  : EMAC SGMII PHY register block.
>>> +- interrupts : Interrupt numbers used by this controller
>>> +- interrupt-names : Interrupt resource names referenced in
>>> 'interrupts' above.
>>> +    Required interrupt resource entries are:
>>> +    "emac_core0"   : EMAC core0 interrupt.
>>> +    "sgmii_irq"   : EMAC SGMII interrupt.
>>> +- phy-addr            : Specifies phy address on MDIO bus.
>>> +            Required if the optional property "qcom,no-external-phy"
>>> +            is not specified.
>>
>> This is not the standard way to represent an Ethernet PHY hanging off a
>> MDIO bus see ethernet.txt and phy.txt in D/dt/bindings/net/
> 
> The MDIO bus on these chips is not accessible as a separate entity.  It
> is melded (for lack of a better word) into the EMAC itself.  That's why
> there is a "qcom,no-external-phy" property.  You could, in theory, wire
> the internal phy of one SOC directly to the internal phy of another SOC,
> and use that as in interconnect between SOCs.  I don't know of any such
> use-cases however.

The fact the MDIO bus is built-into the MAC is really not a problem
here, there are tons of drivers that deal with that just fine, yet, the
DT binding needs to reflect that properly by having a sub-node of the
Ethernet MAC which is a MDIO bus controller node. If external or
internal PHYs are accessible through that MDIO bus, they also need to
appear as child-nodes of that MDIO bus controller node.

BTW, wiring two PHYs internally is a waste of HW resource at best, if
not just asking for trouble, you can do an Ethernet MAC to MAC
connection, tons of HW do that too.

[snip]

>>> +- qcom,no-external-phy      : Indicates there is no external PHY
>>> connected to
>>> +                  EMAC. Include this only if the EMAC is directly
>>> +                  connected to the peer end without EPHY.
>>
>> How is the internal PHY accessed, is it responding on the MDIO bus at a
>> particular address?
> 
> There is a set of memory-mapped registers.  It's not connected via MDIO
> at all.  It's mapped via the "sgmii" addresses in the device tree (see
> function emac_sgmii_config).
> 
>> If so, standard MDIO scanning/probing works, and you
>> can have your PHY driver flag this device has internal. Worst case, you
>> can do what BCMGENET does, and have a special "phy-mode" value set to
>> "internal" when this knowledge needs to exist prior to MDIO bus scanning
>> (e.g: to power on the PHY).
> 
> So the internal phy is not a real phy.  It's not capable of driving an
> RJ45 port (there's no analog part).  It's an SGMII-like device that is
> hard-wired to the EMAC itself.

OK, that explains things a bit, thanks, this is quite a bit of important
detail actually.

> 
> In theory, the internal PHY is optional.  You could design an SOC that
> has just the EMAC connected via normal MDIO to an external phy.  I
> really wish our hardware designers has done that.  But unfortunately,
> there are no SOCs like that, and so we have to treat the internal phy as
> an extension of the EMAC.
> 
> My preference would be to get rid of the "qcom,no-external-phy" property
> and have an external phy be required, at least until Qualcomm creates an
> SOC without the internal phy (which may never happen, for all I know).
> 

Can we just say that, an absence of PHY specified in the Device Tree (no
phy-handle property and PHY not a child node of the MDIO bus), means
that there is no external PHY?

[snip]

>> Do you need to maintain these flags when most, if not all of them
>> already exist in dev->flags or dev->features?
> 
> So you're saying that, for example, in emac_set_features() I should
> remove this:
> 
>     if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>         set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>     else
>         clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
> 
> and then in emac_mac_mode_config(), I should do this instead:
> 
> void emac_mac_mode_config(struct emac_adapter *adpt)
> {
>     struct net_device *netdev = adpt->netdev;
> 
>     if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>         mac |= VLAN_STRIP;
>     else
>         mac &= ~VLAN_STRIP;
> 
> 
> If so, then what do I do in emac_rx_mode_set()?  Should I delete this
> entire block:
> 
>     /* Check for Promiscuous and All Multicast modes */
>     if (netdev->flags & IFF_PROMISC) {
>         set_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>     } else if (netdev->flags & IFF_ALLMULTI) {
>         set_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
>         clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>     } else {
>         clear_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
>         clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>     }
> 
> It does look like Gilad is just mirroring the flags/features variable
> into adpt->status.  What I can't figure out is why.  It seems completely
> redundant, but I have a nagging feeling that there is a good reason.

Yes, I think your set_features and set_rx_mode functions would be
greatly simplified, if each of them did take care of programming the HW
immediately based on function arguments/flags. Unless absolutely
required (e.g: suspend/resume, outside of the scope of the function
etc..) having bookeeping variables is always something that can be out
of sync, so better avoid them as much as possible.

[snip]

>>> +    napi_enable(&adpt->rx_q.napi);
>>> +
>>> +    /* enable mac irq */
>>> +    writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
>>> +    writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
>>> +
>>> +    netif_start_queue(netdev);
>>
>> Starting the TX queue is typically the last ting you want to do, to
>> avoid a transient state where the TX queue is enabled, and the link is
>> not (which is okay if your driver is properly implemented and reflects
>> carrier changes anyway).
> 
> So I should move the netif_start_queue() to the end of this function?
> Sorry if that's a stupid question, but I know little about the MAC side
> of network drivers.

That's fine, yes moving netif_start_queue() at the far end of the
function is a good change.

[snip]

>>
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +/* Bring down the interface/HW */
>>> +void emac_mac_down(struct emac_adapter *adpt, bool reset)
>>> +{
>>> +    struct net_device *netdev = adpt->netdev;
>>> +    struct emac_phy *phy = &adpt->phy;
>>> +    unsigned long flags;
>>> +
>>> +    set_bit(EMAC_STATUS_DOWN, &adpt->status);
>>
>> Do you need to maintain that? Would not netif_running() tell you what
>> you want if you reflect the carrier state properly?
> 
> I think that emac_work_thread_link_check() handles this.  It's a timer
> thread that polls the link state and calls netif_carrier_off() if the
> link is down.  Is that sufficient?
> 

Probably, then again, with PHYLIB you have the option of either
switching the PHY to interrupt mode (thsus saving the polling_), or it
polls the PHY for link statuses every HZ.

[snip]

>>> +    if (skb_network_offset(skb) != ETH_HLEN)
>>> +        TPD_TYP_SET(&tpd, 1);
>>> +
>>> +    emac_tx_fill_tpd(adpt, tx_q, skb, &tpd);
>>> +
>>> +    netdev_sent_queue(adpt->netdev, skb->len);
>>> +
>>> +    /* update produce idx */
>>> +    prod_idx = (tx_q->tpd.produce_idx << tx_q->produce_shift) &
>>> +            tx_q->produce_mask;
>>> +    emac_reg_update32(adpt->base + tx_q->produce_reg,
>>> +              tx_q->produce_mask, prod_idx);
>>
>> Since you have a producer index, you should consider checking
>> skb->xmit_more to know whether you can update the register now, or
>> later, which could save some expensive operation and batch TX.
> 
> I'll have to figure out what means and get back to you.  When would
> "later" be?

After the driver gets accepted mainline for instance would seem fine.
Considering how this seems to work, something like this is usally all
that is needed:

if (!skb->xmit_more || netif_xmit_stopped(txq)
	/* write producer index to get HW to transmit */

[snip]

>>> +static int debug = -1;
>>> +module_param(debug, int, S_IRUGO | S_IWUSR | S_IWGRP);
>>
>> ethtool -s <iface> msglvl provides you with that already.
> 
> I'll remove it.  There's no ethtool support in this driver anyway, but
> there's no code that uses this parameter.

Adding support for changing message levels is really trivial, and will
probably help you while developing this driver.

[snip]

>>
>>> +}
>>> +
>>> +irqreturn_t emac_isr(int _irq, void *data)
>>> +{
>>> +    struct emac_irq *irq = data;
>>> +    struct emac_adapter *adpt = container_of(irq, struct
>>> emac_adapter, irq);
>>> +    struct emac_rx_queue *rx_q = &adpt->rx_q;
>>> +
>>> +    int max_ints = 1;
>>> +    u32 isr, status;
>>> +
>>> +    /* disable the interrupt */
>>> +    writel(0, adpt->base + EMAC_INT_MASK);
>>> +
>>> +    do {
>>
>> With max_ints = 1, this is essentially the same as no loop, so just
>> inline it to reduce the indentation.
> 
> In another internal version of this driver, max_ints is set to 5.  Could
> this be some way of processing multiple packets in one interrupt?  Isn't
> that something that NAPI already takes care of, anyway?

Yes, NAPI is going to mitigate the cost of taking an interrupt and
scheduling your bottom-half/soft IRQ for actual packet processing, it is
the recommended way to mitigate the number of interrupts in the receive
path (and transmit for that matter).

> 
>>> +        isr = readl_relaxed(adpt->base + EMAC_INT_STATUS);
>>> +        status = isr & irq->mask;
>>> +
>>> +        if (status == 0)
>>> +            break;
>>> +
>>> +        if (status & ISR_ERROR) {
>>> +            netif_warn(adpt,  intr, adpt->netdev,
>>> +                   "warning: error irq status 0x%lx\n",
>>> +                   status & ISR_ERROR);
>>> +            /* reset MAC */
>>> +            set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
>>> +            emac_work_thread_reschedule(adpt);
>>> +        }
>>> +
>>> +        /* Schedule the napi for receive queue with interrupt
>>> +         * status bit set
>>> +         */
>>> +        if ((status & rx_q->intr)) {
>>> +            if (napi_schedule_prep(&rx_q->napi)) {
>>> +                irq->mask &= ~rx_q->intr;
>>> +                __napi_schedule(&rx_q->napi);
>>> +            }
>>> +        }
>>> +
>>> +        if (status & TX_PKT_INT)
>>> +            emac_mac_tx_process(adpt, &adpt->tx_q);
>>
>> You should consider using a NAPI instance for reclaiming TX buffers as
>> well.
> 
> I'll have to figure out what means and get back to you.

drivers/net/ethernet/broadcom/bcmsysport.c is an example driver that
reclaims transmitted buffers in NAPI. What that means is, take the TX
completion interrupt, schedule a NAPI instance to run, and this NAPI
instance cleans up the entire TX queue (it is not bounded, like the RX
NAPI instance). It is really just moving the freeing of SKBs into
softIRQ context vs. hardIRQ.

[snip]

>>> +/* Configure VLAN tag strip/insert feature */
>>> +static int emac_set_features(struct net_device *netdev,
>>> +                 netdev_features_t features)
>>> +{
>>> +    struct emac_adapter *adpt = netdev_priv(netdev);
>>> +
>>> +    netdev_features_t changed = features ^ netdev->features;
>>> +
>>> +    if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX |
>>> NETIF_F_HW_VLAN_CTAG_RX)))
>>> +        return 0;
>>> +
>>> +    netdev->features = features;
>>> +    if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>>> +        set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>> +    else
>>> +        clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>
>> What about TX vlan offload?
> 
> I don't know what that is.

TX VLAN offload would be that you can specify the VLAN id somewhere in a
packet's descriptor and have the HW automatically build an Ethernet
frame with the correct VLAN id, and all the Ethernet frame payload
appropriately placed at the correct offsets, with no cost for the CPU
but indicating that information (and not having to do a memmove() to
insert the 802.1Q tag).

[snip]

>>> +/* Probe function */
>>> +static int emac_probe(struct platform_device *pdev)
>>> +{
>>> +    struct net_device *netdev;
>>> +    struct emac_adapter *adpt;
>>> +    struct emac_phy *phy;
>>> +    int ret = 0;
>>> +    u32 hw_ver;
>>> +    u32 extended_irq_mask = emac_irq_use_extended ? IMR_EXTENDED_MASK :
>>> +                            IMR_NORMAL_MASK;
>>> +
>>> +    netdev = alloc_etherdev(sizeof(struct emac_adapter));
>>> +    if (!netdev)
>>> +        return -ENOMEM;
>>
>> There are references to multiple queues in the code, so why not
>> alloc_etherdev_mq() here with the correct number of queues?
> 
> That support was removed from the driver, and on our SOC, we hard-code
> the number of queues to 1 anyway.  I'm planning on adding multiple queue
> support (much) later.

Sounds like a good thing to do later, yes.

> 
>>> +    dev_set_drvdata(&pdev->dev, netdev);
>>> +    SET_NETDEV_DEV(netdev, &pdev->dev);
>>> +
>>> +    adpt = netdev_priv(netdev);
>>> +    adpt->netdev = netdev;
>>> +    phy = &adpt->phy;
>>> +    adpt->msg_enable = netif_msg_init(debug, EMAC_MSG_DEFAULT);
>>> +
>>> +    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>>
>> Really, is not that supposed to run on ARM64 servers?
> 
> Well, this version of the driver isn't, which is why it supports DT and
> not ACPI.  I'm planning on adding that support in a later patch.
> However, I'll add support for 64-bit masks in the next version of this
> patch.
> 
> Would this be okay:
> 
>     retval = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
>     if (retval) {
>         dev_err(&pdev->dev, "failed to set DMA mask err %d\n", retval);
>         goto err_res;
>     }
> 
> I've seen code like this in other drivers:
> 
>         ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
>         if (ret) {
>                 ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
>                 if (ret) {
>                         dev_err(dev, "failed to set dma mask\n");
>                         return ret;
>                 }
>         }
> 
> and I've never understood why it's necessary to fall back to 32-bits if
> 64 bits fails.  Isn't 64 bits a superset of 32 bits?  The driver is
> saying that the hardware supports all of DDR.  How could fail, and how
> could 32-bit succeed if 64-bits fails?

I believe there could be cases where the HW is capable of addressing
more physical memory than the CPU itself (usually unlikely, but it
could), there could be cases where the HW is behind an IOMMMU which only
has a window into the DDR, and that could prevent a higher DMA_BIT_MASK
from being successfully configured.
-- 
Florian
