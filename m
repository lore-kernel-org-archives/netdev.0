From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/2] net: l3mdev: Fix source address for unnumbered deployments
Date: Wed, 24 Feb 2016 11:47:01 -0800
Message-ID: <1456343223-17622-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36728 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbcBXTrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 14:47:12 -0500
Received: by mail-pf0-f181.google.com with SMTP id e127so18351695pfe.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 11:47:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter noted a use case where the source address selection fails
to pick an address from a VRF interface - unnumbered interfaces. The use
case has the VRF device as the VRF local loopback with addresses and
interfaces enslaved without an address themselves. e.g,

    ip addr add 9.9.9.9/32 dev lo
    ip link set lo up

    ip link add name vrf0 type vrf table 101
    ip rule add oif vrf0 table 101
    ip rule add iif vrf0 table 101
    ip link set vrf0 up
    ip addr add 10.0.0.3/32 dev vrf0

    ip link add name dummy2 type dummy
    ip link set dummy2 master vrf0 up

    --> note dummy2 has no address - unnumbered device

    ip route add 10.2.2.2/32 dev dummy2 table 101
    ip neigh add 10.2.2.2 dev dummy2 lladdr 02:00:00:00:00:02

ping to the 10.2.2.2 through the L3 domain:

    $ ping -I vrf0 -c1 10.2.2.2
    ping: Warning: source address might be selected on device other than vrf0.
    PING 10.2.2.2 (10.2.2.2) from 9.9.9.9 vrf0: 56(84) bytes of data.

picks up the wrong address -- the one from 'lo' not vrf0. And from tcpdump:
    12:57:29.449128 IP 9.9.9.9 > 10.2.2.2: ICMP echo request, id 2491, seq 1, length 64

This patch series changes address selection to only consider devices in
the same L3 domain and to use the VRF device as the L3 domains loopback.

    $ ping -I vrf0 -c1 10.2.2.2
    PING 10.2.2.2 (10.2.2.2) from 10.0.0.3 vrf0: 56(84) bytes of data.

>From tcpdump:
    12:59:25.096426 IP 10.0.0.3 > 10.2.2.2: ICMP echo request, id 2113, seq 1, length 64

Now the source address comes from vrf0.

David Ahern (1):
  net: l3mdev: address selection should only consider devices in L3
    domain

David Lamparter (1):
  net: l3mdev: prefer VRF master for source address selection

 include/net/l3mdev.h |  4 ++--
 net/ipv4/devinet.c   | 22 ++++++++++++++++++++++
 net/l3mdev/l3mdev.c  | 11 +++++++++--
 3 files changed, 33 insertions(+), 4 deletions(-)

-- 
2.1.4
