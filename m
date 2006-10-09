From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Mon, 09 Oct 2006 15:15:45 +0200
Message-ID: <452A4B81.4040302@voltaire.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com> <200610032310.k93NAGZt003069@death.nxdomain.ibm.com> <4523D254.9060006@voltaire.com> <200610041734.k94HYEZt013562@death.nxdomain.ibm.com> <45251D2E.7050006@voltaire.com> <200610051813.k95IDvZt031303@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:29196 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S932800AbWJINPu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 09:15:50 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200610051813.k95IDvZt031303@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	After some reflection, I suspect it wouldn't be all that awful.
> The main concern is going to be whether or not the existing ifenslave
> binaries supplied with distros will run with the new version of bonding.
> Since the new version of bonding that you're proposing is really just
> relaxing the rules (rather than imposing a different, incompatible set
> of rules), that's probably not a really big deal.  I don't think it
> would require a revision change to the bonding ifenslave API.

Indeed, makes sense, the modified bonding driver would work with old 
ifenslave binaries.

> 	Yes, the long term direction is to have the initscripts
> configure bonding via sysfs, either directly or via the step of
> converting ifenslave to a script that uses sysfs.  

> 	I personally find ifenslave to be more convenient to use than
> repeated "echo whatever > /sys/this/that/the/other", but there's no
> reason that ifenslave couldn't do the various echo things itself under
> the covers.  

> 	One drawback to sysfs is that there's no real-time error
> reporting; you have to look at dmesg to see if your request succeeded or
> not.  I'm not sure offhand if, e.g., adding a sysfs file to bonding for
> "last-request-status" is a kosher sysfs thing to do; if it is, then an
> ifenslave script could check such a thing to figure out error returns.

Can you check that with someone around?

> 
> 	It seems more logical to me to embed all of the bonding sysfs
> magic stuff into a separate script, but the maintainers of initscipts or
> sysconfig may see things differently.
> 
> 	The main advantage to either of these (initscripts/sysconfig
> and/or ifenslave converted to sysfs) is that it eliminates the need to
> load the bonding driver module multiple times to have more than one
> bonding device with differing module parameters (because the sysfs
> interface can create any number of bonding interfaces with arbitrary
> settings).
> 
>> I will look into the current methods used by sysconfig to configure
>> bonding and see if i can come up with sketch of how to do it with sysfs.
> 
> 	It's probably easier to first convert ifenslave to a sysfs-using
> script that the existing initscripts can use.  
> 
> 	This allows the changes to be published in stages, rather than
> requiring a single flag day changeover.  The first stage changes the
> bonding driver itself to permit enslavement with the master down
> (insuring that existing ifenslave binaries supplied with reasonably
> current distros continue to function).  Next, ifenslave is changed to
> use sysfs (simultaneously removing the adjustment of the master or
> slave's up/down state during enslavement).  The next stage either
> changes the initscripts/sysconfig to use sysfs directly or change its
> use of ifenslave to not do multiple loads of the bonding driver. 

This plan makes much sense! however, this way or another (ie whether 
sysconfig tools are modified to use sysfs or ifenslave becomes a script 
that uses sysfs) there should be a change to sysconfig tools 
(specifically /sbin/ifup) in the place where it first makes the bonding 
interface UP and only later enslave the slave devices (eg the quote 
below from /sbin/ifup of sysconfig-0.50.9-13.8 that comes with SLES10)
correct?

>                 # get up the bonding device before enslaving
> #               if ! is_iface_up $INTERFACE; then
>                         ip link set $INTERFACE up 2>&1
> #               fi
>                 # enslave available slave devices; if there is none -> hard break and log
>                 MESSAGE=`/sbin/ifenslave $BONDING_OPTIONS $INTERFACE $BSINTERFACES 2>&1`

So this becomes the forth step on the plan. And the most fragile aspect 
of the plan is the fact that ***two*** packages need to be changed as 
/sbin/ifenslave is not part of sysconfig but rather of (eg on SLES10)
iputils-ss021109-167.2

Or.

