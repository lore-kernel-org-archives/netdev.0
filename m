From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 00:22:55 +0300
Message-ID: <200907030022.55186.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907012201.13760.denys@visp.net.lb> <m11voyzu3y.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36800 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbZGBVXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 17:23:12 -0400
In-Reply-To: <m11voyzu3y.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 July 2009 23:51:29 Eric W. Biederman wrote:
>
> I just looked at the kernel code in a bit more detail as well as some
> examples. With routing properly setup it appears largely fool proof.
> The relevant piece in arp_process appears to be:
>
>              if (addr_type == RTN_UNICAST  && rt->u.dst.dev != dev &&
>
> Which says if when we consult the routing tables we would route the
> packet out an interface that it did not come in by do the whole
> proxy arp thing.
>
> Which says to me you do not have a route to the machine which
> is getting a address conflict on the network segment on which it
> is located.
>
> In summary the evidence I have suggests your routing is misconfigured.
>
> Eric
It just have default route. Using it in proxy_arp clearly VIOLATE RFC!

I did small simulated setup.

Example:
default via 10.0.1.1 dev eth1
10.0.0.0/24 dev eth0  proto kernel  scope link  src 10.0.0.2
10.0.1.0/24 dev eth1  proto kernel  scope link  src 10.0.1.2

eth0 attached to my tap0

defaulthost ~ # sysctl -w net.ipv4.conf.eth0.proxy_arp=1
net.ipv4.conf.eth0.proxy_arp = 1

Testing

home ~ # arping -I tap0 10.0.1.6
ARPING 10.0.1.6 from 10.0.0.1 tap0
Unicast reply from 10.0.1.6 [52:54:00:12:34:56]  85.706ms
Unicast reply from 10.0.1.6 [52:54:00:12:34:56]  0.683ms
^CSent 2 probes (1 broadcast(s))
Received 2 response(s)

!!! Correct. Thats why i need proxy_arp, i can reach hosts in eth1

home ~ # arping -I tap0 5.6.7.8
ARPING 5.6.7.8 from 10.0.0.1 tap0
Unicast reply from 5.6.7.8 [52:54:00:12:34:56]  353.697ms
Unicast reply from 5.6.7.8 [52:54:00:12:34:56]  0.740ms
Unicast reply from 5.6.7.8 [52:54:00:12:34:56]  0.697ms
^CSent 3 probes (1 broadcast(s))
Received 3 response(s)

!!! Not correct. It uses default route as reference "where i can route", which 
violates RFC.
Laptop with ip 5.6.7.8 (have nothing to do to with this router) with Windows 
XP will not be able to work. He will get ip conflict.
Network , for example, is on unmanaged switches, so i cannot isolate it from 
this router.

If i do:
defaulthost ~ # sysctl -w net.ipv4.conf.eth1.medium_id=2
net.ipv4.conf.eth1.medium_id = 2
defaulthost ~ # sysctl -w net.ipv4.conf.eth0.medium_id=2
net.ipv4.conf.eth0.medium_id = 2


home ~ # arping -I tap0 5.6.7.8
ARPING 5.6.7.8 from 10.0.0.1 tap0
^CSent 3 probes (3 broadcast(s))
Received 0 response(s)

Correct. Laptop will not get ip conflict

home ~ # arping -I tap0 10.0.1.6
ARPING 10.0.1.6 from 10.0.0.1 tap0
^CSent 3 probes (3 broadcast(s))
Received 0 response(s)

Not correct. Oops, i cannot talk with 10.0.1.6 anymore, and proxy_arp supposed 
to help me with this.

If i set different medium id - it will be same as default, 0. 
Any ideas how medium_id will help here?


So once more again, i dont mind proxy_arp main purprose to help devices to 
communicate in different physical networks. But if it gives answers to ARP 
announce it is WRONG. Because ARP answer for ARP announce(gratitous), it 
should only answer if it really knows about ip conflict. In current setup - 
if it have ip on this machine. 

ARP announce main puprose to update ARP cache AND to check for possible IP 
conflicts. proxy_arp current behavior will just screw this idea even without 
default issue.

If i have two networks proxy arp'ed
10.0.0.0/24 physical segment
10.0.1.0/24 physical segment

proxy_arp host between them, so users can set on their laptops /22 and 
communicate freely like they are in one segment.

Some user with XP on laptop with ip 10.0.0.66/22 will come to 10.0.1.0/24 
physical segment. As second he will turn on his laptop - proxy_arp host will 
give him incorrect answer to his ARP announce "10.0.0.66 (ff:ff:ff:ff:ff:ff) 
tell 10.0.0.66", it will tell "Reply 10.0.0.66 is-at 52:54:00:12:34:56" - 
that IP is busy. And thats wrong. arp_proxy should help hosts to communicate, 
but should not give incorrect answers that ip is taken.
