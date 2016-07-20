From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/20][pull request] 100GbE Intel Wired LAN Driver Updates 2016-07-20
Date: Wed, 20 Jul 2016 15:23:38 -0700
Message-ID: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbcGTWYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Ngai-Mint provides a fix to clear PCIE_GMBX bits to ensure the proper
functioning of the mailbox global interrupt after a data path reset.

Jake provides most of the patches in the series, starting with a early
return from fm10k_down() if we are already down to prevent conflict with
other threads.  Fixed an issue where fm10k_update_stats() could cause
a null pointer dereference, specifically if it is called when we are going
down and the rings have been removed.  Cleans up and fixes the data path
reset flow, Tx hang routine and stop_hw().  Re-worked the fm10k_reinit()
to be more maintainable and fixed several inconsistencies with the work
flow.  Implemented fm10k_prepare_suspend() and fm10k_handle_resume()
which abstract around the now existing fm10k_prepare_for_reset and
fm10k_handle_reset. The new functions also handle stopping the service
task, which is something that the original re-init flow does not need.
Fixed an issue where if an FLR occurs, VF devices will be knocked out of
bus master mode, and the driver will be unable to recover from the reset
properly, so ensure bus master is enabled after every reset.  Fixed an
issue where a reset will occur as if for no reason, regularly every few
minutes until the switch manager software is loaded, which is caused
by continuously requesting the lport map so only do the request after
we have verified the switch mailbox is tx_ready.

The following are changes since commit c0d661ca3701f38d9313ca3954e3741ad92e3aaa:
  Merge branch 'mlxsw-per-prio-tc-counters'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (19):
  fm10k: no need to continue in fm10k_down if __FM10K_DOWN already set
  fm10k: avoid possible null pointer dereference in fm10k_update_stats
  fm10k: prevent multiple threads updating statistics
  fm10k: don't stop reset due to FM10K_ERR_REQUESTS_PENDING
  fm10k: perform data path reset even when switch is not ready
  fm10k: use actual hardware registers when checking for pending Tx
  fm10k: only warn when stop_hw fails with FM10K_ERR_REQUESTS_PENDING
  fm10k: wait for queues to drain if stop_hw() fails once
  fm10k: split fm10k_reinit into two functions
  fm10k: implement prepare_suspend and handle_resume
  fm10k: use common reset flow when handling io errors from PCI stack
  fm10k: implement reset_notify handler for PCIe FLR events
  fm10k: use common flow for suspend and resume
  fm10k: enable bus master after every reset
  fm10k: check if PCIe link is restored
  fm10k: implement request_lport_map pointer
  fm10k: force link to remain down for at least a second on resume
    events
  fm10k: return proper error code when pci_enable_msix_range fails
  fm10k: bump version number

Ngai-Mint Kwan (1):
  fm10k: Reset mailbox global interrupts

 drivers/net/ethernet/intel/fm10k/fm10k.h         |   2 +
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |   6 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |   2 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  14 +-
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     |   2 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 322 +++++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |  38 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   2 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  12 +-
 9 files changed, 233 insertions(+), 167 deletions(-)

-- 
2.5.5
