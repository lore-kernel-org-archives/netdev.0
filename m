From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark in bonding structure as no ARP sent.
Date: Thu, 21 Nov 2013 13:12:59 -0800
Message-ID: <17860.1385068379@death.nxdomain>
References: <528D5980.3040309@oracle.com> <20131121111022.GA30998@redhat.com> <528E6E40.6020201@oracle.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:44114 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab3KUVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 16:13:04 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 21 Nov 2013 14:13:04 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CF35A3E4003F
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 14:13:02 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rALJBFqF42336450
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 20:11:15 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rALLD2X1011723
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 14:13:02 -0700
In-reply-to: <528E6E40.6020201@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:

>On 11/21/2013 3:10 AM, Veaceslav Falico wrote:
>> On Wed, Nov 20, 2013 at 04:53:20PM -0800, rama nichanamatlu wrote:
>>> During the creation of VLAN's atop bonding the underlying interfaces
>>> are made part of VLAN's, and at the same bonding driver gets aware
>>> that VLAN's exists above it and hence would consult IP routing for
>>> every ARP to  be sent to determine the route which tells bonding
>>> driver the correct VLAN tag to attach to the outgoing ARP packet. But,
>>> during the VLAN creation when vlan driver puts the underlying
>>> interface into default vlan and then actual vlan, in-between this if
>>> bonding driver consults the IP for a route, IP fails to provide a
>>> correct route and upon which bonding driver drops the ARP packet. ARP
>>> monitor when it
>>> comes around next time, sees no ARP response and fails-over to the
>>> next available slave. Consulting for a IP route,
>>> ip_route_output(),happens in bond_arp_send_all().
>> 
>> bonding works as expected - nothing to fix here. And even as a
>> workaround/hack - I'm not sure we need that to suppress one failover *only*
>> when vlan is added on top.
>> 
>>>
>Thank U.
>With *out* this change our systems failed system testing, to
>consistently be on designated primary interface on *every* single
>reboot. With this change the behavior was as expected even after a few
>thousand reboots & System testing could move to next level catching an
>another bug in sr-iov :). And Without, the outcome was less predictable
>after a reboot and bonding was on a different slave each time.
>-Rama

	By "designated primary" you mean the bonding primary option,
correct?  If not, does setting primary resolve the problem?  If so,
you're saying that during the bringup, bonding would end up with a
non-primary slave as the active slave?  Or that there would be a
failover / failback cycle during the bringup due to the lack of VLAN
availability?

	There is already a mechanism in bond_ab_arp_inspect() to give
new slaves a grace period before applying link failures:

                /*
                 * Give slaves 2*delta after being enslaved or made
                 * active.  This avoids bouncing, as the last receive
                 * times need a full ARP monitor cycle to be updated.
                 */
                if (bond_time_in_interval(bond, slave->jiffies, 2))
                        continue;

	If you extend that grace period (the "2", which is in units of
the arp_interval), does the problem resolve itself, or is the time
window here longer than that?

	How is the configuration of bonding and the VLANs taking place?

	I don't think this patch is suitable (because it can mask
legitimate failures), but I'm not entirely sure I understand the details
of the problem.  Is this simply that the arp_ip_target is specified as a
VLAN destination signficantly before (meaning perhaps many seconds of
real time) the VLAN is configured above bonding, or is it some kind of
race condition in the VLAN code?

	-J

>>> To prevent this false fail-over, when bonding driver fails to send an
>>> ARP out it marks in its private structure, bonding{},  not to expect
>>> an ARP response, when ARP monitor comes around next time ARP sending
>>> will be tried again.
>>>
>>> Extensively tested in a VM environment; sr-iov intf->bonding
>>> intf->vlan intf. All virtual interfaces created at boot time.

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
