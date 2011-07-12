From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Tue, 12 Jul 2011 09:30:05 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net>
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
Received: from mail.infrasupportetc.com ([216.160.2.132]:33771 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876Ab1GLOaG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 10:30:06 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> First of all, I still can't find your kernel version in any of your
> mails. Can you please repeat the uname -a output of the affected box?

Woops - sorry - I never posted it, that's why you didn't see it.  Here
it is:

[root@ehac-fw2011 firewall-scripts]# uname -a
Linux ehac-fw2011 2.6.35.6-48.fc14.i686.PAE #1 SMP Fri Oct 22 15:27:53
UTC 2010 i686 i686 i386 GNU/Linux

It's just as Red Hat delivered it.


> The VLAN saves you the SNAT on your clients traffic towards the NATed
> services, because the traffic back from those NATed services goes
> through the firewall, which will apply its conntrack entries.

I don't see it that way.  I have a couple of devices with public IP
Addresses and most with "normal" private IP Addresses.  Those public IP
devices can easily be on the same Ethernet segment and in the same
collision domain as the private ones.  There's no good reason to
separate them at this particular site.  Oh - I think see what you're
thinking - the words, "public IP Address", lead to a wrong conclusion
that those devices really are **public**.  Just because some of the
devices have public IP Addresses does **NOT**  mean they're completely
accessible to the public.  Just like for, say, web servers, we NAT TCP
port 80 and block the rest - for these public IP Address devices at this
site, I ACCEPT TCP 1720 and use the H.323 conntrack module to handle
that traffic because H.323 does not get along easily with NAT.  Pretty
much the only difference between the public IP stuff and the private IP
stuff is, I NAT for the private IP stuff and just ACCEPT traffic I want
to let in/out for the public IP stuff.  There's no reason to separate
the public IP stuff and private IP stuff with VLANs.  

Anyway, at this site, the H.323 stuff is the **reason**  why I need a
bridge, so the H.323 stuff is only indirectly related to the problem.  I
have other sites with different reasons for various systems to have real
public IP Addresses. 


> Also, what you're doing is a case of _layer 3_ routing of packets that
> arrive at an interface - br0 - back out to the same interface - br0.

Yes, absolutely, when internal users need to access the NATed websites
using public IP Addresses instead of their private IP Addresses.
Classic router on a stick topology, but using DNAT and MASQUERADE.

Let me try to describe it this way.  Forget about the reason I need a
bridge.  I have a good reason this site is bridged and have now
hopefully presented a reasonable case why I need one.  

I have a public website at private IP Address 192.168.10.2.  The
firewall DNATs TCP port 80 for public IP Address aa.bb.115.151 to
192.168.10.2.  Most of this traffic will come in from the Internet.  But
I also want my **internal** users to have the same experience as the
rest of the world when viewing this website, so that traffic will come
in from the private LAN.  I have good reasons for this - one biggie is
so my internal users can see website changes as the rest of the world
sees them. I know I can simulate this with a private DNS server, but I
don't like multiple versions of DNS floating around.  So I choose to do
it with layer 3 routing and some fancy DNAT and SNAT (really
MASQUERADing) at the firewall.  

This all worked for several years, right up until I put in a replacement
based on Fedora 14.  By now, the script I have in place at this site is
battle hardened and has been in service for close to 10 years and many
hardware upgrades. 

And it broke with Fedora 14.

> Either way I still don't understand your setup. Are you using
ebtables?

Yes to ebtables.  I use ebtables to mark packets so I know which
interface they come in on.  Anything coming in from the Internet gets a
mark of 1.  Anything coming in on the LAN side gets a mark of 2.  You
have me kind of afraid to post the code....but I'll paste it in below
anyway.  btw, I posted code earlier because one reply asked me to do so.

.
.
.
echo "Flushing and zeroing all ebtables tables and chains"
$EBTABLES -t broute -F
$EBTABLES -t broute -Z
$EBTABLES -t filter -F
$EBTABLES -t filter -Z
$EBTABLES -t nat -F
$EBTABLES -t nat -Z

#
# Use ebtables to mark packets based on the in/out interface.
# 1 - (bit 0 set) for packets entering on the Internet physical
interface
# 2 - (bit 1 set) for packets entering on the trusted physical interface
# 3 - (bits 0 and 1) for packets exiting via the Internet physical
interface
# (Kernel 2.6.23 or so changed the order of iptables/ebtables going out,
so
# marking outbound packets is meaningless now.)

echo "Marking bridged packets at layer 2 for later layer 3 filtering."
$EBTABLES -t broute -A BROUTING -i $INET_IFACE \
        -j mark --mark-set 1 --mark-target CONTINUE
$EBTABLES -t broute -A BROUTING -i $TRUSTED1_IFACE \
        -j mark --mark-set 2 --mark-target CONTINUE
.
.
.

> Is there a separate third DMZ network? What is $DMZ_IFACE?

That DMZ network is not relevant and I should not have included any
reference to it.  It's eth2 and the NIC is in the box but nothing is
connected to it.  And it's not part of the bridge.  It's an empty NIC
that we may use in the future, but right now not relevant.  


> Where is your private IP that's facing towards the clients?

I don't know what this question means.  The setup is a traditional
Public<-->firewall<-->private topology, as the ASCII art I posted
earlier shows.  But some of the stuff on the private side needs public
IP Addresses, so the firewall is a bridge plus a router, not just a
router.  


> So it works when you switch the bridge members into PROMISC? (not the
> bridge itself!)

No, the br0 bridge device itself.  After a bunch of troubleshooting,
below is literally the single one and only change I needed to make this
work again.

.
.
.
echo "  Putting $BR_IFACE into promiscuous mode"
# This fixes a bug forwarding packets bound for external IP Addresses
# from the private LAN.

ip link set $BR_IFACE promisc on
.
.
.

I don't think I should need to do this by hand and I never needed it
before.  That's why it took me weeks and plenty of help with the
Netfilter folks to find it.  Something apparently changed with bridging.


Reading through some of the replies to this post, I decided to look and
see what happens with the physical ethnnn devices when I add them to a
bridge, so I looked at a couple of other sites with similar setups.
I've never had any need to dig into this before because it all just
worked.  

- Greg
