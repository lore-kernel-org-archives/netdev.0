From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/11] Mellanox 100G mlx5 seamless error recovery
Date: Fri,  9 Sep 2016 17:35:16 +0300
Message-ID: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35502 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752859AbcIIOhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Mohamad improves the driver load/unload flows
to seamlessly handle pci errors and device internal errors recovery
reset flows.

Current pci and internal error handling is too heavy and is done
with a full restart of the driver by unregistering mlx5 interfaces
(mlx5e netedevs and mlx5_ib) which will cause losing all the current
interfaces and mlx5 core configurations.

To improve this, we add new callback functions of mlx5 interface 
object (attach/detach) to be called upon reset flows when errors are
detected rather than calling register and unregister interfaces.

On their side, interfaces such as (mlx5e and mlx5_ib) can choose to implement
those callback, if not, the old heavy reset will be called for that interface.

For non-interface mlx5 modules such as sriov and eswitch, we refactored 
and reorganized the code in a way that the software state objects are created 
only once on driver load.  Those software state objects are kept upon reset recovery
flows and only freed once on driver unload. On seamless soft reset flows, only
hardware resources are released on stop and re-allocated on start according to the 
current soft state.

In this series only mlx5e interface implements attach/detach callbacks
so that the netdevice will be kept alive on reset. On detach only hardware resources 
are released and the netdevice will be marked as detached to the stack. Once
attached again it will re-allocate the hardware resources according to the current
netdevice state, and all the configurations and the software state will be kept or restored
after recovery.

Note: I will be out of office all next week, in case of any updates
or V2 is required, Tariq will post the new series, I hope it is ok.

Thanks,
Saeed.

Mohamad Haj Yahia (11):
  net/mlx5: Skip waiting for vf pages in internal error
  net/mlx5: SRIOV core code refactoring
  net/mlx5: Introduce attach/detach to interface API
  net/mlx5: Split the load/unload flow into hardware and software flows
  net/mlx5: Implement SRIOV attach/detach flows
  net/mlx5: Implement eswitch attach/detach flows
  net/mlx5: Align sriov/eswitch modules with the new load/unload flow.
  net/mlx5: Implement vports admin state backup/restore
  net/mlx5e: Implement mlx5e interface attach/detach callbacks
  net/mlx5e: Restore vlan filter after seamless reset
  net/mlx5: Organize device list API in one place

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/dev.c      | 345 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  38 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 200 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  39 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 271 +++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  18 +-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c      |  24 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 416 ++++++++-------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  21 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    | 217 +++++------
 include/linux/mlx5/driver.h                        |   4 +-
 14 files changed, 1000 insertions(+), 615 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/dev.c

-- 
2.7.4
