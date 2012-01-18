From: Tore Anderson <tore@fud.no>
Subject: Re: [RFC] ipv6: =?UTF-8?Q?dst=5Fallfrag=28=29=20not=20taken=20into=20acco?=
 =?UTF-8?Q?unt=20by=20TCP?=
Date: Wed, 18 Jan 2012 15:43:02 +0100
Message-ID: <9903c7bcb83314b495e7378dae23e703@localhost>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop> <00f1ef555b452980aae95eb3028072f8@localhost> <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:47084 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757791Ab2AROnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 09:43:05 -0500
In-Reply-To: <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet

> Now I wonder if some RFC can allow us to send small frames without a
> frag header, since this frag header forces us to perform tx checksum in
> software.

Yes. In my opinion, the most correct thing to do would be to keep track
of the actual IPv6 Path MTU (the value indicated in the ICMPv6 Packet
Too Big message received) as a separate property that is added to the
routing cache, and to include the Fragment header only if you transmit
a packet that is larger than the PMTU.

So, let's say you get an ICMPv6 PTB with MTU=800. Then the resulting
host route added to the routing cache should contain both "mtu 1280"
as well as "pmtu 800". You can then safely omit the Fragmentation
header from any packet smaller than 800 bytes. You might of course then
get another ICMPv6 PTB with an even smaller MTU originated from an IPv4
router even further out in the path, which should then result in
lowering the cached pmtu value further, of course.

> > I guess 576 should be safe ?

I have difficulty determining whether or not the minimum permitted IPv4
MTU is 576 or 68 bytes, actually. Assuming it's the latter, by hard-
coding the former, you may end up in a situation where you'll be stuck
in a PMTUD loop - you'll be re-transmitting 576 bytes large packets
over and over again, while getting back ICMPv6 PTBs with an even lower
MTU value for each of the packets you transmit.

That said, you can add 20 bytes to whatever value you hard-code, as the
IPv6 header is 20 bytes larger than the IPv4 header. In other words,
596- and 88-byte large IPv6 packets will be translated into 576- or
68-byte large IPv4 packets.

Another way of solving it and avoiding the Fragmentation headers
altogether would be to allow the "route MTU" to drop below 1280 as a
result of Path MTU Discovery. I opened an enchancement bug report
requesting this:

https://bugzilla.kernel.org/show_bug.cgi?id=42599

Best regards,
-- 
Tore Anderson
