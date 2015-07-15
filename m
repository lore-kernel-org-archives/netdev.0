From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/16][pull request] Intel Wired LAN Driver Updates 2015-07-14
Date: Tue, 14 Jul 2015 18:30:24 -0700
Message-ID: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbbGOBao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Joe Stringer and Jesse Gross add a ndo_features_check function to ensure
that the i40e driver does not try to offload packets that exceed 80 bytes
in length.

Anjali adds additional stats to track flow director ATR and SB current
state and flow director flush count which will help the need for verbose
debug logs with respect to flow director.  Also refines an error message
to avoid confusion, so that it indicates what may have really happened
when the init_shared_code() call possibly fails.

Pawel adds new fields to the capabilities structures to handle Flex-10
device/function capabilities which is needed to support Flex-10 configs.

Jesse improves the transmit performance by added a prefetch for the
next transmit descriptor to be used when we know there are more coming.

Mitch modifies i40evf driver to handle/allow an abundance of vectors.
Currently the driver only maps transmit and receive queues to a single
MSI-X vector per queue if there are exactly enough vectors for this, but
if we have too many vectors, it will fail and allocate queues to vectors
in a suboptimal manner.  So change the condition check to allow for an
excess number of vectors and won't use the extras.  Also update the
driver to just return success if the user attempts to set a port VLAN on
a VF that already has the same port VLAN configured, instead of going
through unnecessary filter removals & adds.  Fix the MAC filters for VFs,
which were being programmed with 0 for the VLAN value when there was no
VLAN assigned.  Instead, we must use -1 to indicate that no VLAN is in
use.  Fix the VF disable code, which was not properly cleaning up the VF
and would leave the VF in an indeterminate state, so fix this by
notifying the VF and then call the normal VF reset routine.  Fix the
logic in the driver so that MAC filters are added and removed correctly
and added a check for the driver's hardware MAC address so that this
filter does not get removed incorrectly.

Carolyn removes incorrect #ifdef's which should not have been added in
the first place and with the #ifdef's removed, make the necessary
changes in the driver to resolve compile errors.

Greg updates the admin queue command header defines.

v2: fix indentation in patch 12 based on feedback from Sergei Shtylyov

The following are changes since commit aad0d51e933f8656880592020319d2dbd09532a2:
  ravb: kill useless initializers
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (2):
  i40e/i40evf: Add stats to track FD ATR and SB dynamic enable state
  i40e: Refine an error message to avoid confusion

Carolyn Wyborny (1):
  i40e: Remove incorrect #ifdef's

Catherine Sullivan (1):
  i40e/i40evf: Bump version to 1.3.6 for i40e and 1.3.2 for i40evf

Faisal Latif (1):
  i40e/i40evf: Add support for pre-allocated pages for PD

Greg Rose (1):
  i40e/i40evf: Update the admin queue command header

Jesse Brandeburg (1):
  i40e/i40evf: improve Tx performance with a small tweak

Joe Stringer (1):
  i40e: Implement ndo_features_check()

Mitch Williams (7):
  i40evf: Allow for an abundance of vectors
  i40e: ignore duplicate port VLAN requests
  i40e: correctly program filters for VFs
  i40e: do a proper reset when disabling a VF
  i40e: un-disable VF after reset
  i40evf: don't delete all the filters
  i40evf: add MAC address filter in open, not init

Pawel Orlowski (1):
  i40e/i40evf: Update Flex-10 related device/function capabilities

 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 24 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 24 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  2 +
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         | 30 ++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 51 ++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 14 +++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 23 +++++-----
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 18 +++-----
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  2 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 14 +++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 20 +++------
 15 files changed, 155 insertions(+), 79 deletions(-)

-- 
2.4.3
