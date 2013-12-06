From: Joe Perches <joe@perches.com>
Subject: [PATCH -next] etherdevice: Optimize a few is_<foo>_ether_addr
 functions
Date: Fri, 06 Dec 2013 15:44:21 -0800
Message-ID: <1386373461.31845.50.camel@joe-AO722>
References: <1386317890.31845.26.camel@joe-AO722>
	 <20131206.153944.1382127535160341376.davem@davemloft.net>
	 <1386364621.31845.32.camel@joe-AO722>
	 <20131206.163806.1555069105347405484.davem@davemloft.net>
	 <1386368461.31845.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386368461.31845.38.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set,
several is_<foo>_ether_addr functions can be slightly
improved by using u32 dereferences.

I believe all current uses of is_zero_ether_addr and
is_broadcast_ether_addr are u16 aligned, so always use
u16 references to improve those functions performance.

Document the u16 alignment requirements.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3526e81..9518e59 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -61,6 +61,8 @@ static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =
  *
  * Return true if address is link local reserved addr (01:80:c2:00:00:0X) per
  * IEEE 802.1Q 8.6.3 Frame filtering.
+ *
+ * Please note: addr must be aligned to u16.
  */
 static inline bool is_link_local_ether_addr(const u8 *addr)
 {
@@ -68,7 +70,12 @@ static inline bool is_link_local_ether_addr(const u8 *addr)
 	static const __be16 *b = (const __be16 *)eth_reserved_addr_base;
 	static const __be16 m = cpu_to_be16(0xfff0);
 
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	return (((*(const u32 *)addr) ^ (*(const u32 *)b)) |
+		((a[2] ^ b[2]) & m)) == 0;
+#else
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
+#endif
 }
 
 /**
@@ -76,10 +83,18 @@ static inline bool is_link_local_ether_addr(const u8 *addr)
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is all zeroes.
+ *
+ * Please note: addr must be aligned to u16.
  */
 static inline bool is_zero_ether_addr(const u8 *addr)
 {
-	return !(addr[0] | addr[1] | addr[2] | addr[3] | addr[4] | addr[5]);
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	return ((*(const u32 *)addr) | (*(const u16 *)(addr + 4))) == 0;
+#else
+	return (*(const u16 *)(addr + 0) |
+		*(const u16 *)(addr + 2) |
+		*(const u16 *)(addr + 4)) == 0;
+#endif
 }
 
 /**
@@ -110,10 +125,14 @@ static inline bool is_local_ether_addr(const u8 *addr)
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is the broadcast address.
+ *
+ * Please note: addr must be aligned to u16.
  */
 static inline bool is_broadcast_ether_addr(const u8 *addr)
 {
-	return (addr[0] & addr[1] & addr[2] & addr[3] & addr[4] & addr[5]) == 0xff;
+	return (*(const u16 *)(addr + 0) &
+		*(const u16 *)(addr + 2) &
+		*(const u16 *)(addr + 4)) == 0xffff;
 }
 
 /**
@@ -135,6 +154,8 @@ static inline bool is_unicast_ether_addr(const u8 *addr)
  * a multicast address, and is not FF:FF:FF:FF:FF:FF.
  *
  * Return true if the address is valid.
+ *
+ * Please note: addr must be aligned to u16.
  */
 static inline bool is_valid_ether_addr(const u8 *addr)
 {
