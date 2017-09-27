From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 00/12] mlxsw: Add support for offloading IPv4 multicast routes
Date: Wed, 27 Sep 2017 08:23:10 +0200
Message-ID: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32951 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdI0GXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:25 -0400
Received: by mail-wm0-f66.google.com with SMTP id m127so10553682wmm.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

This patch-set introduces offloading of the kernel IPv4 multicast router
logic in the Spectrum driver.

The first patch makes the Spectrum driver ignore FIB notifications that are
not of address family IPv4 or IPv6. This is needed in order to prevent
crashes while the next patches introduce the RTNL_FAMILY_IPMR FIB
notifications.

Patches 2-5 update ipmr to use the FIB notification chain for both MFC and
VIF notifications, and patches 8-12 update the Spectrum driver to register
to these notifications and offload the routes.

Similarly to IPv4 and IPv6, any failure will trigger the abort mechanism
which is updated in this patch-set to eject multicast route tables too.

At this stage, the following limitations apply:
 - A multicast MFC route will be offloaded by the driver if all the output
   interfaces are Spectrum router interfaces (RIFs). In any other case
   (which includes pimreg device, tunnel devices and management ports) the
   route will be trapped to the CPU and the packets will be forwarded by
   software.
 - ipmr proxy routes are not supported and will trigger the abort
   mechanism.
 - The MFC TTL values are currently treated as boolean: if the value is
   different than 255, the traffic is forwarded to the interface and if the
   value is 255 it is not forwarded. Dropping packets based on their TTL isn't
   currently supported.

To allow users to have visibility on which of the routes are offloaded and
which are not, patch 6 introduces a per-route offload indication similar to
IPv4 and IPv6 routes which is sent to the user via the RTNetlink interface.

The Spectrum driver multicast router offloading support, which is
introduced in patches 8 and 9, is divided into two parts:
 - The hardware logic which abstracts the Spectrum hardware and provides a
   simple API for the upper levels.
 - The offloading logic which gets the MFC and VIF notifications from the
   kernel and updates the hardware using the hardware logic part.

Finally, the last patch makes the Spectrum router logic not ignore the
multicast FIB notifications and call the corresponding functions in the
multicast router offloading logic.

---
v2->v3:
 - Move the ipmr_rule_default function definition to be inside the already
   existing CONFIG_IP_MROUTE_MULTIPLE_TABLES ifdef block (patch 6)
 - Remove double =0 initialization in spectrum_mr.c (patch 7)
 - Fix route4 allocation size (patch 7)
v1->v2:
 - Add comments for struct fields in mroute.h
 - Take the mrt_lock while dumping VIFs in the fib_notifier dump callback
 - Update the MFC lastuse field too

Yotam Gigi (12):
  fib: notifier: Add VIF add and delete event types
  ipmr: Add reference count to MFC entries
  ipmr: Add FIB notification access functions
  ipmr: Send FIB notifications on MFC and VIF entries
  net: ipmr: Add MFC offload indication
  net: mroute: Check if rule is a default rule
  mlxsw: spectrum: Add the multicast routing offloading logic
  mlxsw: spectrum: Add the multicast routing hardware logic
  mlxsw: spectrum: router: Squash the default route table to main
  mlxsw: spectrum_router: Add multicast routes notification handling
    functionality
  mlxsw: spectrum: Notify multicast router on RIF MTU changes
  mlxsw: spectrum: router: Don't ignore IPMR notifications

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    3 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |    2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c  | 1014 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h  |  133 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c |  828 ++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.h |   43 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  205 +++-
 include/linux/mroute.h                             |   45 +
 include/net/fib_notifier.h                         |    2 +
 include/net/netns/ipv4.h                           |    3 +
 net/ipv4/ipmr.c                                    |  213 +++-
 11 files changed, 2480 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.h

-- 
2.9.5
