From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) - Problem with ARP monitoring in active backup mode
Date: Fri, 25 Feb 2011 11:02:30 -0800
Message-ID: <17444.1298660550@death>
References: <bug-29712-10286@https.bugzilla.kernel.org/> <20110224145129.f366b59e.akpm@linux-foundation.org> <4D672525.5080609@hp.com> <19879D0AB3081A4B883186484ECC6FC05E780ADF@MPBAGVEX02.corp.mphasis.com> <E351E450E8B9F54684A699D42DC5ADF20C6F1D4A@MPBAGVEX02.corp.mphasis.com>
Cc: "Brian Haley" <brian.haley@hp.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Harsha R02" <Harsha.R02@mphasis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59912 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932658Ab1BYTCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:02:36 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1PIvP6S015404
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:57:25 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p1PJ2XF7104694
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 12:02:33 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1PJ2WKj031086
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 12:02:33 -0700
In-reply-to: <E351E450E8B9F54684A699D42DC5ADF20C6F1D4A@MPBAGVEX02.corp.mphasis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harsha R02 <Harsha.R02@mphasis.com> wrote:

>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 40fb5ee..0413917 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3020,11 +3020,16 @@ static void bond_ab_arp_probe(struct bonding *bond)
>                       bond->curr_active_slave->dev->name);
>        if (bond->curr_active_slave) {
>+                if((bond->curr_active_slave != bond->primary_slave) &&
>+                   (IS_UP(bond->primary_slave->dev)))
>+                        goto failover;
>+
>                bond_arp_send_all(bond, bond->curr_active_slave);
>                read_unlock(&bond->curr_slave_lock);
>                return;
>        }
>+failover:
>        read_unlock(&bond->curr_slave_lock);
>        /* if we don't have a curr_active_slave, search for the next available

	I'm not sure this is the proper place to put the "failover:"
label, as it will go through the "search for any peer" logic that's
normally used when there are no available slaves.  That will likely take
longer than simply switching to the primary.

	It should be possible to simply call bond_change_active_slave
with the appropriate arguments; did you try this?

	-J


>-------------------------------------------------------------------------------
>From: Harsha R02
>Sent: Fri 2/25/2011 6:14 PM
>To: Brian Haley; Andrew Morton
>Cc: bugzilla-daemon@bugzilla.kernel.org; bugme-daemon@bugzilla.kernel.org;
>netdev@vger.kernel.org; Jay Vosburgh
>Subject: RE: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) -
>Problem with ARP monitoring in active backup mode
>
>Attached patch resolves the issue. Failover happened back to primary when it
>was up again in both the point to point and switch configuration.
>
>Please let us know if this change can be included.
>
>Thanks,
>
>- Harsha
>
>-----Original Message-----
>From: Brian Haley [mailto:brian.haley@hp.com]
>Sent: Friday, February 25, 2011 9:12 AM
>To: Andrew Morton
>Cc: Harsha R02; bugzilla-daemon@bugzilla.kernel.org;
>bugme-daemon@bugzilla.kernel.org; netdev@vger.kernel.org; Jay Vosburgh
>Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) -
>Problem with ARP monitoring in active backup mode
>
>On 02/24/2011 05:51 PM, Andrew Morton wrote:
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Wed, 23 Feb 2011 10:41:34 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=29712
>>>
>>>            Summary: Bonding Driver(version : 3.5.0) - Problem with ARP
>>>                     monitoring in active backup mode
>>>            Product: Drivers
>>>            Version: 2.5
>>>     Kernel Version: 2.6.32
>>
>> That's a paleolithic kernel you have there.  This problem might have
>> been fixed already.  Can you test a more recent kernel?
>
>I can add some more info since I originally looked at the problem.  This
>happens on 2.6.38 as well, and on this 2.6.32 kernel with a backported
>3.7.0 bonding driver (with the primary_reselect option).  Harsha has a
>prototype patch that's being tested, but wanted to log the bug to see
>if one of the bonding maintainers had a better solution.
>
>I'll let him respond as I'm now out of the loop...
>
>Thanks,
>
>-Brian

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
