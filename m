From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 40GbE Intel Wired LAN Driver Updates 2017-04-30
Date: Sun, 30 Apr 2017 06:24:38 -0700
Message-ID: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19886 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163082AbdD3NY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jake provides majority of the changes in this series, starting with the
renaming of a flag to avoid confusion.  Then renamed a variable to a
more meaningful name to clarify what is actually being done and to
reduce confusion.  Amortizes the wait time when initializing or disabling
lots of VFs by using i40e_reset_all_vfs() and
i40e_vsi_stop_rings_no_wait().  Cleaned up a unnecessary delay since
pci_disable_sriov() already has its own delay, so need to add a additional
delay when removing VFs.  Avoid using the same name flags for both
vsi->state and pf->state, to make code review easier and assist future
work to use the correct state field when checking bits.  Use
DECLARE_BITMAP() to ensure that we always allocate enough space for flags.
Replace hw_disabled_flags with the new _AUTO_DISABLED flags, which are
more readable because we are not setting an *_ENABLED flag to
disable the feature.

Alex corrects a oversight where we were not reprogramming the ports
after a reset, which was causing us to lose all of the receive tunnel
offloads.

Arnd Bergmann moves the declaration of a local variable to avoid a
warning seen on architectures with larger pages about an unused variable.

The following are changes since commit c08bac03d2894113bdb114e66e6ada009defb120:
  Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e: Reprogram port offloads after reset

Arnd Bergmann (1):
  i40evf: hide unused variable

Jacob Keller (11):
  i40e: properly spell I40E_VF_STATE_* flags
  i40e: make use of i40e_reset_all_vfs when initializing new VFs
  i40e: rename index to port to avoid confusion
  i40e: amortize wait time when disabling lots of VFs
  i40e: remove unnecessary msleep() delay in i40e_free_vfs
  i40e: separate PF and VSI state flags
  i40e: use DECLARE_BITMAP for state fields
  i40evf: remove needless min_t() on num_online_cpus()*2
  i40e: remove hw_disabled_flags in favor of using separate flag bits
  i40evf: remove I40E_FLAG_FDIR_ATR_ENABLED
  i40evf: allocate queues before we setup the interrupts and q_vectors

 drivers/net/ethernet/intel/i40e/i40e.h             |  31 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c      |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  50 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 332 +++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  36 +--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 144 +++++----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  15 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   8 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  12 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  45 +--
 12 files changed, 372 insertions(+), 334 deletions(-)

-- 
2.12.2
