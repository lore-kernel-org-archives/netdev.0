From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Wed, 16 Nov 2011 13:02:21 +0100
Message-ID: <4EC3A64D.40405@gmail.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com> <20111115193535.GC25132@gospo.rdu.redhat.com> <4EC2C550.6050805@gmail.com> <20111115204659.GE25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, debian-kernel@lists.debian.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756388Ab1KPMCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 07:02:22 -0500
Received: by wwe5 with SMTP id 5so589620wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 04:02:21 -0800 (PST)
In-Reply-To: <20111115204659.GE25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/11/2011 21:47, Andy Gospodarek a =E9crit :
> Nicolas,
>
> I took a look at the ifenslave package for debian more closely and it
> actually looks like devices are enslaved last, after mode is set.  Ca=
n
> you please take a look at this package and confirm what I'm seeing in
> the 'pre-up' script.
>
> It appears to me that setup_master sets the mode and enslave_slaves i=
s
> called after and enslaves the devices:
>
> # Option slaves deprecated, replaced by bond-slaves, but still suppor=
ted
> # for backward compatibility.
> IF_BOND_SLAVES=3D${IF_BOND_SLAVES:-$IF_SLAVES}
>
> if [ "$IF_BOND_MASTER" ] ; then
>          BOND_MASTER=3D"$IF_BOND_MASTER"
>          BOND_SLAVES=3D"$IFACE"
> else
>          if [ "$IF_BOND_SLAVES" ] ; then
>                  BOND_MASTER=3D"$IFACE"
>                  BOND_SLAVES=3D"$IF_BOND_SLAVES"
>          fi
> fi
>
> # Exit if nothing to do...
> [ -z "$BOND_MASTER$BOND_SLAVES" ]&&  exit
>
> add_master
> early_setup_master
> setup_master
> enslave_slaves
> exit 0

Andy,

I'm really surprise by this extract. In the most up to date version of =
the ifenslave-2.6 package=20
(1.1.0-19), the order is:

add_master
early_setup_master
enslave_slaves
setup_master

early_setup_master was created to be able to do things that absolutely =
need to be done before=20
enslavement. (See the comment just before this function). The idea was =
to do every possible setup in=20
setup_master, after enslavement, except those that need to be done in e=
arly_setup_master. So having=20
enslave_slaves after setup_master instead of before is definitely a mis=
take. Some of the operations=20
in setup_master must be done after enslavement, in particular selecting=
 the primary slave.

In version 1.1.0-18 (change log below), I checked all the possible orde=
r constraints of the sysfs=20
interface and totally reworked most of the setup code, putting everythi=
ng in the right order to=20
achieve consistent results.

	ifenslave-2.6 (1.1.0-18) experimental; urgency=3Dlow

	  * Apply patch from Nicolas de Peslo=FCan:

	    - Major change: Check and fix the order in which the configuration=
 is
	      written into /sys files, to ensure reliable results, according t=
o the
	      tests done in the kernel (in drivers/net/bonding/bond_sysfs.c).
	    - Ensure that master is properly brought down when changing a para=
meter
	      that require it to be down.
	    - Ensure the master is brought up at the end of the setup, in the =
case
	      where ifup won't bring it up because it is currently configuring=
 a slave.
	    - Add support for some previously unsupported /sys files: ad_selec=
t,
	      num_grat_arp, num_unsol_na, primary_reselect and queue_id.
	    - Enhance the documentation (README.Debian), to describe all the c=
urrently
	      supported bond-* options.
	    - Many other changes in the documentation.
	    - Reverse the order of the arguments to most sysfs_* internal func=
tions, for
	      better readability.

It was a hard work, because there really exist many such constraints. I=
 fail to find enough time to=20
insert the result of this work into Documentation/networking/bonding.tx=
t, but still plan to do so,=20
even if the result is documented in the script you looked at.

Of course, it is possible to change the scripts in ifenslave-2.6 packag=
e to arrange for one more=20
constraint. For as far as I understand, this would cause the Debian ker=
nel that introduce the change=20
we discuss about and all the future Debian kernels to be flagged with '=
Breaks: ifenslave-2.6 (<<=20
1.1.0-20)'. I'm not really comfortable with this and the Debian kernel =
team need to be involved. I=20
copied them.

All that being said, I really advocate for less constraints on the sysf=
s setup. This is not strictly=20
related to sysfs setup. If we eventually add a NETLINK interface for al=
l the things we can setup=20
using sysfs, we will face the exact same problem.

I perfectly understand, as Veaceslav noted in another email that there =
are a lot of mode-specific=20
initialization stuff that's present only in bond_enslave(), but I think=
 this is what needs to be=20
fixed... Those initialization stuff should be moved out of bond_enslave=
() and called at appropriate=20
sime, from bond_enslave() and from other locations, in particular when =
changing mode.

	Nicolas.
