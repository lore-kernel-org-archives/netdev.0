From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
Date: Tue, 3 Oct 2017 11:31:05 -0700
Message-ID: <fd7379ac-d617-1fed-45a2-6698256cf160@gmail.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
 <1847c902-8364-3c7c-f079-3d123ba1d3f1@gmail.com>
 <ccab5880-eace-503c-d325-d20867b98bd5@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:52510 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdJCSbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:31:11 -0400
Received: by mail-wr0-f176.google.com with SMTP id k62so7022885wrc.9
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:31:10 -0700 (PDT)
In-Reply-To: <ccab5880-eace-503c-d325-d20867b98bd5@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 11:03 AM, Dan Murphy wrote:
> Florian
> 
> Thanks for the review
> 
> On 10/03/2017 12:15 PM, Florian Fainelli wrote:
>>> +		} else {
>>> +			value &= ~DP83822_WOL_SECURE_ON;
>>> +		}
>>> +
>>> +		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
>>> +			  DP83822_WOL_CLR_INDICATION);
>>
>> The extra parenthesis should not be required here.
> 
> I did not code that in.  I had to add it after Checkpatch cribbed about it.
> Let me know if you want me to remove it.

Let's keep those, that does not change much.

> 
>>
>>> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
>>> +			      value);
>>> +	} else {
>>> +		value =
>>> +		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>>> +		value &= (~DP83822_WOL_EN);
>>
>> Same here, parenthesis should not be needed.
> 
> There are three lines of code in the else.  This code all needs to be excuted in the else case.
> I might reformat it to read better.  Lindent messed that one up.

sorry, I meant to write that you don't need the parenthesis around
DP83822_WOL_EN since that is just a single bit here.

[snip]

>>> +
>>> +	mutex_unlock(&phydev->lock);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static int dp83822_resume(struct phy_device *phydev)
>>> +{
>>> +	int value;
>>> +
>>> +	mutex_lock(&phydev->lock);
>>> +
>>> +	value = phy_read(phydev, MII_BMCR);
>>> +	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
>>
>> And genphy_resume() here as well?
> 
> genphy_resume does not have WoL.

I should have been cleared, I meant using genphy_{suspend,resume} to
avoid open coding the setting of the BMCR_PDOWN bit, conversely clearing
of that bit. Because of the locking, maybe you could introduce unlocked
versions of these two routines, or you acquire and release the lock
outside of genphy_{suspend,resume}?

> 
>>
>>> +
>>> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>>> +
>>> +	phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG, value |
>>> +		      DP83822_WOL_CLR_INDICATION);
>>> +
>>> +	mutex_unlock(&phydev->lock);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static struct phy_driver dp83822_driver[] = {
>>> +	{
>>> +	 .phy_id = DP83822_PHY_ID,
>>> +	 .phy_id_mask = 0xfffffff0,
>>> +	 .name = "TI DP83822",
>>> +	 .features = PHY_BASIC_FEATURES,
>>> +	 .flags = PHY_HAS_INTERRUPT,
>>> +
>>> +	 .config_init = genphy_config_init,
>>> +	 .soft_reset = dp83822_phy_reset,
>>> +
>>> +	 .get_wol = dp83822_get_wol,
>>> +	 .set_wol = dp83822_set_wol,
>>> +
>>> +	 /* IRQ related */
>>> +	 .ack_interrupt = dp83822_ack_interrupt,
>>> +	 .config_intr = dp83822_config_intr,
>>> +
>>> +	 .config_aneg = genphy_config_aneg,
>>> +	 .read_status = genphy_read_status,
>>> +	 .suspend = dp83822_suspend,
>>> +	 .resume = dp83822_resume,
>>> +	 },
>>
>> I would omit newlines between definitions of callbacks, but this is
>> really a personal preference. Unless you are planning on adding new IDs,
>> you could also avoid using an array of 1 element and just a plain
>> phy_driver structure, but that's not a big deal either.
> 
> Yes there is a plan to add another phy id in early 2018 to this driver.

Alright then!
-- 
Florian
