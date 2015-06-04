From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/13] mlx5: Add Interface Step Sequence ID support
Date: Thu,  4 Jun 2015 19:30:35 +0300
Message-ID: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47625 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932134AbbFDQbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ISSI (Interface Step Sequence ID) defines the step sequence ID of the 
interface between the driver to the firmware and is incremented by 
steps of one. ISSI is used to enable deprecating/modifying features, 
command interfaces and such, while maintaining compatibility.

As the driver serves both ConnectIB (CIB) and ConnectX4, we carefully 
made sure that the IB functionality keeps running also on older CIB 
firmware releases that don't support ISSI. 

The Ethernet functionailty is available only on ConnectX4 where all 
firmware releases support the feature since the very basic ISSI level. 
So at this point no need for compatility code there.

As done prior to this series, when the Ethernet functionlity is enabled, 
during the initialization flow, the core driver performs a query of the 
supported ISSIs using the QUERY_ISSI command, and then, if ISSI is supported, 
sets the actual issi value informing the firmware on which ISSI level to run, 
using SET_ISSI command.

Previously, the IB driver wasn't ready to work on that mode, and hence
building both the IB driver and the Ethernet functionality in the core
driver were disallowed by Kconfigs, with this series, we allow users to
enable them both.

Or.

Amir Vadai (1):
  net/mlx5_en: Add missing check for memory allocation failure

Haggai Abramonvsky (4):
  net/mlx5_core: Apply proper name convention to helpers
  net/mlx5_core: Enable XRCs and SRQs when using ISSI > 0
  net/mlx5_core: Check the return bitmask when querying ISSI
  mlx5: Enable mutual support for IB and Ethernet

Majd Dibbiny (8):
  net/mlx5_core: Make the vport helpers available for the IB driver too
  net/mlx5_core: Add new query HCA vport commands
  net/mlx5_core: Get vendor-id using the query adapter command
  net/mlx5_core: Use port number in the query port mtu helpers
  net/mlx5_core: Use port number when querying port ptys
  net/mlx5_core: Add more query port helpers
  IB/mlx5: Avoid using the MAD_IFC command under ISSI > 0 mode
  IB/mlx5: Don't create IB instance over Ethernet ports

 drivers/infiniband/hw/mlx5/mad.c                   |  297 +++++++++++
 drivers/infiniband/hw/mlx5/main.c                  |  543 +++++++++++++-------
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   17 +
 drivers/infiniband/hw/mlx5/qp.c                    |    3 +-
 drivers/infiniband/hw/mlx5/srq.c                   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    2 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |    2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   26 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   59 ++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   16 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   90 +++-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |    7 +
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  444 ++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  176 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   35 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  265 ++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/vport.h    |   41 --
 include/linux/mlx5/device.h                        |   13 +
 include/linux/mlx5/driver.h                        |   68 +++-
 include/linux/mlx5/mlx5_ifc.h                      |   46 ++-
 include/linux/mlx5/vport.h                         |   55 ++
 25 files changed, 1840 insertions(+), 377 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.h
 create mode 100644 include/linux/mlx5/vport.h
