From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] Intel Wired LAN Driver Updates 2015-09-23
Date: Wed, 23 Sep 2015 23:59:23 -0700
Message-ID: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31471 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbbIXG7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Mark provides all the changes in this series, first clears the destination
location for I2C data initially so that the received data will not be
corrupted by previous attempts.  Then reduced the pauses/delays in the
PHY detection when no SFP is present by reducing the number of retires,
once an SFP is detected, the "normal" number of retries in PHY detection
will be used.  Added support for X55EM_x SFP+ dual-speed, and fixed 1G and
10G link stability for X550EM_x by configuring the CS4227 correctly by
moving code to ixgbe_setup_mac_link_sfp_x550em().  Added functionality to
reset CS4227, since on some platforms the CS4227 does not initialize
properly.  Next reduces the SFP polling rate, due to when an SFP is not
present, the I2C timeouts that result are very costly.  So prevent the
SFP polling from being done more than once every two seconds.  Added
support for I2C bus MUX.  Fixed the setting of RDRXCTL register which
should fall through X540 and 82599, not 82598.  In addition, added small
packet padding support in X550 by setting RDRXCTL.PSP when the driver is
in SRIOV mode.  Fixed a known hardware issue where the PCI transactions
pending bit sticks high when there are pending transactions, so
workaround the issue by wait and then continue with our reset flow.
Added a new device ID for X550EM device with SFPs.  Provided a fix with
the DCA setup, which was suggested by Alex Duyck <aduyck@mirantis.com>,
by making it so that we always set the relaxed ordering bits related to
the DCA registers even if DCA is not enbaled.  Then moves the
configuration out of the ixgbe_down() and into ixgbe_configure() before
enabling the transmit and receive rings.  This ensures that DCA is
configured correctly before starting the processing of packets.
Fixed VM-to-VM loopback mode which requires that FCRTH be set, but
the datasheets did not specify what the value should be.  It has now
been determined that the correct value should be RXPBSIZE - (24*1024).

The following are changes since commit 06e60e5912c0373b15143cc52e4a11fafeaafff3:
  net/ethoc: support big-endian register layout
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Mark Rustad (18):
  ixgbe: Clear I2C destination location
  ixgbe: Allow reduced delays during SFP detection
  ixgbe: Add X550EM_x dual-speed SFP+ support
  ixgbe: Fix 1G and 10G link stability for X550EM_x SFP+
  ixgbe: Add logic to reset CS4227 when needed
  ixgbe: Allow SFP+ on more than 82598 and 82599
  ixgbe: Limit SFP polling rate
  ixgbe: Add I2C bus mux support
  ixgbe: Correct error path in semaphore handling
  ixgbe: Correct setting of RDRXCTL register for X550* devices
  ixgbe: Add small packet padding support for X550
  ixgbe: Update ixgbe_disable_pcie_master flow for X550*
  ixgbe: Add new X550EM SFP+ device ID
  ixgbe: Correct several flaws with with DCA setup
  ixgbe: Only clear adapter_stopped if ixgbe_setup_fc succeeded
  ixgbe: Fix FCRTH value in VM-to-VM loopback mode
  ixgbe: X540 thermal warning interrupt not a GPI
  ixgbe: Advance version to 4.2.1

 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     | 192 ++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    | 226 +++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  61 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |  21 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |  27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      | 102 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      | 485 +++++++++++++++++++--
 11 files changed, 855 insertions(+), 278 deletions(-)

-- 
2.4.3
