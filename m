From: Chris Severance <aur.severach@spamgourmet.com>
Subject: iputils ping -I interface no longer functional for ipv4 addresses
 (unknown iface)
Date: Tue, 24 May 2016 02:18:37 -0400
Message-ID: <1464070717.4154112.616715209.09C1370C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44710 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704AbcEXGSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 02:18:39 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 1534D20CE2
	for <netdev@vger.kernel.org>; Tue, 24 May 2016 02:18:38 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

% ping -V
ping utility, iputils-s20160308
# https://www.archlinux.org/packages/core/x86_64/iputils/

% ping -I enp3s0 192.168.50.1
PING 192.168.50.1 (192.168.50.1) from 192.168.50.10 enp3s0: 56(84) bytes
of data.
64 bytes from 192.168.50.1: icmp_seq=1 ttl=64 time=0.127 ms

% ip addr
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel
state UP group default qlen 1000
    inet 192.168.50.10/24 brd 192.168.50.255 scope global enp3s0
    inet6 2001:470:x:x:x:x:x:3227/64 scope global noprefixroute dynamic

% ping -I 192.168.50.10 192.168.50.1
ping: unknown iface 192.168.50.10

Works in: ping-20121221
Doesn't work in: ping-20150815
Works in: traceroute-20150815 -s 

Here are more examples of things that work and don't.

% ping -I 192.168.50.10 www.ebay.com
ping: unknown iface 192.168.50.10
# ebay is ipv4 at this time. The current connection is downloading at
capacity and is super slow. I can tell from the delay that ping does the
DNS lookup before declaring that the interface is unknown. Seems like it
would know a little sooner than that.

% ping -I 192.168.50.1 www.google.com
PING www.google.com(ord08s10-in-x04.1e100.net
(2607:f8b0:4009:804::2004)) from :: : 56 data bytes
64 bytes from ord08s10-in-x04.1e100.net (2607:f8b0:4009:804::2004):
icmp_seq=2 ttl=57 time=1128 ms
# Note that the typing error 192.168.50.1 is an invalid interface and a
mismatched ipv4 to ipv6 ping. Let's try that again.

% ping -I 192.168.50.10 www.google.com
PING www.google.com(ord08s10-in-x04.1e100.net
(2607:f8b0:4009:804::2004)) from :: : 56 data bytes
64 bytes from ord08s10-in-x04.1e100.net (2607:f8b0:4009:804::2004):
icmp_seq=1 ttl=57 time=638 ms
# Now a valid interface but not valid for use with an ipv6 address. Ping
should have stopped, or corrected it to a valid interface, or selected
the A record instead of showing :: as the source address.

% ping -I 2001:470:x:x:x:x:x:3227 www.google.com
PING www.google.com(ord08s10-in-x04.1e100.net
(2607:f8b0:4009:804::2004)) from 2001:470:x:x:x:x:x:3227 : 56 data bytes
64 bytes from ord08s10-in-x04.1e100.net (2607:f8b0:4009:804::2004):
icmp_seq=1 ttl=57 time=333 ms
# Ping from a filled out SLAAC address works.

% ping www.google.com
PING www.google.com(ord08s10-in-x04.1e100.net
(2607:f8b0:4009:804::2004)) 56 data bytes
64 bytes from ord08s10-in-x04.1e100.net (2607:f8b0:4009:804::2004):
icmp_seq=1 ttl=57 time=167 ms

Unfortunately support for ipv6 addressing seems erratic. Moving to
another machine running with a short form ipv6 address from DHCPv6 we
see this.

$ ping -V
ping utility, iputils-s20160308

$ ip addr
3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state
UP group default qlen 1000
    inet 128.0.0.6/24 brd 128.0.0.255 scope global eno1
    inet 128.0.0.66/24 brd 128.0.0.255 scope global secondary eno1
    inet6 2601:x:x:x::6/128 scope global dynamic
# Here 128.0.0.0/24 is being used as a private IP. I'm not in Romania.

$ ping -I 2601:x:x:x::6 www.ebay.com
ping: SO_BINDTODEVICE: Invalid argument
# Perhaps this is intended behavior for trying to ping an ipv4 address
from an ipv6 address. If so the error message should be improved or
amended. The messages and behavior should be consistent among all 4/6
address mismatches.

$ ping -I '[2601:x:x:x::6]' www.ebay.com
ping: invalid source address [2601:x:x:x::6]
# The bracketed form should not be an invalid address.

$ ping -I 2601:x:x:x::6 www.google.com
PING www.google.com(ord30s25-in-x2004.1e100.net
(2607:f8b0:4009:80e::2004)) from 2601:x:x:x::6 : 56 data bytes
64 bytes from ord30s25-in-x2004.1e100.net (2607:f8b0:4009:80e::2004):
icmp_seq=1 ttl=52 time=40.9 ms

$ ping www.google.com
PING www.google.com(ord30s25-in-x04.1e100.net
(2607:f8b0:4009:80e::2004)) 56 data bytes
64 bytes from ord30s25-in-x04.1e100.net (2607:f8b0:4009:80e::2004):
icmp_seq=1 ttl=52 time=30.9 ms

Here on Windows 7 we can see that the error message is minimally
acceptable and ping accepts both bracketed and non bracketed forms.

C:\>ping -S [2601:x:x:x::132] www.ebay.com
The source and destination address have different address family.

C:\>ping -S 2601:x:x:x::132 ipv6.google.com
Pinging ipv6.l.google.com [2607:f8b0:4009:80e::200e] from
2601:x:x:x::132 with 32 bytes of data:
Reply from 2607:f8b0:4009:80e::200e: time=28ms

C:\>ping -S [2601:405:8404:a5e0::132] ipv6.google.com
Pinging ipv6.l.google.com [2607:f8b0:4009:80e::200e] from
2601:x:x:x::132 with 32 bytes of data:
Reply from 2607:f8b0:4009:80e::200e: time=30ms

C:\>ping -S 128.0.0.132 www.ebay.com
Pinging e9428.b.akamaiedge.net [23.52.41.158] from 128.0.0.132 with 32
bytes of data:
Reply from 23.52.41.158: bytes=32 time=43ms TTL=56

C:\>ping -S [2601:x:x:x::132] www.google.com
Pinging www.google.com [2607:f8b0:4009:80e::2004] from 2601:x:x:x::132
with 32 bytes of data:
Reply from 2607:f8b0:4009:80e::2004: time=28ms

C:\>ping -S 128.0.0.132 www.google.com
Pinging www.google.com [216.58.192.196] from 128.0.0.132 with 32 bytes
of data:
Reply from 216.58.192.196: bytes=32 time=45ms TTL=53

Notice that Windows ping ignores or uses the AAAA record as appropriate
to perform the ping in the manner requested. The error only comes when I
force the issue.

C:\>ping -S 128.0.0.132 ipv6.google.com
The source and destination address have different address family.

iputils-ping does not select the correct A/AAAA record.

$ ping -I 128.0.0.6 www.google.com
PING www.google.com(ord30s25-in-x2004.1e100.net
(2607:f8b0:4009:80e::2004)) from :: : 56 data bytes
64 bytes from ord30s25-in-x2004.1e100.net (2607:f8b0:4009:80e::2004):
icmp_seq=1 ttl=52 time=22.4 ms

Looks to me like there is a missing not (!) in the ipv4 code that is
permitting ip4->ip6 pings and denying ip4->ip4 pings. The ipv6 code
seems to work though the error messages are not informative and
inconsistent. Go ahead and leave the error messages you have as they are
useful for program analysis. Just add new ones that are clear about what
the problem is.

ping should be enhanced to accept the bracketed form and pick the right
A/AAAA record to match the source address.

The goal is to test if split access is working properly.
http://superuser.com/questions/325128/how-can-i-ensure-outbound-traffic-uses-the-same-interface-as-that-of-inbound-tra

Debian Bug report logs - #819204
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=819204

The only similar messages are from 2012.

http://marc.info/?l=linux-netdev&m=135419837306218&w=2
List:       linux-netdev
Subject:    iputils: ping -I <iface>
From:       Jan Synacek <jsynacek () redhat ! com>
Date:       2012-11-29 14:12:43
