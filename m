From: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Subject: Re: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector
 bits by reading ANAR
Date: Wed, 29 May 2013 13:20:56 +0200
Message-ID: <51A5E498.2030101@efe-gmbh.de>
References: <51A4D6FE.3080308@efe-gmbh.de> <AE90C24D6B3A694183C094C60CF0A2F6026B7251@saturn3.aculab.com> <635022046.487018.1369769745682.open-xchange@email.1und1.de> <AE90C24D6B3A694183C094C60CF0A2F6026B7253@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52333 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965683Ab3E2LUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 07:20:47 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7253@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 29.05.2013 10:51, schrieb David Laight:
>>> David Laight <David.Laight@ACULAB.COM> hat am 28. Mai 2013 um 18:22
>>> geschrieben:
>>>
>>>
>>>> This patch reads the PHY's MII_ADVERTISE register (ANAR) before modifying
>>>> it.
>>>> Hence, the protocol selector bits (4:0) which indicate IEEE 803.3u support
>>>> are
>>>> prevented from being cleared.
>>>> ...
>>>>                 /* Advertise only 10 and 100mbps full/half duplex speeds */
>>>> -               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
>>>> +               adv = phy_read(lp->phy_dev, MII_ADVERTISE);
>>>> +               if (adv < 0)
>>>> +                       return adv;
>>>> +               phy_write(lp->phy_dev, MII_ADVERTISE, adv | ADVERTISE_ALL);
>>>
>>> Given the comment shouldn't this be removing some bits?
>>>
>>> It is a long time since I read the definitions of the ANAR (etc).
>>> But I remember it having at least 5 bits defined for 10M and 100M
>>> operation (including 100T4), so the reference to keeping bits (4:0)
>>> seems confusing.
>>>
>>>    David
>>>
>>
>> David, thanks for your feedback!
>> The bits I mentioned (the 5 least bits in ANAR) are the so-called protocol
>> selection bits (at least that's what they call it at Intel, TI, Marvell, Maxim,
>> etc.). The only value that seems actually to be used is 1 (0b00001) which means
>> 802.3 / fast ethernet capability (maybe 0 for slower devices?). 1 is the
>> default value for all the 10/100(/1000) PHYs I know of, in some PHYs it is even
>> hardcoded (i.e. read-only). It must not be confused with ANAR bits 9:5 where
>> the actual speed and duplex mode can be selected.
>> ADVERTISE_ALL as defined in mii.h lacks this bit, in contrast to ADVERTISE_FULL
>> where it is set through ADVERTISE_CSMA. Whether this is correct or not; at
>> least it makes some sense to me to read what's actually written in these
>> register bits and not to clear them. Otherwise some PHYs might fall back to
>> 10-half as seen for the TI DP83640 which has been used to test this patch.
>> I hope this explains the reason for this patch.
> 

[...]

> However if you want to advertise 10M/100M HDX and FDX you need to unset
> the other speed bits (100T4 was assigned a bit, and I'm sure there were
> extra bits reserved for higher speeds - which also need clearing).
> Given that the ANAR is defined by 803.x you shouldn't really have a problem!

[...]

You are right. The 1000BASE-T capability is advertised in another register and
already gets cleared one code line before (see original list mail), while the
100BASE-T4 bit now remains unchanged with my patch which is not intended.
Consequently the new patch would look like this:
-               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
+               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL |
+                         ADVERTISE_CSMA);
This only advertises HDX & FDX for both 10M / 100M, sets the 802.3 selector
bits as defined in ADVERTISE_CSMA, and clears all other bits which should be
safe. It is done a similar way in some other drivers.
I will prepare a patch resend then.

Jens.
