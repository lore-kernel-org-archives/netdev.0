From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Tue, 12 Jul 2011 11:28:49 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:35101 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738Ab1GLQ2u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 12:28:50 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> P.S.: you blissfully ignored my "ip neigh add proxy 1.2.3.4" note :)

Sorry - didn't ignore it, just didn't reply back to it.  I'll look into
it. What I've read about this before has all been kind of vague.  Does
this mean I proxy ARP only for IP Address 1.2.3.4?  So somebody sends an
ARP whois 1.2.3.4, I'll answer with 1.2.3.4. is at {My MAC Address}?  If
so, then I agree, not nearly as evil as just setting proxy_arp.  

> Whoa. And here I was almost ashamed of running 2.6.38. I'm sorry, but
I
> think you need to go bug RedHat.

Yeah, maybe.  OK, probably.  This was such a bizarre problem - I started
with Netfilter and those guys suggested I try here.  At least now I
understand the problem lots better than before. And it's not like I can
just go and update dozens of kernels at dozens of sites all the time
when a new kernel comes out.  

> You totally misunderstood me. I'm suggesting the separate VLAN for
your
> servers which have private IPs but which have services exposed to the
> internet (and your clients) on public IPs through NAT.

Ahh - OK.  The challenge with many small sites is, economic reality.
That same server that hosts the public ftp and websites also hosts all
the internal Windows file/print services.  It's the only server at this
site, so it has several roles.  I would love to build a real DMZ network
and put all the public facing stuff in there, but I don't have money for
multiple servers.  This will become even more difficult to separate when
we go to virtual servers and clustered hosts.  

> Your H323 stuff is totally unrelated.

Agreed.  Wholeheartedly.  

> Yes. Your problem seems to be between the private-IP clients in your
> network and your private-IP servers if I understand correctly.

Yes.  Dead-bang, right on target.  

> Yes. And because it is a router, it as an IP from the private subnet
> your clients are in. My question was: what device is that IP on?

Ahh - eth1 is the private LAN side, 192.168.10.1.  All the NATed LAN
stuff and all the workstations are in the 192.168.10.0/24 subnet and
connected to eth1.  Eth0 is the Internet side.  The Internet side has
the firewall NIC, a cable, and the Internet router.  That's it.
Everything is connected to the LAN side.  

> No. You're jumping to conclusions. You're affecting the "top" bridge
> device's promiscuity. I would say that the effect you're seeing is in
> the IP stack above it, caused by it now promiscuously handling packets
> that are dropped otherwise.

Well they were sure dropped before I set it to PROMISC mode, that's for
sure. And it all worked with the earlier version.  That's why this feels
like a layer 2 issue.  If it was an IP issue, why didn't it break
several years ago when I first set it up?

Does bridging make everything a little more complex and delicate to set
up?  Well, yeah.  And some of the netfilter stuff has been a moving
target over the years.  

I don't see how ICMP redirects matter.  Comparing
/proc/sys/net/ipv4/conf/*/accept_redirects with this version and an
older one at another site - all identical.  ../all/accept_recdirects is
0, the rest are all 1.  Shared media and ARP settings -
/proc/sys/net/ipv4/conf/*/shared_media - all 1 for all interfaces.
There are a zillion arp settings.  Looking at
/proc/sys/net/ipv4/conf/*/*arp* - all are 0 in both the other older site
and this newer site.  

Curiously - at one of my other older sites, apparently br0 is not in
promisc mode.  But I don't think these guys do any of the stick routing
stuff.  I wonder if these guys have the problem but we don't see it
because they never try it?

[root@NSSSS-fw1 ~]# more /sys/class/net/br0/flags
0x1003
[root@NSSSS-fw1 ~]#
[root@NSSSS-fw1 ~]# more /proc/version
Linux version 2.6.32.11-99.fc12.i686.PAE
(mockbuild@x86-05.phx2.fedoraproject.org) (gcc version 4.4.3 20100127
(Red Hat 4.4.3-4) (GCC) )
#1 SMP Mon Apr 5 16:15:03 EDT 2010
[root@NSSSS-fw1 ~]#
[root@NSSSS-fw1 ~]# uname -a
Linux NSSSS-fw1 2.6.32.11-99.fc12.i686.PAE #1 SMP Mon Apr 5 16:15:03 EDT
2010 i686 i686 i386 GNU/Linux
[root@NSSSS-fw1 ~]#


Here is a much older bridged site based on Fedora 9 and I'm sure these
guys use my stick routing stuff.  Look at the difference in ..br0/flags.


[root@lme-fw2 ~]#  more /sys/class/net/br0/flags
0x1103
[root@lme-fw2 ~]#
[root@lme-fw2 ~]# more /proc/version
Linux version 2.6.25-14.fc9.i686 (mockbuild@) (gcc version 4.3.0
20080428 (Red H
at 4.3.0-8) (GCC) ) #1 SMP Thu May 1 06:28:41 EDT 2008
[root@lme-fw2 ~]#
[root@lme-fw2 ~]# uname -a
Linux lme-fw2 2.6.25-14.fc9.i686 #1 SMP Thu May 1 06:28:41 EDT 2008 i686
i686 i386 GNU/Linux

I can still get my hands on the old box at the site in question.  I
guess it couldn't hurt to fire it up and look at its br0 flags.  

- Greg

