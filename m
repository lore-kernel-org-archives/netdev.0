From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH] ethtool: add dynamic flag to {SG}RXFH
Date: Tue,  2 Feb 2016 15:22:05 -0800
Message-ID: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbcBBXWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 18:22:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series proposes the addition of a dynamic flag to the
ethtool {SG}RXFH operations. The primary reasoning for this is so that
drivers may indicate when they destroyed configured RSS settings, and
can determine when they have more liberty to remove user's settings.
The default mode shall be the current static mode, where drivers
should make best effort to maintain the RSS table settings if
possible. However, if the user sets dynamic mode flag, then the driver
is free (if necessary or useful) to modify the requested settings. The
primary reason for this is when queue sizes change dynamically. If you
increase the number of available queues, the RSS table may be
il-configured and the driver might which to change the settings.
Today, most drivers attempt to maintain the RSS table when possible.
This means that a user can observe functioning RSS, decrease the
number of queues, and then increase them again. Under current
functionality, drivers may end up never re-writing the RSS table back
to the default when the queues are increased. Even worse, if a driver
does do this today, they may have destroyed some specific settings the
user configured in the RSS table. Instead, use the dynamic mode value
which the driver will use to indicate whether or not the current
settings might change due to dynamic factors.

This series includes support to fix all the driver function pointers,
and a patch to enhance fm10k driver to support this feature. The
previous behavior of the fm10k driver was especially problematic, and
the current patch series attempts to resolve this.

It is possible to have most of the behavior handled purely in driver,
but then we lose any ability to communicate this to the user via
ethtool.

Jacob Keller (3):
  ethtool: add dynamic flag to ETHTOOL_{GS}RXFH commands
  fm10k: support dynamic mode for RSS table control
  ethtool: add support for dynamic mode in {SG}RXFH commands

 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c         |  7 +++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c  |  7 +++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c    |  5 ++++-
 drivers/net/ethernet/broadcom/tg3.c                  |  8 ++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c  |  7 +++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c   |  7 +++++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c       |  7 +++++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c       |  7 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c     |  8 ++++++--
 drivers/net/ethernet/intel/fm10k/fm10k.h             |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c     | 15 +++++++++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c        |  8 +++++---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c       |  7 +++++--
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c   |  6 ++++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c         |  6 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c     |  7 +++++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c         |  5 ++++-
 drivers/net/ethernet/marvell/mvneta.c                |  8 ++++++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c      |  7 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  7 +++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c |  7 +++++--
 drivers/net/ethernet/sfc/ethtool.c                   |  7 +++++--
 include/linux/ethtool.h                              |  4 ++--
 include/uapi/linux/ethtool.h                         |  8 +++++++-
 net/core/ethtool.c                                   | 27 ++++++++++++++++-----------
 25 files changed, 138 insertions(+), 55 deletions(-)

 ethtool-copy.h |  8 +++++++-
 ethtool.c      | 36 +++++++++++++++++++++++++++++++++++-
 2 files changed, 42 insertions(+), 2 deletions(-)

-- 
2.6.3.505.g5cc1fd1
