From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 10:16:17 -0700
Message-ID: <23c238e0-2af8-3171-9986-af02e9c19129@gmail.com>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk> <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
 <20170601131955.GH9282@lunn.ch>
 <20170601154735.GB22219@n2100.armlinux.org.uk>
 <20170601162417.GA14541@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:32818 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFARQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:16:20 -0400
Received: by mail-qk0-f193.google.com with SMTP id c206so6533928qkb.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 10:16:20 -0700 (PDT)
In-Reply-To: <20170601162417.GA14541@n2100.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 09:24 AM, Russell King - ARM Linux wrote:
> On Thu, Jun 01, 2017 at 04:47:35PM +0100, Russell King - ARM Linux wrote:
>> On Thu, Jun 01, 2017 at 03:19:55PM +0200, Andrew Lunn wrote:
>>> On Thu, Jun 01, 2017 at 02:09:00PM +0100, Russell King - ARM Linux wrote:
>>>> On Thu, Jun 01, 2017 at 03:05:27PM +0200, Andrew Lunn wrote:
>>>>> So you are saying a 10G PHY driver always needs to have a aneg_done
>>>>> callback, even if it just needs to call phygen_c45_aneg_done?
>>>>>
>>>>> This seems a bit error prone. I can see somebody writing a 10G driver,
>>>>> leaving out aneg_done() and having the c22 version called. Is the read
>>>>> of MII_BMSR likely to return 0xffff, since the register does not
>>>>> exist? If so, genphy_aneg_done() is likely to always return
>>>>> BMSR_ANEGCOMPLETE.
>>>>
>>>> Don't forget that the read will fail, so phy_read() will return a
>>>> negative number.
>>>
>>> By fail, you mean return something like -EIO or -ETIMEOUT? Is this
>>> guaranteed in the code somewhere? This particular Marvell PHY only
>>> does c45. But i could imagine some other PHYs answering a c22 request
>>> with 0xffff.
>>
>> Yes, C45 allows the PHYs to answer C22 as well, but then they have to
>> implement the C22 register set.  Such a PHY would be out of spec,
>> especially as what you're suggesting is that it answers C22 cycles
>> and fails to implement MII_BMSR.  I also think that there's a comment
>> in the 802.3 specs that says that unimplemented registers are to
>> return zero, not 0xffff.
> 
> Checking 802.3-2015, in "22.2.4 Management functions", the first
> sentence requires all PHYs that respond to Clause 22 cycles to
> implement BMCR and BMSR.  However, my statement about unimplemented
> registers returning zero seems to be a C45 thing, not a C22 thing,
> according to the C22 PICS and "45.2 MDIO Interface Registers"
> 
> However, digging a bit further, "22.2.4.2.10 Auto-Negotiation complete"
> states that bit 5 shall be zero if aneg has not completed or if aneg is
> unimplemented.
> 

So how about we are more defensive than that and if we are presented
with a C45 PHY driver that does not have an aneg_done() function pointer
set we return an error/warning during driver registration?
-- 
Florian
