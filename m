From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 0/5] mlxsw: spectrum_router: Add extack messages for RIF and VRF overflow
Date: Wed, 18 Oct 2017 09:56:51 -0700
Message-ID: <1508345816-25678-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:56613 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdJRQ5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:57:03 -0400
Received: by mail-pf0-f179.google.com with SMTP id b85so4377062pfj.13
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 09:57:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, exceeding the number of VRF instances or the number of router
interfaces either fails with a non-intuitive EBUSY:
    $ ip li set swp1s1.6 vrf vrf-1s1-6 up
    RTNETLINK answers: Device or resource busy

or fails silently (IPv6) since the checks are done in a work queue. This
set adds support for the address validator notifier to spectrum which
allows ext-ack based messages to be returned on failure.

To make that happen the IPv6 version needs to be converted from atomic
to blocking (patch 2), and then support for extack needs to be added
to the notifier (patch 3). Patch 1 reworks the locking in ipv6_add_addr
to work better in the atomic and non-atomic code paths. Patches 4 and 5
add the validator notifier to spectrum and then plumb the extack argument
through spectrum_router.

With this set, VRF overflows fail with:
   $ ip li set swp1s1.6 vrf vrf-1s1-6 up
   Error: spectrum: Exceeded number of supported VRF.

and RIF overflows fail with:
   $ ip addr add dev swp1s2.191 10.12.191.1/24
   Error: spectrum: Exceeded number of supported router interfaces.

v2 -> v3
- fix surround context of patch 4 which was altered by c30f5d012edf

v1 -> v2
- fix error path in ipv6_add_addr: reset rt to NULL (Ido comment) and
  add in6_dev_put on ifa once the hold has been done

RFC -> v1
- addressed various comments from Ido
- refactored ipv6_add_addr to allow ifa's to be allocated with
  GFP_KERNEL as requested by DaveM

David Ahern (5):
  ipv6: addrconf: cleanup locking in ipv6_add_addr
  net: ipv6: Make inet6addr_validator a blocking notifier
  net: Add extack to validator_info structs used for address notifier
  mlxsw: spectrum: router: Add support for address validator notifier
  mlxsw: spectrum_router: Add extack message for RIF and VRF overflow

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  15 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 162 +++++++++++++++------
 drivers/net/ipvlan/ipvlan_main.c                   |  14 +-
 include/linux/inetdevice.h                         |   1 +
 include/net/addrconf.h                             |   1 +
 net/ipv4/devinet.c                                 |   8 +-
 net/ipv6/addrconf.c                                | 129 +++++++++-------
 net/ipv6/addrconf_core.c                           |   9 +-
 9 files changed, 234 insertions(+), 109 deletions(-)

-- 
2.1.4
