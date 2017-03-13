From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/10] mlxsw: Enable VRF offload
Date: Mon, 13 Mar 2017 08:35:26 +0100
Message-ID: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33120 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbdCMHfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:35:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id n11so8324556wma.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:35:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Packets received from netdevs enslaved to different VRF devices are
forwarded using different FIB tables. In the Spectrum ASIC this is
achieved by binding different router interfaces (RIFs) to different
virtual routers (VRs). Each RIF represents an enslaved netdev and each
VR has its own FIB table according to which packets are forwarded.

The first three patches mark the default FIB rules and extend the FIB
notification chain to include the rule's info as part of the
RULE_{ADD,DEL} events. This allows offloading drivers to sanitize the
rules they don't support and flush their tables.

Patches 4-5 introduce small changes in the VRF driver to allow capable
drivers to more easily offload VRFs.

Finally, the last patches gradually add support for VRFs in the mlxsw
driver. First, on top of port netdevs, stacked LAG and VLAN devices and
then on top of bridges.

Some limitations I would like to point out:

1) The old model where 'oif' / 'iif' rules were programmed for each L3
master device isn't supported. Upon insertion of these rules the driver
will flush its tables and forwarding will be done by the kernel instead.
It's inferior in every way to the single 'l3mdev' rule, so this shouldn't
be an issue.

2) Inter-VRF routes pointing to a VRF device aren't offloaded. Packets
hitting these routes will be forwarded by the kernel. Inter-VRF routes
pointing to netdevs enslaved to a different VRF are offloaded.

3) There's a small discrepancy between the kernel's datapath and the
device's. By default, packets forwarded by the kernel first do a lookup
in the LOCAL table and then in the VRF's table (assuming no match). In
the device, lookup is done only in the VRF's table, which is probably
the intended behavior.

Ido Schimmel (10):
  net: fib_rules: Add default rule indication
  ipv4: fib_rules: Add notifier info to FIB rules notifications
  ipv4: fib_rules: Dump FIB rules when registering FIB notifier
  net: Add netif_is_vrf_master helper
  net: vrf: Set slave's private flag before linking
  mlxsw: spectrum_router: Associate RIFs with correct VR
  mlxsw: spectrum_router: Don't destroy RIF if L3 slave
  mlxsw: spectrum_router: Add support for VRFs
  mlxsw: spectrum_router: Add support for VRFs on top of bridges
  mlxsw: spectrum_router: Don't abort on l3mdev rules

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 71 ++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  8 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 89 +++++++++++++++++++++-
 drivers/net/ethernet/rocker/Kconfig                |  2 +-
 drivers/net/ethernet/rocker/rocker_main.c          | 15 +++-
 drivers/net/vrf.c                                  | 10 ++-
 include/linux/netdevice.h                          |  8 ++
 include/net/fib_rules.h                            |  3 +-
 include/net/ip_fib.h                               |  7 ++
 net/core/fib_rules.c                               |  1 +
 net/ipv4/fib_rules.c                               | 32 ++++++--
 12 files changed, 224 insertions(+), 23 deletions(-)

-- 
2.7.4
