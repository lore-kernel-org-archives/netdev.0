From: Lukas Tribus <luky-37@hotmail.com>
Subject: tcpdump's capture filter: "vlan" doesn't match
Date: Thu, 16 Oct 2014 00:58:42 +0200
Message-ID: <DUB123-W23D5ECAD4869F9A799E1F6EDAA0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	=?iso-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Jesse Gross <jesse@nicira.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc1s5.hotmail.com ([157.55.0.204]:56735 "EHLO
	DUB004-OMC1S5.hotmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbaJOXDq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 19:03:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,



since 2.6.39 (including -rc1), tcpdump "vlan" capture filters don't mat=
ch
anymore. All 2.6.38 and older kernels are fine.


I reproduced this specifically on a r8169 NIC on 2.6.39-rc1, but I foun=
d
this problem initially on bnx2 and e1000e nics.


Howto reproduce: just tcpdump with a "not vlan", "vlan" or "vlan <vlani=
d>"
capture filter on a passive eth interface (dot1q/vlan/ip config not nec=
essary).

Actual behavior is that a "vlan [vlanid]" capture filter doesn't match =
the
(tagged) packet, and a "not vlan" capture filter matches everything.


Disabling rx-vlan-offloading via
ethtool -K eth0 rxvlan off

doesn't change anything.


Here we are filtering for "not vlan" and we can see that the matched fr=
ame
is vlan tagged:

# tcpdump -Uenc1 not vlan
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
22:03:39.077584 70:ca:9b:01:23:34> 00:18:f8:01:23:34, \
*ethertype 802.1Q (0x8100), length 70: vlan 7, p 0*, ethertype IPv4, \
192.168.47.9.443> 192.168.32.30.39436: Flags [.], ack 255248912, \
[...]
1 packet captured
169 packets received by filter
0 packets dropped by kernel
59 packets dropped by interface
#




As suggested here [1], we can pipe everything through another tcpdump
instance:
tcpdump -Uw - | tcpdump -en -r - vlan <vlanid>


But that is not something that works for my specific use-case (dedicate=
d
sniffer box, dedicated interface connected to a Cisco SPAN/mirror port,
un/single/double-tagged packets, remotely accessible via remote-pcap [2=
]).


The sniffer should also be able to:
- maintain the frame as-is, including dot1q, dot1p (preferably
=A0 without artificial recreation of header fields/values and including=
 CFI/DEI)
- "direct" capture filter based on vlan (not through multiple userspace
=A0 instances)

Kernel <=3D 2.6.38 perfectly satisfies those requirements.


Isn't disabling rx-vlan-offloading supposed to remedy those problems?




Thanks,

Lukas




[1] https://bugzilla.redhat.com/show_bug.cgi?id=3D498981
[2] https://github.com/frgtn/rpcapd-linux

 		 	   		  