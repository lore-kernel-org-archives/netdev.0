From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: NAT on a stick with ebtables
Date: Wed, 1 Feb 2012 21:50:50 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A04C46@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:30599 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab2BBEGC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 23:06:02 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have another bridging/routing situation.  This one has both a
Sonicwall VPN device and old Cisco VPN device behind my Linux
brouter/firewall.  Both the Sonicwall and Cisco need their outside NICs
to "think" they're really on the outside.  But I want them physically
behind my brouter - that way, all the traffic in and out goes through me
and I can get an accurate picture of what's going on at the border.
This brouter is on a Fedora 16 system.  

I am deathly afraid to go back to pure routing and try ip neigh add
proxy 1.2.248.61 dev em1 because the last time I tried proxy ARP here, I
spent several days only to learn that Cisco does not get along well with
a proxy ARP in front of it.  That Cisco will work behind a bridge, but
not behind any kind of proxy ARP router I've been able to put in front
of it.  

So I would like to keep this one bridged.

When I upgraded from Fedora 9 or so to Fedora 16, the scenario described
in the simplified ASCII art picture below broke. 

Internal LAN
192.168.3.nnn                       Firewall/
--+----------------+------------em3 Brouter em1----+---Internet
Internal      Web server         |           |   Gateway
user          192.168.3.111      +-----br0---+   1.2.248.49
192.168.3.nnn                      192.168.3.5
                                   1.2.248.50
                                   1.2.248.61

Firewall NICs em3 and em1 are bridged with bridge br0.  Bridge br0 has
the IP Addresses above, plus a few others not relevant to this problem.
NICs em3 and em1 do not have IP Addresses.  

1.2.248.61 is the public IP Address for the website at 192.168.3.111.
Inbound web requests DNAT to 192.168.3.111.

My internal user wants to access the website at 192.168.3.111 on her
laptop.  Sometimes the laptop is inside the 192.168.3.nnn subnet,
sometimes it's somewhere on the Internet.  I want to give my user a
consistent view of the website, so I handle it with NAT on the
firewall/brouter.  The idea is, no matter where she is, she can look at
the website using its public IP Address.

>From both inside and outside the internal LAN, my user connects to the
website using 1.2.248.61. I DNAT that web request to 192.168.3.111.  If
the request comes from inside the internal LAN, I also SNAT (MASQUERADE)
the request so the host at 3.111 "thinks" the request came from the
firewall/brouter and "knows" where to send back the reply. The web host
sends back the reply to the masqueraded 192.168.3.5, which should un-NAT
it and forward it back to the internal user.  NAT on a stick.  

This technique is well documented all over the place in netfilter and
I've used it for many years.  But it recently broke with bridging.
That's what I've been nagging about the past 7+ months.  

I think the bridge is sending packets out the wrong NIC.  If I put the
em3 NIC into PROMISC mode, then my technique above works, but PROPMISC
mode breaks other NAT scenarios.  My hunch is, something changed in the
order of how things get done between bridging and routing, because this
all worked just fine with earlier 2.4 and 2.6 kernels.  

That leads to the question - how do I regulate which physical NIC to
use, based on either a source or destination IP Address?  How do I
override the NIC that bridging wants to use and tell it to use the one I
want instead?  I know I am asking to regulate L2 stuff based on L3
fields but there must be a way to do this.  

Thanks

- Greg Scott
