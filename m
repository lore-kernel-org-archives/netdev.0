From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-02-09
Date: Mon,  9 Feb 2015 02:43:46 -0800
Message-ID: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759464AbbBIKoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Rickard Strandqvist removes an unused function for i40e.

John Linville reorders a piece of code so that y_budget does not get used
by the FCoE code before it gets initialized.

Mitch adds a delay after VF reset with a minimum of 10ms to allow the
hardware internal FIFOs to flush.  Bumps up the ARQ descriptors, since
we can easily overrun the PF's admin receive queue.  Added locking around
the VF reset code, since during VF deallocation, we cannot depend on
simply masking the interrupt since this does not lock out the service task,
which can still call the reset routine.  Fix a potential multi-minute
delay on driver unload, VF disable or system shutdown.  When the module
is being unloaded, waiting for the PF to politely handle all of our admin
queue requests might take forever with a lot of VFs enabled, so just
stop everything and request a VF reset.  Also stops the watchdog during
shutdown to prevent a log full of admin queue errors and the occasional
hang when the system is shut down.

Anjali forces Tx descriptor writebacks on ITR by kicking off the SWINT
interrupt since we noticed that there are non-cache-aligned Tx
descriptors waiting in the ring while interrupts are disabled under NAPI.
Enables loopback for the FCoE VSI, so that VSIs can directly talk to each
other without going out on the wire.

Matthew fixes an LED blink issue by making sure to clear the GPIO blink
field, instead of OR'ing against zero if the field is already '1'.

Greg cleans up a function header comment.

Vasu helps biosdevname user tool to differentiate dev_port for PCoE netdev
and PF netdev, by setting different dev_port value for FCoE netdev.

Carolyn adds a call to u64_stats_init to the receive setup in order to
avoid lockdep errors with seqcount on newer kernels.

The following are changes since commit dd83829ed9da6262487252851ca0aa67600d7d56:
  Driver: Vmxnet3: Change the hex constant to its decimal equivalent
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40evf: Force Tx writeback on ITR
  i40e: Enable Loopback for the FCOE vsi as well

Carolyn Wyborny (1):
  i40e/i40evf: Add call to u64_stats_init to init

Greg Rose (1):
  i40e: Fix function header

John W Linville (1):
  i40e: avoid use of uninitialized v_budget in i40e_init_msix

Matt Jared (1):
  i40e: fix led blink toggle to enable steady state

Mitch Williams (7):
  i40e: delay after VF reset
  i40e: Use even more ARQ descriptors
  i40e: add locking around VF reset
  i40evf: reset on module unload
  i40evf: ignore bogus messages from FW
  i40evf: stop the watchdog for shutdown
  i40e: stop the service task at shutdown

Rickard Strandqvist (1):
  i40e: i40e_fcoe.c: Remove unused function

Vasu Dev (1):
  i40e: use dev_port for fcoe netdev

 drivers/net/ethernet/intel/i40e/i40e.h             |  5 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  6 ++--
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        | 16 ++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 14 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  6 ++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 25 +++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 40 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 23 +++++++++----
 9 files changed, 95 insertions(+), 41 deletions(-)

-- 
1.9.3
