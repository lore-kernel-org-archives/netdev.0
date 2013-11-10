From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/8] bonding: add downdelay netlink support
Date: Sat, 9 Nov 2013 21:28:38 -1000
Message-ID: <C73FAA61-4C63-41FC-9BBF-C8314B9DEDE4@cumulusnetworks.com>
References: <20131107094308.15846.58301.stgit@monster-03.cumulusnetworks.com> <3470.1383843910@death.nxdomain> <5C31F7A9-945E-4DA5-A2E2-92AE0A556970@cumulusnetworks.com> <14955.1383945357@death.nxdomain>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	netdev@vger.kernel.org,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47452 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab3KJH2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 02:28:40 -0500
In-Reply-To: <14955.1383945357@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 8, 2013, at 11:15 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:

> Scott Feldman <sfeldma@cumulusnetworks.com> wrote:
>=20
>> What I=92d like to propose, and I hope that you=92ll agree, is we ta=
ckle
>> this in two phases.  The first phase is to finish the current
>> duplication effort to enable netlink equivalents of the attributes i=
n
>> sysfs.  This is a fairly mechanical process, preserving existing
>> behavior as you point out, and keeps the patches single-minded and e=
asy
>> to review.
>>=20
>> The second phase is to revisit ordering constraints and find places
>> where we can remove constraints or streamline the dependency checks.
>>=20
>> Sound like a plan?
>=20
> 	Well, maybe.
>=20
> 	What I want to avoid for the iproute / netlink bonding support
> is all of the hoops that the initscripts / sysconfig scripts had to j=
ump
> through to obey the current sysfs ordering limtations.
>=20
> 	The primary user of this is going to be iproute.  Will the above
> quoted limitations (and their equivalents for various other options)
> make any difference with regards to the following:
>=20
> ip [...] bond arp_validate all arp_interval 1000
> ip [...] bond arp_interval 1000 arp_validate all
>=20
> 	I.e., does the ordering matter at the iproute level when
> multiple options are specified simultaneously?

Surprisingly, order doesn=92t matter.  Regardless of the ordering of at=
trs within the netlink msg, the processing order of attrs is always the=
 same.  In this case of bonding, it=92s bond_netlink.c:bond_changelink(=
) that dictates the order attrs are processed.  So in your examples abo=
ve, both versions would yield the same results.

> 	What happens if I do:
>=20
> ip [...] bond arp_interval 1000 arp_validate all miimon 100
>=20
> 	This is separate from simply changing one thing at a time, e.g.,
>=20
> ip [...] bond arp_validate all
> ip [...] bond arp_interval 1000

This is the problem to be solved.  Bonding has several mutually exclusi=
ve attrs.  When mutually exclusive options are presented at the same ti=
me (like in you first example above), we can pick a winner using the pr=
ocessing order in bond_changelink().  When single attrs are set (like i=
n second example), it=92s trickier to pick winner in bond_changelink(),=
 but do-able, I think.

> 	will presuambly hit the test above, and this is where the
> ordering stuff comes into play for sure.
>=20
> 	Also, as I look at the iproute patch, it doesn't appear to
> accept the text names for the options, only numeric values (e.g., "ip
> [...]  bond arp_validate 3").  That appears to be a limitation of Jir=
i's
> original iproute patch as well.  Am I the only person that perfers th=
e
> text labels (e.g., arp_validate as "all") to numbers (arp_validate as
> "3")?

I can add text names to the iproute patch for v2.

> 	So, honestly, I think if the ordering constraints are going to
> be relaxed, it should happen sooner rather than later.  Perhaps not i=
n
> the same patch as the netlink support, but ideally at least in the sa=
me
> series, so there is no real release with the constraints.  Changing t=
he
> constraints after the script, etc, conversion is done doesn't really
> help much.

Ok, let me study this some more before sending v2.

-scott