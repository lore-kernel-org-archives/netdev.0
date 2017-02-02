From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: [PATCH RFC 0/2] ipv6: IPv4-mapped on wire, :: dst address issue
Date: Thu,  2 Feb 2017 13:27:53 -0500
Message-ID: <cover.1485894457.git.jtleight@udel.edu>
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35840 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdBBS2G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:28:06 -0500
Received: by mail-qt0-f181.google.com with SMTP id k15so44901242qtg.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:28:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under some circumstances IPv6 datagrams are sent with IPv4-mapped IPv6
addresses as the source. Given an IPv6 socket bound to an IPv4-mapped
IPv6 address, and an IPv6 destination address, both TCP and UDP will
will send packets using the IPv4-mapped IPv6 address as the source. Per
RFC 6890 (Table 20), IPv4-mapped IPv6 source addresses are not allowed
in an IP datagram. The problem can be observed by attempting to
connect() either a TCP or UDP socket, or by using sendmsg() with a UDP
socket. The patch is intended to correct this issue for all socket
types.

linux follows the BSD convention that an IPv6 destination address
specified as in6addr_any is converted to the loopback address.
Currently, neither TCP nor UDP consider the possibility that the source
address is an IPv4-mapped IPv6 address, and assume that the appropriate
loopback address is ::1. The patch adds a check on whether or not the
source address is an IPv4-mapped IPv6 address and then sets the
destination address to either ::ffff:127.0.0.1 or ::1, as appropriate.

Jon

Jonathan T. Leighton (2):
  ipv6: Inhibit IPv4-mapped src address on the wire.
  ipv6: Handle IPv4-mapped src to in6addr_any dst.

 net/ipv6/datagram.c   | 14 +++++++++-----
 net/ipv6/ip6_output.c |  3 +++
 net/ipv6/tcp_ipv6.c   | 11 ++++++++---
 net/ipv6/udp.c        |  4 ++++
 4 files changed, 24 insertions(+), 8 deletions(-)

-- 
2.7.4
