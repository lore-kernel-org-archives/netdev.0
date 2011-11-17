From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Wed, 16 Nov 2011 23:16:30 -0200
Message-ID: <20111116231630.214a0cd0@asterix.rh>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
	<20111115170018.GB25132@gospo.rdu.redhat.com>
	<4EC2BC6D.9000304@gmail.com>
	<20111115193535.GC25132@gospo.rdu.redhat.com>
	<4EC2C550.6050805@gmail.com>
	<20111115204659.GE25132@gospo.rdu.redhat.com>
	<4EC3A64D.40405@gmail.com>
	<20111116220200.GF25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, debian-kernel@lists.debian.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754945Ab1KQBRr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:17:47 -0500
In-Reply-To: <20111116220200.GF25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011 17:02:00 -0500
Andy Gospodarek <andy@greyhouse.net> wrote:

> On Wed, Nov 16, 2011 at 01:02:21PM +0100, Nicolas de Peslo=C3=BCan wr=
ote:
> > Le 15/11/2011 21:47, Andy Gospodarek a =C3=A9crit :
> >> Nicolas,
> >>
> >> I took a look at the ifenslave package for debian more closely and
> >> it actually looks like devices are enslaved last, after mode is
> >> set.  Can you please take a look at this package and confirm what
> >> I'm seeing in the 'pre-up' script.
> >>
> >> It appears to me that setup_master sets the mode and
> >> enslave_slaves is called after and enslaves the devices:
> >>
> >> # Option slaves deprecated, replaced by bond-slaves, but still
> >> supported # for backward compatibility.
> >> IF_BOND_SLAVES=3D${IF_BOND_SLAVES:-$IF_SLAVES}
> >>
> >> if [ "$IF_BOND_MASTER" ] ; then
> >>          BOND_MASTER=3D"$IF_BOND_MASTER"
> >>          BOND_SLAVES=3D"$IFACE"
> >> else
> >>          if [ "$IF_BOND_SLAVES" ] ; then
> >>                  BOND_MASTER=3D"$IFACE"
> >>                  BOND_SLAVES=3D"$IF_BOND_SLAVES"
> >>          fi
> >> fi
> >>
> >> # Exit if nothing to do...
> >> [ -z "$BOND_MASTER$BOND_SLAVES" ]&&  exit
> >>
> >> add_master
> >> early_setup_master
> >> setup_master
> >> enslave_slaves
> >> exit 0
> >
> > Andy,
> >
> > I'm really surprise by this extract. In the most up to date version
> > of the ifenslave-2.6 package (1.1.0-19), the order is:
> >
> > add_master
> > early_setup_master
> > enslave_slaves
> > setup_master
> >
> > early_setup_master was created to be able to do things that
> > absolutely need to be done before enslavement. (See the comment
> > just before this function). The idea was to do every possible setup
> > in setup_master, after enslavement, except those that need to be
> > done in early_setup_master. So having enslave_slaves after
> > setup_master instead of before is definitely a mistake. Some of the
> > operations in setup_master must be done after enslavement, in
> > particular selecting the primary slave.
> >
> > In version 1.1.0-18 (change log below), I checked all the possible
> > order constraints of the sysfs interface and totally reworked most
> > of the setup code, putting everything in the right order to achieve
> > consistent results.
> >
> > 	ifenslave-2.6 (1.1.0-18) experimental; urgency=3Dlow
> >
> > 	  * Apply patch from Nicolas de Peslo=C3=BCan:
> >
> > 	    - Major change: Check and fix the order in which the
> > configuration is written into /sys files, to ensure reliable
> > results, according to the tests done in the kernel (in
> > drivers/net/bonding/bond_sysfs.c).
> > 	    - Ensure that master is properly brought down when
> > changing a parameter that require it to be down.
> > 	    - Ensure the master is brought up at the end of the
> > setup, in the case where ifup won't bring it up because it is
> > currently configuring a slave.
> > 	    - Add support for some previously unsupported /sys
> > files: ad_select, num_grat_arp, num_unsol_na, primary_reselect and
> > queue_id.
> > 	    - Enhance the documentation (README.Debian), to
> > describe all the currently supported bond-* options.
> > 	    - Many other changes in the documentation.
> > 	    - Reverse the order of the arguments to most sysfs_*
> > internal functions, for better readability.
> >
> > It was a hard work, because there really exist many such
> > constraints. I fail to find enough time to insert the result of
> > this work into Documentation/networking/bonding.txt, but still plan
> > to do so, even if the result is documented in the script you looked
> > at.
> >
> > Of course, it is possible to change the scripts in ifenslave-2.6
> > package to arrange for one more constraint. For as far as I
> > understand, this would cause the Debian kernel that introduce the
> > change we discuss about and all the future Debian kernels to be
> > flagged with 'Breaks: ifenslave-2.6 (<< 1.1.0-20)'. I'm not really
> > comfortable with this and the Debian kernel team need to be
> > involved. I copied them.
> >
> > All that being said, I really advocate for less constraints on the
> > sysfs setup. This is not strictly related to sysfs setup. If we
> > eventually add a NETLINK interface for all the things we can setup
> > using sysfs, we will face the exact same problem.
>=20
>=20
> I was looking at ifenslave 1.1.0-20.  If you look at Debian bug
> #641250 you will see a very similar report to what prompted Veaceslav
> to come up with this patch and post it here.
>=20
> ifenslave-2.6 (1.1.0-20) unstable; urgency=3Dlow
>=20
>   * Use dashes consistently for bonding options in README.Debian.
>     Closes: #639244
>   * Enslave slaves only after fully setting up the master. Closes:
> #641250
>=20
[...]

> > I perfectly understand, as Veaceslav noted in another email that
> > there are a lot of mode-specific initialization stuff that's
> > present only in bond_enslave(), but I think this is what needs to
> > be fixed... Those initialization stuff should be moved out of
> > bond_enslave() and called at appropriate sime, from bond_enslave()
> > and from other locations, in particular when changing mode.
>=20
> I think Veaceslav is working on this, but there is significant
> re-organization that is needed to make it work properly and make sure
> it is tested.  I could be wrong about how long it will take him, but
> to test it properly it will take some time.

Indeed.

> Since this problem seems like a pretty major problem and now Debian,
> Fedora, RHEL, and Ubuntu all seem to have proper initialization
> scripts to handle it, I stand behind my original ACK.

I agree. I think allowing to change the mode after enslavement can
cause unpredictable issues and the follow-up patch will need some
careful work and testing, so you have my ACK here as well.

fbl
