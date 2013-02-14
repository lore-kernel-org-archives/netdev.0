From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Thu, 14 Feb 2013 10:43:07 -0600
Message-ID: <511D141B.602@genband.com>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain> <511ADEBB.1000701@genband.com> <kfi5k6$1mq$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:36588 "EHLO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758033Ab3BNQnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:43:10 -0500
In-Reply-To: <kfi5k6$1mq$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2013 02:01 AM, Cong Wang wrote:
> On Wed, 13 Feb 2013 at 00:30 GMT, Chris Friesen<chris.friesen@genband.com>  wrote:
>> On 02/12/2013 06:02 PM, Jay Vosburgh wrote:
>>> 	The bond doesn't track all of the MACs that go through it, but
>>> the bridge presumably does, and could respond to the FAILOVER notifier
>>> with something to notify the switch that the port assignments for the
>>> various MACs have changed.
>>
>> That would probably make sense.  I've added the bridging folks, maybe
>> they'll have a suggestion how this sort of thing should be handled.
>>
>
> It is already handled. When BONDING_FAILOVER is triggered and the MAC has
> been changed, NETDEV_CHANGEADDR is issued too, then bridge will capture
> it and update its fdb:
>
>          case NETDEV_CHANGEADDR:
>                  spin_lock_bh(&br->lock);
>                  br_fdb_changeaddr(p, dev->dev_addr);
>                  changed_addr = br_stp_recalculate_bridge_id(br);
>                  spin_unlock_bh(&br->lock);
>
>                  if (changed_addr)
>                          call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
>
>                  break;

I'm not familiar with the bridge code, can you elaborate on how this helps?

The problem scenario is this:

I have a host with eth0/eth1 bonded together as bond0.  eth0/eth1 are 
connected to separate L2 switches, which are interconnected.

On the host there are a number of virtual machines, each with a virtual 
interface.

All the virtual interfaces as well as bond0 are bridged together to 
allow the VMs, the host, and the outside world to talk to each other.

Currently the host does NOT participate in STP because it is considered 
an edge node.

Suppose eth0 is the active link and we pull it.  The bond will make eth1 
active and emit gratuitous arp packets for itself, so the external L2 
switches will update the location of the MAC address belonging to the 
bond.  On loss of carrier for the link to eth0 L2 switch "A" will drop 
the entries for the MAC addresses, including the ones for the virtual 
machines.

The problem is that L2 switch "B" still thinks that all the virtual 
machines are accessible via L2 switch "A".  Thus any incoming packets 
destined for a virtual machine will get dropped.

Chris
