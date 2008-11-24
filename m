From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] eth: Declare an optimized compare_ether_addr_64bits()
 function
Date: Mon, 24 Nov 2008 07:27:46 +0100
Message-ID: <492A4962.1080400@cosmosbay.com>
References: <4927B275.1030407@cosmosbay.com> <20081123.154554.255301279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020901020809060503080604"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35816 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbYKXG1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 01:27:52 -0500
In-Reply-To: <20081123.154554.255301279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020901020809060503080604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 22 Nov 2008 08:19:17 +0100
>=20
>> This patch implements a compare_ether_addr_64bits() function, that
>> handles the case of x86 cpus, but might be used on other arches as
>> well, if their potential misaligned long word reads are not
>> expensive.
>=20
> We have a test for this, HAVE_EFFICIENT_UNALIGNED_ACCESS
>=20
> Please use that instead of CONFIG_X86 and I'll apply this
> to net-next-2.6
>=20

Excellent !

I missed this cool feature.

Thanks David

[PATCH] eth: Declare an optimized compare_ether_addr_64bits() function

Linus mentioned we could try to perform long word operations, even
on potentially unaligned addresses, on x86 at least. David mentioned
the HAVE_EFFICIENT_UNALIGNED_ACCESS test to handle this on all
arches that have efficient unailgned accesses.

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
that uses the CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS ifdef
and get_unaligned() macro to efficiently perform the 6 bytes
comparison on all capable arches.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/etherdevice.h |   44 ++++++++++++++++++++++++++++++++++
 net/ethernet/eth.c          |    6 ++--
 2 files changed, 47 insertions(+), 3 deletions(-)

--------------020901020809060503080604
Content-Type: text/plain;
 name="ether.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ether.patch"

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 0e5e970..2a3419a 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -27,6 +27,7 @@
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
 #include <linux/random.h>
+#include <asm/unaligned.h>
 
 #ifdef __KERNEL__
 extern __be16		eth_type_trans(struct sk_buff *skb, struct net_device *dev);
@@ -140,6 +141,49 @@ static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
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
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	unsigned long fold = get_unaligned((const unsigned long *)addr1) ^
+			     get_unaligned((const unsigned long *)addr2);
+
+	if (sizeof(fold) == 8)
+		return zap_last_2bytes(fold) != 0;
+
+	fold |= zap_last_2bytes(
+			get_unaligned((const unsigned long *)(addr1 + 4)) ^
+			get_unaligned((const unsigned long *)(addr2 + 4))
+			);
+	return fold != 0;
+#else
+	return compare_ether_addr(addr1, addr2);
+#endif
+}
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a87a171..280352a 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -165,8 +165,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
-	if (is_multicast_ether_addr(eth->h_dest)) {
-		if (!compare_ether_addr(eth->h_dest, dev->broadcast))
+	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
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
 

--------------020901020809060503080604--
