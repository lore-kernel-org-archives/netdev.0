From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH for-net V2 00/12] net/mlx5_core: Enhance flow steering support
Date: Sun, 10 Jan 2016 10:39:37 +0200
Message-ID: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51233 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751210AbcAJIkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2016 03:40:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

v0 --> v1 changes:
  - fixed improperly formatted comments.
  - compare value of ib_spec->eth.mask.ether_type in network byte order
     in ('IB/mlx5: Add flow steering utilities').

v1 --> v2 changes:
  - made sure that service functions added in the IB driver are only static-fied 
    on the last commit, to make sure bisection with -Werror works fine.
 
v2 has been generated against net-next commit c9c9931 "Merge tag 
'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge"

The series is signed by Matan who was revently assigned to a maintainer for 
the mlx5_core and IB drivers (this is a 4.5-rc1 change to the maintainers file coming 
from the rdma tree) -- as such I didn't see a neeed to add my signature (Or).

This series adds three new functionalists to the driver flow-steering
infrastructure: auto-grouped flow tables, chaining of flow tables and 
updates for the root flow table.

1. Auto-grouped flow tables - Flow table with auto grouping management.
When a flow table is created, hints regarding the number of rule types
and the number of rules are given in advance. Thus, a flow table is
divided into #NUM_TYPES+1 groups each contains
(#NUM_RULES)/(#NUM_TYPES+1) rules. The first #NUM_TYPES parts are groups
which are filled if the added rule matches the group specification or
the group is empty. The last part is filled by rules that can't fit
any of the former groups.

2. Chaining flow tables - Flow tables from different priorities are chained
together, if there is no match in flow table of priority i we continue
searching for a match in priority i+1. This is both true if priorities
i and i+1 belongs to the same namespace or not.

3. Updating the root flow table - the root flow table is the flow table
with the lowest level. The hardware start searching for a match in the
root flow table and continue according to the matches it find along
the way.

The first usage for the new functionality is flow steering for user-space
ConnectX-4 offloaded HW Eth RX queues done through the mlx5 IB driver.

When the mlx5 core driver is loaded, it opens three flow namespaces:
1. By-pass namespace (used by mlx5 IB driver).
2. Kernel namespace (used in order to get packets to the networking stack
through mlx5 EN driver).
3. Leftovers namespace (used by mlx5 IB and future sniffer)

The series is built as follows:

Patch #1 introduces auto-grouped flow tables support.

Patch #2 add utility functions for finding the next and the previous
flow tables in different priorities. This is used in order to chain
the flow tables in a downstream patch.

Patch #3 introduces a firmware command for updating the root flow table.

Patch #4 introduces modify flow table firmware command, this command is used
when we want to change the next flow table of an existing flow table.
This is used for chaining flow tables as well.

Patch #5 connect/disconnect flow tables. This is actually the chaining
process when we want to link flow tables. This means that if we couldn't
find a match in the first flow table, we'll continue in the chained
flow table.

Patch #6 updates priority's attributes that is required for flow table
level allocation. We update both the max_fts (the number of allowed FTs
in the sub-tree of this priority) and the start_level (which is the first
level we'll assign to the flow-tables created inside the priority).

Patch #7 adds checking of required device capabilities. Some namespaces
could be only created if the hardware supports certain attributes.
This is especially true for the Bypass and leftovers namespaces. This
adds a generic mechanism to check these required attributes.

Patch #8 creates two additional namespaces:
	a. Bypass flow rules(has nine priorities)
	b. Leftovers packets(have one priority) - for unmatched packets.

Patch #9 re-factors ipv4/ipv6 match fields in the mlx5 firmware interface
header to be more clear.

Patch #10 exports the flow steering API for mlx5_ib usage

Patch #11 and #12 implements the required support in mlx5_ib in order
to support the RDMA flow steering verbs.

Regards,
Moni, Matan and Maor

Maor Gottlieb (12):
  net/mlx5_core: Introduce flow steering autogrouped flow table
  net/mlx5_core: Add utilities to find next and prev flow-tables
  net/mlx5_core: Managing root flow table
  net/mlx5_core: Introduce modify flow table command
  net/mlx5_core: Connect flow tables
  net/mlx5_core: Set priority attributes
  net/mlx5_core: Initialize namespaces only when supported by device
  net/mlx5_core: Enable flow steering support for the IB driver
  net/mlx5_core: Make ipv4/ipv6 location more clear
  net/mlx5_core: Export flow steering API
  IB/mlx5: Add flow steering utilities
  IB/mlx5: Add flow steering support

 drivers/infiniband/hw/mlx5/main.c                 | 460 ++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h              |  45 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  52 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 605 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  14 +
 include/linux/mlx5/device.h                       |   2 +
 include/linux/mlx5/fs.h                           |   8 +
 include/linux/mlx5/mlx5_ifc.h                     | 105 +++-
 9 files changed, 1222 insertions(+), 78 deletions(-)

-- 
1.8.3.1



*** BLURB HERE ***

Maor Gottlieb (12):
  net/mlx5_core: Introduce flow steering autogrouped flow table
  net/mlx5_core: Add utilities to find next and prev flow-tables
  net/mlx5_core: Managing root flow table
  net/mlx5_core: Introduce modify flow table command
  net/mlx5_core: Connect flow tables
  net/mlx5_core: Set priority attributes
  net/mlx5_core: Initialize namespaces only when supported by device
  net/mlx5_core: Enable flow steering support for the IB driver
  net/mlx5_core: Make ipv4/ipv6 location more clear
  net/mlx5_core: Export flow steering API
  IB/mlx5: Add flow steering utilities
  IB/mlx5: Add flow steering support

 drivers/infiniband/hw/mlx5/main.c                 | 463 +++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h              |  45 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  52 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 601 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  14 +
 include/linux/mlx5/device.h                       |   2 +
 include/linux/mlx5/fs.h                           |  18 +
 include/linux/mlx5/mlx5_ifc.h                     | 105 +++-
 9 files changed, 1233 insertions(+), 76 deletions(-)

-- 
2.3.7
