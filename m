From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 02:03:08 +0300
Message-ID: <200907030203.08294.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907030022.55186.denys@visp.net.lb> <m1y6r6wwxy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37500 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbZGBXD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 19:03:28 -0400
In-Reply-To: <m1y6r6wwxy.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 01:18:33 Eric W. Biederman wrote:
>
> The problem is you have machines on the wrong subnet.
>
> If you are not enforcing which network your laptops are in you
> want ethernet bridging not proxy_arp.
>
> Eric
>
More important - feature must work CORRECTLY. Sometimes bridge is not fitting 
all needs. Probably behavior of well known networking vendor will be 
respected.

Here is example tested on Cisco IOS ( Cisco IOS Software, 7200 Software 
(C7200-ADVIPSERVICESK9-M), Version 12.4(4)T1, RELEASE SOFTWARE (fc4))


interface FastEthernet1/0
 ip address 10.0.1.2 255.255.255.0
 duplex half
!
interface FastEthernet2/0
 ip address 10.0.2.2 255.255.255.0
 duplex half
!
ip default-gateway 10.0.2.1


fa 1/0 - tap0
fa 2/0 - tap1

home ~ # arping -I tap0 10.0.1.5
ARPING 10.0.1.5 from 10.0.1.21 tap0
^CSent 3 probes (3 broadcast(s))
Received 0 response(s)
home ~ # arping -I tap0 10.0.2.5
ARPING 10.0.2.5 from 10.0.1.21 tap0
Unicast reply from 10.0.2.5 [CA:00:0A:FC:00:1C]  6.477ms
Unicast reply from 10.0.2.5 [CA:00:0A:FC:00:1C]  5.520ms
Unicast reply from 10.0.2.5 [CA:00:0A:FC:00:1C]  4.842ms
^CSent 3 probes (1 broadcast(s))
Received 3 response(s)
home ~ # arping -I tap0 4.5.6.7
ARPING 4.5.6.7 from 10.0.1.21 tap0
^CSent 4 probes (4 broadcast(s))
Received 0 response(s)

home ~ # ip addr add dev tap0 10.0.2.5
home ~ # arping -I tap0 10.0.2.5
ARPING 10.0.2.5 from 10.0.2.5 tap0

home ~ # tcpdump -ni tap0 -s 1500 -vvv
tcpdump: WARNING: tap0: no IPv4 address assigned
tcpdump: listening on tap0, link-type EN10MB (Ethernet), capture size 1500 
bytes
01:46:21.404454
01:46:31.404566
01:46:35.756623 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.5, length 28
01:46:36.756740 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.5, length 28
01:46:37.756821 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.5, length 28

they dont answer btw also for ip's who is not in their network, but this 
doesn't matter, not defined in RFC, but good manner. Also it make impossible 
situation with ARP announce answered by Cisco and  will not make false 
positive IP conflict detection on Windows.

home ~ # tcpdump -ni tap0 -s 1500 -vvv
tcpdump: listening on tap0, link-type EN10MB (Ethernet), capture size 1500 
bytes
01:47:17.754393 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.7, length 28
01:47:18.754581 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.7, length 28
01:47:19.754628 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.7, length 28
01:47:20.754674 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.5 
(ff:ff:ff:ff:ff:ff) tell 10.0.2.7, length 28


This is default behaviour,i just did 6 commands, no shutdown for interfaces, 
assign ip's, default gw and enable proxy arp on interfaces(btw seems they are 
enabled by default!), and it is CORRECT.

Conclusion:

1)Do not use default gateway for proxy-arp
2)Do not answer for ip's who doesn't belong to this interface (at least)

If i will put in network Linux machine, set default gw on other interface, and 
set proxy_arp - it will screw up whole network giving arp reply to all arp 
requests.
