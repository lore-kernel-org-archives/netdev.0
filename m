From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 0/9] mlx5 improved flow steering management
Date: Thu, 10 Dec 2015 17:12:36 +0200
Message-ID: <1449760365-23622-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53736 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754073AbbLJPNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 10:13:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

First two patches fixes some minor issues in recently
introduced SRIOV code.

The other seven patches modifies the driver's code that 
manages flow steering rules with Connectx-4 devices.

Basic introduction:

The flow steering device specification model is composed of the following entities:

Destination (either a TIR/Flow table/vport), where TIR is RSS end-point, vport 
is the VF eSwitch port in SRIOV.
 		
Flow table entry (FTE) - the values used by the flow specification		
Flow table group (FG) - the masks used by the flow specification		
Flow table (FT) - groups several FGs and can serve as destination

The flow steering software entities:

In addition to the device objects, the software have two more objects:

Priorities - group several FTs. Handles order of packet matching.

Namespaces - group several priorities. Namespace are used in order to 
isolate different usages of steering (for example, add two separate
namespaces, one for the NIC driver and one for E-Switch FDB).

The base data structure for the flow steering management is a tree and 
all the flow steering objects such as (Namespace/Flow table/Flow Group/FTE/etc.) 
are represented as a node in the tree, e.g.:
Priority-0 -> FT1 -> FG -> FTE -> TIR (destination)
Priority-1 -> FT2 -> FG->  FTE -> TIR (destination)

Matching begins in FT1 flow rules and if there is a miss on all the FTEs 
then matching continues on the FTEs in FT2.

The new implementation solves/improves the following
issues in the current code:

1) The new impl. supports multiple destinations, the search for existing rule with
   the same matching value is performed by the flow steering management.
   In the current impl. the E-switch FDB management code needs to search 
   for existing rules before calling to the add rule function.

2) The new impl. manages the flow table level, in the current implementation the 
   consumer states the flow table level when new flow table is created without 
   any knowledge about the levels of other flow tables.

3) In the current impl. the consumer can't create or destroy flow
   groups dynamically, the flow groups are passed as argument to the create 
   flow table API. The new impl. exposes API for create/destroy flow group.

The series is built as follows:

Patch #1 add flow steering API firmware commands.

Patch #2 add tree operation of the flow steering tree: add/remove node,
initialize node and take reference count on a node.

Patch #3 add essential algorithms for managing the flow steering.

Patch #4 Initialize the flow steering tree, flow steering initialization is based 
on static tree which illustrates the flow steering tree when the driver is loaded.

Patch #5 is the main patch of the series. It introduce the flow steering API.

Patch #6 Expose the new flow steering API and remove the old one.
The Ethernet flow steering follows the existing implementation,
but uses the new steering API.

Patch #7 Rename en_flow_table.c to en_fs.c in order to be aligned with
the new flow steering files.



Maor Gottlieb (7):
  net/mlx5_core: Introduce flow steering firmware commands
  net/mlx5_core: Add flow steering base data structures
  net/mlx5_core: Add flow steering lookup algorithms
  net/mlx5_core: Introduce flow steering API
  net/mlx5_core: Flow steering tree initialization
  net/mlx5: Use flow steering infrastructure for mlx5_en
  net/mlx5e: Rename en_flow_table.c to en_fs.c

Saeed Mahameed (2):
  net/mlx5: Fix query E-Switch capabilities
  net/mlx5e: Assign random MAC address if needed

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   23 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 1046 -----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 1224 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    7 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  291 +----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   15 +-
 .../net/ethernet/mellanox/mlx5/core/flow_table.c   |  422 -------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  239 ++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   65 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 1047 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  155 +++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |    9 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    3 +
 include/linux/mlx5/driver.h                        |    2 +
 include/linux/mlx5/flow_table.h                    |   63 -
 include/linux/mlx5/fs.h                            |   93 ++
 include/linux/mlx5/mlx5_ifc.h                      |   32 +-
 19 files changed, 2939 insertions(+), 1805 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
 delete mode 100644 include/linux/mlx5/flow_table.h
 create mode 100644 include/linux/mlx5/fs.h
