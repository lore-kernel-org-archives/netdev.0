From: rama nichanamatlu <rama.nichanamatlu@oracle.com>
Subject: Re: [PATCH] bonding: If IP route look-up to send an ARP fails, mark
 in bonding structure as no ARP sent.
Date: Wed, 20 Nov 2013 18:23:01 -0800
Message-ID: <528D6E85.8040904@oracle.com>
References: <528D5980.3040309@oracle.com> <12668.1384996699@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50160 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530Ab3KUCXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 21:23:06 -0500
In-Reply-To: <12668.1384996699@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 5:18 PM, Jay Vosburgh wrote:
> rama nichanamatlu <rama.nichanamatlu@oracle.com> wrote:
> 
>> During the creation of VLAN's atop bonding the underlying interfaces are
>> made part of VLAN's, and at the same bonding driver gets aware that VLAN's
>> exists above it and hence would consult IP routing for every ARP to  be
>> sent to determine the route which tells bonding driver the correct VLAN
>> tag to attach to the outgoing ARP packet. But, during the VLAN creation
>> when vlan driver puts the underlying interface into default vlan and then
>> actual vlan, in-between this if bonding driver consults the IP for a
>> route, IP fails to provide a correct route and upon which bonding driver
>> drops the ARP packet. ARP monitor when it
>> comes around next time, sees no ARP response and fails-over to the next
>> available slave. Consulting for a IP route, ip_route_output(),happens in
>> bond_arp_send_all().
>>
>> To prevent this false fail-over, when bonding driver fails to send an ARP
>> out it marks in its private structure, bonding{},  not to expect an ARP
>> response, when ARP monitor comes around next time ARP sending will be
>> tried again.
>>
>> Extensively tested in a VM environment; sr-iov intf->bonding intf->vlan
>> intf. All virtual interfaces created at boot time.
> 
> 	First, this patch appears to be for an older kernel, as the
> current mainline code is substantially different (e.g., master_ip is no
> longer used).
> 
> 	Second, won't this methodology mask legitimate failures, such as
> when a single arp_ip_target specifies a destination that is not ever
> reachable?  I.e., would specifying a permanently unreachable IP address
> as the arp_ip_target cause all slaves to always stay up (because no ARPs
> will ever be sent), even if no ARP replies are ever received?
> 
> 	-J
> 
Thank U.
I agree with your rationale. Would keep a slave falsely up but traffic
might flow. And true that, it is not what we are looking for.
We can try a different approach too, which we used to fix a false
fail-over in MTU changing case where the device interface takes time to
change the device MTU. And in the mean time bonding was failing over.
What we did to fix was to stop the ARP monitoring, bond_change_mtu(),
and restart it when NETDEV_CHANGE from slave is handled,
bond_slave_netdev_event(). Not sure if this can used for vlan case, as
mtu thing is event driven.


>> Orabug: 17172660
>> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
>> Signed-off-by: Rama Nichanamatlu <rama.nichanamatlu@oracle.com>
