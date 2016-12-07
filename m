From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/19][pull request] 40GbE Intel Wired LAN Driver Updates 2016-12-07
Date: Wed,  7 Dec 2016 14:18:59 -0800
Message-ID: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42627 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932339AbcLGWUL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Filip modifies the i40e to log link speed change and when the link is
brought up and down.

Mitch replaces i40e_txd_use_count() with a new function which is slightly
faster and better documented so the dim witted can better follow the
code.  Fixes the locking of the service task so that it is actually
done in the service task and not in the scheduling function which calls
the service task.

Jacob, being the busy little beaver he is, provides most of the changes
starting restores a workaround that is still needed in some configurations,
specifically the Ethernet Controller XL710 for 40GbE QSFP+.  Removes
duplicate code and simplifies the i40e_vsi_add_vlan() and
i40e_vsi_kill_vlan() functions.  Removes detection of PTP frames over L4
(UDP) on the XL710 MAC, since there was a product decision to defeature
it.  Fixed a previous refactor of active filters which caused issues in
the accounting of active_filters.  Remaining work was done in the VLAN
filters to improve readability and simplify code as much as possible
to reduce inconsistencies.

Alex fixes foul budget accounting in core code by returning actual
work done, capped to budget-1.

Henry fixes the "ethtool -p" function for 1G BaseT PHYs.

Carolyn adds support for 25G devices for i40e and i40evf.

Michal adds functions to apply the correct access method for external PHYs
which could use Clause22 or Clause45 depending on the PHY.

v2: dropped last patch from previous series, since changes are needed based
    on feedback from Sergei Shtylyov

The following are changes since commit d4aea20d889e05575bb331a3dadf176176f7d631:
  tun: Use netif_receive_skb instead of netif_rx
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e/i40evf: napi_poll must return the work done

Bimmy Pujari (1):
  Changed version from 1.6.21 to 1.6.25

Carolyn Wyborny (2):
  i40e: Add support for 25G devices
  i40e: Add FEC for 25g

Filip Sadowski (1):
  i40e: Driver prints log message on link speed change

Henry Tieman (1):
  i40e: Blink LED on 1G BaseT boards

Jacob Keller (10):
  i40e: restore workaround for removing default MAC filter
  i40e: remove code to handle dev_addr specially
  i40e: use unsigned printf format specifier for active_filters count
  i40e: defeature support for PTP L4 frame detection on XL710
  i40e: recalculate vsi->active_filters from hash contents
  i40e: refactor i40e_update_filter_state to avoid passing aq_err
  i40e: delete filter after adding its replacement when converting
  i40e: factor out addition/deletion of VLAN per each MAC address
  i40e: use (add|rm)_vlan_all_mac helper functions when changing PVID
  i40e: move all updates for VLAN mode into i40e_sync_vsi_filters

Michal Kosiarz (1):
  i40e: Add functions which apply correct PHY access method for read and
    write operation

Mitch Williams (2):
  i40e: simplify txd use count calculation
  i40e: lock service task correctly

 drivers/net/ethernet/intel/i40e/i40e.h             |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  51 ++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  85 +++-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  51 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 485 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   4 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  45 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  82 ++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  46 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  51 ++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   4 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  45 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  82 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |   8 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   3 +
 23 files changed, 723 insertions(+), 360 deletions(-)

-- 
2.9.3
