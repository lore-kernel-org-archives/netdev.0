From: "Harsha R02" <Harsha.R02@mphasis.com>
Subject: RE: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) - Problem with ARP monitoring in active backup mode
Date: Thu, 3 Mar 2011 12:01:12 +0530
Message-ID: <E351E450E8B9F54684A699D42DC5ADF2103267E5@MPBAGVEX02.corp.mphasis.com>
References: <bug-29712-10286@https.bugzilla.kernel.org/> <20110224145129.f366b59e.akpm@linux-foundation.org> <4D672525.5080609@hp.com> <19879D0AB3081A4B883186484ECC6FC05E780ADF@MPBAGVEX02.corp.mphasis.com> <E351E450E8B9F54684A699D42DC5ADF20C6F1D4A@MPBAGVEX02.corp.mphasis.com> <17444.1298660550@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brian Haley" <brian.haley@hp.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>, <netdev@vger.kernel.org>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mpbam6ip2.mphasis.com ([203.12.223.66]:10789 "EHLO
	mpbam6ip2.mphasis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab1CCGcG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:32:06 -0500
Content-class: urn:content-classes:message
In-Reply-To: <17444.1298660550@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

We found that the patch that is presented here has some issues and we
cannot go with this solution.

In function "bond_ab_arp_probe" in addition to sending arp probes for
the currently active slave we should also 
be sending arp probes for the primary_slave if the link status of the
primary slave is up correct ?

I have made changes as below :

static void bond_ab_arp_probe(struct bonding *bond)
{
        struct slave *slave;
        int i;

        read_lock(&bond->curr_slave_lock);

        if (bond->current_arp_slave && bond->curr_active_slave)
                pr_info(DRV_NAME "PROBE: c_arp %s && cas %s BAD\n",
                       bond->current_arp_slave->dev->name,
                       bond->curr_active_slave->dev->name);

        if (bond->curr_active_slave) {
+                if((bond->curr_active_slave != bond->primary_slave) &&
+                   (IS_UP(bond->primary_slave->dev))) {
+                    bond_arp_send_all(bond, bond->primary_slave);
+                }
                bond_arp_send_all(bond, bond->curr_active_slave);
                read_unlock(&bond->curr_slave_lock);
                return;
        }


Please let us know if this can help us ? or if you see any side effects
?

Thanks,
Harsha


-----Original Message-----
From: Jay Vosburgh [mailto:fubar@us.ibm.com] 
Sent: Saturday, February 26, 2011 12:33 AM
To: Harsha R02
Cc: Brian Haley; Andrew Morton; bugzilla-daemon@bugzilla.kernel.org;
bugme-daemon@bugzilla.kernel.org; netdev@vger.kernel.org
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version :
3.5.0) - Problem with ARP monitoring in active backup mode

Harsha R02 <Harsha.R02@mphasis.com> wrote:

>diff --git a/drivers/net/bonding/bond_main.c
b/drivers/net/bonding/bond_main.c
>index 40fb5ee..0413917 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3020,11 +3020,16 @@ static void bond_ab_arp_probe(struct bonding
*bond)
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
>        /* if we don't have a curr_active_slave, search for the next
available

	I'm not sure this is the proper place to put the "failover:"
label, as it will go through the "search for any peer" logic that's
normally used when there are no available slaves.  That will likely take
longer than simply switching to the primary.

	It should be possible to simply call bond_change_active_slave
with the appropriate arguments; did you try this?

	-J


>-----------------------------------------------------------------------
--------
>From: Harsha R02
>Sent: Fri 2/25/2011 6:14 PM
>To: Brian Haley; Andrew Morton
>Cc: bugzilla-daemon@bugzilla.kernel.org;
bugme-daemon@bugzilla.kernel.org;
>netdev@vger.kernel.org; Jay Vosburgh
>Subject: RE: [Bugme-new] [Bug 29712] New: Bonding Driver(version :
3.5.0) -
>Problem with ARP monitoring in active backup mode
>
>Attached patch resolves the issue. Failover happened back to primary
when it
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
>Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version :
3.5.0) -
>Problem with ARP monitoring in active backup mode
>
>On 02/24/2011 05:51 PM, Andrew Morton wrote:
>> (switched to email.  Please respond via emailed reply-to-all, not via
the
>> bugzilla web interface).
>>
>> On Wed, 23 Feb 2011 10:41:34 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=29712
>>>
>>>            Summary: Bonding Driver(version : 3.5.0) - Problem with
ARP
>>>                     monitoring in active backup mode
>>>            Product: Drivers
>>>            Version: 2.5
>>>     Kernel Version: 2.6.32
>>
>> That's a paleolithic kernel you have there.  This problem might have
>> been fixed already.  Can you test a more recent kernel?
>
>I can add some more info since I originally looked at the problem.
This
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

Information transmitted by this e-mail is proprietary to MphasiS, its associated companies and/ or its customers and is intended 
for use only by the individual or entity to which it is addressed, and may contain information that is privileged, confidential or 
exempt from disclosure under applicable law. If you are not the intended recipient or it appears that this mail has been forwarded 
to you without proper authority, you are notified that any use or dissemination of this information in any manner is strictly 
prohibited. In such cases, please notify us immediately at mailmaster@mphasis.com and delete this mail from your records.

