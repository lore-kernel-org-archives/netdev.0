From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/17][pull request] Intel Wired LAN Driver Updates 2015-10-19
Date: Mon, 19 Oct 2015 15:49:14 -0700
Message-ID: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbbJSWte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Kiran adds a spinlock around code accessing VSI MAC filter list to
ensure that we are synchronizing access to the filter list, otherwise
we can end up with multiple accesses at the same time which can cause
the VSI MAC filter list to get in an unstable or corrupted state.

Jesse fixes overlong BIT defines, where the RSS enabling call were
mistakenly missed.  Also fixes a bug where the enable function was
enabling the interrupt twice while trying to update the two interrupt
throttle rate thresholds for Rx and Tx, while refactoring the IRQ
enable function to simplify reading the flow.  Addressed the high
CPU utilization of some small streaming workloads that the driver should
reduce CPU in.

Anjali fixes two X722 issues with respect to EEPROM checksum verify and
reading NVM version info.  Fixed where a mask value was accidentally
replaced with a bit mask causing Flow Director sideband to be broken.

Alex Duyck fixes areas of the drivers which run from hard interrupt
context or with interrupts already disabled in netpoll, so use
napi_schedule_irqoff() instead of napi_schedule().

Mitch fixes the VF drivers to not easily give up when it is not able
to communicate with the PF driver.

Carolyn fixes a problem where our tools MAC loopback test, after driver
unbind would fail because the hardware was configured for multiqueue and
unbind operation did not clear this configuration.  Also fixed a issue
where the NVMUpdate tool gets bad data from the PHY when using the PHY
NVM feature because of contention on the MDIO interface from getting
PHY capability calls from the driver during regular operations.

Catherine fixed an issue where we were checking if autoneg was allowed
to change before checking if autoneg was changing, these checks need to
be in the reverse order.

Jean Sacren fixes up an function header comment to align the kernel-docs
with the actual code.

v2: Cleaned up the use of spin_is_locked() in patch 1 based on feedback
    from David Miller, since it always evaluates to zero on uni-processor
    builds

The following are changes since commit 371f1c7e0d854796adc622cc3bacfcc5fc638db1:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (1):
  i40e/i40evf: use napi_schedule_irqoff()

Anjali Singhai (1):
  i40e: Fix basic support for X722 devices

Anjali Singhai Jain (1):
  i40e/i40evf: Fix an accidental error with BIT_ULL replacement

Carolyn Wyborny (2):
  i40e: Fix for Tools loopback test failing after driver load
  i40e: fix for PHY NVM interaction problem

Catherine Sullivan (3):
  i40e: Fix order of checks when enabling/disabling autoneg in ethtool
  i40e: Move error message to debug level
  i40e/i40evf: Bump i40e to 1.3.38 and i40evf to 1.3.25

Jean Sacren (2):
  i40e: fix kernel-doc argument name
  i40e: declare rather than initialize int object

Jesse Brandeburg (5):
  i40evf: fix overlong BIT defines
  i40e/i40evf: refactor IRQ enable function
  i40e/i40evf: fix bug in throttle rate math
  i40e/i40evf: change dynamic interrupt thresholds
  i40e/i40evf: adjust interrupt throttle less frequently

Kiran Patil (1):
  i40e: Lock for VSI's MAC filter list

Mitch Williams (1):
  i40evf: don't give up

 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  17 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  35 ++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 327 +++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  31 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 166 +++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  26 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   5 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 163 ++++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  21 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   4 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   2 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  13 +-
 16 files changed, 611 insertions(+), 219 deletions(-)

-- 
2.4.3
