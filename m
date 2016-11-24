From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Thu, 24 Nov 2016 10:23:15 -0800
Message-ID: <11549d93-4b51-25c8-e693-509048475bef@gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
 <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
 <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
 <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
 <20161124153809.GA20455@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Yegor Yefremov <yegorslists@googlemail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35119 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935249AbcKXSXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 13:23:19 -0500
In-Reply-To: <20161124153809.GA20455@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+Peppe,

Le 24/11/2016 à 07:38, Andrew Lunn a écrit :
>> As for enabling advertising and correct working of cpsw do you mean it
>> would be better to disable EEE in any PHY on cpsw initialization as
>> long as cpsw doesn't provide support for EEE?
>>
>> We observe some strange behavior with our gigabit PHYs and a link
>> partner in a EEE-capable unmanaged NetGear switch. Disabling
>> advertising seems to help. Though we're still investigating the issue.
> 
> Hi Florian
> 
> Am i right in saying, a PHY should not advertise EEE until the MAC
> driver calls phy_init_eee(), indicating the MAC supports EEE?

You would think so, but I don't see how this could possibly work if that
was not the case already, see below.

> 
> If so, it looks like we need to change a few of the PHY drivers, in
> particular, the bcm-*.c.

The first part that bcm-phy-lib.c does is make sure that EEE is enabled
such that this gets reflected in MDIO_PCS_EEE_ABLE, without this, we
won't be able to pass the first test in phy_init_eee(). The second part
is to advertise EEE such that this gets reflected in MDIO_AN_EEE_ADV,
also to make sure that we can pass the second check in phy_init_eee().

Now, looking at phy_init_eee(), and what stmmac does (and bcmgenet,
copied after stmmac), we need to somehow, have EEE advertised for
phy_init_eee() to succeed, prepare the MAC to support EEE, and finally
conclude with a call to phy_ethtool_set_eee(), which writes to the
MDIO_AN_EEE_ADV register, and concludes the EEE auto-negotiated process.
Since we already have EEE advertised, we are essentially just checking
that the EEE advertised settings and the LP advertised settings actually
do match, so it sounds like the final call to phy_ethtool_set_eee() is
potentially useless if the resolved advertised and link partner
advertised settings already match...

So it sounds like at least, the first time you try to initialize EEE, we
should start with EEE not advertised, and then, if we have EEE enabled
at some point, and we re-negotiate the link parameters, somehow
phy_init_eee() does a right job for that.

Peppe, any thoughts on this?
-- 
Florian
