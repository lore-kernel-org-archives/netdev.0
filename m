From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next, V3 0/2] net: force refragmentation for DF reassembed skbs
Date: Fri, 22 May 2015 16:32:49 +0200
Message-ID: <1432305171-21932-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38006 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756048AbbEVOdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

output path tests:

    if (skb->len > mtu) ip_fragment()

This breaks connectivity in one corner case:
 If the skb was reassembled, but has the DF bit set and ..
 .. its reassembled size is <= outdev mtu ..
 .. we will forward a DF packet larger than what the sender
    transmitted on wire.

If a router later in the path can't forward this packet, it will send an
icmp error in response to an mtu that the original sender never exceeded.

This changes ipv4 defrag/output path to

a) force refragmentation for DF reassembled skbs and
b) set DF bit on all fragments when refragmenting if it was set on original
frags.

tested via:
#!/usr/bin/python
from scapy.all import *
dip="10.23.42.2"
payload="A"*1400
packet=IP(dst=dip,id=12345,flags='DF')/UDP(sport=42,dport=42)/payload
frags=fragment(packet,fragsize=1200)
for fragment in frags:
    send(fragment)

Without this patch, we generate fragments without df bit set based
on the outgoing device mtu when fragmenting after forwarding, ie.

IP (ttl 64, id 12345, offset 0, flags [+, DF], proto UDP (17), length 1204)
    192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
IP (ttl 64, id 12345, offset 1184, flags [DF], proto UDP (17), length 244)
    192.168.7.1 > 10.23.42.2: ip-proto-17

on ingress will either turn into

IP (ttl 63, id 12345, offset 0, flags [+], proto UDP (17), length 1396)
    192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
IP (ttl 63, id 12345, offset 1376, flags [none], proto UDP (17), length 52)

(mtu 1400: We strip df and send larger fragment), or

IP (ttl 63, id 12345, offset 0, flags [DF], proto UDP (17), length 1428)
    192.168.7.1.42 > 10.23.42.2.42: [udp sum ok] UDP, length 1400

if mtu is 1500.  And in this case things break; router with a smaller mtu
will send icmp error, but original sender only sent packets <= 1204 byte.

With patch, we keep intent of such fragments and will emit DF-fragments
that won't exceed 1204 byte in size.

Joint work with Hannes Frederic Sowa.

Changes since v2:
 - split unrelated patches from series
 - rework changelog of patch #2 to better illustrate breakage
