From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-09-20
Date: Tue, 20 Sep 2016 20:43:37 -0700
Message-ID: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753010AbcIUDny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Sridhar enables creation of a VF port Representor/Control netdev
associated with each VF, which allows control and configuring VFs from
Pfs namespace.  Then enables the VF specific ethtool statistics via the
VF port Representor.  Adds initial devlink support to set/get the mode
of a SRIOV switch.  Fixes link state event handling by updating the
carrier and starts/stops the Tx queues based on the link state
notification from PF.

Brady fixes an issue where a user defined RSS hash key was not being
set because a user defined indirection table is not supplied when changing
the hash key, so if an indirection table is not supplied now, then a
default one is created and the hash key is correctly set.  Also fixed
an issue where when NPAR was enabled, we were still using pf->mac_seid
to perform the dump port query. Instead, go through the VSI to determine
the correct ID to use in either case.

Mitch provides one fix where a conditional return code was reversed, so
he does a "switheroo" to fix the issue.

Carolyn has two fixes, first fixes an issue in the virt channel code,
where a return code was not checked for NULL when applicable.  Second,
fixes an issue where we were byte swapping the port parameter, then
byte swapping it again in function execution.

Colin Ian King fixes a potential NULL pointer dereference.

Amritha adds support for switchdev ops on the VF port representors and
the PF uplink.

Bimmy changes up i40evf_up_complete() to be void since it always returns
success anyways, which allows cleaning up of code which checked the
return code from this function.

Alex fixed an issue where the driver was incorrectly assuming that we
would always be pulling no more than 1 descriptor from each fragment.
So to correct this, we just need to make certain to test all the way to
the end of the fragments as it is possible for us to span 2 descriptors
in the block before us so we need to guarantee that even the last 6
descriptors have enough data to fill a full frame.

The following are changes since commit 5737f6c92681939e417579b421f81f035e57c582:
  mlx4: add missed recycle opportunity for XDP_TX on TX failure
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: fix setting user defined RSS hash key
  i40e: fix "dump port" command when NPAR enabled

Alexander Duyck (1):
  i40e: Limit TX descriptor count in cases where frag size is greater
    than 16K

Amritha Nambiar (1):
  i40e: Add support for switchdev API for Switch ID

Bimmy Pujari (1):
  i40evf: remove unnecessary error checking against i40evf_up_complete

Carolyn Wyborny (2):
  i40e: Fix to check for NULL
  i40e: Fix for extra byte swap in tunnel setup

Colin Ian King (1):
  i40e: avoid potential null pointer dereference when assigning len

Lihong Yang (1):
  i40evf: remove unnecessary error checking against i40e_shutdown_adminq

Mitch Williams (1):
  i40e: return correct opcode to VF

Sridhar Samudrala (5):
  i40e: Introduce VF port representor/control netdevs
  i40e: Enable VF specific ethtool statistics via VF Port representor
    netdevs
  i40e: Introduce devlink interface
  i40evf: Fix link state event handling
  i40e: Sync link state between VFs and VF Port representors(VFPR)

 drivers/net/ethernet/intel/Kconfig                 |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   7 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  84 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 120 +++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 196 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  16 ++
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   7 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  18 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  10 +-
 12 files changed, 428 insertions(+), 48 deletions(-)

-- 
2.7.4
