From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/4] Clean up intel driver page reuse Rx code
Date: Thu, 13 Nov 2014 08:18:12 -0800
Message-ID: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbaKMQSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 11:18:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series cleans up the page reuse and Rx path so that all of the
fixes that have been applied to any one driver are now in place for igb,
fm10k, and ixgbe.  It occured to me that fm10k was missing the pfmemalloc
bits, and ixgbe was missing some logic that reduced the number of writes
needed as well as the pfmemalloc fix.

In addition ixgbe was carrying around some mostly-dead code that was
wrapping a call to writel.  I removed it since it masked the fact that
ixgbe was missing the mmiowb it was supposed to have between the tail write
and the Tx queue lock release to prevent the MMIO access from racing
between CPUs.

Also one change made to all 3 drivers is that we now only overwrite 3 of
the 4 DWORDs in the Rx descriptor after allocation.  The last DWORD
contains the upper 32 bits of the header address on fetch, and the length
and vlan on writeback.  Since we are no longer using header split we don't
need to clear it prior to descriptor fetch as it is unused so we can save
ourselves a cycle on 32b systems by just leaving it untouched.

---

Alexander Duyck (4):
      igb: Clean-up page reuse code
      fm10k: Clean-up page reuse code
      ixgbe: Clean-up page reuse code
      ixgbe: Remove tail write abstraction and add missing barrier


 drivers/net/ethernet/intel/fm10k/fm10k_main.c |   34 ++++---
 drivers/net/ethernet/intel/igb/igb_main.c     |   35 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    5 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  118 ++++++++++++-------------
 4 files changed, 89 insertions(+), 103 deletions(-)

--
