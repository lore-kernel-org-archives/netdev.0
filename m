From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: discussion questions: SR-IOV, virtualization,
	and bonding
Date: Thu, 02 Aug 2012 13:30:53 -0700
Message-ID: <17679.1343939453@death.nxdomain>
References: <501AD33E.5090308@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <501AD33E.5090308@genband.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Chris Friesen <chris.friesen@genband.com> wrote:
>Hi all,
>
>I wanted to just highlight some issues that we're seeing and see what 
>others are doing in this area.
>
>Our configuration is that we have a host with SR-IOV-capable NICs with 
>bonding enabled on the PF.  Depending on the exact system it could be 
>active/standby or some form of active/active.
>
>In the guests we generally have several VFs (corresponding to several 
>PFs) and we want to bond them for reliability.
>
>We're seeing a number of issues:
>
>1) If the guests use arp monitoring then broadcast arp packets from the 
>guests are visible on the other guests and on the host, and can cause 
>them to think the link is good even if we aren't receiving arp packets 
>from the external network.  (I'm assuming carrier is up.)
>
>2) If both the host and guest use active/backup but pick different 
>devices as the active, there is no traffic between host/guest over the 
>bond link.  Packets are sent out the active and looped back internally 
>to arrive on the inactive, then skb_bond_should_drop() suppresses them.

	Just to be sure that I'm following this correctly, you're
setting up active-backup bonds on the guest and the host.  The guest
sets its active slave to be a VF from "SR-IOV Device A," but the host
sets its active slave to a PF from "SR-IOV Device B."  Traffic from the
guest to the host then arrives at the host's inactive slave (it's PF for
"SR-IOV Device A") and is then dropped.

	Correct?

>3) For active/standby the default is to set the standby to the MAC 
>address of the bond.  If the host has already set the MAC address (using 
>some algorithm to ensure uniqueness within the local network) then the 
>guest is not allowed to change it.
>
>
>So far the solutions to 1 seem to be either using arp validation (which 
>currently doesn't exist for loadbalancing modes) or else have the 
>underlying ethernet driver distinguish between packets coming from the 
>wire vs being looped back internally and have the bonding driver only 
>set last_rx for external packets.

	As discussed previously, e.g.,:

http://marc.info/?l=linux-netdev&m=134316327912154&w=2

	implementing arp_validate for load balance modes is tricky at
best, regardless of SR-IOV issues.

	This is really a variation on the situation that led to the
arp_validate functionality in the first place (that multiple instances
of ARP monitor on a subnet can fool one another), except that the switch
here is within the SR-IOV device and the various hosts are guests.

	The best long term solution is to have a user space API that
provides link state input to bonding on a per-slave basis, and then some
user space entity can perform whatever link monitoring method is
appropriate (e.g., LLDP) and pass the results to bonding.

>For issue 2, it would seem beneficial for the host to be able to ensure 
>that the guest uses the same link as the active.  I don't see a tidy 
>solution here.  One somewhat messy possibility here is to have bonding 
>send a message to the standby PF which then tells all its VFs to fake 
>loss of carrier.

	There is no tidy solution here that I'm aware of; this has been
a long standing concern in bladecenter type of network environments,
wherein all blade "eth0" interfaces connect to one chassis switch, and
all blade "eth1" interfaces connect to a different chassis switch.  If
those switches are not connected, then there may not be a path from
blade A:eth0 to blade B:eth1.  There is no simple mechanism to force a
gang failover across multiple hosts.

	That said, I've seen a slight rub on this using virtualized
network devices (pseries ehea, which is similar in principle to SR-IOV,
although implemented differently).  In that case, the single ehea card
provides all "eth0" devices for all lpars (logical partitions,
"guests").  A separate card (or individual per-lpar cards) provides the
"eth1" devices.

	In this configuration, the bonding primary option is used to
make eth0 the primary, and thus all lpars use eth0 preferentially, and
there is no connectivity issue.  If the ehea card itself fails, all of
the bonds will fail over simultaneously to the backup devices, and
again, there is no connectivity issue.  This works because the ehea is a
single point of failure for all of the partitions.

	Note that the ehea can propagate link failure of its external
port (the one that connects to a "real" switch) to its internal ports
(what the lpars see), so that bonding can detect the link failure.  This
is an option to ehea; by default, all internal ports are always carrier
up so that they can communicate with one another regardless of the
external port link state.  To my knowledge, this is used with miimon,
not the arp monitor.

	I don't know how SR-IOV operates in this regard (e.g., can VFs
fail independently from the PF?).  It is somewhat different from your
case in that there is no equivalent to the PF in the ehea case.  If the
PFs participate in the primary setting it will likely permit initial
connectivity, but I'm not sure if a PF plus all its VFs fail as a unit
(from bonding's point of view).

>For issue 3, the logical solution would seem to be some way of assigning 
>a list of "valid" mac addresses to a given VF--like maybe all MAC 
>addresses assigned to a VM or something.  Anyone have any bright ideas?

	There's an option to bonding, fail_over_mac, that modifies
bonding's handling of the slaves' MAC address(es).  One setting,
"active" instructs bonding to make its MAC be whatever the currently
active slave's MAC is, never changing any of the slave's MAC addresses.

>I'm sure we're not the only ones running into this, so what are others 
>doing?  Is the only current option to use active/active with miimon?

	I think you're at least close to the edge here; I've only done
some basic testing of bonding with SR-IOV, although I'm planning to do
some more early next week (and what you've found has been good input for
me, so thanks for that, at least).

	I suspect that some bonding configurations are simply not going
to work at all; e.g., I'm not aware of any SR-IOV devices that implement
LACP on the internal switch, and in any event, it would have to create
aggregators that span across physical network devices to be really
useful.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


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
