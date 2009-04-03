From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000: fix loss of multicast packets
Date: Thu, 02 Apr 2009 19:00:32 -0700
Message-ID: <20090403020030.25363.85273.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Dave Boutcher <daveboutcher@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:60961
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599AbZDCCAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 22:00:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000 (and e1000e, igb, ixgbe, ixgb) all do a series of
operations each time a multicast address is added.  The flow goes
something like

1) stack adds one multicast address
2) stack passes whole current list of unicast and multicast
   addresses to driver
3) driver clears entire list in hardware
4) driver programs each multicast address using iomem in a loop

This was causing multicast packets to be lost during the
reprogramming process.

reference with test program:
http://kerneltrap.org/mailarchive/linux-netdev/2009/3/14/5160514/thread

Thanks to Dave Boutcher for his report and test program.

This driver fix prepares an array all at once in memory and
programs it in one shot to the hardware, not requiring an "erase"
cycle.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Dave Boutcher <daveboutcher@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   34 ++++++++++++++++++++++++++--------
 1 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 93b861d..a65023d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2335,6 +2335,12 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
 				E1000_NUM_MTA_REGISTERS_ICH8LAN :
 				E1000_NUM_MTA_REGISTERS;
+	u32 *mcarray = kcalloc(mta_reg_count, sizeof(u32), GFP_ATOMIC);
+
+	if (!mcarray) {
+		DPRINTK(PROBE, ERR, "memory allocation failed\n");
+		return;
+	}
 
 	if (hw->mac_type == e1000_ich8lan)
 		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
@@ -2401,22 +2407,34 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	}
 	WARN_ON(uc_ptr != NULL);
 
-	/* clear the old settings from the multicast hash table */
-
-	for (i = 0; i < mta_reg_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
-		E1000_WRITE_FLUSH();
-	}
-
 	/* load any remaining addresses into the hash table */
 
 	for (; mc_ptr; mc_ptr = mc_ptr->next) {
+		u32 hash_reg, hash_bit, mta;
 		hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
-		e1000_mta_set(hw, hash_value);
+		hash_reg = (hash_value >> 5) & 0x7F;
+		hash_bit = hash_value & 0x1F;
+		mta = (1 << hash_bit);
+		mcarray[hash_reg] |= mta;
 	}
 
+	/* write the hash table completely, write from bottom to avoid
+	 * both stupid write combining chipsets, and flushing each write */
+	for (i = mta_reg_count - 1; i >= 0 ; i--) {
+		/*
+		 * If we are on an 82544 has an errata where writing odd
+		 * offsets overwrites the previous even offset, but writing
+		 * backwards over the range solves the issue by always
+		 * writing the odd offset first
+		 */
+		E1000_WRITE_REG_ARRAY(hw, MTA, i, mcarray[i]);
+	}
+	E1000_WRITE_FLUSH();
+
 	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
+
+	kfree(mcarray);
 }
 
 /* Need to wait a few seconds after link up to get diagnostic information from

