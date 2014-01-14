From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] etherdevice: Use ether_addr_copy to copy an
 Ethernet address
Date: Tue, 14 Jan 2014 15:18:47 -0800
Message-ID: <1389741527.24849.68.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-arch <linux-arch@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0245.hostedemail.com ([216.40.44.245]:42916 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751065AbaANXSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:18:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some systems can use the normally known u16 alignment of
Ethernet addresses to save some code/text bytes and cycles.

This does not change currently emitted code on x86 by gcc 4.8.

Signed-off-by: Joe Perches <joe@perches.com>
---

Yes, it's a trivial change, but maybe slightly useful...

For instance: with netpoll.c memcpy changed to ether_addr_copy:

arm old (4.6.3):
	memcpy(eth->h_source, np->dev->dev_addr, ETH_ALEN);
    27e0:	e4973042 	ldr	r3, [r7], #66	; 0x42
    27e4:	e2860006 	add	r0, r6, #6
    27e8:	e3a02006 	mov	r2, #6
    27ec:	e59311e8 	ldr	r1, [r3, #488]	; 0x1e8
    27f0:	ebfffffe 	bl	0 <memcpy>
			27f0: R_ARM_CALL	memcpy
	memcpy(eth->h_dest, np->remote_mac, ETH_ALEN);
    27f4:	e1a00006 	mov	r0, r6
    27f8:	e1a01007 	mov	r1, r7
    27fc:	e3a02006 	mov	r2, #6
    2800:	ebfffffe 	bl	0 <memcpy>
			2800: R_ARM_CALL	memcpy

arm new:

	*(u32 *)dst = *(const u32 *)src;
    27dc:	e5932000 	ldr	r2, [r3]
    27e0:	e5802006 	str	r2, [r0, #6]
	*(u16 *)(dst + 4) = *(const u16 *)(src + 4);
    27e4:	e1d330b4 	ldrh	r3, [r3, #4]
    27e8:	e1c030ba 	strh	r3, [r0, #10]
 * Please note: dst & src must both be aligned to u16.
 */
static inline void ether_addr_copy(u8 *dst, const u8 *src)
{
#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
	*(u32 *)dst = *(const u32 *)src;
    27ec:	e5953042 	ldr	r3, [r5, #66]	; 0x42
    27f0:	e5803000 	str	r3, [r0]
	*(u16 *)(dst + 4) = *(const u16 *)(src + 4);
    27f4:	e1d534b6 	ldrh	r3, [r5, #70]	; 0x46
    27f8:	e1c030b4 	strh	r3, [r0, #4]

 include/linux/etherdevice.h | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index f344ac0..1f26c55 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -218,6 +218,28 @@ static inline void eth_hw_addr_random(struct net_device *dev)
 }
 
 /**
+ * ether_addr_copy - Copy an Ethernet address
+ * @dst: Pointer to a six-byte array Ethernet address destination
+ * @src: Pointer to a six-byte array Ethernet address source
+ *
+ * Please note: dst & src must both be aligned to u16.
+ */
+static inline void ether_addr_copy(u8 *dst, const u8 *src)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	*(u32 *)dst = *(const u32 *)src;
+	*(u16 *)(dst + 4) = *(const u16 *)(src + 4);
+#else
+	u16 *a = (u16 *)dst;
+	const u16 *b = (const u16 *)src;
+
+	a[0] = b[0];
+	a[1] = b[1];
+	a[2] = b[2];
+#endif
+}
+
+/**
  * eth_hw_addr_inherit - Copy dev_addr from another net_device
  * @dst: pointer to net_device to copy dev_addr to
  * @src: pointer to net_device to copy dev_addr from
@@ -229,7 +251,7 @@ static inline void eth_hw_addr_inherit(struct net_device *dst,
 				       struct net_device *src)
 {
 	dst->addr_assign_type = src->addr_assign_type;
-	memcpy(dst->dev_addr, src->dev_addr, ETH_ALEN);
+	ether_addr_copy(dst->dev_addr, src->dev_addr);
 }
 
 /**
