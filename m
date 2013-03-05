From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue,  5 Mar 2013 01:48:33 -0800
Message-ID: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40681 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464Ab3CEJsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 04:48:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000e and igb.

The e1000e fix resolves an issue at 1000Mbps link speed, where one of the
MAC's internal clocks can be stopped for up to 4us when entering K1 (a
power mode of the MAC-PHY interconnect).  If the MAC is waiting for
completion indications for 2 DMA write requests into Host memory
(e.g. descriptor writeback or Rx packet writing) and the
indications occur while the clock is stopped, both indications will be
missed by the MAC causing the MAC to wait for the completion indications
and be unable to generate further DMA write requests.  This results in an
apparent hardware hang.  The patch works-around the issue by disabling
the de-assertion of the clock request when 1000Mbps link is acquired (K1
must be disabled while doing this).

The igb fix to drop BUILD_BUG_ON check from igb_build_rx_buffer resolves
a build error on s390 devices.  The igb driver was throwing a build error
due to the fact that a frame built using build_skb would be larger than 2K.
Since this is not likely to change at any point in the future we are better
off just dropping the check since we already had a check in
igb_set_rx_buffer_len that will just disable the usage of build_skb anyway.

The igb fix for i210 link setup changes the setup copper link function
to use a switch statement, so that the appropriate setup link function
is called for the given PHY types.

Lastly, the igb fix for a lockdep issue in igb_get_i2c_client resolves
the issue by re-factoring the initialization and usage of the i2c_client.

The following are changes since commit aab2b4bf224ef8358d262f95b568b8ad0cecf0a0:
  tcp: fix double-counted receiver RTT when leaving receiver fast path
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  igb: Drop BUILD_BUG_ON check from igb_build_rx_buffer

Bruce Allan (1):
  e1000e: workaround DMA unit hang on I218

Carolyn Wyborny (2):
  igb: Fix link setup for I210 devices
  igb: Fix for lockdep issue in igb_get_i2c_client

 drivers/net/ethernet/intel/e1000e/ich8lan.c  | 71 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/e1000e/ich8lan.h  |  2 +
 drivers/net/ethernet/intel/e1000e/regs.h     |  1 +
 drivers/net/ethernet/intel/igb/e1000_82575.c | 11 ++--
 drivers/net/ethernet/intel/igb/igb.h         |  2 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c   | 14 +++++
 drivers/net/ethernet/intel/igb/igb_main.c    | 76 +---------------------------
 7 files changed, 98 insertions(+), 79 deletions(-)

-- 
1.7.11.7
