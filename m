From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Mon, 7 Jun 2010 10:39:25 -0500
Message-ID: <AANLkTim4kXRAQDnnlW_IkEA5bASWEiqlcvyaWhouUGKC@mail.gmail.com>
References: <20100602.065017.139108801.davem@davemloft.net>
	<AANLkTinR9_VoWX8zZu93MeohHvCbCy_P5XWHH3rxlPuH@mail.gmail.com>
	<20100605140017.GA2750@riccoc20.at.omicron.at>
	<20100607.011835.55846752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53360 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107Ab0FGPj3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 11:39:29 -0400
Received: by wyi11 with SMTP id 11so2473497wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 08:39:28 -0700 (PDT)
In-Reply-To: <20100607.011835.55846752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 3:18 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Sat, 5 Jun 2010 16:00:17 +0200
>
>> On Wed, Jun 02, 2010 at 02:32:11PM -0500, Andy Fleming wrote:
>>> Yeah, I was clearly not thinking clearly. =A0dev_flags will be
>>> overwritten, and is not meant for this. =A0I believe, what we shoul=
d do
>>> is add a "port" field to the PHY device, and if PCR_FIBER_SELECT is
>>> set, then set the port field to PORT_FIBRE. =A0I'm not entirely cle=
ar on
>>> the semantics of that field in the ethtool cmd, but it seems like t=
he
>>> right idea.
>>
>> Here is another try. Is that more like it?
>
> I think this is overkill.

Well, I meant for it to be the same as the ethtool one, and not a flags=
 field.

>
> One, and only one, PHY driver wants to maintain a boolean state and
> we're adding a full 32-bit flags member to the generic PHY device
> struct to accomodate this?


To be fair, this is a generic problem, with a simple solution.  I was
suggesting that a tiny patch would pave the way for others to follow
suit.  Instead, now a tiny patch will do something strange and
incomprehensible, and then will be changed later when some arbitrary
threshold is reached of PHY drivers needing to know what type of port
they are hooked up to.


>
> Andy if you have ideas to use that state via ethtool or whatever in
> the future, you come back to us when the future arrives and you've
> implemented the code in the generic PHY lib code to do that stuff.

Is there some reason for resistance to taking small steps in the right
direction of an obviously good destination (recording the port type)?
At the very least, can I ask that instead of assigning phydev->priv to
the address of the probe function, that we do something like:

phydev->priv =3D (void *) PCR_FIBER_SELECT;

And then check to make sure it is that value?  It's still hacky
(IMHO), but at least it's self-documenting.


>
> As it stands right now, that code doesn't exist so accomodating it is
> just silly.
>
> I also think worrying about the phy_dev->priv pointer being misused i=
n
> the future inside of this driver is a completely bogus argument by an=
y
> measure.
>
> We have many cases all over the kernel tree, in drivers and elsewhere=
,
> where we encode integer states in what are normally pointer values
> when we need to maintain a small piece of state and don't need to do =
a
> full blown memory allocation to allocate a piece of extra memory to
> hold that state.


I would consider it a case of last resort, for when you need to avoid
a memory allocation for performance reasons, and you must use a
generic structure for a non-generic task.  This is something detected
in slow-path code, and is a generic task, so we're only hitting 1/3 of
those conditions.  I won't speculate as to how many of those other
cases in the tree I would find annoying.  ;)

Andy
