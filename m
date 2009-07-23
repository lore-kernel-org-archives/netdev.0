From: Malcolm Scott <linux-netdev@malc.org.uk>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Thu, 23 Jul 2009 17:08:12 +0100 (BST)
Message-ID: <alpine.DEB.2.00.0907231656000.12037@callisto.malc.org.uk>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx> <49902E35.6060506@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pierre Ossman <drzeus-list@drzeus.cx>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helene.retrosnub.co.uk ([78.129.234.8]:39745 "EHLO
	helene.retrosnub.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbZGWQOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 12:14:16 -0400
In-Reply-To: <49902E35.6060506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(apologies for reviving an ancient thread, but I've hit this problem myself)

On Mon, 9 Feb 2009, Patrick McHardy wrote:

> Pierre Ossman wrote:
>> I'm having some problems with r8169 and vlans. The basic problem is
>> that pcap on eth1 gives me tagged packets, but in a form where it is
>> impossible to tell it is tagged. This is causing problems for dhcpd:
>> 
>> Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via 
>> eth1.2
>> Feb  6 20:04:22 asgard dhcpd: DHCPDISCOVER from 00:15:00:08:98:1f via eth1
>> Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.2.230 to 00:15:00:08:98:1f 
>> via eth1.2
>> Feb  6 20:04:23 asgard dhcpd: DHCPOFFER on 10.8.0.128 to 00:15:00:08:98:1f 
>> via eth1
>> Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from 
>> 00:15:00:08:98:1f via eth1.2
>> Feb  6 20:04:23 asgard dhcpd: DHCPACK on 10.8.2.230 to 00:15:00:08:98:1f 
>> via eth1.2
>> Feb  6 20:04:23 asgard dhcpd: DHCPREQUEST for 10.8.2.230 (10.8.2.254) from 
>> 00:15:00:08:98:1f via eth1: wrong network.
>> Feb  6 20:04:23 asgard dhcpd: DHCPNAK on 10.8.2.230 to 00:15:00:08:98:1f 
>> via eth1
>> 
>> I assume this is because the hardware supports vlans and handles all
>> the tag stripping.
>> 
>> (I've confirmed with tcpdump that the packets lack tags when they are
>> presented to userspace)
>> 
>> From what I can tell, I cannot fix this without rebuilding the kernel
>> and removing the acceleration support from the r8169 driver. Is there
>> some method I've overlooked?
>> 
>> Preferably, I'd like the kernel to expose to pcap what's on the wire
>> (i.e. accelerated vs non-accelerated looks the same from userspace). If
>> that means too much processing to be desirable, the next best thing
>> would be to simply not show tagged packets on the raw interface. The
>> ability to turn vlan acceleration on and off in the latter case would
>> also be desirable for network debugging.
>
> Current kernel version (I think starting with 2.6.28) relay the
> VLAN tag information to userspace through packet sockets. The
> current libpcap release from tcpdump.org (or the one Dave keeps
> in a git tree on kernel.org) supports reconstructing the tags.

So to clarify: as of 2.6.28, an app (e.g. dhcpd) listening on eth0 will by 
default see packets from all VLANs with tags removed; if it wishes to do 
otherwise, it should query the kernel for the VLAN tag of every packet and 
discard those with a tag?

Unless I misunderstand, this seems like absolutely the wrong behaviour: 
untagged packets are expected to be treated as from another VLAN just like 
any other, and should be kept separate (from userspace's perspective) from 
all tagged packets.  Prior to 2.6.28 this was indeed the case (on my NICs at 
least -- tg3 and others): listening on eth0, one would see the tagged 
packets with the tags still in place, so these would be correctly ignored by 
apps which were not specifically able to handle tagged packets.

In my case, this is manifesting as the DHCP misbehaviour which Pierre 
mentioned.  (ISC dhcp3d does not use libpcap, and does not query the packet 
socket for the VLAN tag, so it treats every VLAN's packets as for the 
default VLAN.)

-- 
Malcolm Scott
University of Cambridge Computer Laboratory
