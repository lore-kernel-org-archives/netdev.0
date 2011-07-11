From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 13:25:46 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:21161 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758084Ab1GKSbT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 14:31:19 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into a strange situation - I am using a firewall set up as a
bridge.  Physical device eth1 is the private LAN side, eth0 is the
public Internet side.  I setup bridge br0 to bridge eth0 and eth1
together.  I need a bridge because this site has a couple of nodes on
the LAN side that need real public IP Addresses.  

This site also has a few web and ftp sites.  These are NATed behind the
firewall, but internal users need to see them the same way as the rest
of the world.  So I use some iptables SNAT and DNAT rules to make this
happen.  Device br0 has the relevant public IP Address(es) and then NATs
to the appropriate private IP Address(es).  The ruleset works and the
system has been up and running for several years.  

I recently replaced the old system with a new one running Fedora 14 and
that's when the weird behavior started.  

Now, when internal people try to look at those web/ftp sites using the
public IP Addresses, they get nowhere.  Unless I watch with tcpdump -
and then while I'm watching , all works as it should.  With some help,
we figured out the reason it works when watching with tcpdump - because
tcpdump puts the device being monitored into promiscuous mode.  

And, sure enough, when I do:
    ip link set br0 promisc on

everything works as it should.

Looking at "ip link show", it looks like bridge br0 takes on the MAC
address of physical NIC eth0.  But the internal LAN is connected to
physical eth1.  I wonder if this behavior is different than the older
version?  If the MAC Address for bridge br0 is different than the
physical device I'm actually connected to, I wonder if bridging "thinks"
I'm trying to hit a foreign MAC Address - especially since I'm doing
both SNAT and DNAT on the same packet?  

[root@ehac-fw2011 ~]# ip link show eth1
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:0d:88:31:d8:24 brd ff:ff:ff:ff:ff:ff
[root@ehac-fw2011 ~]# ip link show eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff
[root@ehac-fw2011 ~]#
[root@ehac-fw2011 ~]# ip link show br0
5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc prio state
UNKNOWN
    link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff

[root@ehac-fw2011 ~]# brctl show macs br0
bridge name     bridge id               STP enabled     interfaces
br0             8000.0003473a5979       no              eth0
                                                        eth1
Hmmmm - so a packet comes in on eth1, with a destination MAC Address
belonging to physical eth0.  So eth1 throws it away because it "thinks"
this is a foreign MAC Address?  But this all worked before, so what's
different?  Or were earlier bridges in promiscuous mode by default and
now they're not?  Have I stumbled across a new bridging bug?  Is the
best workaround to just put br0 into promiscuous mode?

Thanks

- Greg Scott
