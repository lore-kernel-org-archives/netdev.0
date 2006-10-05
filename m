From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Thu, 05 Oct 2006 11:13:57 -0700
Message-ID: <200610051813.k95IDvZt031303@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com> <200610032310.k93NAGZt003069@death.nxdomain.ibm.com> <4523D254.9060006@voltaire.com> <200610041734.k94HYEZt013562@death.nxdomain.ibm.com> <45251D2E.7050006@voltaire.com>
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42435 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750727AbWJESOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 14:14:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k95IE2X4018776
	for <netdev@vger.kernel.org>; Thu, 5 Oct 2006 14:14:02 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k95IE2Yw288778
	for <netdev@vger.kernel.org>; Thu, 5 Oct 2006 14:14:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k95IE2mO031581
	for <netdev@vger.kernel.org>; Thu, 5 Oct 2006 14:14:02 -0400
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <45251D2E.7050006@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Jay Vosburgh wrote:
[...]
>> 	Yes.  Part of the difficulty is that the changes to the
>> initscripts and sysconfig packages won't be compatible with versions of
>> bonding prior to the bonding kernel changes (because older versions of
>> bonding will refuse to add slaves if the master is down).  It might
>> require adding another API version to bonding, and modifying ifenslave
>> to work both ways (i.e., with the current "enslave with master up" API,
>> as well as the new "enslave with master down" API).
>
>Gee, sounds bad

	After some reflection, I suspect it wouldn't be all that awful.
The main concern is going to be whether or not the existing ifenslave
binaries supplied with distros will run with the new version of bonding.
Since the new version of bonding that you're proposing is really just
relaxing the rules (rather than imposing a different, incompatible set
of rules), that's probably not a really big deal.  I don't think it
would require a revision change to the bonding ifenslave API.

[...]
>So the direction to have sysconfig and initscripts tools configure bonding
>by sysfs and not by the enslave program is something you were considering
>regardless of the needs imposed by bonding support for non ARPHRD_ETHER
>netdevices? and you think the distro packages owners would like this?

	Yes, the long term direction is to have the initscripts
configure bonding via sysfs, either directly or via the step of
converting ifenslave to a script that uses sysfs.  

	I personally find ifenslave to be more convenient to use than
repeated "echo whatever > /sys/this/that/the/other", but there's no
reason that ifenslave couldn't do the various echo things itself under
the covers.  

	One drawback to sysfs is that there's no real-time error
reporting; you have to look at dmesg to see if your request succeeded or
not.  I'm not sure offhand if, e.g., adding a sysfs file to bonding for
"last-request-status" is a kosher sysfs thing to do; if it is, then an
ifenslave script could check such a thing to figure out error returns.

	It seems more logical to me to embed all of the bonding sysfs
magic stuff into a separate script, but the maintainers of initscipts or
sysconfig may see things differently.

	The main advantage to either of these (initscripts/sysconfig
and/or ifenslave converted to sysfs) is that it eliminates the need to
load the bonding driver module multiple times to have more than one
bonding device with differing module parameters (because the sysfs
interface can create any number of bonding interfaces with arbitrary
settings).

>I will look into the current methods used by sysconfig to configure
>bonding and see if i can come up with sketch of how to do it with sysfs.

	It's probably easier to first convert ifenslave to a sysfs-using
script that the existing initscripts can use.  

	This allows the changes to be published in stages, rather than
requiring a single flag day changeover.  The first stage changes the
bonding driver itself to permit enslavement with the master down
(insuring that existing ifenslave binaries supplied with reasonably
current distros continue to function).  Next, ifenslave is changed to
use sysfs (simultaneously removing the adjustment of the master or
slave's up/down state during enslavement).  The next stage either
changes the initscripts/sysconfig to use sysfs directly or change its
use of ifenslave to not do multiple loads of the bonding driver. 

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
