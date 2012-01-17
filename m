From: Tore Anderson <tore@fud.no>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 21:03:35 +0100
Message-ID: <4F15D417.4050005@fud.no>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:59870 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755555Ab2AQUXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 15:23:05 -0500
In-Reply-To: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet

> Bugzilla reference :
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=42572

Hi, and thanks for taking an interest in this issue!

I've got some general comments regarding running IPv6-only Linux servers
behind stateless IPv4/IPv6 translators. (They are not strictly related
to the above bug, but not completely off-topic either I hope.)

1) The Linux kernel doesn't allow reducing the effective IPv6 link MTU
(as recorded in the routing cache) to anything less than 1280. This
means that it can end up in a situation where the effective IPv6 link
MTU is greater than the actual IPv6 Path MTU. In the PCAP in the
bugzilla, they are 1280 and 1279, respectively. However, the kernel
doesn't appear to record the actual Path MTU anywhere, instead setting
the allfrag feature.

While this is perfectly legal behaviour according to the RFC, from an
operational point of view it would have been nice if there were some way
(e.g. a sysctl) to tell the kernel to also actually allow an ICMPv6 PTB
to reduce the effective IPv6 link MTU to values less than 1280 (at least
down to the minimum IPv4 MTU + 20 bytes). That would have avoided the
need for the allfrag feature to come into play completely.

The RFC allows for this behaviour, too.

2) Since the kernel doesn't keep track of the actual Path MTU (if it's
lower than 1280), when the allfrag feature gets set on a route, *every*
packet gets a fragmentation header. (Which is to be expected, really,
given it's name.) However, this means that even tiny packets such as a
TCP SYN/ACK gets the fragmentation header added. This is clearly not
particularly useful.

If the kernel had kept track of the effective Path MTU, and only
included the IPv6 Fragmentation header on packets that were larger than
it *only*, this wouldn't have been a problem. (Alternatively, if it
allowed the effective link MTU to drop below 1280 that would also have
avoided this problem.)

3) There seems to be a bug related to generating the TCP checksum of
SYN/ACK packets to destinations with the allfrag features set. I just
submitted a bug report about this:

https://bugzilla.kernel.org/show_bug.cgi?id=42595

This makes the allfrag feature pretty much useless for me, as I can only
successfully establish a single TCP session from a client behind a <1280
MTU link for the entire lifetime of the routing cache entry.

Best regards,
-- 
Tore Anderson
