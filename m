From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on
 attached PHY
Date: Fri, 31 Jan 2014 17:36:29 -0800
Message-ID: <CAGVrzcYULudTcuparnH4m1kDb9KUYUhXD1Ve5aJV2_VjROqHCg@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
 <1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com> <52E8A407.1020809@gmail.com>
 <CAMo8BfJ_nce_H_8HJ7iw9ME=8C+sjF_Q43RaDG+1eVrpxWRvdQ@mail.gmail.com>
 <CAGVrzcboHp8-qHZseGOVm14u1-cTcOjRZGExFxNu_nbK__XCSA@mail.gmail.com>
 <CAMo8BfK-3-B-n7gxLaSO3JXSNNT_HwF0yTAMd+L5pp6odJKFTg@mail.gmail.com>
 <CAMo8BfKkZOhsXBXWXS5scc5zN6qQnvk51HOCxAJmDWW19wFM-Q@mail.gmail.com>
 <CAGVrzcaN=noWOoMj0w720H5TUBypOv2HAFPPzJRAfA=R4RLUmw@mail.gmail.com>
 <CAGVrzcY00GS8n0POtUpSNEAiTSCZLKVB_6AUFAuB0B3Ax4wbXA@mail.gmail.com> <CAMo8BfJZsBdBVnfTLoD-jUiZ59wT-rUBRvT97haMGSPtD9eK0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Gauthier <marc@cadence.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Zankel <chris@zankel.net>,
	"linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMo8BfJZsBdBVnfTLoD-jUiZ59wT-rUBRvT97haMGSPtD9eK0g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-31 Max Filippov <jcmvbkbc@gmail.com>:
> On Sat, Feb 1, 2014 at 4:54 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> 2014-01-31 Florian Fainelli <f.fainelli@gmail.com>:
>>>>> Maybe they boot up with gigabit advertisement disabled in their PHY
>>>>> and thus they don't see the problem?
>>>>>
>>>>>> Other drivers do the following:
>>>>>>
>>>>>> - connect to the PHY
>>>>>> - phydev->supported = PHY_BASIC_FEATURES
>>>>>> - phydev->advertising &= phydev->supported
>>>>>> - start the PHY state machine
>>>>>>
>>>>>> And they work just fine. Is the PHY driver you are bound to the "Generic
>>>>>> PHY" or something else which does something funky in config_aneg()?
>>>>>
>>>>> It's marvell 88E1111 from the KC-705 board, but the behaviour doesn't
>>>>> change if I disable it and the generic phy is used.
>>>>
>>>> Florian,
>>>>
>>>> I don't see how the generic genphy_config_advert can ever change
>>>> gigabit advertisement if phydev->supported has gigabit speeds masked
>>>> off.
>>>
>>> It does not, but it makes sure that phydev->advertising gets masked
>>> with phydev->supported. So, prior to starting your PHY state machine,
>>> if you do:
>>>
>>> phydev->supported &= PHY_BASIC_FEATURES;
>>> phydev->advertising = phydev->supported;
>>
>> It looks like there might be one problem however, if we have the following:
>>
>> - phydev->supported masks off the Gigabit features
>> - PHY device comes out of reset/default with Gigabit features set in
>> MII_CTRL1000
>
> That's exactly my case.
>
>> Could you try the following patch:
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 78bf1a4..b607f4a 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -749,25 +749,24 @@ static int genphy_config_advert(struct phy_device *phydev)
>>         }
>>
>>         /* Configure gigabit if it's supported */
>> +       adv = phy_read(phydev, MII_CTRL1000);
>> +       if (adv < 0)
>> +               return adv;
>> +
>> +       oldadv = adv;
>> +       adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
>> +
>>         if (phydev->supported & (SUPPORTED_1000baseT_Half |
>>                                  SUPPORTED_1000baseT_Full)) {
>> -               adv = phy_read(phydev, MII_CTRL1000);
>> -               if (adv < 0)
>> -                       return adv;
>> -
>> -               oldadv = adv;
>> -               adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
>>                 adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
>> -
>> -               if (adv != oldadv) {
>> -                       err = phy_write(phydev, MII_CTRL1000, adv);
>> -
>> -                       if (err < 0)
>> -                               return err;
>> +               if (adv != oldadv)
>>                         changed = 1;
>> -               }
>>         }
>>
>> +       err = phy_write(phydev, MII_CTRL1000, adv);
>
>
> I don't think this is correct: MII_CTRL1000 is reserved for 10/100 PHYs,
> we probably need to read/write it conditionally, depending on MII_BMSR
> BMSR_ESTATEN bit.
> Otherwise yes, it works for me too.

You are right, that needs to be made conditional. I will give this
patch some more proper testing on a truly non-gigabit PHY. Thanks!
-- 
Florian
