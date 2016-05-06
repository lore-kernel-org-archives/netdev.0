From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] 40GbE Intel Wired LAN Driver Updates 2016-05-05
Date: Fri,  6 May 2016 00:03:37 -0700
Message-ID: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40771 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbcEFHG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

The theme behind this series is code reduction, yeah!  Jesse provides
most of the changes starting with a refactor of the interpretation of
a tunnel which lets us start using the hardware's parsing.  Removed
the packet split receive routine and ancillary code in preparation
for the Rx-refactor.  The refactor of the receive routine,
aligns the receive routine with the one in ixgbe which was highly
optimized.  The hardware supports a 16 byte descriptor for receive,
but the driver was never using it in production.  There was no performance
benefit to the real driver of 16 byte descriptors, so drop a whole lot
of complexity while getting rid of the code.  Fixed a bug where while
changing the number of descriptors using ethtool, the driver did not
test the limits of the system memory before permanently assuming it
would be able to get receive buffer memory.

Mitch fixes a memory leak of one page each time the driver is opened by
allocating the correct number of receive buffers and do not fiddle with
next_to_use in the VF driver.

Arnd Bergmann fixed a indentation issue by adding the appropriate
curly braces in i40e_vc_config_promiscuous_mode_msg().

Julia Lawall fixed an issue found by Coccinelle, where i40e_client_ops
structure can be const since it is never modified.

The following are changes since commit 035cd6ba53eff060760c4f4d11339fcc916a967c:
  MAINTAINERS: Cleanup Intel Wired LAN maintainers list
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Arnd Bergmann (1):
  i40e: fix misleading indentation

Jesse Brandeburg (8):
  i40e/i40evf: Refactor tunnel interpretation
  i40e: Drop packet split receive routine
  i40e/i40evf: Remove reference to ring->dtype
  i40e: Refactor receive routine
  i40evf: Drop packet split receive routine
  i40evf: refactor receive routine
  i40e/i40evf: Remove unused hardware receive descriptor code
  i40e: Test memory before ethtool alloc succeeds

Julia Lawall (1):
  i40e: constify i40e_client_ops structure

Mitch Williams (1):
  i40evf: Allocate Rx buffers properly

 drivers/infiniband/hw/i40iw/i40iw_main.c           |   2 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_client.h      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  31 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  54 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  73 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 968 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  69 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   5 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 930 ++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  69 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   7 -
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  65 --
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  34 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   4 -
 15 files changed, 1062 insertions(+), 1262 deletions(-)

-- 
2.5.5
