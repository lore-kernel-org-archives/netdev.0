From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 3/8] bonding: add downdelay netlink support
Date: Fri, 08 Nov 2013 13:15:57 -0800
Message-ID: <14955.1383945357@death.nxdomain>
References: <20131107094308.15846.58301.stgit@monster-03.cumulusnetworks.com> <3470.1383843910@death.nxdomain> <5C31F7A9-945E-4DA5-A2E2-92AE0A556970@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	netdev@vger.kernel.org,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:52527 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757460Ab3KHVQF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 16:16:05 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 8 Nov 2013 14:16:05 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DF8B119D8036
	for <netdev@vger.kernel.org>; Fri,  8 Nov 2013 14:15:57 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA8LG1fB245592
	for <netdev@vger.kernel.org>; Fri, 8 Nov 2013 14:16:01 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rA8LG0Tx017947
	for <netdev@vger.kernel.org>; Fri, 8 Nov 2013 14:16:01 -0700
In-reply-to: <5C31F7A9-945E-4DA5-A2E2-92AE0A556970@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman <sfeldma@cumulusnetworks.com> wrote:

>
>On Nov 7, 2013, at 7:05 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>> Scott Feldman <sfeldma@cumulusnetworks.com> wrote:
>>=20
>>> +int bond_option_downdelay_set(struct bonding *bond, int downdelay)
>>> +{
>>> +	if (!(bond->params.miimon)) {
>>> +		pr_err("%s: Unable to set down delay as MII monitoring is disabl=
ed\n", bond->dev->name);
>>> +		return -EPERM;
>>> +	}
>>=20
>> 	I would argue that it is better to permit this option to be set
>> at any time, regardless of whether miimon is enabled or not.  This
>> removes an ordering constraint and makes things generally easier to =
deal
>> with.  Setting the option has no effect if miimon is not set, but th=
at's
>> ok.
>>=20
>> 	My comment here would also apply to other options that are
>> "secondary," in the sense that they affect the behavior of other opt=
ions
>> or modes, e.g., updelay, arp_validate (in another path of this serie=
s),
>> arp_ip_targets, etc.
>>=20
>> 	I'm aware that this is simply duplicating the existing behavior
>> of the sysfs API, but I'd be in favor of changing that, too.  These
>> limitations are a holdover from the module paramters days, and shoul=
d
>> have been made more flexible a long time ago.
>
>What I=E2=80=99d like to propose, and I hope that you=E2=80=99ll agree=
, is we tackle
>this in two phases.  The first phase is to finish the current
>duplication effort to enable netlink equivalents of the attributes in
>sysfs.  This is a fairly mechanical process, preserving existing
>behavior as you point out, and keeps the patches single-minded and eas=
y
>to review.
>
>The second phase is to revisit ordering constraints and find places
>where we can remove constraints or streamline the dependency checks.
>
>Sound like a plan?

	Well, maybe.

	What I want to avoid for the iproute / netlink bonding support
is all of the hoops that the initscripts / sysconfig scripts had to jum=
p
through to obey the current sysfs ordering limtations.

	The primary user of this is going to be iproute.  Will the above
quoted limitations (and their equivalents for various other options)
make any difference with regards to the following:

ip [...] bond arp_validate all arp_interval 1000
ip [...] bond arp_interval 1000 arp_validate all

	I.e., does the ordering matter at the iproute level when
multiple options are specified simultaneously?

	What happens if I do:

ip [...] bond arp_interval 1000 arp_validate all miimon 100

	This is separate from simply changing one thing at a time, e.g.,

ip [...] bond arp_validate all
ip [...] bond arp_interval 1000

	will presuambly hit the test above, and this is where the
ordering stuff comes into play for sure.

	Also, as I look at the iproute patch, it doesn't appear to
accept the text names for the options, only numeric values (e.g., "ip
[...]  bond arp_validate 3").  That appears to be a limitation of Jiri'=
s
original iproute patch as well.  Am I the only person that perfers the
text labels (e.g., arp_validate as "all") to numbers (arp_validate as
"3")?

	That number-only limitation also may make life for initscripts /
sysconfig more difficult, or at least the upgrade path more of a hassle=
,
since currently the ifcfg-bond* files can have the bonding options
specified as text labels in addition to the numeric values.

	So, honestly, I think if the ordering constraints are going to
be relaxed, it should happen sooner rather than later.  Perhaps not in
the same patch as the netlink support, but ideally at least in the same
series, so there is no real release with the constraints.  Changing the
constraints after the script, etc, conversion is done doesn't really
help much.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
