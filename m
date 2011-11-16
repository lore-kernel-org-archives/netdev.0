From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
	present
Date: Wed, 16 Nov 2011 17:02:00 -0500
Message-ID: <20111116220200.GF25132@gospo.rdu.redhat.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com> <20111115193535.GC25132@gospo.rdu.redhat.com> <4EC2C550.6050805@gmail.com> <20111115204659.GE25132@gospo.rdu.redhat.com> <4EC3A64D.40405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, debian-kernel@lists.debian.org
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab1KPWDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 17:03:03 -0500
Content-Disposition: inline
In-Reply-To: <4EC3A64D.40405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 01:02:21PM +0100, Nicolas de Peslo=FCan wrote:
> Le 15/11/2011 21:47, Andy Gospodarek a =E9crit :
>> Nicolas,
>>
>> I took a look at the ifenslave package for debian more closely and i=
t
>> actually looks like devices are enslaved last, after mode is set.  C=
an
>> you please take a look at this package and confirm what I'm seeing i=
n
>> the 'pre-up' script.
>>
>> It appears to me that setup_master sets the mode and enslave_slaves =
is
>> called after and enslaves the devices:
>>
>> # Option slaves deprecated, replaced by bond-slaves, but still suppo=
rted
>> # for backward compatibility.
>> IF_BOND_SLAVES=3D${IF_BOND_SLAVES:-$IF_SLAVES}
>>
>> if [ "$IF_BOND_MASTER" ] ; then
>>          BOND_MASTER=3D"$IF_BOND_MASTER"
>>          BOND_SLAVES=3D"$IFACE"
>> else
>>          if [ "$IF_BOND_SLAVES" ] ; then
>>                  BOND_MASTER=3D"$IFACE"
>>                  BOND_SLAVES=3D"$IF_BOND_SLAVES"
>>          fi
>> fi
>>
>> # Exit if nothing to do...
>> [ -z "$BOND_MASTER$BOND_SLAVES" ]&&  exit
>>
>> add_master
>> early_setup_master
>> setup_master
>> enslave_slaves
>> exit 0
>
> Andy,
>
> I'm really surprise by this extract. In the most up to date version o=
f=20
> the ifenslave-2.6 package (1.1.0-19), the order is:
>
> add_master
> early_setup_master
> enslave_slaves
> setup_master
>
> early_setup_master was created to be able to do things that absolutel=
y=20
> need to be done before enslavement. (See the comment just before this=
=20
> function). The idea was to do every possible setup in setup_master, a=
fter=20
> enslavement, except those that need to be done in early_setup_master.=
 So=20
> having enslave_slaves after setup_master instead of before is definit=
ely=20
> a mistake. Some of the operations in setup_master must be done after=20
> enslavement, in particular selecting the primary slave.
>
> In version 1.1.0-18 (change log below), I checked all the possible or=
der=20
> constraints of the sysfs interface and totally reworked most of the s=
etup=20
> code, putting everything in the right order to achieve consistent=20
> results.
>
> 	ifenslave-2.6 (1.1.0-18) experimental; urgency=3Dlow
>
> 	  * Apply patch from Nicolas de Peslo=FCan:
>
> 	    - Major change: Check and fix the order in which the configurati=
on is
> 	      written into /sys files, to ensure reliable results, according=
 to the
> 	      tests done in the kernel (in drivers/net/bonding/bond_sysfs.c)=
=2E
> 	    - Ensure that master is properly brought down when changing a pa=
rameter
> 	      that require it to be down.
> 	    - Ensure the master is brought up at the end of the setup, in th=
e case
> 	      where ifup won't bring it up because it is currently configuri=
ng a slave.
> 	    - Add support for some previously unsupported /sys files: ad_sel=
ect,
> 	      num_grat_arp, num_unsol_na, primary_reselect and queue_id.
> 	    - Enhance the documentation (README.Debian), to describe all the=
 currently
> 	      supported bond-* options.
> 	    - Many other changes in the documentation.
> 	    - Reverse the order of the arguments to most sysfs_* internal fu=
nctions, for
> 	      better readability.
>
> It was a hard work, because there really exist many such constraints.=
 I=20
> fail to find enough time to insert the result of this work into=20
> Documentation/networking/bonding.txt, but still plan to do so, even i=
f=20
> the result is documented in the script you looked at.
>
> Of course, it is possible to change the scripts in ifenslave-2.6 pack=
age=20
> to arrange for one more constraint. For as far as I understand, this=20
> would cause the Debian kernel that introduce the change we discuss ab=
out=20
> and all the future Debian kernels to be flagged with 'Breaks:=20
> ifenslave-2.6 (<< 1.1.0-20)'. I'm not really comfortable with this an=
d=20
> the Debian kernel team need to be involved. I copied them.
>
> All that being said, I really advocate for less constraints on the sy=
sfs=20
> setup. This is not strictly related to sysfs setup. If we eventually =
add=20
> a NETLINK interface for all the things we can setup using sysfs, we w=
ill=20
> face the exact same problem.


I was looking at ifenslave 1.1.0-20.  If you look at Debian bug #641250
you will see a very similar report to what prompted Veaceslav to come u=
p
with this patch and post it here.

ifenslave-2.6 (1.1.0-20) unstable; urgency=3Dlow

  * Use dashes consistently for bonding options in README.Debian.
    Closes: #639244
  * Enslave slaves only after fully setting up the master. Closes: #641=
250
  * Add build-arch and build-indep targets to debian/rules.

 -- Guus Sliepen <guus@debian.org>  Mon, 14 Nov 2011 11:36:21 +0100

ifenslave-2.6 (1.1.0-19) unstable; urgency=3Dlow

  * Don't bother trying to move configuration files anymore. This is no=
t an
    issue anymore in for the next stable release, and it was broken any=
way.
    Closes: #626959
  * Bump Standards-Version.

 -- Guus Sliepen <guus@debian.org>  Wed, 25 May 2011 18:42:32 +0200

ifenslave-2.6 (1.1.0-18) experimental; urgency=3Dlow

  * Apply patch from Nicolas de Peslo=FCan:

    - Major change: Check and fix the order in which the configuration =
is
      written into /sys files, to ensure reliable results, according to=
 the
      tests done in the kernel (in drivers/net/bonding/bond_sysfs.c).
    - Ensure that master is properly brought down when changing a param=
eter
      that require it to be down.
    - Ensure the master is brought up at the end of the setup, in the c=
ase
      where ifup won't bring it up because it is currently configuring =
a slave.
    - Add support for some previously unsupported /sys files: ad_select=
,
      num_grat_arp, num_unsol_na, primary_reselect and queue_id.
    - Enhance the documentation (README.Debian), to describe all the cu=
rrently
      supported bond-* options.
    - Many other changes in the documentation.
    - Reverse the order of the arguments to most sysfs_* internal funct=
ions, for
      better readability.

  * Upload to experimental due to the freeze.

 -- Guus Sliepen <guus@debian.org>  Tue, 21 Dec 2010 12:46:04 +0100

> I perfectly understand, as Veaceslav noted in another email that ther=
e=20
> are a lot of mode-specific initialization stuff that's present only i=
n=20
> bond_enslave(), but I think this is what needs to be fixed... Those=20
> initialization stuff should be moved out of bond_enslave() and called=
 at=20
> appropriate sime, from bond_enslave() and from other locations, in=20
> particular when changing mode.
>

I think Veaceslav is working on this, but there is significant
re-organization that is needed to make it work properly and make sure i=
t
is tested.  I could be wrong about how long it will take him, but to
test it properly it will take some time.

Since this problem seems like a pretty major problem and now Debian,
=46edora, RHEL, and Ubuntu all seem to have proper initialization scrip=
ts
to handle it, I stand behind my original ACK.
