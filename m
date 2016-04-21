From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] 100GbE Intel Wired LAN Driver Updates 2016-04-20
Date: Wed, 20 Apr 2016 23:09:12 -0700
Message-ID: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbcDUGJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jacob provides majority of the changes in this series, starting with the
addition of helper functions to reduce code duplication and the amount
of code indentation.  Fixed the use or should we say abuse of the ethtool
stats API, which could result in corrupt memory or misleading statistic
output.  Added the appropriate rtnl_lock() and rtnl_unlock() to avoid
RCU warnings during AER events.  Come to find out, the PTP/1588 support
is not working with the current version of switch management software
and possibly never worked, so just remove support for PTP/1588 for now.
Fixed how error responses from the switch manager after a LPORT_MAP
request are handled, originally which were silently being ignored.
Fixed up code documentation to hopefully ease the code and comment
comprehension.  Fixed a possible NULL pointer dereference after a
kcalloc(), where when writing a new default redirection table, and we
needed to populate a new RSS table using ethtool_rxfh_indir_default().
We populate this table into a region of memory allocated using kcalloc()
but never check it for NULL.

Alex adds support for bulk transmit cleanup for fm10k, like he did for
all of our other drivers.

Ngai-Mint fixes a number of issues with the unicast and multicast address
syncs.  Where an issue would occur when the netdev is pre-configured to
either multicast mode and is enabled for the first time.

The following are changes since commit 10c9ead9f3c6bb24bddc9a96681f7d58e6623966:
  rtnetlink: add new RTM_GETSTATS message to dump link stats
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Alexander Duyck (1):
  fm10k: Add support for bulk Tx cleanup & cleanup boolean logic

Jacob Keller (14):
  fm10k: add helper functions to set strings and data for ethtool stats
  fm10k: remove debug-statistics support
  fm10k: use DRV_SUMMARY to reduce code duplication
  fm10k: prevent RCU issues during AER events
  fm10k: drop 1588 support
  fm10k: correctly handle LPORT_MAP error
  fm10k: do not disable PCI device in fm10k_io_error_detected
  fm10k: fix documentation of fm10k_tlv_parse_attr
  fm10k: use 8bit notation instead of 10bit notation for diagram
  fm10k: use different name than FM10K_VLAN_CLEAR for override bit
  fm10k: update comment regarding reserved bits check
  fm10k: fix possible null pointer deref after kcalloc
  fm10k: consistently use Intel(R) for driver names
  fm10k: fix incorrect IPv6 extended header checksum

Ngai-Mint Kwan (2):
  fm10k: Fix multicast mode sync issues
  fm10k: Reset multicast mode when deleting lport

 drivers/net/ethernet/intel/fm10k/Makefile        |   7 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  37 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.h  |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 187 +++------
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  85 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  44 +--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 154 ++------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 121 +-----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      |  21 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     | 462 -----------------------
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     |  20 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  20 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  63 +---
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      |  14 +-
 21 files changed, 201 insertions(+), 1066 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c

-- 
2.5.5
