From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 1GbE Intel Wired LAN Driver Updates 2017-03-17
Date: Fri, 17 Mar 2017 12:58:05 -0700
Message-ID: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30552 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbdCQT6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to mainly igb, with one fix for ixgbe.

Alex does all the changes in the series, starting with adding support
for DMA_ATTR_WEAK_ORDERING to improve performance on some platforms.
Modified igb to use the length of the packet instead of the DD status
bit to determine if a new descriptor is ready to be processed.  Modified
the driver to only go through the region in the receive ring that was
designated to be cleaned up, instead of going through the entire ring
on cleanup.  Cleaned up the transmit side, by clearing the transmit
buffer_info only when resetting the rings.  Added a new upper limit for
receive, which is based on the size of a 2K buffer minus padding, which
will allow us to support build_skb going forward.  Fixed ethtool testing
to only sync on the size of the frame that is being tested, instead of
the entire receive buffer.  Updated the handling of page addresses to
always use a void pointer with the consistent name of "va" to indicate
that we are working with a virtual address.  Added a "chicken bit" so
that we can turn off the new receive allocation feature, in the case
where we need to fallback to the legacy receive path.  Added support for
using 3K buffers in order 1 pages the same way we were using 2K buffers
in 4K pages.  Added support for padding packet, since we limit the size
of the frame, we are able to write to an offset within the buffer instead
of having to write at the very start of the buffer.  This allows us to
leaving padding room for things like supporting XDP in the future.
Refactored the receive buffer page management, since there are 2-3 paths
that can be taken depending on what receive modes are enabled, so to
improve maintainability, break out the common bits into their own
functions.  Add support for build_skb, again.  Lastly, fixed a typo in
igb and ixgbe code comments.

The following are changes since commit fe723dff0fa4181ddb8116e72bc67d00d4239cb6:
  liquidio: fix wrong information about link modes reported to ethtool
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (13):
  igb: Add support for DMA_ATTR_WEAK_ORDERING
  igb: Use length to determine if descriptor is done
  igb: Clear Rx buffer_info in configure instead of clean
  igb: Don't bother clearing Tx buffer_info in igb_clean_tx_ring
  igb: Limit maximum frame Rx based on MTU
  igb: Only sync size of expected frame in ethtool testing
  igb: Use page_address offset from page instead of masking virtual
    address
  igb: Add support for ethtool private flag to allow use of legacy Rx
  igb: Add support for using order 1 pages to receive large frames
  igb: Add support for padding packet
  igb: Break out Rx buffer page management
  igb: Re-add support for build_skb in igb
  igb/ixgbe: Fix typo in igb_build_skb and/or ixgbe_build_skb code
    comment

 drivers/net/ethernet/intel/igb/igb.h          |  58 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |  65 +++-
 drivers/net/ethernet/intel/igb/igb_main.c     | 514 ++++++++++++++++----------
 drivers/net/ethernet/intel/igb/igb_ptp.c      |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   2 +-
 5 files changed, 439 insertions(+), 203 deletions(-)

-- 
2.12.0
