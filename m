From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Sat, 25 Mar 2017 08:35:34 +0100
Message-ID: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33769 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750718AbdCYHfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:35:46 -0400
Received: by mail-wr0-f195.google.com with SMTP id 20so1394829wrx.0
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:35:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

While doing the hardware offloading process much of the hardware
specifics cannot be presented. An example for such is the routing
LPM algorithm which differ in hardware implementation from the
kernel software implementation. The only information the user receives
is whether specific route is offloaded or not, but he cannot really
understand the underlying implementation nor get the specific statistics
related to that process.

Another example is ACL offload using TC which is commonly implemented
using TCAM memory. Currently there is no capability to gain visibility
into the TCAM structure and to debug suboptimal resource allocation.

This patchset introduces capability for exporting the ASICs pipeline
abstraction via devlink infrastructure, which should serve as an
complementary tool. This infrastructure allows the user to get visibility
into the ASIC by modeling it as a set of match/action tables.

The main objects defined:
Table - abstraction for a single pipeline stage. Contains the
        available match/actions and counter availability.
Entry - entry in a specific table with specific matches/actions
        values and dedicated counter.
Header/field - tuples which describes the tables behavior.

As an example one of the ASIC's L3 blocks will be modeled. The egress
rif (router interface) table is the final step in the L3 pipeline
processing which does match on the internal rif index which was
determined before by the routing logic. The erif table determines
whether to forward or drop the packet and updates the corresponding
rif L3 statistics.

To expose this internal resources a special metadata header will
be introduced that describes the internal information gathered by
the ASIC's pipeline and contains the following fields: rif_port_index,
forward and drop.

Some internal hardware resources have direct mapping to kernel
objects. For example the rif_port_index is mapped to the net-devices
ifindex. By providing this mapping the users gains visibility into
the offloading process.

Follow-up work will include exporting more L3 tables which will give
visibility into the routing process.

First stage is adding support for dpipe in devlink. Next add support
in spectrum driver. Finally implement egress router interface
(erif) table for spectrum ASIC as an example.

Arkadi Sharshevsky (8):
  devlink: Support for pipeline debug (dpipe)
  mlxsw: reg: Add counter fields to RITR register
  mlxsw: spectrum: Add placeholder for dpipe
  mlxsw: spectrum: Add definition for egress rif table
  mlxsw: reg: Add Router Interface Counter Register
  mlxsw: spectrum: Support for counters on router interfaces
  mlxsw: spectrum_router: Add rif helper functions
  mlxsw: spectrum: Add Support for erif table entries access

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 178 +++++
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  10 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c |   9 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 351 +++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |  43 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 170 +++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  58 ++
 include/net/devlink.h                              | 259 +++++++
 include/uapi/linux/devlink.h                       |  67 +-
 net/core/devlink.c                                 | 836 +++++++++++++++++++++
 13 files changed, 1984 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h

-- 
2.7.4
