From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/2] tg3: Add code to allow ethtool to enable/disable loopback.
Date: Thu, 28 Apr 2011 18:42:02 -0700
Message-ID: <BANLkTimA9YGFKjB0_UMsAJeSGEbKGoFJXQ@mail.gmail.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
	<1304033599-8395-2-git-send-email-maheshb@google.com>
	<1304033599-8395-3-git-send-email-maheshb@google.com>
	<20110429002855.GC19665@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Micha? Miros?aw" <mirq-linux@rere.qmqm.pl>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:34382 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1D2BmG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 21:42:06 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p3T1g3Ea014451
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 18:42:03 -0700
Received: from wyb34 (wyb34.prod.google.com [10.241.225.98])
	by hpaq14.eem.corp.google.com with ESMTP id p3T1g2jd019897
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 18:42:02 -0700
Received: by wyb34 with SMTP id 34so2851750wyb.29
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 18:42:02 -0700 (PDT)
In-Reply-To: <20110429002855.GC19665@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 5:28 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Thu, Apr 28, 2011 at 04:33:19PM -0700, Mahesh Bandewar wrote:
>> ---
>> =A0drivers/net/tg3.c | =A0 32 ++++++++++++++++++++++++++++++++
>> =A01 files changed, 32 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index fa57e3d..208884d 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -6319,6 +6319,33 @@ static u32 tg3_fix_features(struct net_device=
 *dev, u32 features)
>> =A0 =A0 =A0 return features;
>> =A0}
>>
>> +static int tg3_set_features(struct net_device *dev, u32 features)
>> +{
>> + =A0 =A0 struct tg3 *tp =3D netdev_priv(dev);
>> + =A0 =A0 u32 cur_mode =3D 0;
>> + =A0 =A0 int err =3D 0;
>> +
>> + =A0 =A0 spin_lock_bh(&tp->lock);
>> + =A0 =A0 cur_mode =3D tr32(MAC_MODE);
>> +
>> + =A0 =A0 if (features & NETIF_F_LOOPBACK) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Enable internal MAC loopback mode */
>> + =A0 =A0 =A0 =A0 =A0 =A0 tw32(MAC_MODE, cur_mode | MAC_MODE_PORT_IN=
T_LPBACK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_on(tp->dev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Internal MAC loopback mo=
de enabled.\n");
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Disable internal MAC loopback mode */
>> + =A0 =A0 =A0 =A0 =A0 =A0 tw32(MAC_MODE, cur_mode & ~MAC_MODE_PORT_I=
NT_LPBACK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Force link status check */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (netif_running(dev))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tg3_setup_phy(tp, 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Internal MAC loopback mo=
de disabled.\n");
>> + =A0 =A0 }
>
> I think we should be checking netif_running() before touching the
> hardware at all. =A0It might be in a low power state.
>
makes sense. I'll change that.

> Also, wouldn't it be better to verify this particular bit changed bef=
ore
> doing any of these operations?
>
Right! Since netdev infrastructure initiates ndo_set_features() only
when the feature-set is changed, and loopback is the only thing that
is set; I lazily ignored that. But in future additional features could
be set and it's not going to hurt checking before setting that bit.

>> + =A0 =A0 spin_unlock_bh(&tp->lock);
>> +
>> + =A0 =A0 return err;
>> +}
>> +
>> =A0static inline void tg3_set_mtu(struct net_device *dev, struct tg3=
 *tp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int new_m=
tu)
>> =A0{
>> @@ -15028,6 +15055,7 @@ static const struct net_device_ops tg3_netde=
v_ops =3D {
>> =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D tg3_tx_timeout,
>> =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D tg3_change_mtu,
>> =A0 =A0 =A0 .ndo_fix_features =A0 =A0 =A0 =3D tg3_fix_features,
>> + =A0 =A0 .ndo_set_features =A0 =A0 =A0 =3D tg3_set_features,
>> =A0#ifdef CONFIG_NET_POLL_CONTROLLER
>> =A0 =A0 =A0 .ndo_poll_controller =A0 =A0=3D tg3_poll_controller,
>> =A0#endif
>> @@ -15044,6 +15072,7 @@ static const struct net_device_ops tg3_netde=
v_ops_dma_bug =3D {
>> =A0 =A0 =A0 .ndo_do_ioctl =A0 =A0 =A0 =A0 =A0 =3D tg3_ioctl,
>> =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D tg3_tx_timeout,
>> =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D tg3_change_mtu,
>> + =A0 =A0 .ndo_set_features =A0 =A0 =A0 =3D tg3_set_features,
>> =A0#ifdef CONFIG_NET_POLL_CONTROLLER
>> =A0 =A0 =A0 .ndo_poll_controller =A0 =A0=3D tg3_poll_controller,
>> =A0#endif
>> @@ -15241,6 +15270,9 @@ static int __devinit tg3_init_one(struct pci=
_dev *pdev,
>> =A0 =A0 =A0 dev->features |=3D hw_features;
>> =A0 =A0 =A0 dev->vlan_features |=3D hw_features;
>>
>> + =A0 =A0 /* Add the loopback capability */
>> + =A0 =A0 dev->hw_features |=3D NETIF_F_LOOPBACK;
>
> Not all tg3 devices can do MAC loopback. =A0I'd suggest qualifying th=
is
> with:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (GET_ASIC_REV(tp->pci_chip_rev_id) =
=3D=3D ASIC_REV_5780 ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(tp->tg3_flags & TG3_FLAG_CPMU=
_PRESENT))
>
> But that will exclude a lot of our newer devices. =A0Does it matter w=
hat
> type of loopback is used? =A0Newer devices prefer internal phy loopba=
ck
> over MAC loopback.
>
As long as device supports some sort of loopback, we should be setting
this capability and move this logic (or similar) to set_features() and
choose the method that is supported. Since several devices support
loopback at various levels, to keep it consistent, we should be
setting the loopback closest to the host. So can I simply set the
int-phy loopback in the else part of the above 'provided if' or would
need other logic? or in other words -

 if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5780 ||
(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
    supported_mode =3D MAC;
else
    supported_mode =3D INTPHY;

if (supported_mode =3D=3D MAC)
    cur_mode =3D tr32(MAC_MODE);
else
    tg3_readphy(tp, MII_BMCR, &cur_mode);

Would something like this work?

Thanks,
--mahesh..

>> =A0 =A0 =A0 if (tp->pci_chip_rev_id =3D=3D CHIPREV_ID_5705_A1 &&
>> =A0 =A0 =A0 =A0 =A0 !tg3_flag(tp, TSO_CAPABLE) &&
>> =A0 =A0 =A0 =A0 =A0 !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIG=
H)) {
>> --
>> 1.7.3.1
>>
>>
>
>
