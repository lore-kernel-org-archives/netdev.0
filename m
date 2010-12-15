From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
Date: Wed, 15 Dec 2010 18:52:26 +0800
Message-ID: <4D089DEA.2060803@redhat.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208135746.GD11454@hmsreliant.think-freely.org> <4D008643.5040500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Neil Horman <nhorman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab0LOKwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 05:52:47 -0500
In-Reply-To: <4D008643.5040500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2010=E5=B9=B412=E6=9C=8809=E6=97=A5 15:33, Cong Wang =E5=86=99=
=E9=81=93:
> On 12/08/10 21:57, Neil Horman wrote:
>> On Wed, Dec 08, 2010 at 02:52:08AM -0500, Amerigo Wang wrote:
>>> -    bond_for_each_slave(bond, slave, i) {
>>> -        if ((slave->dev->priv_flags&  IFF_DISABLE_NETPOLL) ||
>>> -            !slave->dev->netdev_ops->ndo_poll_controller)
>>> -            ret =3D false;
>>> +    np =3D kmalloc(sizeof(*np), GFP_KERNEL);
>>> +    err =3D -ENOMEM;
>>> +    if (!np)
>>> +        goto out;
>>> +
>>> +    np->dev =3D slave->dev;
>>> +    err =3D __netpoll_setup(np);
>> Setting up our own netpoll instance on each slave worries me a bit. =
 The
>> implication here is that, by doing so, some frames will get entirely=
 processed
>> by the slave.  Most notably arp frames.  That means anything that ge=
ts queued up
>> to the arp_tx queue in __netpoll_rx will get processed during that p=
oll event,
>> and responded to with the mac of the slave device, rather than with =
the mac of
>> the bond device, which isn't always what you want.  I think if you g=
o with this
>> route, you'll need to add code to netpoll_poll_dev, right before the=
 call to
>> service_arp_queue, to check if IFF_SLAVE is set in priv_flags, and m=
ove the list
>> to the master device, or some such.
>
>
> Good point! Will fix i

Hi, Neil,

I think we should do that in bond_poll_controller() rather than netpoll=
_poll_dev(),
right? Since this is bond-specific. Does moving all arp_tx of slaves to=
 their bond
address your concern?

Thanks!
