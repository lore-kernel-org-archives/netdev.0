From: Patrick Schaaf <netdev@bof.de>
Subject: bonding flaps between member interfaces
Date: Tue, 17 May 2011 15:27:34 +0200
Message-ID: <1305638854.6044.223.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bof-2.saar.de ([192.109.53.146]:41982 "EHLO oknodo.bof.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567Ab1EQNxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 09:53:34 -0400
Received: from [192.168.178.21]
	by oknodo.bof.de with esmtp (Exim 4.69)
	(envelope-from <netdev@bof.de>)
	id 1QMKJC-0008Pp-Hw
	for netdev@vger.kernel.org; Tue, 17 May 2011 15:27:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdev,

I'm experiencing a regression with bonding. Bugzilla and cursory
searching of the list did not immediately show up anything that seems
related, so here's the report:

Short summary: bonding flips between members every second

bonding in active-backup mode with ARP monitoring
two members in the bond, both being VLAN interfaces on top of two
separate ethernet interfaces
bnx2 ethernet driver, but saw the same behaviour with a tigon box
concrete settings:
BONDING_MODULE_OPTS="mode=active-backup primary=eth0.24 arp_interval=250
arp_ip_target=192.168.x.x"
See below for a /proc/net/bonding/bond24 output reflecing the
configuration.

This setup I have in production on 2.6.36.2, and it works fine.
It also works fine, tested today, with 2.6.36,4 and 2.6.37.6

Starting with 2.6.38 (2.6.38.6 tested today), and still happening with
2.6.39-rc7, I experience problems. While I can still work over the
interface, it is flipping once per second between the two member
interfaces. There is no indication of the underlying interface going
up/down, but bonding seems to think so.

See below an excerpt of the kernel log for two back-and-forth flapping
cycles.

In /proc/net/bonding/bond24, I see the failure counter of the configured
primary interface counting up with each flap. The counter of the non
primary interface does not move. When I switch the primary interface by
echoing to /sys, the behaviour of the counters flips: always the
configured primary has the counter going up.
 
best regards
  Patrick

Here is /proc/net/bonding/bond24 while running on 2.6.37.6, to show the
concrete configuration from this POV. Everything looks the same with the
failing kernels, except for the noted behaviour of the Failure Counts.

Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: eth0.24 (primary_reselect always)
Currently Active Slave: eth0.24
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 250
ARP IP target/s (n.n.n.n form): 192.168.x.x

Slave Interface: eth0.24
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: d4:85:64:ca:1c:12
Slave queue ID: 0

Slave Interface: eth1.24
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: d4:85:64:ca:1c:14
Slave queue ID: 0

Here is kernel log output for two flapping cycles (booted kernel was
2.6.39-rc7):

May 17 14:58:22 myserver kernel: [ 1016.629155] bonding: bond24: link
status definitely down for interface eth0.24, disabling it
May 17 14:58:22 myserver kernel: [ 1016.629159] bonding: bond24: making
interface eth1.24 the new active one.
May 17 14:58:22 myserver kernel: [ 1016.629162] device eth0.24 left
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.629164] device eth0 left
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.629191] device eth1.24 entered
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.629193] device eth1 entered
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.878596] bonding: bond24: link
status definitely up for interface eth0.24.
May 17 14:58:22 myserver kernel: [ 1016.878600] bonding: bond24: making
interface eth0.24 the new active one.
May 17 14:58:22 myserver kernel: [ 1016.878603] device eth1.24 left
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.878605] device eth1 left
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.878631] device eth0.24 entered
promiscuous mode
May 17 14:58:22 myserver kernel: [ 1016.878633] device eth0 entered
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.626919] bonding: bond24: link
status definitely down for interface eth0.24, disabling it
May 17 14:58:23 myserver kernel: [ 1017.626923] bonding: bond24: making
interface eth1.24 the new active one.
May 17 14:58:23 myserver kernel: [ 1017.626926] device eth0.24 left
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.626928] device eth0 left
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.626955] device eth1.24 entered
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.626957] device eth1 entered
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.876359] bonding: bond24: link
status definitely up for interface eth0.24.
May 17 14:58:23 myserver kernel: [ 1017.876363] bonding: bond24: making
interface eth0.24 the new active one.
May 17 14:58:23 myserver kernel: [ 1017.876366] device eth1.24 left
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.876368] device eth1 left
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.876394] device eth0.24 entered
promiscuous mode
May 17 14:58:23 myserver kernel: [ 1017.876396] device eth0 entered
promiscuous mode


