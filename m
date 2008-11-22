From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] eth: Declare an optimized compare_ether_addr_64bits() function
Date: Sat, 22 Nov 2008 08:19:17 +0100
Message-ID: <4927B275.1030407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060605080801080309090208"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39803 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbYKVHTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:19:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060605080801080309090208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello David, this is a resend of a patch previously sent in a 
"tbench regression ..." thread on lkml

We should also address the problem of skb_pull(skb, ETH_HLEN);
in eth_type_trans() :

Being not inlined, this force eth_type_trans() to be a non
leaf function, that cost precious cpu cycles on many arches.

Thank you

[PATCH] eth: Declare an optimized compare_ether_addr_64bits() function

Linus mentioned we could try to perform long word operations, even
on potentially unaligned addresses, on x86 at least.

I tried this idea and got nice assembly on 32 bits:

158:   33 82 38 01 00 00       xor    0x138(%edx),%eax
15e:   33 8a 34 01 00 00       xor    0x134(%edx),%ecx
164:   c1 e0 10                shl    $0x10,%eax
167:   09 c1                   or     %eax,%ecx
169:   74 0b                   je     176 <eth_type_trans+0x87>

And very nice assembly on 64 bits of course (one xor, one shl)

Nice oprofile improvement in eth_type_trans(), 0.17 % instead of 0.41 %,
expected since we remove 8 instructions on a fast path.

This patch implements a compare_ether_addr_64bits() function,
that handles the case of x86 cpus, but might be used on other arches as well,
if their potential misaligned long word reads are not expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/etherdevice.h |   41 ++++++++++++++++++++++++++++++++++
 net/ethernet/eth.c          |    4 +--
 2 files changed, 43 insertions(+), 2 deletions(-)

--------------060605080801080309090208
Content-Type: text/plain;
 name="compare_ether_addr_64bits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="compare_ether_addr_64bits.patch"

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 25d62e6..ee0df09 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -136,6 +136,47 @@ static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
 	BUILD_BUG_ON(ETH_ALEN != 6);
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
 }
+
+static inline unsigned long zap_last_2bytes(unsigned long value)
+{
+#ifdef __BIG_ENDIAN
+	return value >> 16;
+#else
+	return value << 16;
+#endif
+}
+
+/**
+ * compare_ether_addr_64bits - Compare two Ethernet addresses
+ * @addr1: Pointer to an array of 8 bytes
+ * @addr2: Pointer to an other array of 8 bytes
+ *
+ * Compare two ethernet addresses, returns 0 if equal.
+ * Same result than "memcmp(addr1, addr2, ETH_ALEN)" but without conditional
+ * branches, and possibly long word memory accesses on CPU allowing cheap
+ * unaligned memory reads.
+ * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
+ * 
+ * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
+ */
+
+static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
+						 const u8 addr2[6+2])
+{
+#if defined(CONFIG_X86)
+	unsigned long fold = *(const unsigned long *)addr1 ^
+			     *(const unsigned long *)addr2;
+
+	if (sizeof(fold) == 8)
+		return zap_last_2bytes(fold) != 0;
+
+	fold |= zap_last_2bytes(*(const unsigned long *)(addr1 + 4) ^
+				*(const unsigned long *)(addr2 + 4));
+	return fold != 0;
+#else
+	return compare_ether_addr(addr1, addr2);
+#endif
+}
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index b9d85af..dcfeb9b 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -166,7 +166,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	eth = eth_hdr(skb);
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		if (!compare_ether_addr(eth->h_dest, dev->broadcast))
+		if (!compare_ether_addr_64bits(eth->h_dest, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_MULTICAST;
@@ -181,7 +181,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	else if (1 /*dev->flags&IFF_PROMISC */ ) {
-		if (unlikely(compare_ether_addr(eth->h_dest, dev->dev_addr)))
+		if (unlikely(compare_ether_addr_64bits(eth->h_dest, dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 

--------------060605080801080309090208--
