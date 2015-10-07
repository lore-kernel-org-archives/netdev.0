From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] Intel Wired LAN Driver Updates 2015-10-07
Date: Wed,  7 Oct 2015 15:46:54 -0700
Message-ID: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:33566 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbbJGWrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Paul updates i40e to simply increase the amount of time we wait for a
reset to complete since we have seen in some rare occasions the reset
can take longer to complete.

Shannon updates the driver to turn on Wake-on-LAN by default if it is
enabled in the hardware config to begin with, rather than always disable
it and wait for the user to expressly turn it on.  Added new device id's
and support for future devices.  Fixed a possible type compare problem
between a size and possible negative number.  Also fixed a shift value
that was wrong, which ended up with a bad bitmask.  Did general house
cleaning of the driver to cleanup several low lying fruit in the
driver.  Fixed an issue where new unicast address's would be added to
the VSI list and then immediately removed and would never actually
make it down to the hardware.  Resolved the issue by removing the
separation from unicast and multicast in the search for filters to be
deleted.

Mitch fixes an issue where the hardware would continue to access the
memory formerly used by the rings for a VF which have been removed,
causing memory corruption or DMAR errors.  To relieve this condition,
explicitly stop all rings associated with each VF before releasing its
resources.  Also fixed a panic if the driver is unable to enable MSI-X
or its unable to acquire enough vectors, so propagate interrupt
allocation failure information to the calling function.  Cleaned up
opcode that is not required.

Carolyn extends the size of the test available for the interrupt names
so that all the descriptive data available for the Flow Director
interrupts is not truncated.

Catherine fixes an issue where there was a possibility of speed getting
set to 0 if advertised is set to 0 (which is the case when autoneg is
disabled).

Jesse fixes the checksum on big endian machines, so added code to swap
it correctly.  Also fixed a bug in the return from get_link_status()
where only true or false was being returned, but false could mean
multiple things.  So allow the caller to get all the return values
in the call chain bubbled back to the source so that the reason for
the failure does not get lost.

Anjali adds statistics to keep track of how many times we ask the stack
to linearize the SKB because the hardware cannot handle SKBs with more
than 8 frags per segment/single packet.

The following are changes since commit acb4a6bfc80ddeea4c44074dd630f916259e909e:
  tcp: ensure prior synack rtx behavior with small backlogs
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (1):
  i40e/i40evf: Add a stat to keep track of linearization count

Carolyn Wyborny (1):
  i40e: Fix for truncated interrupt name

Catherine Sullivan (1):
  i40e: Never let speed get set to 0 in get_settings

Jesse Brandeburg (2):
  i40e: add little endian conversion for checksum
  i40e: fix bug in return from get_link_status and avoid spurious link
    messages

Mitch Williams (3):
  i40e: stop VF rings
  i40evf: propagate interrupt allocation failure
  i40e/i40evf: remove unused opcode

Neerav Parikh (1):
  i40e: Additional checks for CEE APP priority validity

Paul M Stillwell Jr (1):
  i40e: Increase the amount of time we wait for reset to be done

Shannon Nelson (8):
  i40e: enable WoL operation if config bit show WoL capable
  i40e/i40evf: add driver support for new device ids
  i40e/i40evf: fix a potential type compare issue
  i40e: fix bad CEE status shift value
  i40e: make i40e_init_pf_fcoe to void
  i40e/i40evf: assure clean asq status report
  i40e/i40evf: give up the __func__
  i40e/i40evf: fix unicast mac address add

 drivers/net/ethernet/intel/i40e/i40e.h             |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   2 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  18 ++--
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |  48 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  20 +++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 116 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   1 -
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   5 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   5 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  56 +++++-----
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  59 +++++------
 26 files changed, 207 insertions(+), 171 deletions(-)

-- 
2.4.3
