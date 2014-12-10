From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: Re: [PATCH 1/1] net: dsa: Fix of kernel panic in case of missing
 PHY.
Date: Wed, 10 Dec 2014 11:06:45 +0100
Message-ID: <54881B35.3020706@nexvision.fr>
References: <54873205.30401@nexvision.fr> <5487BCBA.2060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Brian Norris <computersforpeace@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 6.mo3.mail-out.ovh.net ([188.165.43.173]:38576 "EHLO
	mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755993AbaLJNqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 08:46:08 -0500
Received: from mail436.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo3.mail-out.ovh.net (Postfix) with SMTP id 9E213FFA598
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 11:06:51 +0100 (CET)
In-Reply-To: <5487BCBA.2060403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 10/12/2014 04:23, Florian Fainelli wrote :
> On 09/12/14 09:31, Andrey Volkov wrote:
>> Fix of kernel panic in case of missing PHY.
>>
>> Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
>=20
> Brian has actually been able to reproduce such a crash in this code-p=
ath
> today:
>=20
> if (!p->phy) {
>                 p->phy =3D ds->slave_mii_bus->phy_map[p->port];
>                 phy_connect_direct(slave_dev, p->phy,
> 				   dsa_slave_adjust_link,
>                                    p->phy_interface);
> }
>=20
> we basically assume here that we have a valid phy pointer out of
> ds->slave_mii_bus->phy_map[p->port] which is not true in all cases,
> especially not if the device is not there.
Yes it's  what really happened in my case: some PHYs were not soldered=20
(development version of the board). But in real life, they may be misse=
d for various
reasons, so that the assumption was wrong.

>=20
> I will come up with a fix for that, as for propagating the error code
> down to the caller, this can be a separate patch.
Ok, I'll wait for it

>=20
> Thanks!
=C2=B2You are welcome!

>=20
>> ---
>>  net/dsa/slave.c |   19 +++++++++++++++----
>>  1 file changed, 15 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>> index 528380a..6f89caa 100644
>> --- a/net/dsa/slave.c
>> +++ b/net/dsa/slave.c
>> @@ -512,7 +512,7 @@ static int dsa_slave_fixed_link_update(struct ne=
t_device *dev,
>>  }
>> =20
>>  /* slave device setup *********************************************=
**********/
>> -static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>> +static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>>  				struct net_device *slave_dev)
>>  {
>>  	struct dsa_switch *ds =3D p->parent;
>> @@ -533,7 +533,7 @@ static void dsa_slave_phy_setup(struct dsa_slave=
_priv *p,
>>  		ret =3D of_phy_register_fixed_link(port_dn);
>>  		if (ret) {
>>  			netdev_err(slave_dev, "failed to register fixed PHY\n");
>> -			return;
>> +			return ret;
>>  		}
>>  		phy_is_fixed =3D true;
>>  		phy_dn =3D port_dn;
>> @@ -555,12 +555,17 @@ static void dsa_slave_phy_setup(struct dsa_sla=
ve_priv *p,
>>  	 */
>>  	if (!p->phy) {
>>  		p->phy =3D ds->slave_mii_bus->phy_map[p->port];
>> -		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
>> +		if(p->phy)
>> +			phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
>>  				   p->phy_interface);
>> +		else
>> +			return -ENODEV;
>> +
>>  	} else {
>>  		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
>>  			    p->phy->addr, p->phy->drv->name);
>>  	}
>> +	return 0;
>>  }
>> =20
>>  int dsa_slave_suspend(struct net_device *slave_dev)
>> @@ -653,7 +658,13 @@ dsa_slave_create(struct dsa_switch *ds, struct =
device *parent,
>>  	p->old_link =3D -1;
>>  	p->old_duplex =3D -1;
>> =20
>> -	dsa_slave_phy_setup(p, slave_dev);
>> +	ret =3D dsa_slave_phy_setup(p, slave_dev);
>> +	if (ret) {
>> +		netdev_err(master, "error %d registering interface %s\n",
>> +			   ret, slave_dev->name);
>> +		free_netdev(slave_dev);
>> +		return NULL;
>> +	}
>> =20
>>  	ret =3D register_netdev(slave_dev);
>>  	if (ret) {
>>
>=20
>=20
