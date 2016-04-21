From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 21 Apr 2016 13:03:33 -0500
Message-ID: <571915F5.5070504@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com>
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
In-Reply-To: <57100962.40404@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:

> Well, PHYLIB does prefer using MDIO accesses to "speak" to PHYs,
> built-in or external, but there is always the option of investing into
> some custom development with the subsystem to make it play nicely with
> your HW.

So I've done some more research, and I believe that the internal phy is 
not a candidate for phylib, but the external phy (which is a real phy) 
might be.  There's no MDIO bus to the internal phy.

Does this mean that I will need to enable a PHY driver, and that driver 
will control the external phy?  If so, then does that mean that I would 
delete all to code in my driver that calls emac_phy_read() and 
emac_phy_write()?  For example, I wouldn't need emac_phy_link_check() 
any more?

>> The MDIO bus on these chips is not accessible as a separate entity.  It
>> is melded (for lack of a better word) into the EMAC itself.  That's why
>> there is a "qcom,no-external-phy" property.  You could, in theory, wire
>> the internal phy of one SOC directly to the internal phy of another SOC,
>> and use that as in interconnect between SOCs.  I don't know of any such
>> use-cases however.
>
> The fact the MDIO bus is built-into the MAC is really not a problem
> here, there are tons of drivers that deal with that just fine, yet, the
> DT binding needs to reflect that properly by having a sub-node of the
> Ethernet MAC which is a MDIO bus controller node. If external or
> internal PHYs are accessible through that MDIO bus, they also need to
> appear as child-nodes of that MDIO bus controller node.

Does the compatible property of the phy node (for the external phy) need 
to list the actual external phy?  That is, should it look like this:

	phy0: ethernet-phy@0 {
		compatible = "qcom,fsm9900-emac-phy";
		reg = <0>;
	}

or this:

	phy0: ethernet-phy@0 {
		compatible = "athr,whatever-phy";
		reg = <0>;
	}



> Can we just say that, an absence of PHY specified in the Device Tree (no
> phy-handle property and PHY not a child node of the MDIO bus), means
> that there is no external PHY?

Yes, that works.

>
> [snip]
>
>>> Do you need to maintain these flags when most, if not all of them
>>> already exist in dev->flags or dev->features?
>>
>> So you're saying that, for example, in emac_set_features() I should
>> remove this:
>>
>>      if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>>          set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>      else
>>          clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>
>> and then in emac_mac_mode_config(), I should do this instead:
>>
>> void emac_mac_mode_config(struct emac_adapter *adpt)
>> {
>>      struct net_device *netdev = adpt->netdev;
>>
>>      if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>>          mac |= VLAN_STRIP;
>>      else
>>          mac &= ~VLAN_STRIP;
>>
>>
>> If so, then what do I do in emac_rx_mode_set()?  Should I delete this
>> entire block:
>>
>>      /* Check for Promiscuous and All Multicast modes */
>>      if (netdev->flags & IFF_PROMISC) {
>>          set_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>>      } else if (netdev->flags & IFF_ALLMULTI) {
>>          set_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
>>          clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>>      } else {
>>          clear_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
>>          clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
>>      }
>>
>> It does look like Gilad is just mirroring the flags/features variable
>> into adpt->status.  What I can't figure out is why.  It seems completely
>> redundant, but I have a nagging feeling that there is a good reason.
>
> Yes, I think your set_features and set_rx_mode functions would be
> greatly simplified, if each of them did take care of programming the HW
> immediately based on function arguments/flags. Unless absolutely
> required (e.g: suspend/resume, outside of the scope of the function
> etc..) having bookeeping variables is always something that can be out
> of sync, so better avoid them as much as possible.

Ok, I'll try to clean this up.

>> So I should move the netif_start_queue() to the end of this function?
>> Sorry if that's a stupid question, but I know little about the MAC side
>> of network drivers.
>
> That's fine, yes moving netif_start_queue() at the far end of the
> function is a good change.

Ok.

>>>> +/* Bring down the interface/HW */
>>>> +void emac_mac_down(struct emac_adapter *adpt, bool reset)
>>>> +{
>>>> +    struct net_device *netdev = adpt->netdev;
>>>> +    struct emac_phy *phy = &adpt->phy;
>>>> +    unsigned long flags;
>>>> +
>>>> +    set_bit(EMAC_STATUS_DOWN, &adpt->status);
>>>
>>> Do you need to maintain that? Would not netif_running() tell you what
>>> you want if you reflect the carrier state properly?
>>
>> I think that emac_work_thread_link_check() handles this.  It's a timer
>> thread that polls the link state and calls netif_carrier_off() if the
>> link is down.  Is that sufficient?
>>
>
> Probably, then again, with PHYLIB you have the option of either
> switching the PHY to interrupt mode (thsus saving the polling_), or it
> polls the PHY for link statuses every HZ.

I'll have to check and see if interrupt mode is even an option.  So 
phylib can do the polling for me?

>>> Since you have a producer index, you should consider checking
>>> skb->xmit_more to know whether you can update the register now, or
>>> later, which could save some expensive operation and batch TX.
>>
>> I'll have to figure out what means and get back to you.  When would
>> "later" be?
>
> After the driver gets accepted mainline for instance would seem fine.
> Considering how this seems to work, something like this is usally all
> that is needed:
>
> if (!skb->xmit_more || netif_xmit_stopped(txq)
> 	/* write producer index to get HW to transmit */

Oh, I thought you meant later in the code somewhere.  At a later date 
with another patch sounds great to me, though.

>>>> +irqreturn_t emac_isr(int _irq, void *data)
>>>> +{
>>>> +    struct emac_irq *irq = data;
>>>> +    struct emac_adapter *adpt = container_of(irq, struct
>>>> emac_adapter, irq);
>>>> +    struct emac_rx_queue *rx_q = &adpt->rx_q;
>>>> +
>>>> +    int max_ints = 1;
>>>> +    u32 isr, status;
>>>> +
>>>> +    /* disable the interrupt */
>>>> +    writel(0, adpt->base + EMAC_INT_MASK);
>>>> +
>>>> +    do {
>>>
>>> With max_ints = 1, this is essentially the same as no loop, so just
>>> inline it to reduce the indentation.
>>
>> In another internal version of this driver, max_ints is set to 5.  Could
>> this be some way of processing multiple packets in one interrupt?  Isn't
>> that something that NAPI already takes care of, anyway?
>
> Yes, NAPI is going to mitigate the cost of taking an interrupt and
> scheduling your bottom-half/soft IRQ for actual packet processing, it is
> the recommended way to mitigate the number of interrupts in the receive
> path (and transmit for that matter).

I'll clean up the code and remove max_ints.

>
>>
>>>> +        isr = readl_relaxed(adpt->base + EMAC_INT_STATUS);
>>>> +        status = isr & irq->mask;
>>>> +
>>>> +        if (status == 0)
>>>> +            break;
>>>> +
>>>> +        if (status & ISR_ERROR) {
>>>> +            netif_warn(adpt,  intr, adpt->netdev,
>>>> +                   "warning: error irq status 0x%lx\n",
>>>> +                   status & ISR_ERROR);
>>>> +            /* reset MAC */
>>>> +            set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
>>>> +            emac_work_thread_reschedule(adpt);
>>>> +        }
>>>> +
>>>> +        /* Schedule the napi for receive queue with interrupt
>>>> +         * status bit set
>>>> +         */
>>>> +        if ((status & rx_q->intr)) {
>>>> +            if (napi_schedule_prep(&rx_q->napi)) {
>>>> +                irq->mask &= ~rx_q->intr;
>>>> +                __napi_schedule(&rx_q->napi);
>>>> +            }
>>>> +        }
>>>> +
>>>> +        if (status & TX_PKT_INT)
>>>> +            emac_mac_tx_process(adpt, &adpt->tx_q);
>>>
>>> You should consider using a NAPI instance for reclaiming TX buffers as
>>> well.
>>
>> I'll have to figure out what means and get back to you.
>
> drivers/net/ethernet/broadcom/bcmsysport.c is an example driver that
> reclaims transmitted buffers in NAPI. What that means is, take the TX
> completion interrupt, schedule a NAPI instance to run, and this NAPI
> instance cleans up the entire TX queue (it is not bounded, like the RX
> NAPI instance). It is really just moving the freeing of SKBs into
> softIRQ context vs. hardIRQ.

Thanks.  I don't think I'll get to any of the NAPI fixes in v5 of this 
driver.  I want to make sure I get the phylib conversion correct first.

>>>> +/* Configure VLAN tag strip/insert feature */
>>>> +static int emac_set_features(struct net_device *netdev,
>>>> +                 netdev_features_t features)
>>>> +{
>>>> +    struct emac_adapter *adpt = netdev_priv(netdev);
>>>> +
>>>> +    netdev_features_t changed = features ^ netdev->features;
>>>> +
>>>> +    if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX |
>>>> NETIF_F_HW_VLAN_CTAG_RX)))
>>>> +        return 0;
>>>> +
>>>> +    netdev->features = features;
>>>> +    if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
>>>> +        set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>>> +    else
>>>> +        clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
>>>
>>> What about TX vlan offload?
>>
>> I don't know what that is.
>
> TX VLAN offload would be that you can specify the VLAN id somewhere in a
> packet's descriptor and have the HW automatically build an Ethernet
> frame with the correct VLAN id, and all the Ethernet frame payload
> appropriately placed at the correct offsets, with no cost for the CPU
> but indicating that information (and not having to do a memmove() to
> insert the 802.1Q tag).

I have no idea if our hardware supports that.  I'll make a note of TX 
VLAN offload and submit a separate patch if I can make it work.

>> and I've never understood why it's necessary to fall back to 32-bits if
>> 64 bits fails.  Isn't 64 bits a superset of 32 bits?  The driver is
>> saying that the hardware supports all of DDR.  How could fail, and how
>> could 32-bit succeed if 64-bits fails?
>
> I believe there could be cases where the HW is capable of addressing
> more physical memory than the CPU itself (usually unlikely, but it
> could),there could be cases where the HW is behind an IOMMMU which only
> has a window into the DDR, and that could prevent a higher DMA_BIT_MASK
> from being successfully configured.

So, so I'm going to add dma-ranges support (I posted another patch asked 
for feedback, but I haven't gotten it yet).

For ACPI, we're going to depend on IORT to set the DMA mask for us.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
