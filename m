From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/2] tg3: Add code to allow ethtool to enable/disable loopback.
Date: Fri, 29 Apr 2011 10:45:38 -0700
Message-ID: <BANLkTikFC_Eg1PCDJiuHFsbtjmPUHRfXsA@mail.gmail.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
	<1304033599-8395-2-git-send-email-maheshb@google.com>
	<1304033599-8395-3-git-send-email-maheshb@google.com>
	<20110429002855.GC19665@mcarlson.broadcom.com>
	<BANLkTimA9YGFKjB0_UMsAJeSGEbKGoFJXQ@mail.gmail.com>
	<20110429024652.GB20805@mcarlson.broadcom.com>
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
Received: from smtp-out.google.com ([216.239.44.51]:27603 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760660Ab1D2Rpl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:45:41 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p3THje69022872
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:45:40 -0700
Received: from bwz8 (bwz8.prod.google.com [10.188.26.8])
	by kpbe16.cbf.corp.google.com with ESMTP id p3THjV6Q022685
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:45:39 -0700
Received: by bwz8 with SMTP id 8so49099bwz.35
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:45:39 -0700 (PDT)
In-Reply-To: <20110429024652.GB20805@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 7:46 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Thu, Apr 28, 2011 at 06:42:02PM -0700, Mahesh Bandewar wrote:
>> >> + ? ? spin_unlock_bh(&tp->lock);
>> >> +
>> >> + ? ? return err;
>> >> +}
>> >> +
>> >> ?static inline void tg3_set_mtu(struct net_device *dev, struct tg=
3 *tp,
>> >> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?int new_mtu)
>> >> ?{
>> >> @@ -15028,6 +15055,7 @@ static const struct net_device_ops tg3_ne=
tdev_ops =3D {
>> >> ? ? ? .ndo_tx_timeout ? ? ? ? =3D tg3_tx_timeout,
>> >> ? ? ? .ndo_change_mtu ? ? ? ? =3D tg3_change_mtu,
>> >> ? ? ? .ndo_fix_features ? ? ? =3D tg3_fix_features,
>> >> + ? ? .ndo_set_features ? ? ? =3D tg3_set_features,
>> >> ?#ifdef CONFIG_NET_POLL_CONTROLLER
>> >> ? ? ? .ndo_poll_controller ? ?=3D tg3_poll_controller,
>> >> ?#endif
>> >> @@ -15044,6 +15072,7 @@ static const struct net_device_ops tg3_ne=
tdev_ops_dma_bug =3D {
>> >> ? ? ? .ndo_do_ioctl ? ? ? ? ? =3D tg3_ioctl,
>> >> ? ? ? .ndo_tx_timeout ? ? ? ? =3D tg3_tx_timeout,
>> >> ? ? ? .ndo_change_mtu ? ? ? ? =3D tg3_change_mtu,
>> >> + ? ? .ndo_set_features ? ? ? =3D tg3_set_features,
>> >> ?#ifdef CONFIG_NET_POLL_CONTROLLER
>> >> ? ? ? .ndo_poll_controller ? ?=3D tg3_poll_controller,
>> >> ?#endif
>> >> @@ -15241,6 +15270,9 @@ static int __devinit tg3_init_one(struct =
pci_dev *pdev,
>> >> ? ? ? dev->features |=3D hw_features;
>> >> ? ? ? dev->vlan_features |=3D hw_features;
>> >>
>> >> + ? ? /* Add the loopback capability */
>> >> + ? ? dev->hw_features |=3D NETIF_F_LOOPBACK;
>> >
>> > Not all tg3 devices can do MAC loopback. ?I'd suggest qualifying t=
his
>> > with:
>> >
>> > ? ? ? ? ? ? ? ?if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_R=
EV_5780 ||
>> > ? ? ? ? ? ? ? ? ? ?(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
>> >
>> > But that will exclude a lot of our newer devices. ?Does it matter =
what
>> > type of loopback is used? ?Newer devices prefer internal phy loopb=
ack
>> > over MAC loopback.
>> >
>> As long as device supports some sort of loopback, we should be setti=
ng
>> this capability and move this logic (or similar) to set_features() a=
nd
>> choose the method that is supported. Since several devices support
>> loopback at various levels, to keep it consistent, we should be
>> setting the loopback closest to the host. So can I simply set the
>> int-phy loopback in the else part of the above 'provided if' or woul=
d
>> need other logic? or in other words -
>>
>> =A0if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5780 ||
>> (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
>> =A0 =A0 supported_mode =3D MAC;
>> else
>> =A0 =A0 supported_mode =3D INTPHY;
>>
>> if (supported_mode =3D=3D MAC)
>> =A0 =A0 cur_mode =3D tr32(MAC_MODE);
>> else
>> =A0 =A0 tg3_readphy(tp, MII_BMCR, &cur_mode);
>>
>> Would something like this work?
>
> That might be where we want to end up, but it'll be some work to get
> there. =A0Maybe it makes sense to just keep MAC loopback mode for now=
 and
> only enable it for a subset of devices. =A0Adding phy loopback mode s=
ounds
> like it will require some surgery.
>
Thanks for your comments Matt, I'll post the updated patch soon.

--mahesh..
>
