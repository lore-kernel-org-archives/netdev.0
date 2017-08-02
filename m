From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] ipv4: fib: Provide per-nexthop offload indication
Date: Wed,  2 Aug 2017 09:56:00 +0200
Message-ID: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34026 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdHBH4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:10 -0400
Received: by mail-wm0-f68.google.com with SMTP id x64so6136394wmg.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Offload indication for IPv4 routes is currently set in the FIB info's
flags. When multipath routes are employed, this can lead to a route being
marked as offloaded although only one of its nexthops is actually
offloaded.

Instead, this patchset aims to proivde a higher resolution for the offload
indication and report it on a per-nexthop basis.

Example output from patched iproute:

$ ip route show 192.168.200.0/24
192.168.200.0/24
        nexthop via 192.168.100.2 dev enp3s0np7 weight 1 offload
        nexthop via 192.168.101.3 dev enp3s0np8 weight 1

And once the second gateway is resolved:

$ ip route show 192.168.200.0/24
192.168.200.0/24
        nexthop via 192.168.100.2 dev enp3s0np7 weight 1 offload
        nexthop via 192.168.101.3 dev enp3s0np8 weight 1 offload

First patch teaches the kernel to look for the offload indication in the
nexthop flags. Patches 2-5 adjust current capable drivers to provide
offload indication on a per-nexthop basis. Last patch removes no longer
used functions to set offload indication in the FIB info's flags.

Ido Schimmel (6):
  ipv4: fib: Set offload indication according to nexthop flags
  rocker: Provide offload indication using nexthop flags
  mlxsw: spectrum_router: Provide offload indication using nexthop flags
  mlxsw: spectrum_router: Don't check state when refreshing offload
    indication
  mlxsw: spectrum_router: Refresh offload indication upon group refresh
  ipv4: fib: Remove unused functions

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 73 ++++++++++++++++++----
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |  6 +-
 include/net/ip_fib.h                               | 13 ----
 net/ipv4/fib_semantics.c                           |  2 +
 4 files changed, 65 insertions(+), 29 deletions(-)

-- 
2.9.3
