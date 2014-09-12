From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates 2014-09-12
Date: Fri, 12 Sep 2014 05:33:40 -0700
Message-ID: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50729 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663AbaILMd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, ixgbe and ixgbevf.

Mark provide two fixes to reduce compile warnings produce by ixgbe
and ixgbevf.

Alex provides two patches for ixgbe, first removes the receive buffer
allocation at the end of the ixgbe_clean_rx_irq().  The reason for
removing this is to avoid the extra latency introduced by the MMIO write.
Second patch addresses several issues in the current ixgbe implementation
of busy poll sockets.  It was possible for frames to be delivered out of
order if they were held in GRO, so address this by flushing the GRO
buffers before releasing the q_vector back to the idle state.  Also, we
were having to take a spinlock on changing the state to and from idle,
so to resolve this, replaced the state value with an atomic and use
atomic_cmpxchg to change the value from idle, and a simple atomic set
to restore it back to idle after we have acquired it.  This allows us
to only use a locked operation on acquiring the vector without a need
for a locked operation to release it.

Florian Westphal provides several patches for e1000 which does some
cleanup and updating of the driver.  Moved e1000_tbi_adjust_stats()
so that he could make the function static.  Added a helper function
to deal with the tbi workaround that was located in 2 different
Rx clean functions.  Added a e1000_rx_buffer struct for use on receive
since the transmit and receive have different requirements.  Updates
e1000 to use napi_gro_frags API.

The following are changes since commit b954d83421d51d822c42e5ab7b65069b25ad3005:
  net: bpf: only build bpf_jit_binary_{alloc, free}() when jit selected
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Drop Rx alloc at end of Rx cleanup
  ixgbe: Refactor busy poll socket code to address multiple issues

Florian Westphal (7):
  e1000: move e1000_tbi_adjust_stats to where its used
  e1000: move tbi workaround code into helper function
  e1000: perform copybreak ahead of DMA unmap
  e1000: add and use e1000_rx_buffer info for Rx
  e1000: rename struct e1000_buffer to e1000_tx_buffer
  e1000: convert to build_skb
  e1000: switch to napi_gro_frags api

Mark Rustad (2):
  ixgbe: Resolve warnings produced in W=2 builds
  ixgbevf: Resolve missing-field-initializers warnings

 drivers/net/ethernet/intel/e1000/e1000.h         |  19 +-
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  38 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c      |  78 ----
 drivers/net/ethernet/intel/e1000/e1000_hw.h      |   2 -
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 498 ++++++++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         | 112 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  21 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c     |   2 +-
 10 files changed, 396 insertions(+), 383 deletions(-)

-- 
1.9.3
