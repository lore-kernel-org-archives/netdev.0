From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-02
Date: Mon,  2 Oct 2017 12:48:37 -0700
Message-ID: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29126 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751469AbdJBTtS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Shannon Nelson fixes an issue where when a machine has more CPUs than
queue pairs, the counting gets a "little funky" and turns off Flow
Director.  So to correct it, limit the number of LAN queues initially
allocated to be sure there are some left for Flow Director and other
features.

Lihong cleans up dead code by removing a condition check which cannot
ever be true.

Christophe Jaillet fixes a potential NULL pointer dereference, which
could happen if kzalloc() fails.

Filip corrects the reporting of supported link modes, which was incorrect
for some NICs.  Added support for 'ethtool -m' command, which displays
information about QSFP+ modules.

Mariusz adds functions to read/write the LED registers to control the
LEDS, instead of accessing the registers directly whenever the LEDs
need to be controlled.

Jake fixes a regression where we introduced a scheduling while atomic,
so introduce a separate helper function which will manage its own need
for the mac_filter_hash_lock.  Also cleaned up the "PF" parameter in
i40e_vc_disable_vf() since it is never used and is not needed.  Fixed
a rare case where it is possible that a reset does not occur when
i40e_vc_disable_vf() is called, so modify i40e_reset_vf() to return a
bool to indicate whether it reset or not so that i40e_vc_disable_vf()
can wait until a reset actually occurs.

Alan adds the ability for the VF to request more or less underlying
allocated queues from the PF.  Fixes the incorrect method for clearing
the vf_states variable with a NULL assignment, when we should be
using atomic bitops since we don't actually want to clear all the
flags.  Fixed a resource leak, where the PF driver fails to inform
clients of a VF reset because we were incorrectly checking the
I40E_VF_STATE_PRE_ENABLE bit.

Mitch converts i40evf_map_rings_to_vectors() to a void function since
it cannot fail and allows us to clean up the checks for the function
return value.

Scott enables the driver(s) to pass traffic with VLAN tags using the
802.1ad Ethernet protocol.

The following are changes since commit 1dd236fda0c500a21c54f2140dadc488cde9265b:
  Merge branch 'mlxsw-Fixlets'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (3):
  i40evf: Enable VF to request an alternate queue allocation
  i40e: fix handling of vf_states variable
  i40e: fix client notify of VF reset

Christophe JAILLET (1):
  i40e: Fix a potential NULL pointer dereference

Filip Sadowski (2):
  i40e: Fix reporting of supported link modes
  i40e: Add support for 'ethtool -m'

Jacob Keller (4):
  i40e: don't hold spinlock while resetting VF
  i40e: drop i40e_pf *pf from i40e_vc_disable_vf()
  i40e: make use of i40e_vc_disable_vf
  i40e: ensure reset occurs when disabling VF

Lihong Yang (1):
  i40e: remove logically dead code

Mariusz Stachura (1):
  i40e: use admin queue for setting LEDs behavior

Mitch Williams (1):
  i40e: make i40evf_map_rings_to_vectors void

Scott Peterson (1):
  i40e: Stop dropping 802.1ad tags - eth proto 0x88a8

Shannon Nelson (1):
  i40e: limit lan queue count in large CPU count machine

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  12 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  55 +++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 201 ++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 154 ++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  18 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   9 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  19 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 102 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   5 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  55 +++++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  69 +++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   9 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  20 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  38 +++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  97 +++++++++-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  44 ++++-
 17 files changed, 837 insertions(+), 74 deletions(-)

-- 
2.14.2
