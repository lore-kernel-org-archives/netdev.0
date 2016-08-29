From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 100GbE Intel Wired LAN Driver Updates 2016-08-29
Date: Mon, 29 Aug 2016 02:13:32 -0700
Message-ID: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756473AbcH2JNs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jake provides all the changes in this series starting with fixes an issue
where VF devices may fail during an unbind/bind and we will never zero
the reference counter for the pci_dev structure.  Updated the hot path
to use SW counters instead of checking for hardware Tx pending for
possible transmit hangs, which will improve performance.  Fixed the NAPI
budget accounting so that fm10k_poll will return actual work done,
capped at (budget - 1) instead of returning 0.  Added a check to ensure
that the device is in the normal IO state before continuing to probe,
which allows us to give a more descriptive message of what is wrong
in the case of uncorrectable AER error.  In preparation for adding Geneve
Rx offload support, refactored the current VXLAN offload flow to be a bit
more generic.  Added support for receive offloads on one Geneve tunnel.
Ensure that other bits in the RXQCTL register do not get cleared, to
make sure that bits related to queue ownership are maintained.  Fixed
an issue in queue ownership assignment which casued a race condition
between the PF and the VF such that potentially a VF could cause FUM
fault errors due to normal PF/VF driver behavior.

The following are changes since commit 0b498a52778368ff501557d68c7b50878ab1701e:
  net_sched: fix use of uninitialized ethertype variable in cls_flower
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (14):
  fm10k: fix PCI device enable_cnt leak in .io_slot_reset
  fm10k: use software values when checking for Tx hangs in hot path
  fm10k: use variadic form of alloc_workqueue
  fm10k: remove fm10k_get_reta_size from namespace
  fm10k: prefer READ_ONCE instead of ACCESS_ONCE
  fm10k: NAPI polling routine must return actual work done
  fm10k: print error code when pci_enable_device_mem fails during probe
  fm10k: don't continue probe if PCI device not in normal IO state
  fm10k: don't try to stop queues if we've lost hw_addr
  fm10k: rework vxlan_port offload before adding geneve support
  fm10k: add support for Rx offloads on one Geneve tunnel
  fm10k: remove unnecessary extra parenthesis around ((~value))
  fm10k: don't clear the RXQCTL register when enabling or disabling
    queues
  fm10k: don't re-map queues when a mailbox message suffices

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  10 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |   3 +
 drivers/net/ethernet/intel/fm10k/fm10k_common.h  |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  29 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 193 ++++++++++++++---------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  30 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |  46 ++++--
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   1 +
 10 files changed, 200 insertions(+), 122 deletions(-)

-- 
2.7.4
