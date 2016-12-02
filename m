From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Fri, 2 Dec 2016 09:48:27 -0800
Message-ID: <5809df57-997b-3531-838f-8c5a61605fe5@gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
 <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
 <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
 <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
 <20161124153809.GA20455@lunn.ch>
 <11549d93-4b51-25c8-e693-509048475bef@gmail.com>
 <2b4912e6-c380-b2bd-762a-d1da2b0a7d82@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>,
        Fabrice GASNIER <fabrice.gasnier@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34997 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbcLBRsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:48:31 -0500
In-Reply-To: <2b4912e6-c380-b2bd-762a-d1da2b0a7d82@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2016 01:11 AM, Giuseppe CAVALLARO wrote:
> Hi Florian
> sorry for my delay.
> 
> On 11/24/2016 7:23 PM, Florian Fainelli wrote:
>> +Peppe,
>>
>> Le 24/11/2016 à 07:38, Andrew Lunn a écrit :
>>>> As for enabling advertising and correct working of cpsw do you mean it
>>>> would be better to disable EEE in any PHY on cpsw initialization as
>>>> long as cpsw doesn't provide support for EEE?
>>>>
>>>> We observe some strange behavior with our gigabit PHYs and a link
>>>> partner in a EEE-capable unmanaged NetGear switch. Disabling
>>>> advertising seems to help. Though we're still investigating the issue.
>>>
>>> Hi Florian
>>>
>>> Am i right in saying, a PHY should not advertise EEE until the MAC
>>> driver calls phy_init_eee(), indicating the MAC supports EEE?
>>
>> You would think so, but I don't see how this could possibly work if that
>> was not the case already, see below.
>>
>>>
>>> If so, it looks like we need to change a few of the PHY drivers, in
>>> particular, the bcm-*.c.
>>
>> The first part that bcm-phy-lib.c does is make sure that EEE is enabled
>> such that this gets reflected in MDIO_PCS_EEE_ABLE, without this, we
>> won't be able to pass the first test in phy_init_eee(). The second part
>> is to advertise EEE such that this gets reflected in MDIO_AN_EEE_ADV,
>> also to make sure that we can pass the second check in phy_init_eee().
>>
>> Now, looking at phy_init_eee(), and what stmmac does (and bcmgenet,
>> copied after stmmac), we need to somehow, have EEE advertised for
>> phy_init_eee() to succeed, prepare the MAC to support EEE, and finally
>> conclude with a call to phy_ethtool_set_eee(), which writes to the
>> MDIO_AN_EEE_ADV register, and concludes the EEE auto-negotiated process.
>> Since we already have EEE advertised, we are essentially just checking
>> that the EEE advertised settings and the LP advertised settings actually
>> do match, so it sounds like the final call to phy_ethtool_set_eee() is
>> potentially useless if the resolved advertised and link partner
>> advertised settings already match...
>>
>> So it sounds like at least, the first time you try to initialize EEE, we
>> should start with EEE not advertised, and then, if we have EEE enabled
>> at some point, and we re-negotiate the link parameters, somehow
>> phy_init_eee() does a right job for that.
>>
>> Peppe, any thoughts on this?
> 
> I share what you say.
> 
> In sum, the EEE management inside the stmmac is:
> 
> - the driver looks at own HW cap register if EEE is supported
> 
>     (indeed the user could keep disable EEE if bugged on some HW
>      + Alex, Fabrice: we had some patches for this to propose where we
>              called the phy_ethtool_set_eee to disable feature at phy
>              level
> 
> - then the stmmac asks PHY layer to understand if transceiver and
>   partners are EEE capable.
> 
> - If all matches the EEE is actually initialized.
> 
> the logic above should be respected when use ethtool, hmm, I will
> check the stmmac_ethtool_op_set_eee asap.
> 
> Hoping this is useful

This is definitively useful, the only part that I am struggling to
understand in phy_init_eee() is this:

                eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
                                                MDIO_MMD_AN);
                if (eee_adv <= 0)
                        goto eee_exit_err;

if we are not already advertising EEE in the PHY's MMIO_MMD_AN page, by
the time we call phy_init_eee(), then we cannot complete the EEE
configuration at the PHY level, and presumably we should abort the EEE
configuration at the MAC level.

While this condition makes sense if e.g: you are re-negotiating the link
with your partner for instance and if EEE was already advertised, the
very first time this function is called, it seems to be like we should
skip the check, because phy_init_eee() should actually tell us if, as a
result of a successful check, we should be setting EEE as something we
advertise?

Do you remember what was the logic behind this check when you added it?

Thanks!
-- 
Florian
