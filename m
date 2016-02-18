From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V6 0/8] ethtool per queue parameters support
Date: Thu, 18 Feb 2016 07:39:48 -0500
Message-ID: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40499 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947704AbcBRUAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 15:00:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modern network interface controllers usually support multiple receive
and transmit queues. Each queue may have its own parameters. For
example, Intel XL710/X710 hardware supports per queue interrupt
moderation. However, current ethtool does not support per queue
parameters option. User has to set parameters for the whole NIC.
This series extends ethtool to support per queue parameters option.

Since the support of per queue parameters vary with different cards,
it is impossible to address all cards in one patch. This series only
supports per queue coalesce options on i40e driver. The framework used
in the patch can be easily extended to other cards and parameters.

The lib bitmap needs to be extended to facilitate exchanging queue bitmaps
between user space and kernel space. Two patches from David's latest V8
patch series are also cited in this series. You may refer to
https://lkml.org/lkml/2016/2/9/919 for more details.

Changes since V5:
 - Update the first two patches to David's latest V8 version

Changes since V4:
 - Modify set/get_per_queue_coalesce function description
 - Change the queue number to be u32
 - Correct an error of calculating coalesce backup buffer address
 - Rename queue_num to n_queues
 - Don't log error message in __i40e_get_coalesce

Changes since V3:
 - Based on David's lib bitmap.
 - ETHTOOL_PERQUEUE should be handled before the containing switch
 - Make the rollback code unconditional
 - some minor changes according to Ben's feedback

Changes since V2:
 - Add queue-specific settings for interrupt moderation in i40e

Changes since V1:
 - Checking the sub-command number to determine whether the command
   requires CAP_NET_ADMIN
 - Refine the struct ethtool_per_queue_op and improve the comments
 - Use bitmap functions to parse queue mask
 - Improve comments
 - Use bitmap functions to parse queue mask
 - Improve comments
 - Add rollback support
 - Correct the way to find the vector for specific queue.

David Decotigny (2):
  lib/bitmap.c: conversion routines to/from u32 array
  test_bitmap: unit tests for lib/bitmap.c

Kan Liang (6):
  net/ethtool: introduce a new ioctl for per queue setting
  net/ethtool: support get coalesce per queue
  net/ethtool: support set coalesce per queue
  i40e: queue-specific settings for interrupt moderation
  i40e/ethtool: support coalesce getting by queue
  i40e/ethtool: support coalesce setting by queue

 drivers/net/ethernet/intel/i40e/i40e.h         |   7 -
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 151 +++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   8 +
 include/linux/bitmap.h                         |  10 +
 include/linux/ethtool.h                        |  15 +-
 include/uapi/linux/ethtool.h                   |  17 ++
 lib/Kconfig.debug                              |   8 +
 lib/Makefile                                   |   1 +
 lib/bitmap.c                                   |  89 ++++++
 lib/test_bitmap.c                              | 358 +++++++++++++++++++++++++
 net/core/ethtool.c                             | 121 ++++++++-
 tools/testing/selftests/lib/Makefile           |   2 +-
 tools/testing/selftests/lib/bitmap.sh          |  10 +
 16 files changed, 760 insertions(+), 73 deletions(-)
 create mode 100644 lib/test_bitmap.c
 create mode 100755 tools/testing/selftests/lib/bitmap.sh

-- 
1.8.3.1
