From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] e1000: convert to use netdev_for_each_mc_addr
Date: Mon, 22 Feb 2010 20:10:44 +0100
Message-ID: <20100222191044.GC4141@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46923 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769Ab0BVTKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:10:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000/e1000_main.c |   37 +++++++++++++++++--------------------
 1 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 3b14dd7..c99f95c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2161,29 +2161,26 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 
 	WARN_ON(i == rar_entries);
 
-	mc_ptr = netdev->mc_list;
-
-	for (; i < rar_entries; i++) {
-		if (mc_ptr) {
-			e1000_rar_set(hw, mc_ptr->da_addr, i);
-			mc_ptr = mc_ptr->next;
-		} else {
-			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
-			E1000_WRITE_FLUSH();
-			E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) + 1, 0);
-			E1000_WRITE_FLUSH();
+	netdev_for_each_mc_addr(mc_ptr, netdev) {
+		if (i == rar_entries) {
+			/* load any remaining addresses into the hash table */
+			u32 hash_reg, hash_bit, mta;
+			hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
+			hash_reg = (hash_value >> 5) & 0x7F;
+			hash_bit = hash_value & 0x1F;
+			mta = (1 << hash_bit);
+			mcarray[hash_reg] |= mta;
+		}
+		else {
+			e1000_rar_set(hw, mc_ptr->da_addr, i++);
 		}
 	}
 
-	/* load any remaining addresses into the hash table */
-
-	for (; mc_ptr; mc_ptr = mc_ptr->next) {
-		u32 hash_reg, hash_bit, mta;
-		hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
-		hash_reg = (hash_value >> 5) & 0x7F;
-		hash_bit = hash_value & 0x1F;
-		mta = (1 << hash_bit);
-		mcarray[hash_reg] |= mta;
+	for (; i < rar_entries; i++) {
+		E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
+		E1000_WRITE_FLUSH();
+		E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) + 1, 0);
+		E1000_WRITE_FLUSH();
 	}
 
 	/* write the hash table completely, write from bottom to avoid
-- 
1.6.6

