From: Manfred Spraul <manfred@colorfullife.com>
Subject: ether_crc wrong in 2.5.50
Date: Tue, 10 Dec 2002 21:35:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF65013.2090303@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040607060806030409070906"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040607060806030409070906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The ether_crc were converted to use the crc32 library in 2.5.
The conversion is incorrect:

crc32_le and _be are about the bit order in which the bits are processed:
_le means least significant bit first, _be msb first.

ethernet is always lsb first.
ether_crc means the output should be in the cpu bit order [msb in bit 31],
ether_crc_le means the output should be with msb in bit 0: that what 
crc32_le usually generates.

The attached patch is tested with winbond-840, natsemi and 8139too, i.e. 
ether_crc works.
ether_crc_le generates the same output as the inline functions from 
2.4.18, but it's untested due to lack of nics.

Could someone test it on a nic that uses ether_crc_le?

-- 
   Manfred


--------------040607060806030409070906
Content-Type: text/plain;
 name="patch-crc"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-crc"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 5
//  SUBLEVEL = 50
//  EXTRAVERSION =
--- 2.5/include/linux/crc32.h	2002-11-04 23:30:16.000000000 +0100
+++ build-2.5/include/linux/crc32.h	2002-12-10 19:15:50.000000000 +0100
@@ -9,9 +9,19 @@
 
 extern u32  crc32_le(u32 crc, unsigned char const *p, size_t len);
 extern u32  crc32_be(u32 crc, unsigned char const *p, size_t len);
+extern u32  bitreverse(u32 in);
 
 #define crc32(seed, data, length)  crc32_le(seed, (unsigned char const *)data, length)
+
+/*
+ * Helpers for hash table generation of ethernet nics:
+ *
+ * Ethernet sends the least significant bit of a byte first, thus crc32_le
+ * is used. The output of crc32_le is bit reversed [most significant bit
+ * is in bit nr 0], thus it must be reversed before use. Except for
+ * nics that bit swap the result internally...
+ */
+#define ether_crc(length, data)    bitreverse(crc32_le(~0, data, length))
 #define ether_crc_le(length, data) crc32_le(~0, data, length)
-#define ether_crc(length, data)    crc32_be(~0, data, length)
 
 #endif /* _LINUX_CRC32_H */
--- 2.5/lib/crc32.c	2002-11-04 23:30:03.000000000 +0100
+++ build-2.5/lib/crc32.c	2002-12-10 19:16:47.000000000 +0100
@@ -255,6 +255,16 @@
 }
 #endif
 
+u32 bitreverse(u32 x)
+{
+	x = (x >> 16) | (x << 16);
+	x = (x >> 8 & 0x00ff00ff) | (x << 8 & 0xff00ff00);
+	x = (x >> 4 & 0x0f0f0f0f) | (x << 4 & 0xf0f0f0f0);
+	x = (x >> 2 & 0x33333333) | (x << 2 & 0xcccccccc);
+	x = (x >> 1 & 0x55555555) | (x << 1 & 0xaaaaaaaa);
+	return x;
+}
+
 /*
  * A brief CRC tutorial.
  *
@@ -399,16 +409,6 @@
 }
 #endif
 
-static u32 attribute((const)) bitreverse(u32 x)
-{
-	x = (x >> 16) | (x << 16);
-	x = (x >> 8 & 0x00ff00ff) | (x << 8 & 0xff00ff00);
-	x = (x >> 4 & 0x0f0f0f0f) | (x << 4 & 0xf0f0f0f0);
-	x = (x >> 2 & 0x33333333) | (x << 2 & 0xcccccccc);
-	x = (x >> 1 & 0x55555555) | (x << 1 & 0xaaaaaaaa);
-	return x;
-}
-
 static void bytereverse(unsigned char *buf, size_t len)
 {
 	while (len--) {
--- 2.5/drivers/net/natsemi.c	2002-11-04 23:30:05.000000000 +0100
+++ build-2.5/drivers/net/natsemi.c	2002-12-10 19:20:01.000000000 +0100
@@ -164,6 +164,7 @@
 #include <linux/delay.h>
 #include <linux/rtnetlink.h>
 #include <linux/mii.h>
+#include <linux/crc32.h>
 #include <asm/processor.h>	/* Processor type for cache alignment. */
 #include <asm/bitops.h>
 #include <asm/io.h>
@@ -1898,44 +1899,6 @@
 	return &np->stats;
 }
 
-/**
- * dp83815_crc - computer CRC for hash table entries
- *
- * Note - this is, for some reason, *not* the same function
- * as ether_crc_le() or ether_crc(), though it uses the
- * same big-endian polynomial.
- */
-#define DP_POLYNOMIAL			0x04C11DB7
-static unsigned dp83815_crc(int length, unsigned char *data)
-{
-	u32 crc;
-	u8 cur_byte;
-	u8 msb;
-	u8 byte, bit;
-
-	crc = ~0;
-	for (byte=0; byte<length; byte++) {
-		cur_byte = *data++;
-		for (bit=0; bit<8; bit++) {
-			msb = crc >> 31;
-			crc <<= 1;
-			if (msb ^ (cur_byte & 1)) {
-				crc ^= DP_POLYNOMIAL;
-				crc |= 1;
-			}
-			cur_byte >>= 1;
-		}
-	}
-	crc >>= 23;
-
-	return (crc);
-}
-
-
-void set_bit_le(int offset, unsigned char * data)
-{
-	data[offset >> 3] |= (1 << (offset & 0x07));
-}
 #define HASH_TABLE	0x200
 static void __set_rx_mode(struct net_device *dev)
 {
@@ -1960,9 +1923,8 @@
 		memset(mc_filter, 0, sizeof(mc_filter));
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
 			 i++, mclist = mclist->next) {
-			set_bit_le(
-				dp83815_crc(ETH_ALEN, mclist->dmi_addr) & 0x1ff,
-				mc_filter);
+			int i = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
+			mc_filter[i/8] |= (1 << (i & 0x07));
 		}
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptMulticast | AcceptMyPhys;

--------------040607060806030409070906--
