From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] net: vrf: Add support for local traffic to local addresses
Date: Thu,  2 Jun 2016 13:15:09 -0700
Message-ID: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33757 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932220AbcFBUQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 16:16:41 -0400
Received: by mail-pf0-f182.google.com with SMTP id b124so35099791pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 13:16:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for locally originated traffic to VRF-local addresses,
be it addresses on enslaved devices or addresses on the VRF device:

$ ip addr show dev red
33: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65536 qdisc pfifo_fast state UP group default qlen 1000
    link/ether be:00:53:b5:e4:25 brd ff:ff:ff:ff:ff:ff
    inet 1.1.1.1/32 scope global red
       valid_lft forever preferred_lft forever
    inet6 1111:1::1/128 scope global
       valid_lft forever preferred_lft forever

$ ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP group default qlen 1000
    link/ether 02:e0:f9:79:34:bd brd ff:ff:ff:ff:ff:ff
    inet 10.100.1.1/24 brd 10.100.1.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 2100:1::1/120 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::e0:f9ff:fe79:34bd/64 scope link
       valid_lft forever preferred_lft forever

$ ping -c1 -I red 10.100.1.1
    ping: Warning: source address might be selected on device other than red.
    PING 10.100.1.1 (10.100.1.1) from 10.100.1.1 red: 56(84) bytes of data.
    64 bytes from 10.100.1.1: icmp_seq=1 ttl=64 time=0.057 ms

$ ping -c1 -I red 1.1.1.1
PING 1.1.1.1 (1.1.1.1) from 1.1.1.1 red: 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=64 time=0.136 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.136/0.136/0.136/0.000 ms

$ ping6 -c1 -I red  2100:1::1
ping6: Warning: source address might be selected on device other than red.
PING 2100:1::1(2100:1::1) from 2100:1::1 red: 56 data bytes
64 bytes from 2100:1::1: icmp_seq=1 ttl=64 time=0.167 ms

--- 2100:1::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.167/0.167/0.167/0.000 ms

$ ping6 -c1 -I red 1111::1
PING 1111::1(1111::1) from 1111:1::1 red: 56 data bytes
64 bytes from 1111::1: icmp_seq=1 ttl=64 time=0.187 ms

--- 1111::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.187/0.187/0.187/0.000 ms

This change also enables use of loopback address on the VRF device:
$ ip addr add dev red 127.0.0.1/8

$ ping -c1 -I red 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 red: 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.058 ms

David Ahern (3):
  net: vrf: Minor refactoring for local address patches
  net: vrf: ipv4 support for local traffic to local addresses
  net: vrf: ipv6 support for local traffic to local addresses

 drivers/net/vrf.c | 234 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 201 insertions(+), 33 deletions(-)

-- 
2.1.4
