From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates 2014-11-20
Date: Thu, 20 Nov 2014 15:08:58 -0800
Message-ID: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745AbaKTXJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf, i40e and i40evf.

Emil updates ixgbevf with much of the work that Alex Duyck did while at
Intel.  First updates the driver to clear the status bits on allocation
instead of in the cleanup routine, this way we can leave the recieve
descriptor rings as a read only memory block until we actually have
buffers to give back to the hardware.  Clean up ixgbevf_clean_rx_irq()
by creating ixgbevf_process_skb_field() to merge several similar
operations into this new function.  Cleanup temporary variables within
the receive hot-path and reducing the scope of variables that do not
need to exist outside the main loop.  Save on stack space by just
storing our updated values back in next_to_clean instead of using
a stack variable, which also collapses the size the function.  Improve
performace on IOMMU enabled systems and reduce cache misses by changing
the basic receive patch for ixgbevf so that instead of receiving the
data into an skb, it is received into a double buffered page.  Add
netpoll support by creating ixgbevf_netpoll(), which is a callback for
.ndo_poll_controller to allow for the VF interface to be used with
netconsole.

Mitch provides several cleanups and trivial fixes for i40e and i40evf.
First is a fix the overloading of the msg_size field in the
arq_event_info struct by splitting the field into two and renaming to
indicate the actual function of each field.  Updates code comments
to match the actual function.  Cleanup several checkpatch.pl warnings
by adding or removing blank lines, aligning function parameters, and
correcting over-long lines (which makes the code more readable).

Shannon provides a patch for i40e to write the extra bits that will
turn off the ITR wait for the interrupt, since we want the SW INT to
go off as soon as possible.

v2: updated patch 07 based on feedback from Alex Duyck by
 - adding pfmemalloc check to a new function for reusable page
 - moved atomic_inc outside of #if/else in ixgbevf_add_rx_frag()
 - reverted the removal of the API check in ixgbevf_change_mtu()

The following are changes since commit daaf427c6ab392bedcd018e326b2ffa1e1110cd6:
  bpf: fix arraymap NULL deref and missing overflow and zero size checks
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Emil Tantilov (9):
  ixgbevf: Update ixgbevf_alloc_rx_buffers to handle clearing of status
    bits
  ixgbevf: Test Rx status bits directly out of the descriptor
  ixgbevf: Combine the logic for post Rx processing into single function
  ixgbevf: Cleanup variable usage, improve stack performance
  ixgbevf: reorder main loop in ixgbe_clean_rx_irq to allow for
    do/while/continue
  ixgbevf: Update Rx next to clean in real time
  ixgbevf: Change receive model to use double buffered page based
    receives
  ixgbevf: compare total_rx_packets and budget in ixgbevf_clean_rx_irq
  ixgbevf: add netpoll support

Mitch Williams (5):
  i40e: don't overload fields
  i40evf: update header comments
  i40evf: make checkpatch happy
  i40evf: make comparisons consistent
  i40evf: remove unnecessary else

Shannon Nelson (1):
  i40e: trigger SW INT with no ITR wait

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  17 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  14 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  71 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  23 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  39 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 720 ++++++++++++++-------
 12 files changed, 595 insertions(+), 314 deletions(-)

-- 
1.9.3
