From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] 40GbE Intel Wired LAN Driver Updates 2016-06-27
Date: Tue, 28 Jun 2016 21:40:46 -0700
Message-ID: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52537 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbcF2EoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:44:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Mitch provides several changes, first adds functions to enable and disable
VSI on a VEB, which allows for configuration of limited promiscuous mode
specifically for bridging purposes.  Sets the RSS Hash Enable registers by
default now that VF RSS is configured by the PF driver.  Fixed a issue
where we could overflow the buffer, by checking the address count and bail
out of the loop at the appropriate time.  Removed the need for a reset
when the device enters limited promiscuous mode, since this was causing
heartburn for people who were using VFs and bridging.

Catherine adds a call to set the client interface down when we put the VSI
down.  Fixed an issue where RSS queues was being limited to the number
of CPUs, so if a user wants to use more queues than CPUs, we want to
trust they know what they are doing and let them.

Greg cleans up the driver suspend routine to ensure we are calling
synchronize_irq() before freeing IRQ vectors and explicitly free the other
causes interrupt resources and shut down the MSIX interrupt.

Serey fixes i40e_set_settings() to not fail when a Direct Attach (DA)
cable is used.

Avinash fixes a supported link bug by removing code which was not allowing
100BaseT to show up in the supported link modes for 10GBaseT PHYs.

Shannon adds a bit of information to the error messages to help determine
the source of error by adding VSI info to macaddr messages.

Tushar Dave fixes error received when turning off TSO on some systems,
which was caused by enabling FD_SB without checking availability of
MSIx vectors, so add the check.

Neerav fixes a possible panic when LLDP/DCBX change happens and the
driver tried to notify the client(s) for each of the PF VSIs, which would
panic when it reached a VSI that did not have any netdev associated with
it.

The following are changes since commit de2fbe7ae3637533ebf711b91b04988633bf38ee:
  Merge branch 'sfp-infra'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Avinash Dayanand (1):
  i40e: Removing unnecessary code which caused supported link mode bug

Bimmy Pujari (1):
  i40e/i40evf: Bump version from 1.5.16 to 1.6.4

Catherine Sullivan (2):
  i40e: Add a call to set the client interface down
  i40e: Fix RSS to not be limited by the number of CPUs

Greg Rose (2):
  i40e: Clean up MSIX IRQs before suspend
  i40e: Save PCI state before suspend

Mitch Williams (6):
  i40e: add functions to control default VSI
  i40e: add hw struct local variable
  i40e: write HENA for VFs
  i40evf: don't overflow buffer
  i40evf: always activate correct MAC address filter
  i40e: set default VSI without a reset

Neerav Parikh (1):
  i40e: Don't notify client(s) for DCB changes on all VSIs

Serey Kong (1):
  i40e: fix missing DA cable check

Shannon Nelson (1):
  i40e: add VSI info to macaddr messages

Tushar Dave (1):
  i40e: Fix errors resulted while turning off TSO

 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  56 +++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 173 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   2 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   6 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   6 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   8 +
 8 files changed, 183 insertions(+), 73 deletions(-)

-- 
2.5.5
