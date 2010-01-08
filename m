From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/5] e1000e: fix and commonize code for setting the
	receive address registers
Date: Thu, 07 Jan 2010 18:32:13 -0800
Message-ID: <20100108023213.31476.17023.stgit@localhost.localdomain>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:42070 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227Ab0AHCcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:32:31 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Fix e1000e_rar_set() to flush consecutive register writes to avoid write
combining which some parts cannot handle.  Update e1000e_init_rx_addrs()
to call the fixed e1000e_rar_set() instead of duplicating code.

Also change e1000e_rar_set() to _not_ set the Address Valid bit if the MAC
address is all zeros.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/lib.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 97649bf..2fa9b36 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -125,6 +125,7 @@ void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value)
 void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 {
 	u32 i;
+	u8 mac_addr[ETH_ALEN] = {0};
 
 	/* Setup the receive address */
 	e_dbg("Programming MAC Address into RAR[0]\n");
@@ -133,12 +134,8 @@ void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
 	e_dbg("Clearing RAR[1-%u]\n", rar_count-1);
-	for (i = 1; i < rar_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1), 0);
-		e1e_flush();
-		E1000_WRITE_REG_ARRAY(hw, E1000_RA, ((i << 1) + 1), 0);
-		e1e_flush();
-	}
+	for (i = 1; i < rar_count; i++)
+		e1000e_rar_set(hw, mac_addr, i);
 }
 
 /**
@@ -164,10 +161,19 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 
 	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
 
-	rar_high |= E1000_RAH_AV;
+	/* If MAC address zero, no need to set the AV bit */
+	if (rar_low || rar_high)
+		rar_high |= E1000_RAH_AV;
 
-	E1000_WRITE_REG_ARRAY(hw, E1000_RA, (index << 1), rar_low);
-	E1000_WRITE_REG_ARRAY(hw, E1000_RA, ((index << 1) + 1), rar_high);
+	/*
+	 * Some bridges will combine consecutive 32-bit writes into
+	 * a single burst write, which will malfunction on some parts.
+	 * The flushes avoid this.
+	 */
+	ew32(RAL(index), rar_low);
+	e1e_flush();
+	ew32(RAH(index), rar_high);
+	e1e_flush();
 }
 
 /**

