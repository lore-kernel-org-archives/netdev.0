From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Tue, 18 Apr 2017 09:40:59 -0700
Message-ID: <68e1a232-2fde-da42-d49f-20ea1fec6dbf@gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
 <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
 <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
 <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
 <20161124153809.GA20455@lunn.ch>
 <11549d93-4b51-25c8-e693-509048475bef@gmail.com>
 <2b4912e6-c380-b2bd-762a-d1da2b0a7d82@st.com>
 <5809df57-997b-3531-838f-8c5a61605fe5@gmail.com>
 <eb4a3c77-6bf4-8749-85a3-b614bff69cf2@gmail.com>
 <a45177c1-cd2b-46a3-7858-753ad3f28ae7@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>,
        Fabrice GASNIER <fabrice.gasnier@st.com>,
        rmk+kernel@armlinux.org.uk
To: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32786 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdDRQlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:41:03 -0400
In-Reply-To: <a45177c1-cd2b-46a3-7858-753ad3f28ae7@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 06:23 AM, Niklas Cassel wrote:
> On 01/04/2017 03:33 PM, Florian Fainelli wrote:
>> On 12/02/2016 09:48 AM, Florian Fainelli wrote:
>>>>> Peppe, any thoughts on this?
>>>>
>>>> I share what you say.
>>>>
>>>> In sum, the EEE management inside the stmmac is:
>>>>
>>>> - the driver looks at own HW cap register if EEE is supported
>>>>
>>>>     (indeed the user could keep disable EEE if bugged on some HW
>>>>      + Alex, Fabrice: we had some patches for this to propose where we
>>>>              called the phy_ethtool_set_eee to disable feature at phy
>>>>              level
>>>>
>>>> - then the stmmac asks PHY layer to understand if transceiver and
>>>>   partners are EEE capable.
>>>>
>>>> - If all matches the EEE is actually initialized.
>>>>
>>>> the logic above should be respected when use ethtool, hmm, I will
>>>> check the stmmac_ethtool_op_set_eee asap.
>>>>
>>>> Hoping this is useful
>>>
>>> This is definitively useful, the only part that I am struggling to
>>> understand in phy_init_eee() is this:
>>>
>>>                 eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
>>>                                                 MDIO_MMD_AN);
>>>                 if (eee_adv <= 0)
>>>                         goto eee_exit_err;
>>>
>>> if we are not already advertising EEE in the PHY's MMIO_MMD_AN page, by
>>> the time we call phy_init_eee(), then we cannot complete the EEE
>>> configuration at the PHY level, and presumably we should abort the EEE
>>> configuration at the MAC level.
>>>
>>> While this condition makes sense if e.g: you are re-negotiating the link
>>> with your partner for instance and if EEE was already advertised, the
>>> very first time this function is called, it seems to be like we should
>>> skip the check, because phy_init_eee() should actually tell us if, as a
>>> result of a successful check, we should be setting EEE as something we
>>> advertise?
>>>
>>> Do you remember what was the logic behind this check when you added it?
>>
>> Peppe, can you remember why phy_init_eee() was written in a way that you
>> need to have already locally advertised EEE for the function to
>> successfully return? Thank you!
>>
> 
> I'm curious about this as well.
> 
> I can get EEE to work with stmmac, but to be able to turn EEE on,
> I need to set eee advertise via ethtool first.
> (Tested with 2 different PHYs from different vendors, with their
> PHY specific driver enabled.)
> 
> Is this the same for all PHYs or are there certain PHYs/PHY drivers
> that actually advertise eee by default?

It depends on whether the PHY driver takes care of the EEE advertisement
part for your or not, most drivers probably don't do that.

> (From reading this mail thread there seems to be a suggestion that
> the broadcom PHY driver might advertise eee by default.)

As written before, some (not all) Broadcom PHY drivers (cygnus, 7xxx) do
advertise EEE by default in order to validate the first check done in
phy_init_eee(), but that's the only reason really.

Since we have not been able to get a straight answer from Peppe about
why there is this initial check, I think the cleanest path moving
forward is the following:

- rename phy_init_eee() into something like: phy_can_do_eee() and remove
the first check on whether EEE is already advertised because that's
precisely what we are trying to determine with this function

- Ethernet MAC drivers keep calling phy_can_do_eee() (formerly
phy_init_eee()) during their adjust_link callback in order to
re-negotiate EEE with their link partner, just like they should call
phy_ethtool_set_eee() to really enable EEE the first time they want to
enable EEE with the link partner

- remove the part from phy_init_eee() that tries to stop the PHY TX
clock and provide a set of helpers: phy_can_stop_tx_clk() and
phy_set_stop_tx_clk() which will take care of that

Does that look reasonable?
-- 
Florian
