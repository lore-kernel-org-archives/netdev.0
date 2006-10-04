From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Wed, 04 Oct 2006 10:34:14 -0700
Message-ID: <200610041734.k94HYEZt013562@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com> <200610032310.k93NAGZt003069@death.nxdomain.ibm.com> <4523D254.9060006@voltaire.com>
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:22956 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S964918AbWJDReQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 13:34:16 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k94HYGR2023622
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 13:34:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k94HYFkH482036
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 11:34:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k94HYFc4027483
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 11:34:15 -0600
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <4523D254.9060006@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:
[...]
>Looking on the sysconfig package, some tools eg /sbin/if{up,down,status}
>use ifenslave which is in turn provided by the iputils package.
>
>My understanding is that changing ifenslave and the bonding kernel code to
>allow for enslaving while master is not up is enough, so actually no
>change is needed to the sysconfig tools, correct?

	Incorrect.  The /sbin/ifup included with sysconfig (I'm looking
at version 0.31-0-15.51) has logic to set the bonding master device up
prior to adding any slaves.  E.g.,

		# get up the bonding device before enslaving
#		if ! is_iface_up $INTERFACE; then
			ip link set $INTERFACE up 2>&1
#		fi
		# enslave available slave devices; if there is none -> hard break and log
		MESSAGE=`/sbin/ifenslave $BONDING_OPTIONS $INTERFACE $BSINTERFACES 2>&1`

	For your purposes, this would cause it to register as an
ethernet hardware type, not an IB type.  The /sbin/ifup included with
initscripts operates a little differently, but also sets the bonding
master up prior to adding any slaves.

>I have now removed the two assertions in the bonding code on enslaving
>while master is not up and manage to work fine with IPoIB slave devices
>and ***without*** the two module params!
>
>When you have the most troublesome to deploy, the troubles you refer to is
>make sure that the distros would include ***both*** the bonding kernel
>changes and use an iputils package which has the ifenslave changes?

	Yes.  Part of the difficulty is that the changes to the
initscripts and sysconfig packages won't be compatible with versions of
bonding prior to the bonding kernel changes (because older versions of
bonding will refuse to add slaves if the master is down).  It might
require adding another API version to bonding, and modifying ifenslave
to work both ways (i.e., with the current "enslave with master up" API,
as well as the new "enslave with master down" API).

>> 	Yes, ifenslave is still supported.  It probably will be
>> obsoleted some day (or replaced with a script that uses sysfs), but not
>> anytime soon.  As far as I know, all current distros use ifenslave to
>> configure bonding.
>
>Cool, thanks for bringing this into my attention... I understand now my
>patch set should also handle the ifenslave.c source that comes with the
>kernel (eg to allow for not setting the hw address etc)

	An alternate approach would be to undertake the more substantial
task of converting the initscripts and sysconfig code to use sysfs to
configure bonding.  This would permit changing the logic (to add slaves
while the bonding master is down, then set it up), as well as remove the
current hacks (present only in sysconfig) to load the bonding module
once per configured bonding interface.  The initscripts currently don't
do this (as far as I know), so it's generally only possible to have one
bonding interface under initscripts control.

	In this case, ifenslave would continue to work as it does now,
and would simply not be supported for the new hardware.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
