From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: Initialize ds->enabled_port_mask
 and ds->phys_mii_mask
Date: Sun, 5 Jun 2016 15:38:59 -0700
Message-ID: <5754AA03.7050208@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-7-git-send-email-f.fainelli@gmail.com>
 <20160604202959.GF2063@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33934 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932501AbcFEWjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 18:39:01 -0400
Received: by mail-oi0-f68.google.com with SMTP id r4so2400255oib.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 15:39:01 -0700 (PDT)
In-Reply-To: <20160604202959.GF2063@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/06/2016 13:29, Andrew Lunn a =C3=A9crit :
>> @@ -517,6 +541,15 @@ static int dsa_parse_ports_dn(struct device_nod=
e *ports, struct dsa_switch *ds)
>>  			return -EINVAL;
>> =20
>>  		ds->ports[reg].dn =3D port;
>> +
>> +		if (dsa_port_is_cpu(port))
>> +			ds->dst->cpu_port =3D reg;
>> +		else
>> +			/* Initialize enabled_port_mask now for drv->setup()
>> +			 * to have access to a correct value, just like what
>> +			 * net/dsa/dsa.c::dsa_switch_setup_one does.
>> +			 */
>> +			ds->enabled_port_mask |=3D 1 << reg;
>=20
> Hi Florian
>=20
> You need to be careful here. There can be multiple CPU ports, in
> different switches. We want dst->cpu_port to be deterministic,
> independent of the order switches are registered. Which is why i set
> it as part of dsa_cpu_parse(), which only happens when all the
> switches have registered, and we are parsing their device tree nodes
> in order. So we guarantee dst->cpu_port is the first CPU node.

Ah OK, I completely missed that part and just wanted to avoid walking
the ports children nodes more than twice.

We might be able to get away with just initializing
ds->enabled_port_mask here actually.

>=20
> You now set dst->cpu_port via dsa_parse_ports_dn(), so it is now non
> deterministic, it depends on the probe order of the switches.
>=20
> In the long run, i want to deprecate and then remove dst->cpu_port,
> but i'm not that far yet.
>=20
> Please rethink this part of the patch, keeping in mind you have
> multiple switches, with multiple CPU and DSA ports, all connected in
> some crazy fashion.
--=20
=46lorian
