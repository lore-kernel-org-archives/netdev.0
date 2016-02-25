From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] 1GbE Intel Wired LAN Driver Updates 2016-02-24
Date: Wed, 24 Feb 2016 18:14:47 -0800
Message-ID: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44722 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759006AbcBYC0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb and igbvf.

Raanan provides updates for e1000e, first increases the ULP timer since it
now takes longer for the ULP exit to complete on Skylake.  Fixes the
configuration of the internal hardware PHY clock gating mechanism, which was
causing packet loss due to mis configuring.  Fixed additional ULP
configuration settings which were not being properly cleared after cable
connect in V-Pro capable systems.  Added support for more i219 devices.

Takuma Ueba provides a fix for I210 where IPv6 autoconf test sometimes
fails due to DAD NS for link-local is not transmitted.  To avoid this
issue, we need to wait until 1000BASE-T status register "Remote receiver
status OK".

Todd provides a patch to override EEPROM WoL settings for specific OEM
devices. Then renamed igb defines to be more generic, since the define
E1000_MRQC_ENABLE_RSS_4Q enables 4 and 8 queues depending on the part.

Roland Hii fixes an issue where only the half cycle time of less than or
equal to 70 millisecond uses the I210 clock output function.  His patch
adds additional conditions when half cycle time is equal to 125 or 250 or
500 millisecond to use the clock output function.

Alex Duyck adds support for generic transmit checksums for igb and igbvf.

Jon Maxwell fixes an issues where customer applications are registering
and un-registering multicast addresses every few seconds which is leading
to many "Link is up" messages in the logs as a result of the
netif_carrier_off(netdev) in igbvf_msix_other().  So remove the
link is up message when registering multicast addresses.

Corinna Vinschen provides a fix for when switching off VLAN offloading on
i350, the VLAN interface becomes unusable.

Stefan Assmann updates the driver to use ndo_stop() instead of
dev_close() when running ethtool offline self test.  Since dev_close()
causes IFF_UP to be cleared which will remove the interfaces routes
and some addresses.

v2: Dropped patches 6-10 in the original series.  Patch 6-7 added support
    for character device for AVB and based on community feedback, we do not
    want to do this.  Patches 8-10 provided fixes to the problematic code
    added in patches 6 & 7.  So all of them must go!

The following are changes since commit 5aba8186856981672447d78a634ada8155b86eb6:
  Merge branch 'gianfar-xmit-improvements'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (2):
  igb: Add support for generic Tx checksums
  igbvf: Add support for generic Tx checksums

Corinna Vinschen (1):
  igb: Fix VLAN tag stripping on Intel i350

Jon Maxwell (1):
  igbvf: remove "link is Up" message when registering mcast address

Julia Lawall (1):
  igb: constify e1000_phy_operations structure

Raanan Avargil (5):
  e1000e: Increase ULP timer
  e1000e: Increase PHY PLL clock gate timing
  e1000e: Set HW FIFO minimum pointer gap for non-gig speeds
  e1000e: Clear ULP configuration register on ULP exit
  e1000e: Initial support for KabeLake

Roland Hii (1):
  igb: add conditions for I210 to generate periodic clock output

Stefan Assmann (1):
  igb: call ndo_stop() instead of dev_close() when running offline
    selftest

Takuma Ueba (1):
  igb: When GbE link up, wait for Remote receiver status condition

Todd Fujinaka (2):
  igb: enable WoL for OEM devices regardless of EEPROM setting
  igb: rename igb define to be more generic

 drivers/net/ethernet/intel/e1000e/hw.h       |   4 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c  |  30 +++-
 drivers/net/ethernet/intel/e1000e/ich8lan.h  |   7 +
 drivers/net/ethernet/intel/e1000e/netdev.c   |   4 +
 drivers/net/ethernet/intel/igb/e1000_82575.c |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h |   4 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h    |   2 +-
 drivers/net/ethernet/intel/igb/igb.h         |   2 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c    | 199 +++++++++++++++++----------
 drivers/net/ethernet/intel/igb/igb_ptp.c     |   3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c    | 143 ++++++++++---------
 drivers/net/ethernet/intel/igbvf/vf.h        |   1 +
 13 files changed, 261 insertions(+), 144 deletions(-)

-- 
2.5.0
