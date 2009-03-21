From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: net_device_ops support in bridging and fec_mpc52xx.c
Date: Sat, 21 Mar 2009 16:00:34 -0600
Message-ID: <fa686aa40903211500s1cfbc599lc2a51a6aeca34396@mail.gmail.com>
References: <ae4f76fd0902180241s28458450hd91ebf8da94ceb53@mail.gmail.com>
	 <20090218.134852.118040610.davem@davemloft.net>
	 <ae4f76fd0902190145r7ed5fadbwfca18c97dbfc9ed1@mail.gmail.com>
	 <fa686aa40903101013j2324e8acw18830c930e12ae46@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, bridge@osdl.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Henk Stegeman <henk.stegeman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:23315 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434AbZCUWAh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:00:37 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1554133ywb.1
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:00:34 -0700 (PDT)
In-Reply-To: <fa686aa40903101013j2324e8acw18830c930e12ae46@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Henk,

At the very least, I still need a signed-off-by: line from you on this =
one.

g.

On Tue, Mar 10, 2009 at 11:13 AM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> Hi Henk,
>
> Acked-by: Grant Likely <grant.likely@secretlab.ca>
>
> Can you please repost with a blurb for the commit description and you=
r
> signed-off-by line? =A0The blub below makes sense in the context of t=
his
> mailing list thread, but it won't be very useful for someone looking
> at the commit message in git. =A0Also, your patch is line-wrap damage=
d
> (cut and paste into your mail client doesn't usually work) and has
> inconsistent whitespace (run it through scripts/checkpatch.pl).
>
> Jeff, after Henk provides his s-o-b line, do you want to pick it up,
> or should I merge it through my mpc52xx powerpc tree (via benh).
>
> Thanks,
> g.
>
> On Thu, Feb 19, 2009 at 3:45 AM, Henk Stegeman <henk.stegeman@gmail.c=
om> wrote:
>> I must have made a mistake when I tested the previous patch, I
>> discovered later it still had errors:
>> - I had accidentally removed the base address in the fec_mpc52xx dri=
ver.
>> - The priv->phydev pointer was sometimes not initialized (NULL) but
>> still passed by the fec_mpc52xx driver, this pointer is then used
>> unchecked by the eth_tool_* functions (used by bridging to determine
>> port priority). As far as I see this depends on whether
>> mpc52xx_fec_open (or mpc52xx_fec_close) is called which in turn call
>> mpc52xx_init_phy to initialize priv->phydev. My work around checks t=
he
>> priv->phydev pointer in the fec_mpc52xx driver and returns -ENODEV t=
o
>> indicate there's no physical device. Big chance this is not the righ=
t
>> way to handle the problem, but it works, hopefully someone with some
>> more fundamental Linux network driver experience can pick this up or
>> give me some hints on this.
>>
>> At least bridging now works on my board in combination with the
>> fec_mpc52xx driver.
>>
>> ifconfig eth0 0.0.0.0 down
>> ifconfig eth1 0.0.0.0 down
>> brctl addbr br0
>> brctl setfd br0 0
>> brctl stp br0 off
>> ifconfig br0 192.168.1.30 down
>> ifconfig br0 up
>> brctl addif br0 eth0
>> ifconfig eth0 up
>> brctl addif br0 eth1
>> ifconfig eth1 up
>>
>>
>> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
>> index cd8e98b..e228973 100644
>> --- a/drivers/net/fec_mpc52xx.c
>> +++ b/drivers/net/fec_mpc52xx.c
>> @@ -847,24 +847,40 @@ static void mpc52xx_fec_get_drvinfo(struct
>> net_device *dev,
>> =A0static int mpc52xx_fec_get_settings(struct net_device *dev, struc=
t
>> ethtool_cmd *cmd)
>> =A0{
>> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 =A0 if (!priv->phydev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> +
>> =A0 =A0 =A0 =A0return phy_ethtool_gset(priv->phydev, cmd);
>> =A0}
>>
>> =A0static int mpc52xx_fec_set_settings(struct net_device *dev, struc=
t
>> ethtool_cmd *cmd)
>> =A0{
>> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 =A0 if (!priv->phydev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> +
>> =A0 =A0 =A0 =A0return phy_ethtool_sset(priv->phydev, cmd);
>> =A0}
>>
>> =A0static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
>> =A0{
>> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 =A0 if (!priv->phydev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> =A0 =A0 =A0 =A0return priv->msg_enable;
>> =A0}
>>
>> =A0static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 =
level)
>> =A0{
>> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 =A0 if (!priv->phydev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> =A0 =A0 =A0 =A0priv->msg_enable =3D level;
>> =A0}
>>
>> @@ -882,12 +898,31 @@ static int mpc52xx_fec_ioctl(struct net_device
>> *dev, struct ifreq *rq, int cmd)
>> =A0{
>> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
>>
>> + =A0 =A0 =A0 if (!priv->phydev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> +
>> =A0 =A0 =A0 =A0return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cm=
d);
>> =A0}
>>
>> =A0/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D */
>> =A0/* OF Driver =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0*/
>> =A0/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D */
>> +static const struct net_device_ops mpc52xx_fec_netdev_ops =3D {
>> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_=
open,
>> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_=
close,
>> + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D mpc52xx_fec_hard_s=
tart_xmit,
>> + =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D mpc52xx_fec_tx_tim=
eout,
>> + =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_get_=
stats,
>> + =A0 =A0 =A0 .ndo_set_multicast_list =3D mpc52xx_fec_set_multicast_=
list,
>> + =A0 =A0 =A0 .ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
>> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D mpc52xx_fec_set_mac_ad=
dress,
>> + =A0 =A0 =A0 .ndo_do_ioctl =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_ioct=
l,
>> +
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> + =A0 =A0 =A0 .ndo_poll_controller =A0 =A0 =3D mpc52xx_fec_poll_cont=
roller,
>> +#endif
>> +};
>> +
>>
>> =A0static int __devinit
>> =A0mpc52xx_fec_probe(struct of_device *op, const struct of_device_id=
 *match)
>> @@ -929,20 +964,10 @@ mpc52xx_fec_probe(struct of_device *op, const
>> struct of_device_id *match)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
>>
>> =A0 =A0 =A0 =A0/* Init ether ndev with what we have */
>> - =A0 =A0 =A0 ndev->open =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_=
open;
>> - =A0 =A0 =A0 ndev->stop =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_=
close;
>> - =A0 =A0 =A0 ndev->hard_start_xmit =A0 =3D mpc52xx_fec_hard_start_x=
mit;
>> - =A0 =A0 =A0 ndev->do_ioctl =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_ioct=
l;
>> =A0 =A0 =A0 =A0ndev->ethtool_ops =A0 =A0 =A0 =3D &mpc52xx_fec_ethtoo=
l_ops;
>> - =A0 =A0 =A0 ndev->get_stats =A0 =A0 =A0 =A0 =3D mpc52xx_fec_get_st=
ats;
>> - =A0 =A0 =A0 ndev->set_mac_address =A0 =3D mpc52xx_fec_set_mac_addr=
ess;
>> - =A0 =A0 =A0 ndev->set_multicast_list =3D mpc52xx_fec_set_multicast=
_list;
>> - =A0 =A0 =A0 ndev->tx_timeout =A0 =A0 =A0 =A0=3D mpc52xx_fec_tx_tim=
eout;
>> =A0 =A0 =A0 =A0ndev->watchdog_timeo =A0 =A0=3D FEC_WATCHDOG_TIMEOUT;
>> =A0 =A0 =A0 =A0ndev->base_addr =A0 =A0 =A0 =A0 =3D mem.start;
>> -#ifdef CONFIG_NET_POLL_CONTROLLER
>> - =A0 =A0 =A0 ndev->poll_controller =3D mpc52xx_fec_poll_controller;
>> -#endif
>> + =A0 =A0 =A0 ndev->netdev_ops =3D &mpc52xx_fec_netdev_ops;
>>
>> =A0 =A0 =A0 =A0priv->t_irq =3D priv->r_irq =3D ndev->irq =3D NO_IRQ;=
 /* IRQ are free for now */
>>
>>
>>
>> On Wed, Feb 18, 2009 at 10:48 PM, David Miller <davem@davemloft.net>=
 wrote:
>>> From: Henk Stegeman <henk.stegeman@gmail.com>
>>> Date: Wed, 18 Feb 2009 11:41:14 +0100
>>>
>>> Please CC: netdev, now added, on all networking reports and patches=
=2E
>>>
>>> Thank you.
>>>
>>>> I discovered the hard way that because linux bridging uses
>>>> net_device_ops, bridging only works with network drivers that publ=
ish
>>>> their device operations trough net_device_ops.
>>>>
>>>> In my case running:
>>>>
>>>> brctl addif br0 eth0 (where eth0 fec_mpc52xx.c did not yet support
>>>> net_device_ops) gave me a:
>>>>
>>>> Unable to handle kernel paging request...
>>>>
>>>> After changing fec_mpc52xx.c to support net_device_ops the problem=
 was fixed.
>>>>
>>>> If possible some kind of detection in the bridging software is i t=
hink
>>>> mostly appreciated for early detection of this problem, as it is
>>>> pretty hard to relate the error message to a not updated driver.
>>>>
>>>> cheers,
>>>>
>>>> Henk
>>>>
>>>> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
>>>> index cd8e98b..a2841eb 100644
>>>> --- a/drivers/net/fec_mpc52xx.c
>>>> +++ b/drivers/net/fec_mpc52xx.c
>>>> @@ -888,6 +888,22 @@ static int mpc52xx_fec_ioctl(struct net_devic=
e
>>>> *dev, struct ifreq *rq, int cmd)
>>>> =A0/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D */
>>>> =A0/* OF Driver =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0*/
>>>> =A0/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D */
>>>> +static const struct net_device_ops mpc52xx_fec_netdev_ops =3D {
>>>> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fe=
c_open,
>>>> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fe=
c_close,
>>>> + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D mpc52xx_fec_hard=
_start_xmit,
>>>> + =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D mpc52xx_fec_tx_t=
imeout,
>>>> + =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_ge=
t_stats,
>>>> + =A0 =A0 =A0 .ndo_set_multicast_list =3D mpc52xx_fec_set_multicas=
t_list,
>>>> + =A0 =A0 =A0 .ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
>>>> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D mpc52xx_fec_set_mac_=
address,
>>>> + =A0 =A0 =A0 .ndo_do_ioctl =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_io=
ctl,
>>>> +
>>>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>>>> + =A0 =A0 =A0 .ndo_poll_controller =A0 =A0 =3D mpc52xx_fec_poll_co=
ntroller,
>>>> +#endif
>>>> +};
>>>> +
>>>>
>>>> =A0static int __devinit
>>>> =A0mpc52xx_fec_probe(struct of_device *op, const struct of_device_=
id *match)
>>>> @@ -929,20 +945,7 @@ mpc52xx_fec_probe(struct of_device *op, const
>>>> struct of_device_id *match)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>>>>
>>>> =A0 =A0 =A0 /* Init ether ndev with what we have */
>>>> - =A0 =A0 ndev->open =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_op=
en;
>>>> - =A0 =A0 ndev->stop =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_cl=
ose;
>>>> - =A0 =A0 ndev->hard_start_xmit =A0 =3D mpc52xx_fec_hard_start_xmi=
t;
>>>> - =A0 =A0 ndev->do_ioctl =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_ioctl;
>>>> - =A0 =A0 ndev->ethtool_ops =A0 =A0 =A0 =3D &mpc52xx_fec_ethtool_o=
ps;
>>>> - =A0 =A0 ndev->get_stats =A0 =A0 =A0 =A0 =3D mpc52xx_fec_get_stat=
s;
>>>> - =A0 =A0 ndev->set_mac_address =A0 =3D mpc52xx_fec_set_mac_addres=
s;
>>>> - =A0 =A0 ndev->set_multicast_list =3D mpc52xx_fec_set_multicast_l=
ist;
>>>> - =A0 =A0 ndev->tx_timeout =A0 =A0 =A0 =A0=3D mpc52xx_fec_tx_timeo=
ut;
>>>> - =A0 =A0 ndev->watchdog_timeo =A0 =A0=3D FEC_WATCHDOG_TIMEOUT;
>>>> - =A0 =A0 ndev->base_addr =A0 =A0 =A0 =A0 =3D mem.start;
>>>> -#ifdef CONFIG_NET_POLL_CONTROLLER
>>>> - =A0 =A0 ndev->poll_controller =3D mpc52xx_fec_poll_controller;
>>>> -#endif
>>>> + =A0 =A0 ndev->netdev_ops =3D &mpc52xx_fec_netdev_ops;
>>>>
>>>> =A0 =A0 =A0 priv->t_irq =3D priv->r_irq =3D ndev->irq =3D NO_IRQ; =
/* IRQ are free for now */
>>>> _______________________________________________
>>>> Linuxppc-dev mailing list
>>>> Linuxppc-dev@ozlabs.org
>>>> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>>>
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@ozlabs.org
>> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>>
>
>
>
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
