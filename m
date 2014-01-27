From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached PHY
Date: Mon, 27 Jan 2014 14:31:07 -0800
Message-ID: <CAGVrzcYuphSwoBfh6+tSzo13QUBqcpwVGtBUYTd5ytxs4kYTtQ@mail.gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
 <1390795167-6677-2-git-send-email-jcmvbkbc@gmail.com> <1390817904.2735.127.camel@deadeye.wl.decadent.org.uk>
 <52E6868C.3070401@gmail.com> <CAGVrzcZ15Ov4zFDkaX=YuK0xVa+_QVjha1TN0cnhoMHYh1Jx4Q@mail.gmail.com>
 <CAMo8BfLx9iVTqW9fQonF=7C=oDG1RpU5iyGUXf_wFnk7TEvShA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMo8BfLx9iVTqW9fQonF=7C=oDG1RpU5iyGUXf_wFnk7TEvShA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(fixing Rob's email)

2014-01-27 Max Filippov <jcmvbkbc@gmail.com>:
> On Mon, Jan 27, 2014 at 11:36 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> 2014-01-27 Max Filippov <jcmvbkbc@gmail.com>:
>>> On Mon, Jan 27, 2014 at 2:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
>>>> On Mon, 2014-01-27 at 07:59 +0400, Max Filippov wrote:
>>>>> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
>>>>> not disable advertisement when PHY supports them. This results in
>>>>> non-functioning network when the MAC is connected to a gigabit PHY connected
>>>>> to a gigabit switch.
>>>>>
>>>>> The fix is to disable gigabit speed advertisement on attached PHY
>>>>> unconditionally.
>>>>>
>>>>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>>>>> ---
>>>>>  drivers/net/ethernet/ethoc.c | 2 ++
>>>>>  1 file changed, 2 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
>>>>> index 4de8cfd..0aa1a05 100644
>>>>> --- a/drivers/net/ethernet/ethoc.c
>>>>> +++ b/drivers/net/ethernet/ethoc.c
>>>>> @@ -712,6 +712,8 @@ static int ethoc_open(struct net_device *dev)
>>>>>               netif_start_queue(dev);
>>>>>       }
>>>>>
>>>>> +     priv->phy->advertising &= ~(ADVERTISED_1000baseT_Full |
>>>>> +                                 ADVERTISED_1000baseT_Half);
>>>>>       phy_start(priv->phy);
>>>>>       napi_enable(&priv->napi);
>>>>>
>>>>
>>>> This is not sufficient to disable gigabit speeds; the supported mask
>>>> should also be limited.  And it should be done even before the net
>>>
>>> I tried that, but when I also limit supported mask the phy driver doesn't
>>> touch gigabit advertising register int the genphy_config_advert at all.
>>> That's probably right for ethtool interface, but ethoc doesn't support
>>> ethtool.
>>
>> This is not right for libphy either, phydev->supported must reflect
>> that you support Gigabit or not.
>
> I'm sorry, does that mean that I must not touch phydev->supported,
> or that I must update it too and somehow fix genphy_config_advert?

What I meant is that your driver has to set both phydev->advertising
and phydev->supported. genphy_config_advert() is doing
phdev->advertising &= phydev->supported, leaving phydev->supported to
something more restrictive will produce unexpected results. This is
also important if phy_driver::config_aneg() is not using the generic
implementation and directly uses/modifies phydev->advertising and
phydev->supported.

It seems like there is room for improvements in that area regardless
of how we access things. For instance, specifying the PHY interface
mode (MII, GMII etc...) should already provide a hint of what
phydev->supported should look like. You cannot do Gigabit with MII for
instance.

>
>> Since ethoc supports libphy, there really is no reason not to
>> implement the ethtool_{get,set}_settings callbacks using
>> phy_mii_ioctl().
>
> Ok, I'll add that.
>
>>>> device is registered.
>>>>
>>>> Rather than poking into the phy_device structure directly from this
>>>> driver, I think you should add a function in phylib for this purpose.
>>
>> All drivers are currently modifying phydev->advertising and
>> phydev->supported directly, most of them do it correctly as far as I
>> checked. It does make some sense to add a helper function though.
>
> [...]
>
>>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>>> index 48a4dc3..0282a8d 100644
>>> --- a/include/linux/phy.h
>>> +++ b/include/linux/phy.h
>>> @@ -559,6 +559,11 @@ static inline int phy_read_status(struct phy_device *phydev) {
>>>         return phydev->drv->read_status(phydev);
>>>  }
>>>
>>> +static inline void phy_update_adv(struct phy_device *phydev, u32 mask, u32 set)
>>> +{
>>> +       phydev->advertising = (phydev->advertising & mask) | set;
>>> +}
>>> +
>>
>> This should be a preliminary patch to this patchset, so you first
>> introduce the function, then use it in the driver, but the idea looks
>> good. There is room for updating quite some drivers out there since
>> those used to modify phydev->advertising and phydev->supported
>> directly without using an accessor.
>
> What about those that do something like this:
>
> phydev->advertising = phydev->supported;
>
> leave them as is, or provide read accessor for phydev->supported?

Those should be just fine since genphy_config_advert() does
phydev->advertising &= phydev->supported, so the end result will be
identical. You mean a write accessor instead of a read accessor?
-- 
Florian
