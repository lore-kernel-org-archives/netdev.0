From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 5/5] tlan: enable faster hash function
Date: Tue, 19 Oct 2004 11:24:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019112420.1a929633@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanout dead code, and use better hash function. The faster hash function
was already there, but not turned on by default.  Tested hash function for
10 million random addresses.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tlan.h b/drivers/net/tlan.h
--- a/drivers/net/tlan.h	2004-10-19 11:14:54 -07:00
+++ b/drivers/net/tlan.h	2004-10-19 11:14:54 -07:00
@@ -500,39 +500,31 @@
 
 }
 
-
-
-#if 0
-static inline void TLan_ClearBit(u8 bit, u16 port)
-{
-	outb_p(inb_p(port) & ~bit, port);
-}
-
-
-
-
-static inline int TLan_GetBit(u8 bit, u16 port)
-{
-	return ((int) (inb_p(port) & bit));
-}
-
-
-
-
-static inline void TLan_SetBit(u8 bit, u16 port)
-{
-	outb_p(inb_p(port) | bit, port);
-}
-#endif
-
 #define TLan_ClearBit( bit, port )	outb_p(inb_p(port) & ~bit, port)
 #define TLan_GetBit( bit, port )	((int) (inb_p(port) & bit))
 #define TLan_SetBit( bit, port )	outb_p(inb_p(port) | bit, port)
 
-#ifdef I_LIKE_A_FAST_HASH_FUNCTION
-/* given 6 bytes, view them as 8 6-bit numbers and return the XOR of those */
-/* the code below is about seven times as fast as the original code */
-static inline u32 TLan_HashFunc( u8 *a )
+/*
+ * given 6 bytes, view them as 8 6-bit numbers and return the XOR of those 
+ * the code below is about seven times as fast as the original code 
+ *
+ * The original code was:
+ *
+ * u32	xor( u32 a, u32 b ) {	return ( ( a && ! b ) || ( ! a && b ) ); }
+ *
+ * #define XOR8( a, b, c, d, e, f, g, h )	\
+ * 	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
+ * #define DA( a, bit )		( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
+ *
+ * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24), DA(a,30), DA(a,36), DA(a,42) );
+ * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25), DA(a,31), DA(a,37), DA(a,43) ) << 1;
+ * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26), DA(a,32), DA(a,38), DA(a,44) ) << 2;
+ * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27), DA(a,33), DA(a,39), DA(a,45) ) << 3;
+ * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28), DA(a,34), DA(a,40), DA(a,46) ) << 4;
+ * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29), DA(a,35), DA(a,41), DA(a,47) ) << 5;
+ *
+ */
+static inline u32 TLan_HashFunc( const u8 *a )
 {
         u8     hash;
 
@@ -545,30 +537,4 @@
 
         return (hash & 077);
 }
-
-#else /* original code */
-
-static inline	u32	xor( u32 a, u32 b )
-{
-	return ( ( a && ! b ) || ( ! a && b ) );
-}
-#define XOR8( a, b, c, d, e, f, g, h )	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
-#define DA( a, bit )					( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
-
-static inline u32 TLan_HashFunc( u8 *a )
-{
-	u32	hash;
-
-	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24), DA(a,30), DA(a,36), DA(a,42) );
-	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25), DA(a,31), DA(a,37), DA(a,43) ) << 1;
-	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26), DA(a,32), DA(a,38), DA(a,44) ) << 2;
-	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27), DA(a,33), DA(a,39), DA(a,45) ) << 3;
-	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28), DA(a,34), DA(a,40), DA(a,46) ) << 4;
-	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29), DA(a,35), DA(a,41), DA(a,47) ) << 5;
-
-	return hash;
-
-} 
-
-#endif /* I_LIKE_A_FAST_HASH_FUNCTION */
 #endif
