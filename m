From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v2] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 2 Jul 2013 01:48:58 +0200
Message-ID: <51D2156A.3070403@xdin.com>
References: <51CB05BB.3030909@xdin.com> <20130628.211632.1064715548223073397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>, Arvid Brodin <Arvid.Brodin@xdin.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:59596 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754607Ab3GBAZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 20:25:10 -0400
In-Reply-To: <20130628.211632.1064715548223073397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-06-29 06:16, David Miller wrote:
> From: Arvid Brodin <arvid.brodin@xdin.com>
> Date: Wed, 26 Jun 2013 17:16:11 +0200
>
>> +static int hsr_dev_open(struct net_device *dev)
>> +{
>> +	struct hsr_priv *hsr_priv;
>> +
>> +	hsr_priv =3D netdev_priv(dev);
>> +
>> +	if (hsr_priv->slave[0])
>> +		dev_open(hsr_priv->slave[0]);
>> +	if (hsr_priv->slave[1])
>> +		dev_open(hsr_priv->slave[1]);
>> +
>> +	return 0;
>> +}
>
> dev_open() can and does fail, you must thus check for error returns, =
undo any
> necessary state, and propagate that error to callers of hsr_dev_open.
>

I'm not sure it's an error (from the HSR interface's point of view) if =
the slave(s)
won't come up here. The calls to dev_open() can be seen more like a con=
venience
than a necessity (I actually left them out to begin with). If none of t=
he slaves
could go up the HSR interface would end up as admin UP but with opersta=
te
IF_OPER_LOWERLAYERDOWN until any of the slaves went up.

I see that the VLAN code, in its vlan_dev_open(), checks the underlying=
 interface's
IFF_UP flag and returns -ENETDOWN if it's not set. That might be an opt=
ion here -
but then one would have to set three interfaces up to get a working HSR=
 interface,
which is a bit tedious... Also, the HSR interface could end up in the s=
tate above
anyway if both slaves went down after the HSR interface went up success=
fully.

What about checking the return values and printing a warning if a slave=
 dev_open()
fails, but still return success for the HSR interface no matter what?


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
