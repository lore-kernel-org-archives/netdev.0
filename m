From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/8] net/mlx5e: Driver updates 04-Aug-2015
Date: Tue,  4 Aug 2015 14:05:39 +0300
Message-ID: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36404 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933112AbbHDLGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduces two features to the ConnectX-4 driver: Patch 8/8
("Support physical port counters") exposes some hardware counters through
ethtool. Rest of the patches are preparation and usage of what we call
light-weight netdev open/close. Some flows that used to be in the ndo_open/stop
are moved to the PCI probe/remove flows - i.e. we will make the netdev
open/close operations more "light-weight".

The benefits of this change are:
1) Reduce the execution time of the stop/open operations.
2) Avoid saving SW shadows of resource configurations that must
   persist through stop/open operations (e.g flow table steering
   rules), and avoid deleting/applying them from/to the device upon
   netdev stop/open.
3) Avoid synchronizing threads that access those resources with the
   netdev stop/open threads.

Instead of create/destroy the resource during netdev open/stop, This patchset
changes the behavior such that upon netdev stop, traffic is redirected to a
"Drop RQ" (a RQ that silently drops, at the NIC HW level all incoming traffic).
After redirecting the traffic, RX/TX software resources could be destroyed.
During netdev open, the RX/TX rings are created and traffic is redirected to
the RX rings.

Patchset was applied and tested over commit ba7591d ("ebpf: add skb->hash to
offset map for usage in {cls, act}_bpf or filters")

Thanks,
Amir

Achiad Shochat (7):
  net/mlx5e: Unify the RX flow
  net/mlx5e: Introduce the "Drop RQ"
  net/mlx5_core: Introduce access function to modify RSS/LRO params
  net/mlx5e: Light-weight netdev open/stop
  net/mlx5e: Rename/move functions following the ndo_stop flow change
  net/mlx5e: Disable async events before unregister_netdev()
  net/mlx5e: Take advantage of the light-weight netdev open/stop

Gal Pressman (1):
  net/mlx5_core: Support physical port counters

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  97 ++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  10 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 113 +---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 746 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  24 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   4 +
 include/linux/mlx5/device.h                        |  10 +
 include/linux/mlx5/driver.h                        |   1 +
 include/linux/mlx5/mlx5_ifc.h                      |  18 +-
 9 files changed, 675 insertions(+), 348 deletions(-)

-- 
2.4.3.413.ga5fe668
