From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates 2014-08-27
Date: Wed, 27 Aug 2014 02:26:35 -0700
Message-ID: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64375 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932180AbaH0J0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Carolyn provides two patches, first changes the wording of the flow
director add/remove and asynchronous failure messages to include the
fd_id to try and add some way to track the operations on a given fd_id.
Second adds a check during handle_link_event for unqualified modules
when link is down and there is a module plugged in.

Anjali provides four patches to i40e/i40evf.  First update flow director
messages so that a user can tell if a filter was added or deleted.  Then
updates the ATR policy to not auto-disable ATR when we have errors in
programming.  The disabling of ATR when we got programming errors was
buggy and was still adding new rules and causing continuous errors.
With this policy change, we flush instead when we see too many errors.
In addition she adds a flow director flush counter to ethtool to help
know how many times the interface had to flush and replay the flow
director filter table.  Updates the driver to ignores a driver
perceived transmit hang if the number of descriptors pending is less
than 4, and instead log a stat when this situation happens.  This is
because the queue progresses forward and the stack never experiences
a real hang in these situations.

Shannon provides three patches for i40e/i40evf, first enables the
l2tsel bit on receive queue contexts that are assigned to VFs so that
the VF can get the stripped VLAN tag.  Then adds a max buffer size
parameter to the print helper to be sure the code knows when to stop.
Lastly, remove the complaint when removing the default MAC VLAN filter.
This was because old firmware had an incorrect MAC VLAN filter that
needed to be replaced at startup, and now newer firmware does not have
this problem.  So now we only add the new filter if the removal
succeeded and no need to complain if the removal fails.

Ashish provides a change to vsi->num_queue_pairs to equal the number
that is configured by the VF.  This limits the number of queues that
are enabled/disabled and fixes the mismatch case for when a VF
configures fewer queues than is allocated to it by the PF.

The following are changes since commit a3d1214688d5259a200414def4d38f1e4531febd:
  neigh: document gc_thresh2
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (4):
  i40e: Some FD message fixes
  i40e: ATR policy change to flush the table to clean stale ATR rules
  i40e: Add a FD flush counter to ethtool
  i40e/i40evf: Ignore a driver perceived Tx hang if the number of desc
    pending < 4

Ashish Shah (1):
  i40e: set num_queue_pairs to num configured by VF

Carolyn Wyborny (2):
  i40e: Update flow director error messages to reduce user confusion
  i40e: Add checks and message for Qualified Module info

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e & i40evf version

Shannon Nelson (3):
  i40e: Enable l2tsel bit for VLAN tag control
  i40e/i40evf: add max buf len to aq debug print helper
  i40e: quiet complaints when removing default MAC VLAN filter and make
    set_mac reversible

 drivers/net/ethernet/intel/i40e/i40e.h             |   8 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   3 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  15 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 216 +++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  88 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  14 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   9 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 16 files changed, 301 insertions(+), 98 deletions(-)

-- 
1.9.3
