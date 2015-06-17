From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/17][pull request] Intel Wired LAN Driver Updates 2015-06-17
Date: Wed, 17 Jun 2015 05:54:47 -0700
Message-ID: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22624 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbbFQMzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Alex provides two fixes for the fm10k, first folds the fm10k_pull_tail()
call into fm10k_add_rx_frag(), this way the fragment does not have to be
modified after it is added to the skb.  The second fixes missing braces
to an if statement.

The remaining patches are from Jacob which contain improvements and fixes
for fm10k.  First fix makes it so that invalid address will simply be
skipped and allows synchronizing the full list to proceed with using
iproute2 tool.  Fixed a possible kernel panic by using the correct
transmit timestamp function.  Simplified the code flow for setting the
IN_PROGRESS bit of the shinfo for an skb that we will be timestamping.
Fix a bug in the timestamping transmit enqueue code responsible for a
NULL pointer dereference and invalid access of the skb list by freeing
the clone in the cases where we did not add it to the queue.  Update the
PF code so that it resets the empty TQMAP/RQMAP regirsters post-VFLR to
prevent innocent VF drivers from triggering malicious driver events.
The SYSTIME_CFG.Adjust direction bit is actually supposed to indicate
that the adjustment is positive, so fix the code to align correctly with
the hardware and documentation.  Cleanup local variable that is no longer
used after a previous refactor of the code.  Fix the code flow so that we
actually clear the enabled flag as part of our removal of the LPORT.

v2:
 - updated patch 07 description based on feedback from Sergei Shtylyov
 - updated patch 09 & 10 to use %d in error message based on feedback
   from Sergei Shtylyov

The following are changes since commit 89d256bb69f2596c3a31ac51466eac9e1791c388:
  bpf: disallow bpf tc programs access current->pid,uid
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (2):
  fm10k: fold fm10k_pull_tail into fm10k_add_rx_frag
  fm10k: Fix missing braces after if statement

Jacob Keller (15):
  fm10k: ignore invalid multicast address entries
  fm10k: use correct ethernet driver Tx timestamp function
  fm10k: move setting shinfo inside ts_tx_enqueue
  fm10k: fix incorrect free on skb in ts_tx_enqueue
  fm10k: add call to fm10k_clean_all_rx_rings in fm10k_down
  fm10k: use an unsigned int for i in ethtool_get_strings
  fm10k: remove extraneous NULL check on l2_accel
  fm10k: trivial fixup message style to include a colon
  fm10k: use dma_set_mask_and_coherent in fm10k_probe
  fm10k: force LPORT delete when updating VLAN or MAC address
  fm10k: re-map all possible VF queues after a VFLR
  fm10k: pack TLV overlay structures
  fm10k: fix incorrect DIR_NEVATIVE bit in 1588 code
  fm10k: remove err_no reference in fm10k_mbx.c
  fm10k: fix iov_msg_lport_state_pf issue

 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     | 38 ++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 66 +++++++-----------------
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |  5 --
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 11 +---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 27 +++-------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 18 ++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      |  8 +--
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     | 13 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  2 +-
 10 files changed, 84 insertions(+), 109 deletions(-)

-- 
2.4.3
