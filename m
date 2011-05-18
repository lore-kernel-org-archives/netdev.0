From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding flaps between member interfaces
Date: Tue, 17 May 2011 18:22:22 -0700
Message-ID: <27478.1305681742@death>
References: <1305638854.6044.223.camel@lat1>
Cc: netdev@vger.kernel.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38022 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932082Ab1ERBW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 21:22:29 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4I1BHWO012156
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 21:11:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4I1MRP7429988
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 21:22:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4I1MQ6r001870
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 22:22:26 -0300
In-reply-to: <1305638854.6044.223.camel@lat1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Schaaf <netdev@bof.de> wrote:

>Dear netdev,
>
>I'm experiencing a regression with bonding. Bugzilla and cursory
>searching of the list did not immediately show up anything that seems
>related, so here's the report:
>
>Short summary: bonding flips between members every second

	I have reproduced the problem on a 2.6.38-rc5-ish kernel.

	The described configuration is enslaving two VLAN interfaces; I
also tried enslaving eth0/eth1 directly and stacking the VLAN atop
bonding.  That doesn't work either.  I don't get any errors, and bonding
says the slaves are up, but ping through the VLAN fails.  Ping over the
non-VLAN (directly on bond0) works ok.

	I'll give it some bisect action and report back.

	-J

>bonding in active-backup mode with ARP monitoring
>two members in the bond, both being VLAN interfaces on top of two
>separate ethernet interfaces
>bnx2 ethernet driver, but saw the same behaviour with a tigon box
>concrete settings:
>BONDING_MODULE_OPTS="mode=active-backup primary=eth0.24 arp_interval=250
>arp_ip_target=192.168.x.x"
>See below for a /proc/net/bonding/bond24 output reflecing the
>configuration.
>
>This setup I have in production on 2.6.36.2, and it works fine.
>It also works fine, tested today, with 2.6.36,4 and 2.6.37.6
>
>Starting with 2.6.38 (2.6.38.6 tested today), and still happening with
>2.6.39-rc7, I experience problems. While I can still work over the
>interface, it is flipping once per second between the two member
>interfaces. There is no indication of the underlying interface going
>up/down, but bonding seems to think so.
>
>See below an excerpt of the kernel log for two back-and-forth flapping
>cycles.
>
>In /proc/net/bonding/bond24, I see the failure counter of the configured
>primary interface counting up with each flap. The counter of the non
>primary interface does not move. When I switch the primary interface by
>echoing to /sys, the behaviour of the counters flips: always the
>configured primary has the counter going up.
>
>best regards
>  Patrick
>
>Here is /proc/net/bonding/bond24 while running on 2.6.37.6, to show the
>concrete configuration from this POV. Everything looks the same with the
>failing kernels, except for the noted behaviour of the Failure Counts.
>
>Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)
>
>Bonding Mode: fault-tolerance (active-backup)
>Primary Slave: eth0.24 (primary_reselect always)
>Currently Active Slave: eth0.24
>MII Status: up
>MII Polling Interval (ms): 0
>Up Delay (ms): 0
>Down Delay (ms): 0
>ARP Polling Interval (ms): 250
>ARP IP target/s (n.n.n.n form): 192.168.x.x
>
>Slave Interface: eth0.24
>MII Status: up
>Speed: 1000 Mbps
>Duplex: full
>Link Failure Count: 0
>Permanent HW addr: d4:85:64:ca:1c:12
>Slave queue ID: 0
>
>Slave Interface: eth1.24
>MII Status: up
>Speed: 1000 Mbps
>Duplex: full
>Link Failure Count: 0
>Permanent HW addr: d4:85:64:ca:1c:14
>Slave queue ID: 0
>
>Here is kernel log output for two flapping cycles (booted kernel was
>2.6.39-rc7):
>
>May 17 14:58:22 myserver kernel: [ 1016.629155] bonding: bond24: link
>status definitely down for interface eth0.24, disabling it
>May 17 14:58:22 myserver kernel: [ 1016.629159] bonding: bond24: making
>interface eth1.24 the new active one.
>May 17 14:58:22 myserver kernel: [ 1016.629162] device eth0.24 left
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.629164] device eth0 left
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.629191] device eth1.24 entered
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.629193] device eth1 entered
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.878596] bonding: bond24: link
>status definitely up for interface eth0.24.
>May 17 14:58:22 myserver kernel: [ 1016.878600] bonding: bond24: making
>interface eth0.24 the new active one.
>May 17 14:58:22 myserver kernel: [ 1016.878603] device eth1.24 left
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.878605] device eth1 left
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.878631] device eth0.24 entered
>promiscuous mode
>May 17 14:58:22 myserver kernel: [ 1016.878633] device eth0 entered
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.626919] bonding: bond24: link
>status definitely down for interface eth0.24, disabling it
>May 17 14:58:23 myserver kernel: [ 1017.626923] bonding: bond24: making
>interface eth1.24 the new active one.
>May 17 14:58:23 myserver kernel: [ 1017.626926] device eth0.24 left
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.626928] device eth0 left
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.626955] device eth1.24 entered
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.626957] device eth1 entered
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.876359] bonding: bond24: link
>status definitely up for interface eth0.24.
>May 17 14:58:23 myserver kernel: [ 1017.876363] bonding: bond24: making
>interface eth0.24 the new active one.
>May 17 14:58:23 myserver kernel: [ 1017.876366] device eth1.24 left
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.876368] device eth1 left
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.876394] device eth0.24 entered
>promiscuous mode
>May 17 14:58:23 myserver kernel: [ 1017.876396] device eth0 entered
>promiscuous mode

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
