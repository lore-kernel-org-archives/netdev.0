From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] net: vrf: Handle ipv6 multicast and link-local addresses
Date: Mon, 13 Jun 2016 13:44:16 -0700
Message-ID: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33903 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423347AbcFMUo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:44:26 -0400
Received: by mail-pf0-f170.google.com with SMTP id 62so49556197pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:44:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 multicast and link-local addresses require special handling by the
VRF driver. Rather than using the VRF device index and full FIB lookups,
packets to/from these addresses should use direct FIB lookups based on
the VRF device table.

Multicast routes do not make sense for the L3 master device directly.
Accordingly, do not add mcast routes for the device, and the VRF driver
should fail attempts to send packets to ipv6 mcast addresses on the
device (e.g, ping6 ff02::1%<vrf> should fail)

With this change connections into and out of a VRF enslaved device work
for multicast and link-local addresses (icmp, tcp, and udp).  e.g.,

1. packets into VM with VRF config:
    ping6 -c3 fe80::e0:f9ff:fe1c:b974%br1
    ping6 -c3 ff02::1%br1
    ssh -6 fe80::e0:f9ff:fe1c:b974%br1

2. packets going out a VRF enslaved device:
    ping6 -c3 fe80::18f8:83ff:fe4b:7a2e%eth1
    ping6 -c3 ff02::1%eth1
    ssh -6 root@fe80::18f8:83ff:fe4b:7a2e%eth1

David Ahern (3):
  net: l3mdev: Remove const from flowi6 arg to get_rt6_dst
  net: ipv6: Do not add multicast route for l3 master devices
  net: vrf: Handle ipv6 multicast and link-local addresses

 drivers/net/vrf.c       | 100 +++++++++++++++++++++++++++++++++++++++++++++---
 include/net/ip6_route.h |   2 +
 include/net/l3mdev.h    |   6 +--
 net/ipv6/addrconf.c     |   2 +-
 net/ipv6/icmp.c         |   2 +-
 net/ipv6/route.c        |   5 ++-
 net/l3mdev/l3mdev.c     |   2 +-
 7 files changed, 105 insertions(+), 14 deletions(-)

-- 
2.1.4
