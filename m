From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/12][pull request] 40GbE Intel Wired LAN Driver Updates 2017-03-15
Date: Wed, 15 Mar 2017 02:25:33 -0700
Message-ID: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52220 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751694AbdCOJZy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:25:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Aaron fixes an issue on x710 devices where simultaneous read accesses
were interfering with each other, so make sure all devices acquire the
NVM lock before reads on all devices.

Shannon adds Wake On LAN support feature for x722 devices and cleaned
up the opcodes so that they are in numerical order.

Mitch adds a client interface to the VF driver, in preparation for the
upcoming RDMA-capable hardware (and client driver).  Cleaned up the
client interface in the PF driver, since it was originally over
engineered to handle multiple clients on multiple netdevs, but that
did not happen and now there will be one client per driver, so apply
the "KISS" (Keep It Simple & Stupid) to the i40e client interface.
Bumped the number of MAC filters an untrusted VF can create.

Jake fixes an issue where a recent refactor of queue pairs accidentally
added all remaining vecotrs to the num_lan_msix which can adversely
affect performance.

Lihong fixes an ethtool issue with x722 devices where "-e" will error
out since its EEPROM has a scope limit at offset 0x5B9FFF, so set the
EEPROM length to the scope limit.  Also fixed an issue where RSS
offloading only worked on PF0.

Filip cleans up and clarifies code comment so there is no confusion
about MAC/VLAN filter initialization routine.

Alex adds support for DMA_ATTR_SKIP_CPU_SYNC and DMA_ATTR_WEAK_ORDERING,
which improves performance on architectures that implement either one.

Harshitha cleans up confusion on flags disabled due to hardware limitation
versus featured disabled by the user, so rename auto_disable_flags to
hw_disabled_flags to avoid the confusion.

v2: Merged patch #1 and #4 in first version to make patch #3 in this
    series based on feedback from David Miller.

The following are changes since commit 9c79ddaa0f962d1f26537a670b0652ff509a6fe0:
  qed*: Add support for QL41xxx adapters
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Aaron Salter (1):
  i40e: Acquire NVM lock before reads on all devices

Alexander Duyck (1):
  i40e/i40evf: Add support for mapping pages with DMA attributes

Bimmy Pujari (1):
  i40e/i40evf: Change version from 1.6.27 to 2.1.7

Filip Sadowski (1):
  i40e: Clarify steps in MAC/VLAN filters initialization routine

Harshitha Ramamurthy (1):
  i40e: rename auto_disable_flags to hw_disabled_flags

Jacob Keller (1):
  i40e: don't add more vectors to num_lan_msix than number of CPUs

Lihong Yang (2):
  i40e: fix ethtool to get EEPROM data from X722 interface
  i40e: fix RSS queues only operating on PF0

Mitch Williams (3):
  i40evf: add client interface
  i40e: KISS the client interface
  i40e: Allow untrusted VFs to have more filters

Shannon Nelson (1):
  i40e: fix up recent proxy and wol bits for X722_SUPPORT

 drivers/net/ethernet/intel/i40e/i40e.h             |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  65 ++-
 drivers/net/ethernet/intel/i40e/i40e_client.c      | 457 ++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_client.h      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 115 +++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  51 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  10 +-
 drivers/net/ethernet/intel/i40evf/Makefile         |   2 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  65 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  31 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   3 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  33 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  29 +-
 drivers/net/ethernet/intel/i40evf/i40evf_client.c  | 563 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_client.h  | 166 ++++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  89 +++-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  13 +-
 20 files changed, 1333 insertions(+), 413 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_client.c
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40evf_client.h

-- 
2.12.0
