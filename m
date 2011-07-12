From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 21:38:51 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:26247 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab1GLCiw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 22:38:52 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If I understand your setup correctly, you have:
> 
> (servers)
>  |
>  +--------[eth0 <-br0-> eth1]------- internet
>  |
>  (clients)

Close.  Here's a better ASCII art picture.  There aren't really any
internal-->external clients.

Internet        firewall    Private LAN
----------------+******+---------+-------+
              eth0     eth1     NATed    H.323
               Bridge br0      servers  devices

The H.323 devices work better if they have real, public IP Addresses.
I've done them with NAT, but H.323 just works better if the devices
"think" they're directly connected to the Internet.  All the servers are
all on the physical private LAN side, physically behind the firewall.  

> Why not proxy ARP?

I used to use proxy ARP until I got burned really badly with what proxy
ARP really does - the NIC answers ARP requests (in proxy) for everyone
and anyone that asks with its own MAC address.  Think about that - proxy
ARP impersonates everyone and anyone on the LAN to which it's connected.


I had one of these in a colo center and for several hours, my box
Proxy-ARPed everyone and anyone on that same public network.  I don't
even like to think about how many public webservers I unintentionally
messed with that day.  Oh yes - and to make matters worse, that customer
had an IP load balancer behind my box nobody told me about and proxy ARP
messed that up too.  The stupid load balancer wouldn't clear its ARP
cache and had to be rebooted - and that took down a major website and
pretty much blew my only chance to do business with this customer.  All
in all, not one of my better days.  I decided right then and there, no
more proxy ARP. 

Bridging turns out to be a much cleaner and more polite way to do it.
Don't believe all the forum comments about the wonders of proxy-ARP.  

> Why not use a VLAN?

Because I really don't need one.  Plus it doesn't matter anyway - the
firewall can act as a router on a stick to go between my H.323 devices
and private IP servers.  With or without VLANs makes no difference in
this case.  

> You have a bit of a Frankennet there

I don't think so.  I have a single LAN with a couple of devices that
need public IP Addresses.  This isn't that unusual.  I have lots of
other sites doing it this way.  

> I must say that your bug report sounds more like a 
> forwarding-back-to-source-device IP-level problem.

I don't think it's an IP level problem.  I think it's a layer 2 problem
- and now I think the problem is, bridging is supposed to turn on
PROMISC mode and it didn't.  I had to do it by hand myself.  I never
paid attention to whether or not PROMISC mode was turned on with any of
the other ones like this I've done and never had a problem with it until
this one.  And as soon as I turned on PROMISC mode by hand, everything
worked as it should. If it was an IP problem, or routing problem, or
ruleset/filtering problem, why would PROMISC mode make any difference
one way or the other?

What I don't know yet is, is this a Fedora bug or a stock kernel bug?
Is anyone from Red Hat following this email list?

I think I will take a look at a few of my other bridged sites running
earlier versions and see if they turn on PROMISC mode on their bridged
NICs.  

- Greg

