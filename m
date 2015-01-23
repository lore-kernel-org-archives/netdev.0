From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-01-22
Date: Thu, 22 Jan 2015 18:36:56 -0800
Message-ID: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16342 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbbAWChP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb, fm10k and virtio_net.

Asaf Vertz provides a fix for e1000 to future-proof the time comparisons
by using time_after_eq() instead of plain math.

Mathias Koehrer provides a fix for e1000e to add a check to e1000_xmit_frame()
to ensure a work queue will not be scheduled that has not been initialized.

Jacob adds the use of software timestamping via the virtio_net driver.

Alex Duyck cleans up page reuse code in igb and fm10k.  Cleans up the
page reuse code from getting into a state where all the workarounds
needed are in place as well as cleaning up oversights, such as using
__free_pages instead of put_page to drop a locally allocated page.

Richard Cochran provides 4 patches for igb dealing with time sync.
First provides a helper function since the code that handles the time
sync interrupt is repeated in three different places.  Then serializes
the access to the time sync interrupt since the registers may be
manipulated from different contexts.  Enables the use of i210 device
interrupt to generate an internal PPS event for adjusting the kernel
system time.  The i210 device offers a number of special PTP hardware
clock features on the Software Defined Pins (SDPs), so added support for
two of the possible functions (time stamping external events and
periodic output signals).

Or Gerlitz fixes fm10k from double setting of NETIF_F_SG since the
networking core does it for the driver during registration time.

Joe Stringer adds support for up to 104 bytes of inner+outer headers in
fm10k and adds an initial check to fail encapsulation offload if these
are too large.

Matthew increases the timeout for the data path reset based on feedback
from the hardware team, since 100us is too short of a time to wait for
the data path reset to complete.

Alexander Graf provides a fix for igb to indicate failure on VF reset
for an empty MAC address, to mirror the behavior of ixgbe.

Florian Westphal updates e1000 and e1000e to support txtd update delay
via xmit_more, this way we won't update the Tx tail descriptor if the
queue has not been stopped and we know at least one more skb will be
sent right away.

The following are changes since commit 0c49087462e8587c12ecfeaf1dd46fdc0ddc4532:
  Merge tag 'mac80211-next-for-davem-2015-01-19' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  igb: Clean-up page reuse code
  fm10k: Clean-up page reuse code

Alexander Graf (1):
  igb: Indicate failure on vf reset for empty mac address

Asaf Vertz (1):
  e1000: fix time comparison

Florian Westphal (2):
  net: e1000: support txtd update delay via xmit_more
  net: e1000e: support txtd update delay via xmit_more

Jacob Keller (1):
  virtio_net: add software timestamp support

Joe Stringer (1):
  fm10k: Check tunnel header length in encap offload

Mathias Koehrer (1):
  e1000e: Fix 82572EI that has no hardware timestamp support

Matthew Vick (1):
  fm10k: Increase the timeout for the data path reset

Or Gerlitz (1):
  net/fm10k: Avoid double setting of NETIF_F_SG for the HW encapsulation
    feature mask

Richard Cochran (4):
  igb: refactor time sync interrupt handling
  igb: serialize access to the time sync interrupt registers
  igb: enable internal PPS for the i210
  igb: enable auxiliary PHC functions for the i210

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   3 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c    |  15 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |  30 +--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  40 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  13 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   2 +-
 drivers/net/ethernet/intel/igb/igb.h             |   9 +
 drivers/net/ethernet/intel/igb/igb_main.c        | 153 +++++++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c         | 256 ++++++++++++++++++++++-
 drivers/net/virtio_net.c                         |   4 +
 10 files changed, 424 insertions(+), 101 deletions(-)

-- 
1.9.3
