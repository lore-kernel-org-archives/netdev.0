From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
	present
Date: Tue, 15 Nov 2011 15:47:00 -0500
Message-ID: <20111115204659.GE25132@gospo.rdu.redhat.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com> <20111115193535.GC25132@gospo.rdu.redhat.com> <4EC2C550.6050805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab1KOUrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 15:47:05 -0500
Content-Disposition: inline
In-Reply-To: <4EC2C550.6050805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 09:02:24PM +0100, Nicolas de Peslo=FCan wrote:
> Le 15/11/2011 20:35, Andy Gospodarek a =E9crit :
>> On Tue, Nov 15, 2011 at 08:24:29PM +0100, Nicolas de Peslo=FCan wrot=
e:
>>> Le 15/11/2011 18:00, Andy Gospodarek a =E9crit :
>>>> On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
>>>>> When changing mode via bonding's sysfs, the slaves are not initia=
lized
>>>>> correctly. Forbid to change modes with slaves present to ensure t=
hat every
>>>>> slave is initialized correctly via bond_enslave().
>>>>>
>>>>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>>>>
>>>> Looks good.  This behavior forces someone who wants to change to m=
ode to
>>>> go through steps that are almost as destructive as when module opt=
ions
>>>> are used to configure the mode.  I do not see a problem with this.
>>>
>>> Except the fact that is enforce one more constraint on the exact or=
der
>>> one should write into sysfs to setup a bonding interface. We alread=
y have
>>> many such constraints and probably don't need more.
>>>
>>> Currently, it is possible to enslave slaves before selecting the mo=
de.
>>> The ifenslave-2.6 package from Debian currently enslave slaves befo=
re
>>> setting the mode and would break with this change.
>>>
>>
>> Our testing indicates that 802.3ad mode bonding will not work unless=
 the
>> devices are enslaved after the mode is set.  Does this mean that no =
one
>> using Debian is using 802.2ad mode or are they just not reporting it=
?
>
> I don't know. Possibly, they setup the bonding by hand, instead of=20
> relying on the bonding extensions of /etc/network/interfaces provided=
 by=20
> the ifenslave-2.6 package.
>
> Having a look at popularity for the package=20
> (http://qa.debian.org/popcon.php?package=3Difenslave-2.6), it is obvi=
ously=20
> not the most popular one, but...
>

Nicolas,

I took a look at the ifenslave package for debian more closely and it
actually looks like devices are enslaved last, after mode is set.  Can
you please take a look at this package and confirm what I'm seeing in
the 'pre-up' script.

It appears to me that setup_master sets the mode and enslave_slaves is
called after and enslaves the devices:

# Option slaves deprecated, replaced by bond-slaves, but still supporte=
d
# for backward compatibility.
IF_BOND_SLAVES=3D${IF_BOND_SLAVES:-$IF_SLAVES}

if [ "$IF_BOND_MASTER" ] ; then
        BOND_MASTER=3D"$IF_BOND_MASTER"
        BOND_SLAVES=3D"$IFACE"
else
        if [ "$IF_BOND_SLAVES" ] ; then
                BOND_MASTER=3D"$IFACE"
                BOND_SLAVES=3D"$IF_BOND_SLAVES"
        fi
fi

# Exit if nothing to do...
[ -z "$BOND_MASTER$BOND_SLAVES" ] && exit

add_master
early_setup_master
setup_master
enslave_slaves
exit 0

-andy
