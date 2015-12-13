From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] 1GbE Intel Wired LAN Driver Updates 2015-12-12
Date: Sun, 13 Dec 2015 00:31:13 -0800
Message-ID: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:34868 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbbLMIk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e and igb.

Joern Engel fixes up the e1000 driver to reduce scheduler latencies by
making the eeprom read/write functions scheduler friendly by using a mutex
lock instead of a spin lock.

Todd adds code for igb to initialize the 88E1543 PHY properly.  Then fixed
igb to use the correct i210 register for EEMNGCTL, since the i210 has two
EEPROM access registers (EEARBC and EEMNGCTL).

Dmitry Vyukov provides a fix for e1000 to resolve a data race found with
KernelThreadSanitizer (KTSAN), where no memory barriers were being used
when buffers get recycled, so the recycled buffers can be corrupted.  So
use smp_store_release() to update tx_ring->next_to_clean and
smp_load_acquire() to read tx_ring->next_to_clean to properly hand off
buffers from e1000_clean_tx_irq() to e1000_xmit_frame().

Jarod Wilson fixes igb so that we do not try to unmap a NULL hw_addr.  Then
cleaned up array_rd32() so that it uses igb_rd32() the same as rd32() and
use io_addr() in more places so that we do not have to call E1000_REMOVED().

Janusz Wolak cleans up the e1000 driver by correcting warnings produced
by checkpatch.pl for the driver.

Jean Sacren provides several patches with general cleanups for e1000 and
e1000e, which include code comment fix-ups and cleanup of local variables
not needed.

Dmitry Fleytman fixes a possible division by zero in the receive interrupt
handler for e1000e when working without adaptive interrupt moderation,
which is typically disabled on jumbo MTUs.

Raanan increases the timeout of the polling bit due to timing changes to
the ME firmware on a platform, so increase the timeout to 300ms.  Added
initial support for i219-LM, which is a LOM that will be available on
systems with the Lewisburg Platform Controller HUB (PCH) chipset.

Jan Beulich fixes a NULL dereference in igb, due to the adapter->vf _data
being NULL while adapter->vfs_allocated_count is non-zero.

The following are changes since commit 1d72135dd6be396bf724cd962555758c0277db93:
  Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Dmitriy Vyukov (1):
  e1000: fix data race between tx_ring->next_to_clean

Dmitry Fleytman (1):
  e1000e: fix division by zero on jumbo MTUs

Jan Beulich (1):
  igb: fix NULL derefs due to skipped SR-IOV enabling

Janusz Wolak (2):
  e1000: Remove checkpatch coding style errors
  e1000: Elementary checkpatch warnings and checks removed

Jarod Wilson (2):
  igb: don't unmap NULL hw_addr
  igb: improve handling of disconnected adapters

Jean Sacren (5):
  e1000: clean up the checking logic
  e1000: fix a typo in the comment
  e1000e: clean up the local variable
  e1000: fix kernel-doc argument being missing
  e1000: get rid of duplicate exit path

Joern Engel (1):
  e1000: make eeprom read/write scheduler friendly

Raanan Avargil (2):
  e1000e: Increase timeout of polling bit RSPCIPHY
  e1000e: initial support for i219-LM (3)

Todd Fujinaka (2):
  igb: add 88E1543 initialization code
  igb: use the correct i210 register for EEMNGCTL

 drivers/net/ethernet/intel/e1000/e1000.h       |   7 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c    | 216 ++++++++++++-------------
 drivers/net/ethernet/intel/e1000/e1000_main.c  | 133 ++++++++-------
 drivers/net/ethernet/intel/e1000e/hw.h         |   1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |  45 ++++--
 drivers/net/ethernet/intel/e1000e/netdev.c     |  12 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |   8 +
 drivers/net/ethernet/intel/igb/e1000_defines.h |   1 +
 drivers/net/ethernet/intel/igb/e1000_i210.c    |  27 ++++
 drivers/net/ethernet/intel/igb/e1000_i210.h    |   1 +
 drivers/net/ethernet/intel/igb/e1000_phy.c     |  94 +++++++++++
 drivers/net/ethernet/intel/igb/e1000_phy.h     |   1 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   4 +-
 drivers/net/ethernet/intel/igb/igb.h           |   2 +
 drivers/net/ethernet/intel/igb/igb_main.c      |  22 ++-
 15 files changed, 379 insertions(+), 195 deletions(-)

-- 
2.5.0
