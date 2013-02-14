From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Thu, 14 Feb 2013 10:03:13 -0800
Message-ID: <23692.1360864993@death.nxdomain>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain> <511ADEBB.1000701@genband.com> <kfi5k6$1mq$1@ger.gmane.org> <511D141B.602@genband.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44662 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758490Ab3BNSoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 13:44:03 -0500
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 14 Feb 2013 13:44:02 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D9C062110312
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 13:04:58 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1EI4wZB334876
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 13:04:58 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1EI4v36028309
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 13:04:58 -0500
In-reply-to: <511D141B.602@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>On 02/14/2013 02:01 AM, Cong Wang wrote:
>> On Wed, 13 Feb 2013 at 00:30 GMT, Chris Friesen<chris.friesen@genband.com>  wrote:
>>> On 02/12/2013 06:02 PM, Jay Vosburgh wrote:
>>>> 	The bond doesn't track all of the MACs that go through it, but
>>>> the bridge presumably does, and could respond to the FAILOVER notifier
>>>> with something to notify the switch that the port assignments for the
>>>> various MACs have changed.
>>>
>>> That would probably make sense.  I've added the bridging folks, maybe
>>> they'll have a suggestion how this sort of thing should be handled.
>>>
>>
>> It is already handled. When BONDING_FAILOVER is triggered and the MAC has
>> been changed, NETDEV_CHANGEADDR is issued too, then bridge will capture
>> it and update its fdb:
>>
>>          case NETDEV_CHANGEADDR:
>>                  spin_lock_bh(&br->lock);
>>                  br_fdb_changeaddr(p, dev->dev_addr);
>>                  changed_addr = br_stp_recalculate_bridge_id(br);
>>                  spin_unlock_bh(&br->lock);
>>
>>                  if (changed_addr)
>>                          call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
>>
>>                  break;
>
>I'm not familiar with the bridge code, can you elaborate on how this helps?

	I'm not sure that it does, even if you're using STP (although
I'd want to try it with STP to make sure).  This only updates the fdb's
MAC for the bond's port.  It won't affect the VM's MACs (which it
shouldn't, because they don't change), and won't send any gratuitous
updates through the bond's port to the switch that would notify the
second switch ("B" in Chris's description, below) that the switch port
for the VM's MAC(s) has changed.

	Also, if the bond has fail_over_mac=follow, then no CHANGEADDR
is issued, because the MAC address does not change.  This is not common
(and not the case in the configuration described below), but does occur.

>The problem scenario is this:
>
>I have a host with eth0/eth1 bonded together as bond0.  eth0/eth1 are
>connected to separate L2 switches, which are interconnected.
>
>On the host there are a number of virtual machines, each with a virtual
>interface.
>
>All the virtual interfaces as well as bond0 are bridged together to allow
>the VMs, the host, and the outside world to talk to each other.
>
>Currently the host does NOT participate in STP because it is considered an
>edge node.
>
>Suppose eth0 is the active link and we pull it.  The bond will make eth1
>active and emit gratuitous arp packets for itself, so the external L2
>switches will update the location of the MAC address belonging to the
>bond.  On loss of carrier for the link to eth0 L2 switch "A" will drop the
>entries for the MAC addresses, including the ones for the virtual
>machines.
>
>The problem is that L2 switch "B" still thinks that all the virtual
>machines are accessible via L2 switch "A".  Thus any incoming packets
>destined for a virtual machine will get dropped.

	I'm trying to track down the system I tested previously to see
exactly how it is set up and why it works when yours does not.  It's
possible that it doesn't work, and the testing we did simply missed this
case.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
