From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/22][pull request] 40GbE Intel Wired LAN Driver Updates 2016-10-31
Date: Mon, 31 Oct 2016 15:29:30 -0700
Message-ID: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947441AbcJaW3z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:29:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Colin Ian King fixes a minor issue with dev_err message where a new line
character was missing from the end of the message.

Jake provides several most of the changes in the series, starting with
dropping the is_vf and is_netdev fields in the i40e_mac_filter structure
since they are not needed (along with the checks that used these fields).
Reason being that we use separate VSI's for SRIOV VFs and for netdev VSIs,
therefore a single VSI should only have one type of filter.  Then
simplifies our .set_rx_mode handler by using the kernel provided
__dev_uc_sync and __dev_mc_sync functions for notification of add and
deletion of filters.  Refactored the i40e_put_mac_in_vlan() to resolve
an issue where this function was arbitrarily modifying all filters to
have the same VLAN, which is incorrect because it could be modifying
active filters without putting them into the new state.  Refactored the
delete filter logic so that we can re-use the functionality, where
appropriate, without having to search for the filter twice.  Reduced the
latency of operations related to searching for specific MAC filters by
using a static hash table instead of a list.  Reduced code duplication
in the adminq command to add/delete for filters.  Fixed an issue where
TSYNVALID bit was not being checked as the true indicator of whether
the packet has an associated timestamp.  Cleaned up a second msleep()
call by simply re-ordering the code so that the extra wait is no longer
needed.

Alan provides additional fix to the work Jake has been doing to resolve
a bug where adding at least one VLAN and then removing all VLANs leaves
the MAC filters for the VSI with an incorrect value for the VID which
indicates the MAC filter's VLAN status.

Alex adds a common method for finding a VSI by type.  Also cleaned up
the logic for coalescing RS bits, which was convoluted and larger than
it needed to be.

Mitch fixes an issue with the failure to add filters when the VF driver
is reloaded by simply setting the number of filters to 0 when freeing
VF resources.

Maciej implements a I40E_NVMUPD_STATE_ERROR state for NVM update, so
that the driver has the ability to return NVM image write failure.

Filip removes unreachable code which was found using static analysis
where "if" statements were never in a "true/false" state, so clean up
unnecessary if statements.

The following are changes since commit 17a032b7bfc0997682923509b70f9466940124bb:
  Merge branch 'bridge-PIM-hello'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40e: fix MAC filters when removing VLANs

Alexander Duyck (2):
  i40e: Add common function for finding VSI by type
  i40e: Reorder logic for coalescing RS bits

Colin Ian King (1):
  i40e: Add missing \n to end of dev_err message

Filip Sadowski (1):
  i40e: removed unreachable code

Jacob Keller (14):
  i40e: drop is_vf and is_netdev fields in struct i40e_mac_filter
  i40e: make use of __dev_uc_sync and __dev_mc_sync
  i40e: move i40e_put_mac_in_vlan and i40e_del_mac_all_vlan
  i40e: refactor i40e_put_mac_in_vlan to avoid changing f->vlan
  i40e: When searching all MAC/VLAN filters, ignore removed filters
  i40e: implement __i40e_del_filter and use where applicable
  i40e: store MAC/VLAN filters in a hash with the MAC Address as key
  i40e: properly cleanup on allocation failure in i40e_sync_vsi_filters
  i40e: avoid looping to check whether we're in VLAN mode
  i40e: remove duplicate add/delete adminq command code for filters
  i40e: correct check for reading TSYNINDX from the receive descriptor
  i40e: use a mutex instead of spinlock in PTP user entry points
  i40e: replace PTP Rx timestamp hang logic
  i40evf: avoid an extra msleep while

Maciej Sosin (1):
  i40e: Implementation of ERROR state for NVM update state machine

Michal Kosiarz (1):
  i40e: Fix for division by zero

Mitch Williams (1):
  i40e: clear mac filter count on reset

 drivers/net/ethernet/intel/i40e/i40e.h             |   74 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |    6 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   92 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   30 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   12 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1015 ++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   16 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  137 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  119 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    3 -
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   89 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |    4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  105 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |    1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |    8 +-
 18 files changed, 867 insertions(+), 850 deletions(-)

-- 
2.7.4
