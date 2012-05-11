From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] etherdevice: Remove now unused
 compare_ether_addr_64bits
Date: Fri, 11 May 2012 15:21:06 -0700
Message-ID: <1336774866.13434.16.camel@joe2Laptop>
References: <cover.1336618707.git.joe@perches.com>
	 <acb363688c8ed729cc61e288605cdb4aa4089149.1336618708.git.joe@perches.com>
	 <20120510.233554.263340913611469229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120510.233554.263340913611469229.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move and invert the logic from the otherwise unused
compare_ether_addr_64bits to ether_addr_equal_64bits.

Neaten the logic in is_etherdev_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |   46 ++++++++++++------------------------------
 1 files changed, 13 insertions(+), 33 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index afacf85..dc85c1d 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -193,12 +193,12 @@ static inline unsigned long zap_last_2bytes(unsigned long value)
 }
 
 /**
- * compare_ether_addr_64bits - Compare two Ethernet addresses
+ * ether_addr_equal_64bits - Compare two Ethernet addresses
  * @addr1: Pointer to an array of 8 bytes
  * @addr2: Pointer to an other array of 8 bytes
  *
- * Compare two ethernet addresses, returns 0 if equal, non-zero otherwise.
- * Unlike memcmp(), it doesn't return a value suitable for sorting.
+ * Compare two ethernet addresses, returns true if equal, false otherwise.
+ *
  * The function doesn't need any conditional branches and possibly uses
  * word memory accesses on CPU allowing cheap unaligned memory reads.
  * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
@@ -206,45 +206,25 @@ static inline unsigned long zap_last_2bytes(unsigned long value)
  * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
  */
 
-static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
-						 const u8 addr2[6+2])
+static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
+					   const u8 addr2[6+2])
 {
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 	unsigned long fold = ((*(unsigned long *)addr1) ^
 			      (*(unsigned long *)addr2));
 
 	if (sizeof(fold) == 8)
-		return zap_last_2bytes(fold) != 0;
+		return zap_last_2bytes(fold) == 0;
 
 	fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
 				(*(unsigned long *)(addr2 + 4)));
-	return fold != 0;
+	return fold == 0;
 #else
-	return compare_ether_addr(addr1, addr2);
+	return ether_addr_equal(addr1, addr2);
 #endif
 }
 
 /**
- * ether_addr_equal_64bits - Compare two Ethernet addresses
- * @addr1: Pointer to an array of 8 bytes
- * @addr2: Pointer to an other array of 8 bytes
- *
- * Compare two ethernet addresses, returns true if equal, false otherwise.
- *
- * The function doesn't need any conditional branches and possibly uses
- * word memory accesses on CPU allowing cheap unaligned memory reads.
- * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
- *
- * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
- */
-
-static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
-					   const u8 addr2[6+2])
-{
-	return !compare_ether_addr_64bits(addr1, addr2);
-}
-
-/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
@@ -252,23 +232,23 @@ static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
  * Compare passed address with all addresses of the device. Return true if the
  * address if one of the device addresses.
  *
- * Note that this function calls compare_ether_addr_64bits() so take care of
+ * Note that this function calls ether_addr_equal_64bits() so take care of
  * the right padding.
  */
 static inline bool is_etherdev_addr(const struct net_device *dev,
 				    const u8 addr[6 + 2])
 {
 	struct netdev_hw_addr *ha;
-	int res = 1;
+	bool res = false;
 
 	rcu_read_lock();
 	for_each_dev_addr(dev, ha) {
-		res = compare_ether_addr_64bits(addr, ha->addr);
-		if (!res)
+		res = ether_addr_equal_64bits(addr, ha->addr);
+		if (res)
 			break;
 	}
 	rcu_read_unlock();
-	return !res;
+	return res;
 }
 #endif	/* __KERNEL__ */
 
