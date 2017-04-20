From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-04-19
Date: Wed, 19 Apr 2017 18:57:36 -0700
Message-ID: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765247AbdDTB5z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only, most notable being
the addition of trace points for BPF programs.

Tobias Klauser updates i40evf to use net_device stats struct instead
of a local private copy.

Preethi updates the VF driver to not enable receive checksum offload by
default for tunneled packets.

Alex fixes an issue he introduced when he converted the code over to
using the length field to determine if a descriptor was done or not.

Mitch adds the ability to dump additional information on the VFs, which
is not available through 'ip link show' using debugfs.

Scott adds trace points to the drivers so that BPF programs can be
attached for feature testing and verification.

Jingjing adds admin queue functions for Pipeline Personalization Profile
commands.

Jake does most of the heavy lifting in this series, starting with the
a reduction in the scope of the RTNL lock being held while resetting VFs
to allow multiple PFs to reset in a timely manner.  Factored out the
direct queue modification so that we are able to re-use the code.
Reduced the wait time for admin queue commands to complete, since we were
waiting a minimum of a millisecond, when in practice the admin queue
command is processed often much faster.  Cleaned up code (flag) we never
use.  Make the code to resetting all the VFs optimized for parallel
computing instead of the current way is a serialized fashion, to help
reduce the time it takes.

The following are changes since commit 9868879f293c599ce13b584c5bd8800312970781:
  net: cx89x0: move attribute declaration before struct keyword
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e: Fix support for flow director programming status

Jacob Keller (8):
  i40e: don't hold RTNL lock while waiting for VF reset to finish
  i40e: factor out queue control from i40e_vsi_control_(tx|rx)
  i40e: fix CONFIG_BUSY checks in i40e_set_settings function
  i40e: reduce wait time for adminq command completion
  i40e: remove I40E_FLAG_IN_NETPOLL entirely
  i40e: split some code in i40e_reset_vf into helpers
  i40e: reset all VFs in parallel when rebuilding PF
  i40e: use i40e_stop_rings_no_wait to implement PORT_SUSPENDED state

Jingjing Wu (1):
  i40e: new AQ commands

Mitch Williams (1):
  i40e: dump VF information in debugfs

Scott Peterson (1):
  i40e/i40evf: Add tracepoints

Tobias Klauser (1):
  i40evf: Use net_device_stats from struct net_device

alice michael (1):
  i40e/i40evf: Remove VF Rx csum offload for tunneled packets

 drivers/net/ethernet/intel/i40e/Makefile           |   3 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  19 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  34 +++
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 212 +++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  51 +++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  38 +++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 200 ++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  17 ++
 drivers/net/ethernet/intel/i40e/i40e_trace.h       | 229 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  59 ++++--
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  80 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 209 +++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 +
 drivers/net/ethernet/intel/i40evf/Makefile         |   3 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   2 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  34 +++
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 212 +++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  17 ++
 drivers/net/ethernet/intel/i40evf/i40e_trace.h     | 229 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  25 ++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  80 +++++++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   3 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  23 +--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  22 +-
 27 files changed, 1625 insertions(+), 187 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_trace.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_trace.h

-- 
2.12.2
