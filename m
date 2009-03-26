From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/4] e1000e: fix loss of multicast packets
Date: Thu, 26 Mar 2009 01:05:21 -0700
Message-ID: <20090326080520.30401.33149.stgit@lost.foo-projects.org>
References: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Dave Boutcher <daveboutcher@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:45390 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbZCZIFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:05:41 -0400
In-Reply-To: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000e (and e1000, igb, ixgbe, ixgb) all do a series of operations each
time a multicast address is added.  The flow goes something like

1) stack adds one multicast address
2) stack passes whole current list of unicast and multicast addresses to
   driver
3) driver clears entire list in hardware
4) driver programs each multicast address using iomem in a loop

This was causing multicast packets to be lost during the reprogramming
process.

reference with test program:
http://kerneltrap.org/mailarchive/linux-netdev/2009/3/14/5160514/thread

Thanks to Dave Boutcher for his report and test program.

This driver fix prepares an array all at once in memory and programs it in
one shot to the hardware, not requiring an "erase" cycle.  It would still
be possible for packets to be dropped while the receiver is off during
reprogramming.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Dave Boutcher <daveboutcher@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/lib.c |   62 +++++++++++++---------------------------------
 1 files changed, 18 insertions(+), 44 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index ac2f34e..18a4f59 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -159,41 +159,6 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 }
 
 /**
- *  e1000_mta_set - Set multicast filter table address
- *  @hw: pointer to the HW structure
- *  @hash_value: determines the MTA register and bit to set
- *
- *  The multicast table address is a register array of 32-bit registers.
- *  The hash_value is used to determine what register the bit is in, the
- *  current value is read, the new bit is OR'd in and the new value is
- *  written back into the register.
- **/
-static void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
-{
-	u32 hash_bit, hash_reg, mta;
-
-	/*
-	 * The MTA is a register array of 32-bit registers. It is
-	 * treated like an array of (32*mta_reg_count) bits.  We want to
-	 * set bit BitArray[hash_value]. So we figure out what register
-	 * the bit is in, read it, OR in the new bit, then write
-	 * back the new value.  The (hw->mac.mta_reg_count - 1) serves as a
-	 * mask to bits 31:5 of the hash value which gives us the
-	 * register we're modifying.  The hash bit within that register
-	 * is determined by the lower 5 bits of the hash value.
-	 */
-	hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
-	hash_bit = hash_value & 0x1F;
-
-	mta = E1000_READ_REG_ARRAY(hw, E1000_MTA, hash_reg);
-
-	mta |= (1 << hash_bit);
-
-	E1000_WRITE_REG_ARRAY(hw, E1000_MTA, hash_reg, mta);
-	e1e_flush();
-}
-
-/**
  *  e1000_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
@@ -281,8 +246,13 @@ void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
 					u8 *mc_addr_list, u32 mc_addr_count,
 					u32 rar_used_count, u32 rar_count)
 {
-	u32 hash_value;
 	u32 i;
+	u32 *mcarray = kzalloc(hw->mac.mta_reg_count * sizeof(u32), GFP_ATOMIC);
+
+	if (!mcarray) {
+		printk(KERN_ERR "multicast array memory allocation failed\n");
+		return;
+	}
 
 	/*
 	 * Load the first set of multicast addresses into the exact
@@ -302,20 +272,24 @@ void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
 		}
 	}
 
-	/* Clear the old settings from the MTA */
-	hw_dbg(hw, "Clearing MTA\n");
-	for (i = 0; i < hw->mac.mta_reg_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
-		e1e_flush();
-	}
-
 	/* Load any remaining multicast addresses into the hash table. */
 	for (; mc_addr_count > 0; mc_addr_count--) {
+		u32 hash_value, hash_reg, hash_bit, mta;
 		hash_value = e1000_hash_mc_addr(hw, mc_addr_list);
 		hw_dbg(hw, "Hash value = 0x%03X\n", hash_value);
-		e1000_mta_set(hw, hash_value);
+		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
+		hash_bit = hash_value & 0x1F;
+		mta = (1 << hash_bit);
+		mcarray[hash_reg] |= mta;
 		mc_addr_list += ETH_ALEN;
 	}
+
+	/* write the hash table completely */
+	for (i = 0; i < hw->mac.mta_reg_count; i++)
+		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, mcarray[i]);
+
+	e1e_flush();
+	kfree(mcarray);
 }
 
 /**

