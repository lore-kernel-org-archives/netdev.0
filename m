From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-09-29
Date: Fri, 29 Sep 2017 17:44:52 -0700
Message-ID: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57175 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752591AbdI3Apt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jake provides several of the changes starting with the renaming of a
variable to clarify what the value is actually calculating. Found we
were misusing the __I40E_RECOVERY_PENDING bit to determine when we
should actually request a new IRQ in i40e_setup_misc_vector(), which
lead to a design mistake, so to resolve the issue, use a separate
state bit for miscellaneous IRQ setup and fix up the design while we
are at it.  Cleaned up the old legacy PM support in the driver since
we support the newer generic PM callbacks.  Fixed a failure to
hibernate issue, where on some platforms with a large number of CPUs,
we would allocate many IRQ vectors which we would try to migrate to
CPU0 when hibernating.

Sudheer cleans up a check for unqualified module inside i40e_up_complete()
because the link state information is in flux at time, so log messages
are getting logged with incorrect link state information.  Also provided
additional log message cleanups and simplify member variable access in
the printing of the link messages.

Mariusz relaxes the firmware check since Fortville and Fort Park NICs
can and do have different firmware versions, so only warn for older
Fortville firmware.  Fixed an errata with a flow director statistic that
was not wrapping as expected, simply reset after reading.

Mitch prevents consternation by lowering the log level to debug on a
message seen regularly on VF reset or unload, which is meaningless under
normal circumstances.  Refactor the firmware version checking since
Fortville and Fort Park devices can have different firmware versions.

Alan fixes a ring to vector mapping, where the past implementation
attempted to map each Tx and Rx ring to its own vector, however we use
combined queues so we should be mapping the Tx/Rx rings together on one
vector.  Adds the ability for the VF to request a different number of
queues allocated to it.

The following are changes since commit fa8fefaa678ea390b873195d19c09930da84a4bb:
  net: ipv4: remove fib_info arg to fib_check_nh
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40evf: fix ring to vector mapping
  i40e: Enable VF to negotiate number of allocated queues

Jacob Keller (6):
  i40e/i40evf: rename bytes_per_int to bytes_per_usec
  i40e: use separate state bit for miscellaneous IRQ setup
  i40e: use newer generic PM support instead of legacy PM callbacks
  i40e: don't clear suspended state until we finish resuming
  i40e: prevent service task from running while we're suspended
  i40e: shutdown all IRQs and disable MSI-X when suspended

Mariusz Stachura (2):
  i40e: relax warning message in case of version mismatch
  i40e: fix for flow director counters not wrapping as expected

Mitch Williams (2):
  i40evf: lower message level
  i40e: refactor FW version checking

Sudheer Mogilappagari (3):
  i40e: Fix unqualified module message while bringing link up
  i40e: Fix link down message when interface is brought up
  i40e: simplify member variable accesses

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 249 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  75 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  10 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  12 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  50 +----
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   2 +-
 include/linux/avf/virtchnl.h                       |  20 ++
 12 files changed, 294 insertions(+), 155 deletions(-)

-- 
2.14.1
