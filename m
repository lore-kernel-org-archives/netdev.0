From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates 2015-11-24
Date: Tue, 24 Nov 2015 16:04:30 -0800
Message-ID: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbbKYAEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k, i40e and i40evf.

Alex Duyck fixes up fm10k to use napi_schedule_irqoff() instead of
napi_schedule() since the function it is called from runs from hard interrupt
context or with interrupts already disabled in netpoll.

Shannon cleans up i40e and i40evf unused cd_tunneling parameter and any code
comments that refer to it.  Then clean up a few instances of BUG_ON, based
on a Linux diatribe, especially when WARN_ON can be used.

Helin fixes pointer arithmetic, where a pointer of type void should not be
used in arithmetic since it may result in a compilation error, instead
add a u8 cast to resolve the issue.  Fixed a issue where using ethtool RXNFC
command could let receive flow hash could be set on disabled queues, so
resolve by returning the number of enabled queues before setting RXNFC.

Anjali fixes a MSS issue where the hardware/NVM sets a limit of no less than
256 bytes for MSS, yet the stack can send as low as 76 byte MSS.  Fixed the
issue by lowering the hardware limit to 64 bytes to avoid MDDs from firing
and causing a reset when the MSS is lower than 256.  Added a statistic to
track how many times we forced to do a write back on transmit if the
number of descriptors pending are less than a cache line.

Catherine fixes link status changes, where polling would only change link
status changes in one direction depending on what the last old data saved
off was.  This was due to the watchdog only calling link_event and not
handle_link_event.

Mitch cleans up and enhances error messages related to VF MAC/VLAN filters.

The following are changes since commit 724fe6955c88db8b249681cd78a76c10163bb0ba:
  drivers: net: xgene: optimizing the code
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (1):
  fm10k: use napi_schedule_irqoff()

Anjali Singhai Jain (2):
  i40e: Workaround fix for mss < 256 issue
  i40e/i40evf: Add a stat to track how many times we have to do a force
    WB

Catherine Sullivan (2):
  i40e: Move the saving of old link info from handle_link_event to
    link_event
  i40e: Bump version to 1.4.2

Helin Zhang (5):
  i40e: Properly cast type for arithmetic
  i40e/i40evf: Add comment to #endif
  i40e: return the number of enabled queues for ETHTOOL_GRXRINGS
  i40e: rework the functions to configure RSS with similar parameters
  i40e: create a generic configure rss function

Mitch Williams (2):
  i40e/i40evf: clean up error messages
  i40evf: handle many MAC filters correctly

Shannon Nelson (4):
  i40e/i40evf: remove unused tunnel parameter
  i40e: Change BUG_ON to WARN_ON in service event complete
  i40e: remove BUG_ON from feature string building
  i40e: remove BUG_ON from FCoE setup

 drivers/net/ethernet/intel/fm10k/fm10k_pci.c       |   2 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  76 +++---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 255 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  21 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  12 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  58 ++++-
 14 files changed, 312 insertions(+), 141 deletions(-)

-- 
2.5.0
