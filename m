From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 21:05:40 +0200
Message-ID: <5526CD84.9090402@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:25290 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbbDITFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 15:05:53 -0400
In-Reply-To: <5526806E.5020309@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack wrote:

> Mason wrote:
> 
>> Here is the data sheet for the AR8035:
>> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>>
>> It seems the problem comes from the fact that the PHY treats
>> HW reset and SW reset differently:
>>
>>      HW reset: registers are set to specific values
>>      SW reset: some bits are retained across reset
>>
>> Case in point: the control register (BMCR)
>> HW reset: BMCR = 0x3100
>> SW reset: retain bits[6,8,12,13] / other bits = 0
>>
>> (0x3100 means bit_6=0, bit_8=bit_12=bit_13=1)
>>
>> When we execute this line from genphy_soft_reset()
>>
>>      phy_write(phydev, MII_BMCR, BMCR_RESET);
>>
>> we reset the bits in BMCR, and SW reset does not restore them.
>>
>> It seems to me (please tell me if I am wrong) that it should
>> be safe for all PHYs to write old_val | BMCR_RESET, instead of
>> just BMCR_RESET. Thus...
>>
>> On chips that REALLY reset, the old_val bits will be discarded;
>> while on chips that retain some bits, we do want to keep them.
>>
>> So the patch would go something like below. What do you think?
> 
> I don't think that'll work, because writing a 1 into the RESET bit of
> the register causes the PHY to enter its software reset routine
> immediately. The other bits should hence be reset to their defaults,
> regardless of what you set them to at the same time.

I forgot to ask:

(I presume you have a system with an AR8035.)

When the PHY is reset, you don't see the odd behavior I get?

Can you print the value of BMCR, before and after

    phy_write(phydev, MII_BMCR, BMCR_RESET);

Regards.
