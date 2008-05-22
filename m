From: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>
Subject: DNAT sporadically doesn't replace destination IP address
Date: Thu, 22 May 2008 16:33:03 +0200
Message-ID: <4835A03D.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ulrik De Bie" <ulrik.debie@newtec.eu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.newtec.eu ([62.58.98.194]:1789 "EHLO mail.newtec.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbYEVOyV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 10:54:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Problem:
The replacing of the destination IP address doesn't occur always.  I've got a PC on which I run a program which retrieves web pages of 30 modems which all have the same IP address.  In order to do this I created the configuration as listed below.  For the program the IP addresses will be 10.9.9.1 to 10.9.9.30.  Those will be send out on a specific VLAN and the IP address will be replaced by 192.168.1.1.  A number of times I get a 'no route to host' for those web pages, this happens sporadically.  If I start looking at the ARP messages, I see that when it goes wrong an ARP message is send out for an 10.9.9.x address which shouldn't be the case.
On an older setup I didn't  had this problem, so I downgraded the kernel version from 2.6.22-14-generic to 2.6.17-12-generic on the setup where I had the problem.  
With this downgraded kernel the problem didn't occur anymore. 
The distro is Ubuntu. An upgrade to Ubuntu 8.04 which has kernel 2.6.24 didn't solve the problem.

* Setup:
- On which I have the problem:
PC -> Vlan enabled ethernet switch -> 30 modems with the same IP address.

- Simplified:
PC -> PC
for 1 port use the configuration as mentioned below. For the other port use 192.168.1.1 as IP address for each VLAN.
Then you can just ping 10.9.9.x to test.
I have not tried this.

* Perl script to generate configure script:
!/usr/bin/perl -w

my $vlan  = 100;
my $modem = 1;
my $subip = 2;
for (my $modem = 1;$modem <= 30;$modem++) {
    print "echo \"------------$vlan--------------------\"\n";
    print "vconfig add eth2 $vlan\n";
    print "ifconfig eth2.$vlan 192.168.1.$subip\n";
    print "route del -net 192.168.1.0/24\n";
    print "route add -host 10.9.9.$modem eth2.$vlan\n";
    print "iptables -t nat -A OUTPUT -o eth2.$vlan -j DNAT --to 192.168.1.1\n";

    print "iptables -t mangle -N VLAN$vlan\n";
    print "iptables -t mangle -F VLAN$vlan\n";
    print "iptables -t mangle -A VLAN$vlan -j MARK --set-mark $vlan\n";
    print "iptables -t mangle -A OUTPUT -o eth2.$vlan -j VLAN$vlan\n";
    print "ip ro add table $vlan default dev eth2.$vlan\n";
    print "ip ru add fwmark $vlan table $vlan\n";
    print "ip ro fl ca\n";
    $vlan++;
    $subip++;
};

* HW related info as far it is relevant:
10:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
10:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
3f:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755 Gigabit Ethernet PCI Express (rev 02)

Kind regards,
Kris

Newtec will be present at the following exhibitions :

CommunicAsia, 17-20 June, Singapore, Booth 6B2-01

*** e-mail confidentiality footer ***
This message and any attachments thereto are confidential. They may also
be privileged or otherwise protected by work product immunity or other
legal rules. If you have received it by mistake, please let us know by
e-mail reply and delete it from your system; you may not copy this
message or disclose its contents to anyone.
E-mail transmission cannot be guaranteed to be secure or error free as
information could be intercepted, corrupted, lost, destroyed, arrive
late or incomplete, or contain viruses. The sender therefore is in no
way liable for any errors or omissions in the content of this message,
which may arise as a result of e-mail transmission. If verification is
required, please request a hard copy.

