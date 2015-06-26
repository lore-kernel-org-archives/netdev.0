From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 00/10][pull request] Intel Wired LAN Driver Updates 2015-06-26
Date: Fri, 26 Jun 2015 03:20:30 -0700
Message-ID: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58214 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677AbbFZKUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes for igb, e1000e and i40evf.

Todd disables IPv6 extension header processing due to a hardware errata
and bumps the driver version.

Yanir provides six fixes for e1000e.  First is a fix for a locking issue
where we were not always taking the pci_bus_sem semaphore all the time
when calling pci_disable_link_state_locked(), so fix the code to only call
pci_disable_link_state_locked() when the semaphore has been acquired,
otherwise call pci_disable_link_state().  A previous fix for i219 where
the hardware prevented ULP entry caused EEE in Sx not the be enabled, so
modify the code flow that allows both ULP and EEE in Sx.  Fix an issue
when running 10/100 full duplex on i219 where CRC errors were occurring
by increasing the IPG from 8 to 0xC as per the hardware developers.
Fix a data corruption issue found on some platforms by increasing the
minimum gap between the PHY FIFO read and write pointers.  Fix i219,
which does not require the K1 workaround for LPT devices.

Mitch provides a i40evf fix for a panic when changing MTU.  Down was
requesting queue disables, but then exited immediately without waiting
for the queues to actually be disabled.  This could allow any function
called after i40evf_down() to run immediately, including i40evf_up(),
and causes a memory leak.  Fixed the issue by removing the whole
reinit_locked function which allows for the driver to handle the state
changes by requesting reset from the periodic timer.  The second fix
resolves an issue where RSS was being configured as though it is using
the maximum number of queue.  This can cause the device to drop a lot
of receive traffic, as the packets get assigned to non-functional queues.
This is resolved by only configuring RSS with the number of active queues.

The following are changes since commit 011cb197a84ed547c2b6b12a86adbeec1be0fdaf:
  Merge branch 'bnx2x'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Mitch Williams (2):
  i40evf: fix panic during MTU change
  i40evf: don't configure unused RSS queues

Todd Fujinaka (2):
  igb: disable IPv6 extension header processing
  igb: bump version of igb to 5.2.18

Yanir Lubetkin (6):
  e1000e: fix locking issue with e1000e_disable_aspm
  e1000e: synchronization of MAC-PHY interface only on non- ME systems
  e1000e: i219 - fix to enable both ULP and EEE in Sx state
  e1000e: i219 - increase IPG for speed 10/100 full duplex
  e1000e: i219 - Increase minimum FIFO read/write min gap
  e1000e: i219 - k1 workaround for LPT is not required for SPT

 drivers/net/ethernet/intel/e1000e/ich8lan.c        | 126 ++++++++++++++++-----
 drivers/net/ethernet/intel/e1000e/netdev.c         |  38 ++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 110 ++++++++----------
 drivers/net/ethernet/intel/igb/e1000_82575.c       |  12 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h     |   3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   2 +-
 9 files changed, 198 insertions(+), 104 deletions(-)

-- 
2.4.3
