From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 18 Aug 2016 09:09:17 -0700
Message-ID: <3D5C1ACB-4338-4A9F-9BCC-0424A1793664@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org> <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org> <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com> <57B31780.5030106@codeaurora.org> <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org> <57B3878D.1000805@codeaurora.org> <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com> <57B4C6EE.3080903@codeaurora.org> <57B4E5F7.9040500@codeaurora.org> <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com> <57B52B17.1080809@codeaurora.org> <5CCEFB33-8F93-40D7-BD32-ACDE1CBA586D@gmail.com> <57B5374B.6010805@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        linux-arm-msm <linux-arm-msm@vger.kernel.org>,
        Sagar Dharia <sdharia@codeaurora.org>,
        Shanker Donthineni <shankerd@codeaurora.org>,
        Vikram Sethi <vikrams@codeaurora.org>,
        Christopher Covington <cov@codeaurora.org>,
        Gilad Avidov <gavidov@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Mark Langsdorf <mlangsdo@redhat.com>,
        "jcm@redhat.com" <jcm@redhat.com>,
        Andy Gross <agross@codeaurora.org>,
        David Miller <davem@davemloft.net>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        "Abdulhamid, Harb" <harba@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>, Al Stone <al.stone@linaro.org>,
        Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34631 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754594AbcHSBKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:10:32 -0400
In-Reply-To: <57B5374B.6010805@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On August 17, 2016 9:19:23 PM PDT, Timur Tabi <timur@codeaurora.org> wrote:
>Florian Fainelli wrote:
>> The larger issue is that the emac_sgmii node in the form you posted
>> is going to be backed by a platform device in Linux while you want a
>> PHY device with a reg property that describes a MDIO address
>> (#address-cells = 1, #size-cells = 0).
>
>But how do I get the platform device for the emac_sgmii node?  If I 
>create an of_device_id ID for it, like this:
>
>static const struct of_device_id emac_dt_match[] = {
>	{
>		.compatible = "qcom,fsm9900-emac",
>	},
>	{}
>};
>
>static const struct of_device_id emac_sgmii_dt_match[] = {
>	{
>		.compatible = "qcom,fsm9900-emac-sgmii",
>	},
>	{}
>};
>
>Then the probe function will be called for qcom,fsm9900-emac-sgmii 
>separately from qcom,fsm9900-emac, which just confuses things. So I 
>can't create emac_sgmii_dt_match.
>
>I know this is standard DT stuff, and I used to do a lot of work on DT 
>so maybe I should know this already.  But it seems to me that I need to
>
>manually create the platform_device for qcom,fsm9900-emac-sgmii.

There is a helper function to obtain the platform device associated with a device_node: of_find_device_by_node. AFAICT probe ordering is based on DT ordering, but if there was a dependency order to solve you could use EPROBE_DEFER until the emac driver finds its dependencies.

>
>> IIRC the amd xgbe driver mainline had a similar design but still
>> implemented a PHY device anyway although it may not have been using
>> Device Tree. It should still be possible to implement a PHY driver
>> that you manually register and bind to its device_node pointer such
>> that of_phy_find_device and friends still work. You would do this
>> from the emac_sgmii platform device driver and parent devices in a
>> way that satisfy the PHY device driver lifecycle as well.
>>
>> Hope this helps.
>
>It doesn't, sorry.  The emac_sgmii is really just another register
>block 
>for the driver to program.  Creating another PHY driver for it doesn't 
>really make sense.  It's not on an MDIO bus.

First of a PHY does not have to be on a MDIO bus, it just happens to be the most common thing, and second, this is a PHY of some kind as far as the Ethernet MAC is concerned and this is the abstraction you want at the MAC driver level so you can plug arbitrary external PHYs or internal PHYs irrespective of their backing transport/bus layer.

As long as your DT representation is sane and accurate, however this ends up being implemented matters less. Whether the PHY device model suits you here, you need to tell the emac0 node that it is bound to the emac_sgmii node somehow since there is programming of this block required for operating and for that a phandle property of some kind is required, phy-handle is a standard one which would help with the driver acceptance IMHO.


-- 
Florian
