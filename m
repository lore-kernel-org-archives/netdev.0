From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-02-11
Date: Sat, 11 Feb 2017 21:30:14 -0800
Message-ID: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:15779 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750714AbdBLFaa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jake makes a minor change to prevent a minor bit of work, if it is not
necessary.  In the case where we do not have a client, there is no need
to check the client params, so move the check till after we have ensured
we have a client.  Correct a code comment which incorrectly implied
that raw_packet buffers were freed in i40e_clean_tx_ring(), so fixed
the code comment to better explain where memory is freed.  Reduce the
severity and frequency of the message notifying we cleared the receive
timestamp register, since the logic has a much better detection scheme
that could detect a stalled receive timestamp register.  The improved
logic was actually causing the notification message to occur more
frequently and was giving the user a false perception that a timestamp
event was missed for a valid packet, so reduce the severity from
dev_warn to dev_dbg and only fire off the message when 3 or 4 of the
RXTIME registers are stalled and get cleared within the same
watchdog event.  Fixed a bug, where we were modifying the mac_filter
outside a lock when handling the addition of broadcast filters.  Fix
this by updating i40e_update_filter_state logic so that it knows to
avoid broadcast filters, which ensures that we do not have to remove
the filter separately and can put it back using the normal flow.
Refactored how we add new filters to firmware to avoid a race condition
that can occur due to removing filters from the hash temporarily.

Mitch adds a sleep (without timeout) so that we wait for a reply from
the PF before we continue, since the iWarp client cannot continue until
the operation is completed.  Fixed up a function which could never
return an error, to be void and cleaned up the checking of the now
null and void return value.

Scott limits the DMA sync to CPU to the actual length of the incoming
packet, versus the syncing of the entire buffer.  Also reduces the
receive buffer struct (by a single pointer) and align the driver to be
more consistent with other Intel drivers with respect to packets that
span buffers.

Sudheer adds a field to track the bus number info and modified log
statements to print bus, device and function information.

Henry adds the ability to store the FEC status bits from the link up
event.  Also adds the ethtool support for FEC capabilities and 25G
link types.

The following are changes since commit 1bf960502e4c94425c3a3a985200834fb59839c6:
  net: ethernet: ti: cpsw: return NET_XMIT_DROP if skb_padto failed
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Bimmy Pujari (1):
  i40e/i40evf : Changed version from 1.6.25 to 1.6.27

Henry Tieman (2):
  i40e: Save link FEC info from link up event
  i40e: Save more link abilities when using ethtool

Jacob Keller (5):
  i40e: don't check params until after checking for client instance
  i40e: update comment explaining where FDIR buffers are freed
  i40e: don't warn every time we clear an Rx timestamp register
  i40e: allow i40e_update_filter_state to skip broadcast filters
  i40e: avoid race condition when sending filters to firmware for
    addition

Mitch Williams (2):
  i40evf: track outstanding client request
  i40e: Clean up dead code

Scott Peterson (3):
  i40e/i40evf: Limit DMA sync of RX buffers to actual packet size
  i40e/i40evf: Moves skb from i40e_rx_buffer to i40e_ring
  i40e/i40evf: eliminate i40e_pull_tail()

Sudheer Mogilappagari (1):
  i40e: Add bus number info to i40e_bus_info struct

 drivers/net/ethernet/intel/i40e/i40e.h             |  16 ++
 drivers/net/ethernet/intel/i40e/i40e_client.c      |  33 ++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   3 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 192 +++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 223 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 215 +++++++++++---------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   9 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   3 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   4 +
 17 files changed, 463 insertions(+), 285 deletions(-)

-- 
2.10.2
