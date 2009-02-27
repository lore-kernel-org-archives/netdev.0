From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
Date: Fri, 27 Feb 2009 08:28:39 -0800
Message-ID: <16084.1235752119@death.nxdomain.ibm.com>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44689 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbZB0Q2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:28:55 -0500
In-reply-to: <49A7B17F.2020408@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh <jesper@krogh.cc> wrote:
[...]
>The offending commit seems to be:
>
>bonding: refactor mii monitor
>
>Refactor mii monitor.  As with the previous ARP monitor refactor,
>the motivation for this is to handle locking rationally (in this case,
>removing conditional locking) and generally clean up the code.
>
>This patch breaks up the monolithic mii monitor into two phases:
>an inspection phase, followed by an optional commit phase.  The commit phase
>is the only portion that requires RTNL or makes changes to state, and is
>only called when inspection finds something to change.
>
>Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>
>
>A test with a fresh 2.6.29-rc6 revealed that the problem has been fixed
>subsequently.. but still exists in 2.6.27-newest.  (havent tested
>2.6.28-newest yet).
>
>Any ideas of what the "fixing" commit is .. or should that also be
>bisected?

	I went back and looked at your earlier mail.  Since you're using
802.3ad mode, my first guess would be this commit:

commit fd989c83325cb34795bc4d4aa6b13c06f90eac99
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Tue Nov 4 17:51:16 2008 -0800

    bonding: alternate agg selection policies for 802.3ad
    
        This patch implements alternative aggregator selection policies
    for 802.3ad.  The existing policy, now termed "stable," selects the active
    aggregator by greatest bandwidth, and only reselects a new aggregator
    if the active aggregator is entirely disabled (no more ports or all ports
    down).
    
        This patch adds two new policies: bandwidth and count, selecting
    the active aggregator by total bandwidth (like the stable policy) or by
    the number of ports in the aggregator, respectively.  These two policies
    also differ from the stable policy in that they will reselect the active
    aggregator when availability-related changes occur in the bond (e.g.,
    link state change).
    
        This permits "gang failover" within 802.3ad, allowing redundant
    aggregators along parallel paths to always maintain the "best" aggregator
    as the active aggregator (rather than having to wait for the active to
    entirely fail).
    
        This patch also updates the driver version to 3.5.0.
    
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


	This changed or refactored a great deal of the aggregator
selection logic, and it might be that it also fixed your problem by mere
happenstance.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
