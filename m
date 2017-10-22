From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: Add support for non-equal-cost multi-path
Date: Sun, 22 Oct 2017 23:11:42 +0200
Message-ID: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55706 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932108AbdJVVLw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so6357625wmu.4
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

In the device, nexthops are stored as adjacency entries in an array
called the KVD linear (KVDL). When a multi-path route is hit the
packet's headers are hashed and then converted to an index into KVDL
based on the adjacency group's size and base index.

Up until now the driver ignored the `weight` parameter for multi-path
routes and allocated only one adjacency entry for each nexthop with a
limit of 32 nexthops in a group. This set makes the driver take the
`weight` parameter into account when allocating adjacency entries.

First patch teaches dpipe to show the size of the adjacency group, so
that users will be able to determine the actual weight of each nexthop.
The second patch refactors the KVDL allocator, making it more receptive
towards the addition of another partition later in the set.

Patches 3-5 introduce small changes towards the actual change in the
sixth patch that populates the adjacency entries according to their
relative weight.

Last two patches finally add another partition to the KVDL, which allows
us to allocate more than 32 entries per-group and thus support more
nexthops and also provide higher accuracy with regards to the requested
weights.

Ido Schimmel (8):
  mlxsw: spectrum_dpipe: Add adjacency group size
  mlxsw: spectrum: Better represent KVDL partitions
  mlxsw: spectrum: Add ability to query KVDL allocation size
  mlxsw: spectrum_router: Store weight in nexthop struct
  mlxsw: spectrum_router: Prepare for large adjacency groups
  mlxsw: spectrum_router: Populate adjacency entries according to
    weights
  mlxsw: spectrum: Increase number of linear entries
  mlxsw: spectrum: Add another partition to KVD linear

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  15 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  12 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   |  46 +++-
 .../net/ethernet/mellanox/mlxsw/spectrum_kvdl.c    | 291 ++++++++++++++++++---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 179 ++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |   2 +-
 6 files changed, 484 insertions(+), 61 deletions(-)

-- 
2.9.5
