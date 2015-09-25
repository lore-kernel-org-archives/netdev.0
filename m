From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 00/11] net: L3 master device
Date: Thu, 24 Sep 2015 18:20:56 -0600
Message-ID: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34591 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbIYAVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:21:14 -0400
Received: by padhy16 with SMTP id hy16so87539870pad.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:21:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF device is essentially a Layer 3 master device used to associate
netdevices with a specific routing table and to influence FIB lookups
via 'ip rules' and controlling the oif/iif used for the lookup.

This series generalizes the VRF into L3 master device, l3mdev. Similar
to switchdev it has a Kconfig option and separate set of operations
in net_device allowing it to be completely compiled out if not wanted.
The l3mdev methods rely on the 'master' aspect and use of
netdev_master_upper_dev_get_rcu to retrieve the master device from a
given netdevice if it is enslaved to an L3_MASTER.

The VRF device is converted to use the l3mdev operations. At the end the
vrf_ptr is no longer and removed, as are all direct references to VRF.
The end result is a much simpler implementation for VRF.

Thanks to Nikolay for suggestions (eg., use of the master linkage which
is the key to making this work) and to Roopa, Andy and Shrijeet for
early reviews.


Changes since RFC:

- Changed IFF_L3MDEV to IFF_L3MDEV_MASTER after Nikolay pointed out a problem
  with my flag changes (uniquely identifying a L3MDEV master device versus an
  enslaved device like a bond that will also be a master device)

- Rolled in icmp fix for panic when flipping from vrf functions to l3mdev

- Moved netif_is_l3_master check into l3mdev_get_rtable

David Ahern (11):
  net: Introduce L3 Master device abstraction
  net: Rename IFF_VRF_MASTER to IFF_L3MDEV_MASTER
  net: Add support for l3mdev ops to VRF driver
  net: Replace vrf_master_ifindex{,_rcu} with l3mdev equivalents
  net: Replace vrf_dev_table and friends
  net: Replace calls to vrf_dev_get_rth
  net: Remove the now unused vrf_ptr
  net: Remove vrf header file
  net: Move netif_index_is_l3_master to l3mdev.h
  net: Rename FLOWI_FLAG_VRFSRC to FLOWI_FLAG_L3MDEV_SRC
  net: Add netif_is_l3_slave

 MAINTAINERS               |   8 ++-
 drivers/net/Kconfig       |   1 +
 drivers/net/vrf.c         |  89 +++++++++++++----------
 include/linux/netdevice.h |  43 ++++-------
 include/net/flow.h        |   2 +-
 include/net/l3mdev.h      | 151 +++++++++++++++++++++++++++++++++++++++
 include/net/route.h       |   5 +-
 include/net/vrf.h         | 178 ----------------------------------------------
 net/Kconfig               |   1 +
 net/Makefile              |   3 +
 net/ipv4/af_inet.c        |   4 +-
 net/ipv4/fib_frontend.c   |  12 ++--
 net/ipv4/fib_trie.c       |   2 +-
 net/ipv4/icmp.c           |   8 +--
 net/ipv4/ip_fragment.c    |   6 +-
 net/ipv4/ip_output.c      |   2 +-
 net/ipv4/route.c          |  15 ++--
 net/ipv4/udp.c            |   4 +-
 net/ipv4/xfrm4_policy.c   |   8 +--
 net/ipv6/xfrm6_policy.c   |   8 +--
 net/l3mdev/Kconfig        |  10 +++
 net/l3mdev/Makefile       |   5 ++
 net/l3mdev/l3mdev.c       |  79 ++++++++++++++++++++
 23 files changed, 359 insertions(+), 285 deletions(-)
 create mode 100644 include/net/l3mdev.h
 delete mode 100644 include/net/vrf.h
 create mode 100644 net/l3mdev/Kconfig
 create mode 100644 net/l3mdev/Makefile
 create mode 100644 net/l3mdev/l3mdev.c

-- 
2.3.8 (Apple Git-58)
