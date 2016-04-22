From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/12] Mellanox 100G extending mlx5 ethtool support
Date: Fri, 22 Apr 2016 22:00:35 +0300
Message-ID: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36878 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751172AbcDVTCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series is centralized around extending and improving mlx5 ethernet driver ethtool 
support We've done some code refactoring for ethtool statistics reporting, making it 
more scalable and robust, now each reported ethtool counter belongs to a group and has 
its own descriptor within that group, the descriptor holds the counter name and offset 
in memory in that group memory block.

Added new counters:
	- Reporting more error and drop counter in ifconig/ip tool.
	- Per priority pause and traffic counter in ethtool.
	- link down events counter in ethtool.
  
Set features handling was also refactored a little bit to be more resilient and generic, 
now setting more than one feature will not stop on the first failed one, buti instead 
it will try to continue setting others. Making it generic to make it simpler for adding 
more features support, it is now done easily by introducing a handler function of the new 
supported netdev feature, and let the generic handler do the job.

New netdev features and ethtool support:
	- Netdev feature RXALL, set on/off FCS check offload.
	- Netdev feature HW_VLAN_CTAG_RX, set on/off rx-vlan stripping offload.
	- Ethtool interface identify.
	- Ethtool dump module EEPROM.

In addition, we have added a patch that disables the port link on device close and enables it
back on device open, for power saving when driver is loaded and interface is down.

Series is applied on top 22d37b6b0058 ("Merge branch 'geneve-vxlan-deps'")

Thanks,
Saeed

Eran Ben Elisha (2):
  net/mlx5e: Add support for RXALL netdev feature
  net/mlx5e: Disable link up on INIT HCA command

Gal Pressman (9):
  net/mlx5e: Report additional error statistics in get stats ndo
  net/mlx5e: Statistics handling refactoring
  net/mlx5e: Rename VPort counters
  net/mlx5e: Add per priority group to PPort counters
  net/mlx5e: Add link down events counter
  net/mlx5e: Improve set features ndo resiliency
  net/mlx5e: Add ethtool support for interface identify (LED blinking)
  net/mlx5e: Add ethtool support for dump module EEPROM
  net/mlx5e: Add ethtool support for rxvlan-offload (vlan stripping)

Saeed Mahameed (1):
  net/mlx5e: Fix checksum handling for non-stripped vlan packets

 drivers/infiniband/hw/mlx5/main.c                  |   11 +
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    5 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  243 +----------
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |   10 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  288 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  459 ++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   20 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  359 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  143 ++++++-
 include/linux/mlx5/device.h                        |   23 +-
 include/linux/mlx5/driver.h                        |    9 +-
 include/linux/mlx5/port.h                          |   28 ++-
 13 files changed, 1125 insertions(+), 477 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
