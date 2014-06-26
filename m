From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2014-06-26
Date: Thu, 26 Jun 2014 05:13:39 -0700
Message-ID: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10390 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757392AbaFZMO1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Kamil provides a cleanup patch to i40e where we do not need to acquire the
NVM for shadow RAM checksum calculation, since we only read the shadow RAM
through SRCTL register.

Paul provides a fix for handling HMC for big endian architectures for i40e
and i40evf.

Mitch provides four cleanup and fixes for i40evf.  Fix an issue where if
the VF driver fails to complete early init, then rmmod can cause a softlock
when the driver tries to stop a watchdog timer that never got initialized.
So add a check to see if the timer is actually initialized before stopping
it.  Make the function i40evf_send_api_ver() return more useful information,
instead of just returning -EIO by propagating firmware errors back to the
caller and log a message if the PF sends an invalid reply.  Fix up a log
message that was missing a word, which makes the log message more readable.
Fix an initialization failure if many VFs are instantiated at the same time
and the VF module is autoloaded by simply resending firmware request if
there is no response the first time.

Jacob does a rename of the function i40e_ptp_enable() to
i40e_ptp_feature_enable(), like he did for ixgbe, to reduce possible
confusion and ambugity in the purpose of the function.  Does follow on
PTP work on i40e, like he did for ixgbe, by breaking the PTP hardware
control from the ioctl command for timestamping mode.  By doing this,
we can maintain state about the 1588 timestamping mode and properly
re-enable to the last known mode during a re-initialization of 1588 bits.

Anjali cleans up the i40e driver where TCP-IPv4 filters were being added
twice, which seems to be left over from when we had to add two PTYPEs for
one filter.  Fixes the flow director sideband logic to detect when there
is a full flow director table.  Also fixes the programming of FDIR where
a couple of fields in the descriptor setup that were not being
programmed, which left the opportunity for stale data to be pushed as
part of the descriptor next time it was used.

The following are changes since commit 9b8d90b963dcc6d3f3f6a616b3547ea1c8b03525:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (3):
  i40e: Avoid adding the TCP-IPv4 filter twice
  i40e: Fix the FD sideband logic to detect a FD table full condition
  i40e: Add debugfs hooks to print current total FD filter count

Jacob Keller (4):
  i40e: rename i40e_ptp_enable to i40e_ptp_feature_enable
  i40e: break PTP hardware control from ioctl command for timestamp mode
  i40e: don't store user requested mode until we've validated it
  i40e: only create PTP device node once

Jesse Brandeburg (1):
  i40e: fix fdir programming

Kamil Krawczyk (1):
  i40e: do not take NVM ownership for SR read

Mitch Williams (4):
  i40evf: don't stop watchdog if it hasn't started
  i40evf: return more useful error information
  i40evf: fix typo
  i40evf: resend FW request if no response

Paul M Stillwell Jr (1):
  i40e/i40evf: Big endian fixes for handling HMC

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   4 +
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     | 247 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |  28 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  20 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 124 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  23 +-
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |  28 ++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  10 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  11 +-
 11 files changed, 373 insertions(+), 134 deletions(-)

-- 
1.9.3
