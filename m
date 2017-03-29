From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 40GbE Intel Wired LAN Driver Updates 2017-03-29
Date: Wed, 29 Mar 2017 03:12:02 -0700
Message-ID: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21132 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755087AbdC2KMU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Preethi changes the default driver mode of operation to descriptor
write-back for VF.

Alex cleans up and addresses several issues in the way that i40e handles
private flags.  Modifies the driver to use the length of the packet
instead of the DD status bit to determine if a new descriptor is ready
to be processed.  Refactors the driver by pulling the code responsible
for fetching the receive buffer and synchronizing DMA into a single
function.  Also pulled the code responsible for handling buffer
recycling and page counting and distributed it through several functions,
so we can commonize the bits that handle either freeing or recycling the
buffers.  Cleans up the code in preparation for us adding support for
build_skb().  Changed the way we handle the maximum frame size for the
receive path so it is more consistent with other drivers.

Paul enables XL722 to use the direct read/write method since it does not
support the AQ command to read/write the control register.

Christopher fixes a case where we miss an arq element if a new one is
added before we enable interrupts and exit the loop.

Jake cleans up a pointless goto statement.  Also cleaned up a flag that
was not being used.

Carolyn does round 2 for adding a delay to the receive queue to
accommodate the hardware needs.

The following are changes since commit 0e42c72195cc1a6f7461bfc48b32dce29e1677f7:
  Merge branch 'netconf-delnetconf'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (7):
  i40e: Clean up handling of private flags
  i40e/i40evf: Use length to determine if descriptor is done
  i40e/i40evf: Pull code for grabbing and syncing rx_buffer from
    fetch_buffer
  i40e/i40evf: Pull out code for cleaning up Rx buffers
  i40e/i40evf: Break i40e_fetch_rx_buffer up to allow for reuse of frag
    code
  i40e/i40evf: Add legacy-rx private flag to allow fallback to old Rx
    flow
  i40e/i40evf: Change the way we limit the maximum frame size for Rx

Christopher N Bednarz (1):
  i40e: Check for new arq elements before leaving the adminq subtask
    loop

Jacob Keller (2):
  i40e: remove a useless goto statement
  i40e: remove FDIR_REQUIRES_REINIT driver flag

Paul M Stillwell Jr (1):
  i40e: use register for XL722 control register read/write

Preethi Banala (1):
  i40evf: enforce descriptor write-back mechanism for VF

Wyborny, Carolyn (1):
  i40e: fix for queue timing delays

 drivers/net/ethernet/intel/i40e/i40e.h             |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 192 ++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  42 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 249 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 312 +++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  18 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 104 +++++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  16 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  18 +-
 13 files changed, 559 insertions(+), 428 deletions(-)

-- 
2.12.0
