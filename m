From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/20][pull request] 1GbE Intel Wired LAN Driver Updates 2016-02-23
Date: Tue, 23 Feb 2016 20:26:04 -0800
Message-ID: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757101AbcBXE01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb and igbvf.

Raanan provides updates for e1000e, first increases the ULP timer since it
now takes longer for the ULP exit to complete on Skylake.  Fixes the
configuration of the internal hardware PHY clock gating mechanism, which was
causing packet loss due to mis configuring.  Fixed additional ULP
configuration settings which were not being properly cleared after cable
connect in V-Pro capable systems.  Added support for more i219 devices.

Gangfeng Huang provides a couple of patches for igb to add support for the
QAV tranmit mode and character device support for AVB, which is supported
in I210 devices.  The character device can be used for developing Audio
and Video Bridging or Industrial Ethernet (whatever that is) applications.

Julia Lawall then provides three fixes to the code added by Gangfeng Huang
to add character device support for AVB.  Guess I could have just fixed up
Gangfeng's patches the first time, but then Julia would not get credit for
fixing his code. :-)

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

The following are changes since commit a30a9ea6e21b495372aff549f3dfd63198bd1f45:
  rocker: fix rocker_world_port_obj_vlan_add()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (2):
  igb: Add support for generic Tx checksums
  igbvf: Add support for generic Tx checksums

Corinna Vinschen (1):
  igb: Fix VLAN tag stripping on Intel i350

Gangfeng Huang (2):
  igb: add function to set I210 transmit mode
  igb: add a character device to support AVB

Jon Maxwell (1):
  igbvf: remove "link is Up" message when registering mcast address

Julia Lawall (4):
  igb: fix compare_const_fl.cocci warnings
  igb: fix itnull.cocci warnings
  igb: fix semicolon.cocci warnings
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

 drivers/net/ethernet/intel/e1000e/hw.h         |   4 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |  30 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h    |   7 +
 drivers/net/ethernet/intel/e1000e/netdev.c     |   4 +
 drivers/net/ethernet/intel/igb/Makefile        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h   |   4 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |  22 ++
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   2 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   7 +
 drivers/net/ethernet/intel/igb/igb.h           |  21 +-
 drivers/net/ethernet/intel/igb/igb_cdev.c      | 510 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_cdev.h      |  45 +++
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 484 ++++++++++++++++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c      | 143 ++++---
 drivers/net/ethernet/intel/igbvf/vf.h          |   1 +
 18 files changed, 1136 insertions(+), 159 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_cdev.c
 create mode 100644 drivers/net/ethernet/intel/igb/igb_cdev.h

-- 
2.5.0
