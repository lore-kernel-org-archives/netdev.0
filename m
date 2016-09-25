From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-09-24
Date: Sat, 24 Sep 2016 23:42:34 -0700
Message-ID: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbcIYGmv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Harshitha removes the ability to set or advertise X722 to 100 Mbps,
since it is not supported, so we should not be able to advertise or
set the NIC to 100 Mbps.

Alan fixes an issue where deleting a MAC filter did not really delete the
filter in question.  The reason being that the wrong cmd_flag is passed to
the firmware.

Preethi adds the encapsulation checksum offload negotiation flag, so that
we can control it.

Jake cleans up the ATR auto_disable_flags use, since some locations
disable ATR accidentally using the "full" disable by disabling the flag
in the standard flags field.  This permanently forces ATR off instead of
temporarily disabling it.  Then updated checks to include when there are
TCP/IP4 sideband rules in effect, where ATR should be disabled.  Lastly,
adds support to the i40evf driver for setting interrupt moderation values
per queue, like in i40e.

Henry cleans up unreachable code, since i40e_shutdown_adminq() is always
true.

Mitch enables support for adaptive interrupt throttling, since all the
code for it is already in the interrupt handler.  The fixes a rare
case where we might get a VSI with no queues and we try to configure
RSS, which would result in a divide by zero.

Alex fixes an issue where transmit cleanup flow was incorrectly assuming
it could check for the flow director bits after it had unmapped the
buffer.  Then adds a txring_txq() to allow us to convert a i40e_ring/
i40evf_ring to a netdev_tx_queue structure, like ixgbe and fm10k.  This
avoids having to make a multi-line function call for all the areas that
need access to it.  Re-factors the Flow Director filter configuration
out into a separate function, like we did for the standard xmit path.
Cleans up the debugfs hook for Flow Director since it was meant for
debug only.

The following are changes since commit c2675de447f8238e7e2e7eced78fa671d42a9a7e:
  gre: use nla_get_be32() to extract flowinfo
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Akeem Abodunrin (1):
  i40e: Increase minimum number of allocated VSI

Alan Brady (1):
  i40e: fix deleting mac filters

Alexander Duyck (4):
  i40e: Fix Flow Director raw_buf cleanup
  i40e/i40evf: Add txring_txq function to match fm10k and ixgbe
  i40e: Split Flow Director descriptor config into separate function
  i40e: Strip out debugfs hook for Flow Director filter programming

Bimmy Pujari (1):
  i40e/i40evf: Changed version to 1.6.16

Harshitha Ramamurthy (1):
  i40e: Remove 100 Mbps SGMII support for X722

Henry Tieman (1):
  i40e: removing unreachable code

Jacob Keller (3):
  i40e: cleanup ATR auto_disable_flags use
  i40e: check conflicting ntuple/sideband rules when re-enabling ATR
  i40evf: support queue-specific settings for interrupt moderation

Mitch Williams (2):
  i40evf: enable adaptive interrupt throttling
  i40e: don't configure zero-size RSS table

Preethi Banala (1):
  i40e: add encap csum VF offload flag

 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  80 --------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  75 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  45 ++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 180 ++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   9 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  51 +++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  17 ++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   7 -
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 206 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  16 +-
 13 files changed, 424 insertions(+), 268 deletions(-)

-- 
2.7.4
