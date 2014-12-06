From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/16][pull request] Intel Wired LAN Driver Updates 2014-12-06
Date: Sat,  6 Dec 2014 05:01:57 -0800
Message-ID: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbaLFNC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Shannon provides several patches to cleanup and fix i40e.  First removes
an unneeded break statement in i40e_vsi_link_event().  Then removes
some debug messages that really do not give any useful information and
ends up getting printed every service_task loop, which fills the logfile
with noise when AQ tracing is enabled.  Updates the aq_cmd arguments to
use %i which is much more forgiving and user friendly than the more
restrictive %x, or %d.  Fixes the netdev_stat macro, where the old
xxx_NETDEV_STAT() macro was defined long before the newer
rtnl_link_stats64 came into being, and just never got updated.
Getting the pf_id from the function number had an issue when
when the PF was setup in passthru mode, the PCI bus/device/function
was virtualized and the number in the VM is different from the number in
the bare metal.  This caused HW configuration issues when the wrong pf_id
was used to set up the HMC and other structures.  The PF_FUNC_RID register
has the real bus/device/function information as configured by the BIOS,
so use that for a better number.

Carolyn adds additional text description for the base pf0 and flow
director generated interrupts, since these interrupts are difficult
to distinguish per port on a multi-function device.

Jacob resolves an issue related to images with multiple PFs per
physical port.  We cannot fully support 1588 PTP features, since only
one port should control (i.e. write) the registers at a time.  Doing
so can cause interference of functionality.

Anjali provides several updates to i40e, first adds the Virtual Channel
OP event opcode for CONFIG_RSS, so that the Virtual Channel state
machine can properly decipher status change events.  Then updates the
driver to add (and use) i40e_is_vf macro for future expansion when new
VF MAC types get added.  Adds new update VSI flow to accommodate a
firmware dix with VSI loopback mode.  All VSIs on a VEB should either
have loopback enabled or disabled, a mixed mode is not supported for a
VEB.  Since our driver supports multiple VSIs per PF that need to talk to
each other make sure to enable Loopback for the PF and FDIR VSI as well.

Mitch provides a couple of i40e and i40evf patches.  First updates
i40evf init code more adept at handling when multiple VFs attempt
to initialize simultaneously.

Joe Perches provides a i40e patch which resolves a compile warning
about about frame size being larger than 2048 bytes by reducing the
stack use by using kmemdup and not using a very large struct on the
stack.

v2:
 - Dropped patch 13 & 14 while Mitch reworks the patches based on
   feedback from Ben Hutchings, probably the tryptophan in the turkey
   is to blame for the delay...
 - Added Joe Perches patch which resolves a compile warning about frame
   size

The following are changes since commit 8d0c4697534a739725e429ff062dea393d8860d1:
  Merge branch 'ebpf-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (4):
  i40e: Add a virtual channel op to config RSS
  i40e: Define and use i40e_is_vf macro
  i40e: Add new update VSI flow to accommodate FW fix with VSI Loopback
    mode
  i40e: Re enable Main VSI loopback setting in the reset path

Carolyn Wyborny (1):
  i40e: Add description to misc and fd interrupts

Catherine Sullivan (1):
  i40e: Bump i40e version to 1.2.2 and i40evf version to 1.0.6

Jacob Keller (1):
  i40e: don't enable PTP support on more than one PF per port

Joe Perches (1):
  i40e: Reduce stack in i40e_dbg_dump_desc

Kevin Scott (1):
  i40e: Increase reset delay

Mitch Williams (2):
  i40evf: make early init sequence even more robust
  i40e: increase ARQ size

Shannon Nelson (5):
  i40e: Remove unneeded break statement
  i40e: remove useless debug noise
  i40e: allow various base numbers in debugfs aq commands
  i40e: fix netdev_stat macro definition
  i40e: get pf_id from HW rather than PCI function

 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  5 +---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 25 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 34 ++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  7 ++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 34 ++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 32 +++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  5 +---
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 11 +++++--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 16 ++++------
 16 files changed, 107 insertions(+), 75 deletions(-)

-- 
1.9.3
