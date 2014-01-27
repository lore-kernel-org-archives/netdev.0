From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached PHY
Date: Mon, 27 Jan 2014 11:36:32 -0800
Message-ID: <CAGVrzcZ15Ov4zFDkaX=YuK0xVa+_QVjha1TN0cnhoMHYh1Jx4Q@mail.gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
 <1390795167-6677-2-git-send-email-jcmvbkbc@gmail.com> <1390817904.2735.127.camel@deadeye.wl.decadent.org.uk>
 <52E6868C.3070401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>,
	Marc Gauthier <marc-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
To: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52E6868C.3070401-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-01-27 Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> Hi Ben,
>
> On Mon, Jan 27, 2014 at 2:18 PM, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> wrote:
>> On Mon, 2014-01-27 at 07:59 +0400, Max Filippov wrote:
>>> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
>>> not disable advertisement when PHY supports them. This results in
>>> non-functioning network when the MAC is connected to a gigabit PHY connected
>>> to a gigabit switch.
>>>
>>> The fix is to disable gigabit speed advertisement on attached PHY
>>> unconditionally.
>>>
>>> Signed-off-by: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>  drivers/net/ethernet/ethoc.c | 2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
>>> index 4de8cfd..0aa1a05 100644
>>> --- a/drivers/net/ethernet/ethoc.c
>>> +++ b/drivers/net/ethernet/ethoc.c
>>> @@ -712,6 +712,8 @@ static int ethoc_open(struct net_device *dev)
>>>               netif_start_queue(dev);
>>>       }
>>>
>>> +     priv->phy->advertising &= ~(ADVERTISED_1000baseT_Full |
>>> +                                 ADVERTISED_1000baseT_Half);
>>>       phy_start(priv->phy);
>>>       napi_enable(&priv->napi);
>>>
>>
>> This is not sufficient to disable gigabit speeds; the supported mask
>> should also be limited.  And it should be done even before the net
>
> I tried that, but when I also limit supported mask the phy driver doesn't
> touch gigabit advertising register int the genphy_config_advert at all.
> That's probably right for ethtool interface, but ethoc doesn't support
> ethtool.

This is not right for libphy either, phydev->supported must reflect
that you support Gigabit or not.

Since ethoc supports libphy, there really is no reason not to
implement the ethtool_{get,set}_settings callbacks using
phy_mii_ioctl().

>
>> device is registered.
>>
>> Rather than poking into the phy_device structure directly from this
>> driver, I think you should add a function in phylib for this purpose.

All drivers are currently modifying phydev->advertising and
phydev->supported directly, most of them do it correctly as far as I
checked. It does make some sense to add a helper function though.

>
> Like below?
>
> ---8<---
> From 347331f399626ecaa9a8e54252f55e0b6788772f Mon Sep 17 00:00:00 2001
> From: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 27 Jan 2014 04:01:40 +0400
> Subject: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached PHY
>
> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
> not disable advertisement when PHY supports them. This results in
> non-functioning network when the MAC is connected to a gigabit PHY connected
> to a gigabit switch.
>
> The fix is to disable gigabit speed advertisement on attached PHY
> unconditionally.
>
> Signed-off-by: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/ethoc.c | 3 +++
>  include/linux/phy.h          | 5 +++++
>  2 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 4de8cfd..e817d58 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -688,6 +688,9 @@ static int ethoc_mdio_probe(struct net_device *dev)
>         }
>
>         priv->phy = phy;
> +       phy_update_adv(phy,
> +                      ~(ADVERTISED_1000baseT_Full |
> +                        ADVERTISED_1000baseT_Half), 0);
>         return 0;
>  }
>
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 48a4dc3..0282a8d 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -559,6 +559,11 @@ static inline int phy_read_status(struct phy_device *phydev) {
>         return phydev->drv->read_status(phydev);
>  }
>
> +static inline void phy_update_adv(struct phy_device *phydev, u32 mask, u32 set)
> +{
> +       phydev->advertising = (phydev->advertising & mask) | set;
> +}
> +

This should be a preliminary patch to this patchset, so you first
introduce the function, then use it in the driver, but the idea looks
good. There is room for updating quite some drivers out there since
those used to modify phydev->advertising and phydev->supported
directly without using an accessor.

>  int genphy_setup_forced(struct phy_device *phydev);
>  int genphy_restart_aneg(struct phy_device *phydev);
>  int genphy_config_aneg(struct phy_device *phydev);
> --
> 1.8.1.4
>
>
> --
> Thanks.
> -- Max
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
