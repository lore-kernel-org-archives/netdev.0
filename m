From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/12] Mellanox 100G mlx5 ethernet aRFS support
Date: Fri, 29 Apr 2016 01:36:30 +0300
Message-ID: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33141 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751731AbcD1WiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series adds accelerated RFS support for the mlx5e driver.
I have added one patch non-related to aRFS that fixes the rtnl_lock
warning mlx5 driver been getting since b7aade15485a ('vxlan: break dependency with netdev drivers')

aRFS support in details:

A direct TIR per RQ is now required in order to have the essential building blocks
for aRFS.  Today the driver has one direct TIR that forwards traffic to RQ[0] (core 0),
and one indirect TIR for RSS indirection table.  For that we've added one direct TIR
per RQ, e.g.: TIR[i] -> RQ[i] (core i).

Publicize Modify flow rule destination and reveal it in flow steering API, to have the 
ability to dynamically modify the destination TIR(core) for aRFS rules from the 
ethernet driver.

Initializing CPU reverse mapping to notify upper layer on internal receive queue cpu
mappings.

Some design refactoring for mlx5e ethernet driver flow tables and flow steering API.
Now the caller of create_flow_table can choose the level of the flow table, this way
we will create the mlx5e flow tables in a reversed order and connect them as we go, 
we create flow table[i+1] before flow table[i] to be able to set flow table[i + 1] as
a destination of flow table[i] once flow table[i] is created.
also we have split the main flow table in the following manner:
    - From before: RX packet had to visit two flow tables until it is delivered to its receive queue:
        RX packet -> vlan filter flow table -> main flow table.
        > vlan filter will check the packet vlan field is allowed.
        > main flow will check if the dest mac is allowed and will check the l3/l4 headers to 
        retrieve the RSS hash for steering the packet into its final receive queue.

    - Now main flow table is split into l2 dst mac steering table and ttc (traffic type classifier) table:
        RX packet -> vlan filter -> l2 table -> ttc table
        > vlan filter - same as before
        > L2 filter - filter packets according their destination mac address
        > ttc table - classify packet headers for RSS steering
            - L3/L4 classification rules to steer the packet according to thier headers hash
            - in case of none of the rules applies the packet is steered to RQ[0]

After the above refactoring all left to-do is to create aRFS flow table which will manage
aRFS steering rules to forward traffic to the desired RQ (core) and just connect the ttc 
table rules destinations to aRFS flow table.  

aRFS flow table in case of a miss will deliver the traffic to the core where the original 
ttc hash would have chosen.

TTC table is not initialized and enabled until the user explicitly asks to, i.e. setting the NETIF_F_NTUPLE
to ON.  This way there is no need for ttc table to forward traffic to aRFS table unless required.
When setting back to OFF aRFS flow table is disabled and disconnected.

Thanks,
Saeed

Maor Gottlieb (10):
  net/mlx5: Introduce modify flow rule destination
  net/mlx5: Set number of allowed levels in priority
  net/mlx5: Add user chosen levels when allocating flow tables
  net/mlx5: Support different attributes for priorities in namespace
  net/mlx5e: Refactor mlx5e flow steering structs
  net/mlx5e: Split the main flow steering table
  net/mlx5: Initializing CPU reverse mapping
  net/mlx5e: Create aRFS flow tables
  net/mlx5e: Add accelerated RFS support
  net/mlx5e: Enabling aRFS mechanism

Matthew Finlay (1):
  net/mlx5e: Call vxlan_get_rx_port() with rtnl lock

Tariq Toukan (1):
  net/mlx5e: Direct TIR per RQ

 drivers/infiniband/hw/mlx5/main.c                  |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  171 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  749 ++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   24 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 1060 +++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  346 ++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   46 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  149 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   18 +
 include/linux/mlx5/driver.h                        |    3 +
 include/linux/mlx5/fs.h                            |    9 +-
 15 files changed, 1736 insertions(+), 849 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
