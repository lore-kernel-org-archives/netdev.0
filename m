From: Vikram Sethi <vikrams@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 17:00:06 -0500
Message-ID: <571012E6.6050303@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org> <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org> <57100962.40404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
	Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, cov@codeaurora.org,
	gavidov@codeaurora.org, Rob Herring <robh+dt@kernel.org>,
	andrew@lunn.ch, bjorn.andersson@linaro.org,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57100962.40404@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of clarifications on the SGMII internal PHY and the DMA capability of the EMAC inline.

On 04/14/2016 04:19 PM, Florian Fainelli wrote:
> On 14/04/16 13:19, Timur Tabi wrote:
>> Florian Fainelli wrote:
>>> On 13/04/16 10:59, Timur Tabi wrote:
>>>> From: Gilad Avidov <gavidov@codeaurora.org>
>>>>
>>>> Add supports for ethernet controller HW on Qualcomm Technologies,
>>>> Inc. SoC.
>>>> This driver supports the following features:
>>>> 1) Checksum offload.
>>>> 2) Runtime power management support.
>>>> 3) Interrupt coalescing support.
>>>> 4) SGMII phy.
>>>> 5) SGMII direct connection without external phy.
>>>
>>>
>>> [snip]
>>>
>>>> +- qcom,no-external-phy      : Indicates there is no external PHY
>>>> connected to
>>>> +                  EMAC. Include this only if the EMAC is directly
>>>> +                  connected to the peer end without EPHY.
>>> How is the internal PHY accessed, is it responding on the MDIO bus at a
>>> particular address?
>> There is a set of memory-mapped registers.  It's not connected via MDIO
>> at all.  It's mapped via the "sgmii" addresses in the device tree (see
>> function emac_sgmii_config).
>>
>>> If so, standard MDIO scanning/probing works, and you
>>> can have your PHY driver flag this device has internal. Worst case, you
>>> can do what BCMGENET does, and have a special "phy-mode" value set to
>>> "internal" when this knowledge needs to exist prior to MDIO bus scanning
>>> (e.g: to power on the PHY).
>> So the internal phy is not a real phy.  It's not capable of driving an
>> RJ45 port (there's no analog part).  It's an SGMII-like device that is
>> hard-wired to the EMAC itself.
There *is* an analog part to the internal SGMII PHY. Please check the SGMII specification. The only non-standard part is that it's not on MDIO.

> OK, that explains things a bit, thanks, this is quite a bit of important
> detail actually.
>
>> In theory, the internal PHY is optional.  You could design an SOC that
>> has just the EMAC connected via normal MDIO to an external phy.  I
>> really wish our hardware designers has done that.  But unfortunately,
>> there are no SOCs like that, and so we have to treat the internal phy as
>> an extension of the EMAC.
>>
>> My preference would be to get rid of the "qcom,no-external-phy" property
>> and have an external phy be required, at least until Qualcomm creates an
>> SOC without the internal phy (which may never happen, for all I know).
>>
> Can we just say that, an absence of PHY specified in the Device Tree (no
> phy-handle property and PHY not a child node of the MDIO bus), means
> that there is no external PHY?
>
> [snip]
>
>
[snip]
>>>> +    dev_set_drvdata(&pdev->dev, netdev);
>>>> +    SET_NETDEV_DEV(netdev, &pdev->dev);
>>>> +
>>>> +    adpt = netdev_priv(netdev);
>>>> +    adpt->netdev = netdev;
>>>> +    phy = &adpt->phy;
>>>> +    adpt->msg_enable = netif_msg_init(debug, EMAC_MSG_DEFAULT);
>>>> +
>>>> +    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>>> Really, is not that supposed to run on ARM64 servers?
>> Well, this version of the driver isn't, which is why it supports DT and
>> not ACPI.  I'm planning on adding that support in a later patch.
>> However, I'll add support for 64-bit masks in the next version of this
>> patch.
>>
>> Would this be okay:
>>
>>     retval = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
>>     if (retval) {
>>         dev_err(&pdev->dev, "failed to set DMA mask err %d\n", retval);
>>         goto err_res;
>>     }

How can you set the mask to 64 bits when the EMAC IP on FSM9900 and QDF2432 can only do 32 bit DMA?
The mask in that API is a bit mask describing which bits of an address your device supports.

>> I've seen code like this in other drivers:
>>
>>         ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
>>         if (ret) {
>>                 ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
>>                 if (ret) {
>>                         dev_err(dev, "failed to set dma mask\n");
>>                         return ret;
>>                 }
>>         }
>>
>> and I've never understood why it's necessary to fall back to 32-bits if
>> 64 bits fails.  Isn't 64 bits a superset of 32 bits?  The driver is
>> saying that the hardware supports all of DDR.  How could fail, and how
>> could 32-bit succeed if 64-bits fails?
> I believe there could be cases where the HW is capable of addressing
> more physical memory than the CPU itself (usually unlikely, but it
> could), there could be cases where the HW is behind an IOMMMU which only
> has a window into the DDR, and that could prevent a higher DMA_BIT_MASK
> from being successfully configured.


-- 
Vikram Sethi
Qualcomm Technologies Inc, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
