From: Santiago Garcia Mantinan <manty@manty.net>
Subject: bonding + arp monitoring fails if interface is a vlan
Date: Thu, 1 Aug 2013 14:11:42 +0200
Message-ID: <20130801121142.GA444@www.manty.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 85.52.197.2.static.abi.uni2.es ([85.52.197.2]:47246 "EHLO
	www.manty.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab3HAMTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 08:19:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm trying to setup a bond of a couple of vlans, these vlans are different
paths to an upstream switch from a local switch.  I want to do arp
monitoring of the link in order for the bonding interface to know which path
is ok and wich one is broken.  If I set it up using arp monitoring and
without using vlans it works ok, it also works if I set it up using vlans
but without arp monitoring, so the broken setup seems to be with bonding +
arp monitoring + vlans. Here is a schema:

 -------------
|Remote Switch|
 -------------
   |      |
   P      P
   A      A
   T      T
   H      H
   1      2
   |      |
 ------------
|Local switch|
 ------------
      |
      | VLAN for PATH1
      | VLAN for PATH2
      |
 Linux machine

The broken setup seems to work but arp monitoring makes it loose the logical
link from time to time, thus changing to other slave if available.  What I
saw when monitoring this with tcpdump is that all the arp requests were
going out and that all the replies where coming in, so acording to the
traffic seen on tcpdump the link should have been stable, but
/proc/net/bonding/bond0 showed the link failures increasing and when testing
with just a vlan interface I was loosing ping when the link was going down.

I've tried this on Debian wheezy with its 3.2.46 kernel and also the 3.10.3
version in unstable, the tests where done on a couple of machines using a 32
bits kernel with different nics (r8169 and skge).

I created a small lab to replicate the problem, on this setup I avoided all
the switching and I directly connected the machine with bonding to another
Linux on which I just had eth0.1002 configured with ip 192.168.1.1, the
results where the same as in the full scenario, link on the bonding slave
was going down from time to time.

This is the setup on the bonding interface.

auto bond0
iface bond0 inet static
        address 192.168.1.2
        netmask 255.255.255.0
        bond-slaves eth0.1002
        bond-mode active-backup
        bond-arp_validate 0
        bond-arp_interval 5000
        bond-arp_ip_target 192.168.1.1
        pre-up ip link set eth0 up || true
        pre-up ip link add link eth0 name eth0.1002 type vlan id 1002 || true
        down ip link delete eth0.1002 || true

These are the messages I was seing on the bonding machines:

[  452.436750] bonding: bond0: adding ARP target 192.168.1.1.
[  452.436851] bonding: bond0: Setting ARP monitoring interval to 5000.
[  452.440287] bonding: bond0: setting mode to active-backup (1).
[  452.440429] bonding: bond0: setting arp_validate to none (0).
[  452.458349] bonding: bond0: Adding slave eth0.1002.
[  452.458964] bonding: bond0: making interface eth0.1002 the new active one.
[  452.458983] bonding: bond0: first active interface up!
[  452.458999] bonding: bond0: enslaving eth0.1002 as an active interface with an up link.
[  452.482560] 8021q: adding VLAN 0 to HW filter on device bond0
[  467.500143] bonding: bond0: link status definitely down for interface eth0.1002, disabling it
[  467.500193] bonding: bond0: now running without any active interface !
[  622.748102] bonding: bond0: link status definitely up for interface eth0.1002.
[  622.748122] bonding: bond0: making interface eth0.1002 the new active one.
[  622.748522] bonding: bond0: first active interface up!
[  637.772179] bonding: bond0: link status definitely down for interface eth0.1002, disabling it
[  637.772228] bonding: bond0: now running without any active interface !
[  642.780173] bonding: bond0: link status definitely up for interface eth0.1002.
[  642.780192] bonding: bond0: making interface eth0.1002 the new active one.
[  642.780603] bonding: bond0: first active interface up!
[  657.804154] bonding: bond0: link status definitely down for interface eth0.1002, disabling it
[  657.804209] bonding: bond0: now running without any active interface !
[  662.812165] bonding: bond0: link status definitely up for interface eth0.1002.
[  662.812185] bonding: bond0: making interface eth0.1002 the new active one.
[  662.812592] bonding: bond0: first active interface up!
[  677.836167] bonding: bond0: link status definitely down for interface eth0.1002, disabling it
[  677.836223] bonding: bond0: now running without any active interface !
[  682.844162] bonding: bond0: link status definitely up for interface eth0.1002.
[  682.844181] bonding: bond0: making interface eth0.1002 the new active one.
[  682.844590] bonding: bond0: first active interface up!
[  697.868153] bonding: bond0: link status definitely down for interface eth0.1002, disabling it

Like I said, running tcpdump on both Linux shows everything fine, all arp
replies and requests are there, but link goes down from time to time, on
this setup the bond is built just with one slave, so network is lost when
link goes down.

Some questions:

am I doing something wrong here?
Is this setup not supported?
If it should work... can anybody reproduce this?
Bug?

What should I do now?

Regards...
-- 
Manty/BestiaTester -> http://manty.net
