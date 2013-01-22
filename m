From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: Bug#697357: bridging broken over bond interfaces
Date: Tue, 22 Jan 2013 21:20:44 +0100
Message-ID: <87y5fl0y1v.fsf@lant.ki.iif.hu>
References: <20130104111712.25539.62770.reportbug@valiant.palfrader.org>
	<20130104114407.GA303@waldi.eu.org>
	<20130104124012.GH14827@anguilla.noreply.org>
	<1357534704.26822.6.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Bastian Blank <waldi@debian.org>,
	697357@bugs.debian.org, Peter Palfrader <weasel@debian.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, wferi@niif.hu
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from listserv2.niif.hu ([193.225.14.155]:49538 "EHLO
	listserv2.niif.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab3AVUyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:54:31 -0500
In-Reply-To: <1357534704.26822.6.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Mon, 07 Jan 2013 04:58:24 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> writes:

> Forwarding this to netdev since the bug is still present in Linux 3.7.1.
> For those joining us, this thread is archive at
> <http://bugs.debian.org/697357>.

Please forgive me for eliding the previous discussion; I think I hit the
same or a very similar problem in the same setup, but without the KVM or
guest parts (but I could reproduce this in a pretty bare KVM guest with
a virtio network device).  My interface configuration (hopefully
comprehensible without familiarity with Debian):

# this is a bare bond interface named after the native VLAN (no .1q!)
auto vlan894
iface vlan894 inet manual
	bond_mode	active-backup
	bond_slaves	eth0
	bond_miimon	100
	bond_updelay	4000

# this bridge has a static IPv4 address and contains the above bond
auto br894
iface br894 inet static
	bridge_ports	vlan894
	bridge_stp	off
	bridge_fd	0
	address		x.y.z.w
	netmask		255.255.255.0
	gateway		x.y.z.g

Actually, I want ARP monitoring for the bond, but if I leave out either
the miimon *or* the updelay configuration, the machine stops responding
to solicited-node multicast packages (neighbor solicitations) thus
becoming unreachable via its autoconfigured global IPv6 address.  That
is, until I put eth0 into promiscuous mode!  And really, with the above
(working) config dmesg says:

bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
bonding: vlan894 is being created...
bonding: vlan894: Setting MII monitoring interval to 100.
bonding: vlan894: Setting up delay to 4000.
bonding: vlan894: setting mode to active-backup (1).
bonding: vlan894: Adding slave eth0.
bonding: vlan894: enslaving eth0 as a backup interface with an up link.
Bridge firewalling registered
device vlan894 entered promiscuous mode
IPv6: ADDRCONF(NETDEV_UP): vlan894: link is not ready
bonding: vlan894: link status definitely up for interface eth0, 4294967295 Mbps full duplex.
bonding: vlan894: making interface eth0 the new active one.
device eth0 entered promiscuous mode
bonding: vlan894: first active interface up!
IPv6: ADDRCONF(NETDEV_CHANGE): vlan894: link becomes ready
br894: port 1(vlan894) entered forwarding state
br894: port 1(vlan894) entered forwarding state

(although ip link does not list any promiscuous interfaces).  On the
other hand, if I don't configure eg. bond_updelay:

bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
bonding: vlan894 is being created...
bonding: vlan894: Setting MII monitoring interval to 100.
bonding: vlan894: setting mode to active-backup (1).
bonding: vlan894: Adding slave eth0.
bonding: vlan894: making interface eth0 the new active one.
bonding: vlan894: first active interface up!
bonding: vlan894: enslaving eth0 as an active interface with an up link.
Bridge firewalling registered
device vlan894 entered promiscuous mode
br894: port 1(vlan894) entered forwarding state
br894: port 1(vlan894) entered forwarding state

ie. promiscuous mode isn't propageted to eth0 and the global IPv6
address of the machine does not respond to ping6 until tcpdump -i eth0
or ip link set eth0 promisc on.  Meanwhile in all cases:

# ip maddr show dev br894
5:	br894
	link  33:33:00:00:00:01
	link  01:00:5e:00:00:01
	link  33:33:ff:02:00:07
	inet  224.0.0.1
	inet6 ff02::1:ff02:7 users 2
	inet6 ff02::1

This happens with the current 3.7.3-1~experimental.1 amd64 kernel under
Debian wheezy (besides the current 3.2 wheezy kernel).
-- 
Thanks for your time,
Feri.
