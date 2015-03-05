From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2015-03-05
Date: Thu,  5 Mar 2015 08:46:18 -0800
Message-ID: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8609 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756890AbbCEQqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Greg provides fixes for the NPAR transmit scheduler where the driver
initialization caused the BW configurations to not take effect, so use
a BW configuration read and write back to "kick" the transmit scheduler
into action.  Fixes the ethtool offline test, where we were not actually
taking the device offline before doing the testing.

Matt modifies the get and set LED functions so they ignore activity LEDs
since we are required to blink the link LEDs only.

Neerav provides a workaround for whenever a DCBX configuration is changed,
where the firmware doe not set the operational status bit of the
application TLV status as returned from the "Get CEE DCBX Oper Cfg" admin
queue command.  So remove the check for the operational and sync bits of
the application TLV status until a firmware fix is provided.

Shannon changes the driver to grab the NVM devstarter version and not
the image version, since it is the more useful version and is what
should be displayed.  Moves the IRQ tracking setup and tear down into
the same routines that do the IRQ setup and tear down.  This keeps
like activities together and allows us to track exactly the number
of vectors reserved from the OS, which may be fewer than are available
from the hardware.

Jesse provides a fix to use a more portable sign extension by replacing
0xffff.... with ~(u64)0 or ~(u32)0.  Also fixes XPS mask when resetting,
where the driver would accidentally clear the XPS mask for all queues
back to 0.  This caused higher CPU utilization and had some other
performance impacts for transmit tests.  Cleans up some whitespace
formatting.

Catherine provides a fix where some firmware versions are incorrectly
reporting a breakout cable as PHY type 0x3 when it should be 0x16
(I40E_PHY_TYPE_10GBASE_SFPP_CU).  Adds the 10G and 40G AOC PHY types
to the case statement in get_media_type and ethtool get_settings so
that the correct information gets reported back to the user. 

Anjali provides IOREMAP changes for future device support, where we
do not want to map the whole CSR space since some of it is mapped by
other drivers with different mapping methods.

Mitch changes the i40e driver to not "spam" the system log with
messages about VF VSI when VFs are created and when they are reset to
reduce user annoyance.

The following are changes since commit 66d06757d9eb74a29775737b8c770e3b57e536d9:
  net: bcmgenet: simplify __bcmgenet_tx_reclaim()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai (1):
  i40e: Ioremap changes

Catherine Sullivan (2):
  i40e: Reassign incorrect PHY type to fix a FW bug
  i40e: Add AOC PHY types to case statements

Greg Rose (2):
  i40e: Fix NPAR Tx Scheduler init
  i40e: Fix ethtool offline test

Jesse Brandeburg (3):
  i40e: use more portable sign extension
  i40e: fix XPS mask when resetting
  i40e/i40evf: Clean up some formatting and other things

Matt Jared (1):
  i40e: during LED interaction ignore activity LED src modes

Mitch A Williams (1):
  i40e: don't spam the system log

Neerav Parikh (1):
  i40e: Don't check operational or sync bit for App TLV

Shannon Nelson (2):
  i40e/i40evf: grab NVM devstarter version not image version
  i40e: move IRQ tracking setup into MSIX setup

Sravanthi Tangeda (1):
  i40e/i40evf: Version bump

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 42 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 14 +++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  2 -
 drivers/net/ethernet/intel/i40e/i40e_fcoe.h        |  1 -
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 97 ++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  3 -
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  3 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  2 +-
 16 files changed, 114 insertions(+), 66 deletions(-)

-- 
1.9.3
