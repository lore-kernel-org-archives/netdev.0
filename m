From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/12] mlxsw: Add support for offloading IPv4 multicast routes
Date: Thu, 21 Sep 2017 08:43:26 +0200
Message-ID: <20170921064338.1282-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:48517 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbdIUGnk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 02:43:40 -0400
Received: by mail-wm0-f46.google.com with SMTP id r68so12570810wmg.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 23:43:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

This patchset introduces offloading of the kernel IPv4 multicast router
logic in the Spectrum driver.

Patches 1-4 update ipmr to use the FIB notification chain for both MFC and
VIF notifications, and patches 7-11 update the Spectrum driver to register
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
which are not, patch 5 introduces a per-route offload indication similar to
IPv4 and IPv6 routes which is sent to the user via the RTNetlink interface.

The Spectrum driver multicast router offloading support, which is
introduced in patches 7 and 8, is divided into two parts:
 - The hardware logic which abstracts the Spectrum hardware and provides a
   simple API for the upper levels.
 - The offloading logic which gets the MFC and VIF notifications from the
   kernel and updates the hardware using the hardware logic part.

Finally, the last patch makes the Spectrum router logic not ignore the
multicast FIB notifications and call the corresponding functions in the
multicast router offloading logic.

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
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c  | 1012 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h  |  133 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c |  828 ++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.h |   43 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  205 +++-
 include/linux/mroute.h                             |   43 +
 include/net/fib_notifier.h                         |    2 +
 include/net/netns/ipv4.h                           |    3 +
 net/ipv4/ipmr.c                                    |  209 +++-
 11 files changed, 2472 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.h

-- 
2.9.5
