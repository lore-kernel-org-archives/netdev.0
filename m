From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Tue, 1 Dec 2009 09:44:10 -0500
Message-ID: <20091201144410.GI1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbZLAOoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 09:44:06 -0500
Content-Disposition: inline
In-Reply-To: <6611.1259632635@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 05:57:15PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >On Mon, Nov 30, 2009 at 04:00:38PM -0800, Jay Vosburgh wrote:
> >> Andy Gospodarek <andy@greyhouse.net> wrote:
> >> 
> >> >This allows a bond device to specify an arp_ip_target as a host that is
> >> >not on the same vlan as the base bond device.  A configuration like
> >> >this, now works:
> >> >
> >> >1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
> >> >    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> >> >    inet 127.0.0.1/8 scope host lo
> >> >    inet6 ::1/128 scope host
> >> >       valid_lft forever preferred_lft forever
> >> >2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
> >> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >> >3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
> >> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >> >8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
> >> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >> >    inet6 fe80::213:21ff:febe:33e9/64 scope link
> >> >       valid_lft forever preferred_lft forever
> >> >9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
> >> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >> >    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
> >> >    inet6 fe80::213:21ff:febe:33e9/64 scope link
> >> >       valid_lft forever preferred_lft forever
> >> 
> >> 	I'm not quite clear here on exactly what it is that doesn't
> >> work.
> >> 
> >> 	Putting the arp_ip_target on a VLAN destination already works
> >> (and has for a long time); I just checked against a 2.6.32-rc to make
> >> sure I wasn't misremembering.
> >> 
> >> 	Perhaps there's some nuance of "not on the same vlan as the base
> >> bond device" that I'm missing.  What I see working before me is, e.g., a
> >> bond0.777 VLAN interface atop a regular bond0 active-backup with a
> >> couple of slaves; bond0 may or may not have an IP address of its own.
> >> The arp_ip_target destination is on VLAN 777 somewhere.
> >
> >Do you have net.ipv4.conf.all.arp_ignore set to 0 and/or an IP address
> >assigned on bond0?  I can easily reproduce this with no IP on bond0 and
> >net.ipv4.conf.all.arp_ignore = 1.
> >
> >I can't say for sure that the sysctl setting makes a difference, but I
> >have that on all my test rigs, so it's worth mentioning.
> >
> >> 	Is this what your patch is meant to enable, or is it something
> >> different?  I'm pulling down today's net-next to see if this is
> >> something that broke recently.
> >> 
> >
> >I first tested and found the problem while running 2.6.30-rc series
> >after it was reported to be a problem on RHEL5.  It's not clear how long
> >it has been broken, but this situation is odd enough that it probably
> >never worked as it was never tested.
> 
> 	I tried it with both arp_ignore set to 1 and 0, and with the
> bond0 interface with and without an IP address.  It works fine in all
> four cases.  I'm using net-next-2.6 pulled earlier today; it claims to
> be 2.6.32-rc7.
> 
> 	I've tested "ARP monitor over VLAN" in the past, so it's worked
> for me before.  Heck, it's working right now.
> 
> 	I thought maybe you have "arp_validate" enabled (which doesn't
> work over a VLAN), but your patch doesn't help there, so presumably not.
> Fixing that is a totally separate adventure into hook-ville; I'd briefly
> hoped you'd found a better way.
> 

I am using arp_validate, actually.  I forgot that the arp_validate
option doesn't show up in the output of /proc/net/bonding/bondX and I
intended to have that in the subject, but somehow dropped it.

Here is a bit more detail on my setup:

# grep -v ^# /etc/sysconfig/network-scripts/ifcfg-bond0 
DEVICE=bond0
BOOTPROTO=none
ONBOOT=no
BONDING_OPTS="mode=active-backup arp_interval=1000 arp_ip_target=10.0.100.1 arp_validate=3"

(The 'active' and 'backup' arp_validate options work just as well as
'all.')

Here is the dmesg output for the above config:

bonding: bond0: Warning: failed to get speed and duplex from eth3, assumed to be 100Mb/sec and Full.
bonding: bond0: enslaving eth3 as a backup interface with an up link.
bonding: bond0: setting mode to active-backup (1).
bonding: bond0: Setting ARP monitoring interval to 1000.
bonding: bond0: ARP target 10.0.100.1 is already present
bonding: bond0: setting arp_validate to all (3).
bnx2: eth2 NIC Copper Link is Up, 100 Mbps full duplex, receive & transmit flow control ON
bnx2: eth3 NIC Copper Link is Up, 100 Mbps full duplex, receive & transmit flow control ON
bonding: bond0: link status definitely down for interface eth2, disabling it
bonding: bond0: making interface eth3 the new active one.
bonding: bond0: no route to arp_ip_target 10.0.100.1
bonding: bond0: link status definitely up for interface eth2.
bond0: no IPv6 routers present
bond0.100: no IPv6 routers present

# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth3
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 1000
ARP IP target/s (n.n.n.n form): 10.0.100.1

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:10:18:36:0a:d4

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:10:18:36:0a:d6

> 	When it's failing, are you getting any messages in dmesg?  I'm
> wondering specifically about any of the various routing-related things
> that bond_arp_send_all might kick out.
> 

When it doesn't work, dmesg just looks like this:

bonding: bond0: Warning: failed to get speed and duplex from eth3, assumed to be 100Mb/sec and Full.
bonding: bond0: enslaving eth3 as a backup interface with an up link.
bonding: bond0: setting mode to active-backup (1).
bonding: bond0: Setting ARP monitoring interval to 1000.
bonding: bond0: ARP target 10.0.100.1 is already present
bonding: bond0: setting arp_validate to all (3).
bnx2: eth2 NIC Copper Link is Up, 100 Mbps full duplex, receive & transmit flow control ON
bnx2: eth3 NIC Copper Link is Up, 100 Mbps full duplex, receive & transmit flow control ON
bonding: bond0: link status definitely down for interface eth2, disabling it
bonding: bond0: making interface eth3 the new active one.
bonding: bond0: no route to arp_ip_target 10.0.100.1
bonding: bond0: link status definitely down for interface eth3, disabling it
bonding: bond0: now running without any active interface !
bond0: no IPv6 routers present
bond0.100: no IPv6 routers present

# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: None
MII Status: down
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 1000
ARP IP target/s (n.n.n.n form): 10.0.100.1

Slave Interface: eth2
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:10:18:36:0a:d4

Slave Interface: eth3
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:10:18:36:0a:d6

Though I think that information won't be that useful now that I've
actually explained this patch makes the arp_validate options work with a
vlan setup like this.

