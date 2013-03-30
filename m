From: ko-zu <causeless@gmail.com>
Subject: BUG: IPv6: ipv6_bind fails on implicitly-assigned address
Date: Sun, 31 Mar 2013 06:29:44 +0900
Message-ID: <CAMdqG7Wci6HD19rc9u4RK-_Wdh3pqQvQ7b3J5O=2SJs9NeyTJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:52146 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391Ab3C3V3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 17:29:45 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so608138eek.36
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 14:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current Any-IP support for IPv6, introduced with this commit
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ab79ad14a2d51e95f0ac3cef7cd116a57089ba82
, allows to assign whole subnet to host but current implemantation
does not allow binding assigned address to socket without IP_FREEBIND
sockopt.
When an ipv6 address was assigned as Any-IP, ipv6_bind() fails with
EADDRNOTAVAIL error because ipv6_chk_addr() does not consider Any-IP
as locally hosted.

To reproduce this bug,

# assign whole subnet to host
ip -4 route add local 192.0.2.0/24 dev lo
ip -6 route add local 2001:db8::/32 dev lo

python -c '
import socket
IP_FREEBIND = 15

print "IPv4 without IP_FREEBIND"
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("192.0.2.123", 10000))

print "IPv6 with IP_FREEBIND"
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_IP, IP_FREEBIND, 1)
s.bind(("2001:db8::1234", 10000))

print "IPv6 without IP_FREEBIND"
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.bind(("2001:db8::5678", 10000))
print "should success without error."
'
