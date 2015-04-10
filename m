From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/3] net: cap size to original frag size when refragmenting
Date: Sat, 11 Apr 2015 00:16:26 +0200
Message-ID: <1428704189-31247-1-git-send-email-fw@strlen.de>
Cc: kaber@trash.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59126 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751911AbbDJWQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series alters ipv4 and ipv6 fragmentation to ensure that we do not
increase the size of the original fragments when refragmenting.

For IPv4, we only do this when DF bit was set on original fragments since
path mtu discovery doesn't happen otherwise.

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

on ingress will turn into

IP (ttl 63, id 12345, offset 0, flags [+], proto UDP (17), length 1396)
    192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
IP (ttl 63, id 12345, offset 1376, flags [none], proto UDP (17), length 52)

(mtu is 1400, we strip df and send larger fragment), or

IP (ttl 63, id 12345, offset 0, flags [DF], proto UDP (17), length 1428)
    192.168.7.1.42 > 10.23.42.2.42: [udp sum ok] UDP, length 1400

if mtu is 1500.

The latter is worse since we keep DF, so anything in the path that has smaller
mtu will send icmp error; but original sender never sent packets larger
than 1204 byte.

With patch, we keep the intent of such fragments and will emit DF-fragments that
won't exceed 1204 byte in size.

IPv6 has similar issue so respect the maximum seen fragment size there as well.
