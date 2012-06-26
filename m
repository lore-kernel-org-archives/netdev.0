From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] net/sh-eth: Add support selecting MII function for
 SH7734 and R8A7740
Date: Tue, 26 Jun 2012 12:35:41 +0900
Message-ID: <4FE92E0D.8000800@renesas.com>
References: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <2360907.koU5zCUYMQ@flexo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:62147 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153Ab2FZD26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 23:28:58 -0400
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0M67004A9GA3HN80@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 26 Jun 2012 12:27:39 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0M67005P6G9ZCW10@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 26 Jun 2012 12:27:39 +0900 (JST)
In-reply-to: <2360907.koU5zCUYMQ@flexo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thank you for your review.

=46lorian Fainelli =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=
=E3=81=97=E3=81=9F:
> On Tuesday 12 June 2012 16:29:02 Nobuhiro Iwamatsu wrote:
>> Ethernet IP of SH7734 and R8A7740 has selecting MII register.
>> The user needs to change a value according to MII to be used.
>> This adds the function to change the value of this register.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>> ---
>>  V2: Fix the check by select_mii.
>>  drivers/net/ethernet/renesas/sh_eth.c |  106=20
> ++++++++++++++++++++-------------
>>  drivers/net/ethernet/renesas/sh_eth.h |    1 +
>>  2 files changed, 65 insertions(+), 42 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c=20
> b/drivers/net/ethernet/renesas/sh_eth.c
>> index be3c221..5358804 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -49,6 +49,33 @@
>>  		NETIF_MSG_RX_ERR| \
>>  		NETIF_MSG_TX_ERR)
>> =20
>> +#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYP=
E_SH7763)=20
> || \
>> +	defined(CONFIG_ARCH_R8A7740)
>> +static void sh_eth_select_mii(struct net_device *ndev)
>> +{
>> +	u32 value =3D 0x0;
>> +	struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> +
>> +	switch (mdp->phy_interface) {
>> +	case PHY_INTERFACE_MODE_GMII:
>> +		value =3D 0x2;
>> +		break;
>> +	case PHY_INTERFACE_MODE_MII:
>> +		value =3D 0x1;
>> +		break;
>> +	case PHY_INTERFACE_MODE_RMII:
>> +		value =3D 0x0;
>> +		break;
>> +	default:
>> +		pr_warn("PHY interface mode was not setup. Set to MII.\n");
>> +		value =3D 0x1;
>> +		break;
>> +	}
>> +
>> +	sh_eth_write(ndev, value, RMII_MII);
>> +}
>> +#endif
>> +
>>  /* There is CPU dependent code */
>>  #if defined(CONFIG_CPU_SUBTYPE_SH7724)
>>  #define SH_ETH_RESET_DEFAULT	1
>> @@ -283,6 +310,7 @@ static struct sh_eth_cpu_data=20
> *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
>>  #elif defined(CONFIG_CPU_SUBTYPE_SH7734) ||=20
> defined(CONFIG_CPU_SUBTYPE_SH7763)
>>  #define SH_ETH_HAS_TSU	1
>>  static void sh_eth_reset_hw_crc(struct net_device *ndev);
>> +
>>  static void sh_eth_chip_reset(struct net_device *ndev)
>>  {
>>  	struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> @@ -292,35 +320,6 @@ static void sh_eth_chip_reset(struct net_device=
 *ndev)
>>  	mdelay(1);
>>  }
>> =20
>> -static void sh_eth_reset(struct net_device *ndev)
>> -{
>> -	int cnt =3D 100;
>> -
>> -	sh_eth_write(ndev, EDSR_ENALL, EDSR);
>> -	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDM=
R);
>> -	while (cnt > 0) {
>> -		if (!(sh_eth_read(ndev, EDMR) & 0x3))
>> -			break;
>> -		mdelay(1);
>> -		cnt--;
>> -	}
>> -	if (cnt =3D=3D 0)
>> -		printk(KERN_ERR "Device reset fail\n");
>> -
>> -	/* Table Init */
>> -	sh_eth_write(ndev, 0x0, TDLAR);
>> -	sh_eth_write(ndev, 0x0, TDFAR);
>> -	sh_eth_write(ndev, 0x0, TDFXR);
>> -	sh_eth_write(ndev, 0x0, TDFFR);
>> -	sh_eth_write(ndev, 0x0, RDLAR);
>> -	sh_eth_write(ndev, 0x0, RDFAR);
>> -	sh_eth_write(ndev, 0x0, RDFXR);
>> -	sh_eth_write(ndev, 0x0, RDFFR);
>> -
>> -	/* Reset HW CRC register */
>> -	sh_eth_reset_hw_crc(ndev);
>> -}
>> -
>>  static void sh_eth_set_duplex(struct net_device *ndev)
>>  {
>>  	struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> @@ -377,9 +376,43 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_dat=
a =3D {
>>  	.tsu		=3D 1,
>>  #if defined(CONFIG_CPU_SUBTYPE_SH7734)
>>  	.hw_crc     =3D 1,
>> +	.select_mii =3D 1,
>>  #endif
>>  };
>> =20
>> +static void sh_eth_reset(struct net_device *ndev)
>> +{
>> +	int cnt =3D 100;
>> +
>> +	sh_eth_write(ndev, EDSR_ENALL, EDSR);
>> +	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDM=
R);
>> +	while (cnt > 0) {
>> +		if (!(sh_eth_read(ndev, EDMR) & 0x3))
>> +			break;
>> +		mdelay(1);
>> +		cnt--;
>> +	}
>> +	if (cnt =3D=3D 0)
>> +		printk(KERN_ERR "Device reset fail\n");
>=20
> It looks like this would need a subsequent fix. Failing to reset the =
adapter=20
> and just erroring out and not returning an error looks obviously wron=
g. Since=20
> sh_eth_reset() is called in sh_eth_dev_init() which does return an in=
t,=20
> propagate the error back to the caller.

Yes, you are right. I will fix your point and send a patch.

Best regards,
   Nobuhiro
