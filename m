From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: ixgbe question
Date: Thu, 26 Nov 2009 17:10:19 +0300
Message-ID: <4B0E8C4B.50905@bigtelecom.ru>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>	 <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>	 <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>	 <4B0A9E4E.9010804@gmail.com> <19210.54486.353397.804028@gargle.gargle.HOWL>	 <4B0ABF6D.9000103@gmail.com>	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>	 <4B0B8F52.3010005@gmail.com> <1259053673.2631.30.camel@ppwaskie-mobl2> <4B0BADA6.7080602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:60555 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbZKZOKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 09:10:15 -0500
In-Reply-To: <4B0BADA6.7080602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Peter P Waskiewicz Jr a =C3=A9crit :
>=20
>> You might have this elsewhere, but it sounds like you're connecting =
back
>> to back with another 82599 NIC.  Our optics in that NIC are dual-rat=
e,
>> and the software mechanism that tries to "autoneg" link speed gets o=
ut
>> of sync easily in back-to-back setups.
>>
>> If it's really annoying, and you're willing to run with a local patc=
h to
>> disable the autotry mechanism, try this:
>>
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c
>> b/drivers/net/ixgbe/ixgbe_main.c
>> index a5036f7..62c0915 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -4670,6 +4670,10 @@ static void ixgbe_multispeed_fiber_task(struc=
t
>> work_struct *work)
>>         autoneg =3D hw->phy.autoneg_advertised;
>>         if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
>>                 hw->mac.ops.get_link_capabilities(hw, &autoneg,
>> &negotiation);
>> +
>> +       /* force 10G only */
>> +       autoneg =3D IXGBE_LINK_SPEED_10GB_FULL;
>> +
>>         if (hw->mac.ops.setup_link)
>>                 hw->mac.ops.setup_link(hw, autoneg, negotiation, tru=
e);
>>         adapter->flags |=3D IXGBE_FLAG_NEED_LINK_UPDATE;
>=20
> Thanks ! This did the trick :)
>=20
> If I am not mistaken, number of TX queues should be capped by number =
of possible cpus ?
>=20
> Its currently a fixed 128 value, allocating 128*128 =3D 16384 bytes,
> and polluting "tc -s -d class show dev fiber0" output.
>=20
> [PATCH net-next-2.6] ixgbe: Do not allocate too many netdev txqueues
>=20
> Instead of allocating 128 struct netdev_queue per device, use the min=
imum
> value between 128 and number of possible cpus, to reduce ram usage an=
d
> "tc -s -d class show dev ..." output
>=20
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index ebcec30..ec2508d 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5582,7 +5583,10 @@ static int __devinit ixgbe_probe(struct pci_de=
v *pdev,
>  	pci_set_master(pdev);
>  	pci_save_state(pdev);
> =20
> -	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_Q=
UEUES);
> +	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter),
> +				   min_t(unsigned int,
> +					 MAX_TX_QUEUES,
> +					 num_possible_cpus()));
>  	if (!netdev) {
>  		err =3D -ENOMEM;
>  		goto err_alloc_etherdev;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

This also fix log time loading TC rules for me

Tested-by: Badalian Vyacheslav <slavon.net@gmail.com>
