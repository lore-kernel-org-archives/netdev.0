From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/5] mlxsw: spectrum_router: Add extack messages for RIF and VRF overflow
Date: Fri, 13 Oct 2017 16:02:08 -0700
Message-ID: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:51969 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdJMXCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:02:23 -0400
Received: by mail-pf0-f182.google.com with SMTP id n14so11459519pfh.8
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:02:23 -0700 (PDT)
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
to blocking (patch 1), and then support for extack needs to be added
to the notifier (patch 2). Patches 3 and 4 add the validator notifier
to spectrum and then plumb the extack argument.

With this set, VRF overflows fail with:
   $ ip li set swp1s1.6 vrf vrf-1s1-6 up
   Error: spectrum: Exceeded number of supported VRF.

and RIF overflows fail with:
   $ ip addr add dev swp1s2.191 10.12.191.1/24
   Error: spectrum: Exceeded number of supported router interfaces.

Changes since RFC
- addressed various comments from Ido
- refactored ipv6_add_addr to allow ifa's to be allocated with
  GFP_KERNEL as requested by DaveM

Ido: given the changes in patch 1 and the impact to what is now
     patch 2 I dropped your Reviewed-by tag from patch 2.

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
 net/ipv6/addrconf.c                                | 122 +++++++++-------
 net/ipv6/addrconf_core.c                           |   9 +-
 9 files changed, 228 insertions(+), 108 deletions(-)

-- 
2.1.4
