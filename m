From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix for race with 8259(8|9) during shutdown
Date: Fri, 11 Jun 2010 16:20:29 -0700
Message-ID: <20100611232029.31430.75582.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Akihiko Saitou <asaitou@users.sourceforge.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:41462
	"EHLO qmta02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750861Ab0FKXUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 19:20:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

There is a small window where the watchdog could be running as the
interface is brought down on a NIC with two ports wired back to back.
If ixgbe_update_status is then called can lead to a panic.  This patch
allows the update to bail if we are in that condition.

This issue was orignally reported and fix proposed by Akihiko Saitou.

CC: Akihiko Saitou <asaitou@users.sourceforge.net>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b2af2f6..ce30c62 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5282,6 +5282,10 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 	u64 non_eop_descs = 0, restart_queue = 0;
 
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
+		return;
+
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		u64 rsc_count = 0;
 		u64 rsc_flush = 0;

