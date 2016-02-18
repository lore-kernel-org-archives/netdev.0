From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-17
Date: Wed, 17 Feb 2016 19:38:42 -0800
Message-ID: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:4847 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424151AbcBRDjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf only (again).

Jesse moves sync_vsi_filters() up in the service_task because it may need
to request a reset, and we do not want to wait another round of service
task time.  Refactored the enable_icr0() in order to allow it to be
decided by the caller whether the CLEARPBA (clear pending events) bit will
be set while re-enabling the interrupt.  Also provides the "Don't Give Up"
patch, where the driver will keep polling trying to allocate receive buffers
until it succeeds.  This should keep all receive queues running even in
the face of memory pressure.  Cleans up the debugging helpers by putting
everything in hex to be consistent.

Neerav updates the DCB firmware version related checkes specific to X710
and XL710 only since the checks are not required for X722 devices.

Shannon adds the use of the new shared MAC filter bit for multicast and
broadcast filters in order to make better use of the filters available
from the device.  Added a parameter to allow the driver to set the
enable/disable of statistics gathering in the hardware switch.  Also the
L2 cloud filtering parameter is removed since it was never used.

Anjali refactors the force_wb and WB_ON_ITR functionality since
Force-WriteBack functionality in X710/XL710 devices has been moved out of
the clean routine and into the service task, so we need to make sure
WriteBack-On-ITR is separated out since it is still called from clean.

Catherine changes the VF driver string to reflect all the products that
are supported.

Mitch refactors the packet split receive code to properly use half-pages
for receives.  Also changes the use of bitwise operators to logical
operators on clean_complete variable, while making a witty reference to
Mr. Spock.  Cleans up (i.e. removes) the hsplit field in the ring
structure and use the existing macro to detect packet split enablement,
which allows debugfs dumps of the VSI to properly show which recevie
routine is in use.

The following are changes since commit 36b6f2cf7edd841c0b0eb7a5ec09c22bd6b5018c:
  Merge branch 'inet_lro-remove'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (1):
  i40e: Refactor force_wb and WB_ON_ITR functionality code

Catherine Sullivan (1):
  i40evf: Change vf driver string to reflect all products i40evf
    supports

Jesse Brandeburg (6):
  i40e: move sync_vsi_filters up in service_task
  i40e/i40evf: don't lose interrupts
  i40e/i40evf: try again after failure
  i40e: dump descriptor indexes in hex
  i40e/i40evf: use __GFP_NOWARN
  i40e/i40evf: Bump version

Mitch Williams (3):
  i40e/i40evf: use pages correctly in Rx
  i40e/i40evf: use logical operators, not bitwise
  i40e: properly show packet split status in debugfs

Neerav Parikh (1):
  i40e: Make the DCB firmware checks for X710/XL710 only

Shannon Nelson (3):
  i40e: set shared bit for multicast filters
  i40e: add VEB stat control and remove L2 cloud filter
  i40e: use new add_veb calling with VEB stats control

 drivers/net/ethernet/intel/i40e/i40e.h             |  23 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  25 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  51 +++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 249 +++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 253 ++++++++++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  10 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   6 +-
 12 files changed, 445 insertions(+), 223 deletions(-)

-- 
2.5.0
