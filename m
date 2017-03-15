From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/9] mlxsw: Enable VRF offload
Date: Wed, 15 Mar 2017 12:05:03 +0100
Message-ID: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36455 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752861AbdCOLFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:16 -0400
Received: by mail-wr0-f196.google.com with SMTP id l37so1588564wrc.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Packets received from netdevs enslaved to different VRF devices are
forwarded using different FIB tables. In the Spectrum ASIC this is
achieved by binding different router interfaces (RIFs) to different
virtual routers (VRs). Each RIF represents an enslaved netdev and each
VR has its own FIB table according to which packets are forwarded.

The first three patches add helpers to check if the FIB rule's selector
matches all packets and extend the FIB notification chain to include the
rule's info as part of the RULE_{ADD,DEL} events. This allows offloading
drivers to sanitize the rules they don't support and flush their tables.

The fourth patch introduces a small change in the VRF driver to allow
capable drivers to more easily offload VRFs.

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
the intended behavior. Changes in v2 allow user to properly re-order the
default rules without triggering the abort mechanism.

Changes in v2:
* Drop default rule indication and allow re-ordering of default rules
  (David Ahern).
* Remove ifdef around 'struct fib_rule_notifier_info' and drop redundant
  dependency on IP_MULTIPLE_TABLES from rocker and mlxsw.
* Add David's Acked-by to the fourth patch.
* Remove netif_is_vrf_master() and use netif_is_l3_master() instead
  (David Ahern).

Ido Schimmel (9):
  net: fib_rules: Check if selector matches all packets
  ipv4: fib_rules: Add notifier info to FIB rules notifications
  ipv4: fib_rules: Dump FIB rules when registering FIB notifier
  net: vrf: Set slave's private flag before linking
  mlxsw: spectrum_router: Associate RIFs with correct VR
  mlxsw: spectrum_router: Don't destroy RIF if L3 slave
  mlxsw: spectrum_router: Add support for VRFs
  mlxsw: spectrum_router: Add support for VRFs on top of bridges
  mlxsw: spectrum_router: Don't abort on l3mdev rules

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 71 +++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  8 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 99 +++++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c          | 26 +++++-
 drivers/net/vrf.c                                  |  8 +-
 include/net/fib_rules.h                            |  1 +
 include/net/ip_fib.h                               | 12 +++
 net/core/fib_rules.c                               | 14 +++
 net/ipv4/fib_rules.c                               | 42 +++++++--
 9 files changed, 261 insertions(+), 20 deletions(-)

-- 
2.7.4
