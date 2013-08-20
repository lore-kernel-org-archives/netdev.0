From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v2] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 20 Aug 2013 19:36:22 +0200
Message-ID: <5213A916.2020505@xdin.com>
References: <51CB05BB.3030909@xdin.com> <20130628.211632.1064715548223073397.davem@davemloft.net> <51D2156A.3070403@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:63535 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533Ab3HTRp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 13:45:26 -0400
In-Reply-To: <51D2156A.3070403@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-07-02 01:48, Arvid Brodin wrote:
> On 2013-06-29 06:16, David Miller wrote:
>> From: Arvid Brodin <arvid.brodin@xdin.com>
>> Date: Wed, 26 Jun 2013 17:16:11 +0200
>>
>>> +static int hsr_dev_open(struct net_device *dev)
>>> +{
>>> +    struct hsr_priv *hsr_priv;
>>> +
>>> +    hsr_priv =3D netdev_priv(dev);
>>> +
>>> +    if (hsr_priv->slave[0])
>>> +        dev_open(hsr_priv->slave[0]);
>>> +    if (hsr_priv->slave[1])
>>> +        dev_open(hsr_priv->slave[1]);
>>> +
>>> +    return 0;
>>> +}
>>
>> dev_open() can and does fail, you must thus check for error returns,=
 undo any
>> necessary state, and propagate that error to callers of hsr_dev_open=
=2E
>>
>
> I'm not sure it's an error (from the HSR interface's point of view) i=
f the slave(s)
> won't come up here. The calls to dev_open() can be seen more like a c=
onvenience
> than a necessity (I actually left them out to begin with). If none of=
 the slaves
> could go up the HSR interface would end up as admin UP but with opers=
tate
> IF_OPER_LOWERLAYERDOWN until any of the slaves went up.
[snip]


Stephen Hemminger explained to me (in private email) that many of the e=
rrors
from dev_open() aren't soft errors - i.e. they should be propagated bac=
k up
even if the HSR driver doesn't care (out of memory, and hardware dead b=
eing
examples).

But HSR is often used in safety critical systems, and it may be importa=
nt that
a hsr_dev->dev_open() does not fail just because one of the slave's cab=
le
happens to be unplugged (or cut) - redundancy being the whole point of =
HSR.

I think the only reasonable thing to do is not to call dev_open() at al=
l here,
and instead just inform the user if a slave is not already up. This way=
 user
space must explicitly set both slaves UP and thus must also decide how =
to treat
different kinds of "slave errors".

I will send a new patch with this change.


Thanks to Stephen for helping me with this!


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
