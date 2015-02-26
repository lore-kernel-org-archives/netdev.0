From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 00/13][pull request] Intel Wired LAN Driver Updates 2015-02-26
Date: Thu, 26 Feb 2015 07:03:36 -0800
Message-ID: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24849 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956AbbBZPD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes for i40e and i40evf only.

Alexey Khoroshilov found a possible leak of 'cmd_buf' when copy_from_user()
failed in i40e_dbg_command_write(), so resolved by calling kfree().

Shannon provides a fix to ensure the shift and bitwise precedences do not
work backwards for us by adding parans.  Fixed the driver by preventing
the driver from allowing stray interrupts or causing system logs from
un-handled interrupts by combining the ICR0 shutdown with the standard
interrupt shutdown and add the interrupt clearing to the PCI shutdown
path.  Fixed an issue where a NVM write times out before a transaction
can complete, so Shannon added logic to make another attempt by
reacquiring the semaphore, then retry the write, if the one retry fails,
we will then give up.  Adds checks to pointers before their use to ensure
we do not try to dereference NULL pointers when returning values from the
AdminQ calls.

Akeem adds a check to bail out if the device is already down when checking
for Tx hang subtask.

Anjali fixes TSO with more than 8 frags per segment issue.  The hardware
has some limitations which the driver needs to adhere to:
  1) no more than 8 descriptors per packet on the wire
  2) no header can span more than 3 descriptors
If one of these events happens, the hardware will generate an internal
error and freeze the Tx queue, so Anjali fixes this by linearizes the skb
to avoid these situations.  Fixed an issue where the per Traffic Class
queue count was higher than queues enabled, which will fix a warning
with multiple function mode where systems regularly have more cores than
vectors.  Fixed TCP/IPv6 over VXLAN Tx checksum offload, where we were
checking the outer protocol flags and deciding the flow for the inner
header.

Jesse fixes a race condition in the transmit hang detection.  Before we
were having issues of false Tx hang detection, no the driver makes more
direct with the checks for progress forward by directly checking the head
write back address and tail register when determining progress.  This
avoids Tx hangs where the software gets behind, because we are directly
checking hardware state when determining a hang state.

Neerav fixes the transmit ring Qset handle when DCB reconfigures. The issue
was when DCB is reconfigured to a single traffic class (TC) and the driver
did not reset the Tx ring Qset handle to correct the mapping, which caused
the Tx queue to disable timeouts.  Also as part of DCB reconfiguration flow
if the Tx queue disable times out, then issue a PF reset to do some level
of recovery.

Mitch stops flow director on shutdown because, in some cases, the hardware
would continue to try to access the FDIR ring after entering D3Hot state,
which would cause either PCIe errors or NMIs, depending upon the system
configuration.

* NOTE * I have verified that this series of patches for net will not cause
any merge issues when you sync up your net tree with your net-next tree.

The following are changes since commit 31639b94cadc03727d0ae1f048e9688dd508883f:
  MAINTAINERS: update my email address
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Akeem G Abodunrin (1):
  i40e: Don't check for Tx hang when PF down

Alexey Khoroshilov (1):
  i40e: Fix memory leak at failure path in i40e_dbg_command_write()

Anjali Singhai (3):
  i40e: Fix TSO with more than 8 frags per segment issue
  i40e: Fix the case where per TC queue count was higher than queues
    enabled
  i40evf: TCP/IPv6 over Vxlan Tx checksum offload fix

Jesse Brandeburg (1):
  i40e: fix race in hang check

Mitch A Williams (1):
  i40e: stop flow director on shutdown

Parikh, Neerav (2):
  i40e: Fix the Tx ring qset handle when DCB reconfigures
  i40e: Issue a PF reset if Tx queue disable timeout

Shannon Nelson (4):
  i40e: fix shift precedence issue
  i40e: disconnect irqs on shutdown
  i40e: catch NVM write semaphore timeout and retry
  i40e: check pointers before use

 drivers/net/ethernet/intel/i40e/i40e_common.c  |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c  |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  44 ++++++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c     |  35 ++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 119 +++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c  | 143 ++++++++++++++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  |   1 +
 9 files changed, 280 insertions(+), 76 deletions(-)

-- 
1.9.3
