From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: discussion questions: SR-IOV, virtualization,
 and bonding
Date: Thu, 02 Aug 2012 16:26:53 -0600
Message-ID: <501AFEAD.10001@genband.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <17679.1343939453@death.nxdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08/02/2012 02:30 PM, Jay Vosburgh wrote:
>
> Chris Friesen<chris.friesen@genband.com>  wrote:

>> 2) If both the host and guest use active/backup but pick different
>> devices as the active, there is no traffic between host/guest over the
>> bond link.  Packets are sent out the active and looped back internally
>> to arrive on the inactive, then skb_bond_should_drop() suppresses them.
>
> 	Just to be sure that I'm following this correctly, you're
> setting up active-backup bonds on the guest and the host.  The guest
> sets its active slave to be a VF from "SR-IOV Device A," but the host
> sets its active slave to a PF from "SR-IOV Device B."  Traffic from the
> guest to the host then arrives at the host's inactive slave (it's PF for
> "SR-IOV Device A") and is then dropped.
>
> 	Correct?


Yes, that's correct.  The issue is that the internal switch on device A 
knows nothing about device B.  Ideally what should happen is that the 
internal switch routes the packets out onto the wire so that they come 
back in on device B and get routed up to the host.  However, at least 
with the Intel devices the internal switch has no learning capabilities.

The alternative is to have the external switch(es) configured to do the 
loopback, but that puts some extra requirements on the selection of the 
external switch.


>> So far the solutions to 1 seem to be either using arp validation (which
>> currently doesn't exist for loadbalancing modes) or else have the
>> underlying ethernet driver distinguish between packets coming from the
>> wire vs being looped back internally and have the bonding driver only
>> set last_rx for external packets.
>
> 	As discussed previously, e.g.,:
>
> http://marc.info/?l=linux-netdev&m=134316327912154&w=2
>
> 	implementing arp_validate for load balance modes is tricky at
> best, regardless of SR-IOV issues.

Yes, I should have referenced that discussion.  I thought I'd include it 
here with the other issues to group everything together.

> 	This is really a variation on the situation that led to the
> arp_validate functionality in the first place (that multiple instances
> of ARP monitor on a subnet can fool one another), except that the switch
> here is within the SR-IOV device and the various hosts are guests.
>
> 	The best long term solution is to have a user space API that
> provides link state input to bonding on a per-slave basis, and then some
> user space entity can perform whatever link monitoring method is
> appropriate (e.g., LLDP) and pass the results to bonding.

I think this has potential.  This requires a virtual communication 
channel between guest/host if we want the host to be able to influence 
the guest's choice of active link, but I think that's not unreasonable.

Actually, couldn't we do this now?  Turn off miimon and arpmon, then 
just have the userspace thing write to 
/sys/class/net/bondX/bonding/active_slave

>> For issue 2, it would seem beneficial for the host to be able to ensure
>> that the guest uses the same link as the active.  I don't see a tidy
>> solution here.  One somewhat messy possibility here is to have bonding
>> send a message to the standby PF which then tells all its VFs to fake
>> loss of carrier.
>
> 	There is no tidy solution here that I'm aware of; this has been
> a long standing concern in bladecenter type of network environments,
> wherein all blade "eth0" interfaces connect to one chassis switch, and
> all blade "eth1" interfaces connect to a different chassis switch.  If
> those switches are not connected, then there may not be a path from
> blade A:eth0 to blade B:eth1.  There is no simple mechanism to force a
> gang failover across multiple hosts.

In our blade server environment those two switches are indeed 
cross-connected, so we haven't had to do gang-failover.


> 	Note that the ehea can propagate link failure of its external
> port (the one that connects to a "real" switch) to its internal ports
> (what the lpars see), so that bonding can detect the link failure.  This
> is an option to ehea; by default, all internal ports are always carrier
> up so that they can communicate with one another regardless of the
> external port link state.  To my knowledge, this is used with miimon,
> not the arp monitor.
>
> 	I don't know how SR-IOV operates in this regard (e.g., can VFs
> fail independently from the PF?).  It is somewhat different from your
> case in that there is no equivalent to the PF in the ehea case.  If the
> PFs participate in the primary setting it will likely permit initial
> connectivity, but I'm not sure if a PF plus all its VFs fail as a unit
> (from bonding's point of view).

With current Intel drivers at least, if the PF detects link failure it 
fires a message to the VFs and they detect link failure within a short 
time (milliseconds).

We can recommend the use of the "primary" option, but we don't always 
have total control over what the guest does, and for some reason some of 
them don't want to use "primary".  I'm not sure why.


>> For issue 3, the logical solution would seem to be some way of assigning
>> a list of "valid" mac addresses to a given VF--like maybe all MAC
>> addresses assigned to a VM or something.  Anyone have any bright ideas?
>
> 	There's an option to bonding, fail_over_mac, that modifies
> bonding's handling of the slaves' MAC address(es).  One setting,
> "active" instructs bonding to make its MAC be whatever the currently
> active slave's MAC is, never changing any of the slave's MAC addresses.

Yes, I'm aware of that option.  It does have drawbacks though, as 
described in the bonding.txt docs.


>> I'm sure we're not the only ones running into this, so what are others
>> doing?  Is the only current option to use active/active with miimon?
>
> 	I think you're at least close to the edge here; I've only done
> some basic testing of bonding with SR-IOV, although I'm planning to do
> some more early next week (and what you've found has been good input for
> me, so thanks for that, at least).

Glad we could help.  :)

Chris

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
