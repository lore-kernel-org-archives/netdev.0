From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/2] Add ethtool set regs support
Date: Wed,  7 Dec 2016 00:33:08 +0200
Message-ID: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54083 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751418AbcLFWdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series adds the support for setting device registers from user
space ethtool.

Currently ethtool only allows to get device registers,
we extend ethtool functionality to also set device registers, by
introducing set_regs to ethtool_ops which will be invoked when
user space requests "ETHTOOL_SREGS", for example via ethtool user app:

ethtool -D DEVNAME [ file FILENAME ] is used to set registers in
the device using vendor specific binary registers data provided via
stdin/file. Changes made by this option can be queried using get
regs -d flag.

This simple ethool change will give HW vendors the flexibility to set
pure HW configurations (not directly related to netdev resources states
and rings), without the need of vendor proprietary tools and hacks.

2nd patch adds the support for ethtool set/get_regs in mlx5e driver.

Important Note: With this extension we will allow HW vendors to access (set) their 
device register without the need for them to open their format, hence the binary
file passed on ethtool -D DEVNAME.

This means that the device driver MUST check for correctness/validity of the 
registers data sent to it and whether this register is permitted to be iset form user space
in order to prevent the user from accessing/setting registers/Device configurations
that already standardized by the kernel/stack user APIs, or not allowed to be seen/set by user.

mlx5 driver have registers allowed access list and will check the user 
Request validity before forwarding it to HW registers. Mlx5 will allow only mlx5 specific
configurations to be set (e.g. Device Diag Counters for HW performance debugging and analysis)
which has no standard API to access it.

Comments and redirections are more than welcome

This series was generated against commit:
b0da4f743db5 ("net: calxeda: xgmac: use new api ethtool_{get|set}_link_ksettings")

Thanks,
Saeed.

Gal Pressman (2):
  ethtool: Add set regs -D option support
  net/mlx5e: Add ethtool get/set reg support

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  19 ----
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  12 +++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  21 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   8 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_regs.c  | 116 +++++++++++++++++++++
 include/linux/ethtool.h                            |   1 +
 include/linux/mlx5/mlx5_ifc.h                      |  22 ++++
 include/uapi/linux/ethtool.h                       |   1 +
 net/core/ethtool.c                                 |  31 ++++++
 10 files changed, 213 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_regs.c

-- 
2.7.4
