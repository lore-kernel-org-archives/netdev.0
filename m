From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] lib/vsprintf.c: Add %pMF to for FDDI bit reversed
 dashed output
Date: Mon, 04 Jan 2010 17:05:45 -0800
Message-ID: <1262653545.1868.50.camel@Joe-Laptop.home>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F63E@mi8nycmail19.Mi8.com>
	 <alpine.LFD.2.00.1001041833560.13474@eddie.linux-mips.org>
	 <20100104.110326.161162074.davem@davemloft.net>
	 <alpine.LFD.2.00.1001042256120.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hartleys@visionengravers.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754180Ab0AEBFu@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1001042256120.13474@eddie.linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
> The example below shows an address, and the sequence of bits or symbols 
> that would be transmitted when the address is used in the Source Address 
> or Destination Address fields on the MAC header.  The transmission line 
> shows the address bits in the order transmitted, from left to right.  For 
> IEEE 802 LANs these correspond to actual bits on the medium.  The FDDI 
> symbols line shows how the FDDI PHY sends the address bits as encoded 
> symbols.
> 
>         MSB:            35:7B:12:00:00:01
>         Canonical:      AC-DE-48-00-00-80
>         Transmission:   00110101 01111011 00010010 00000000 00000000 00000001
>         FDDI Symbols:   35 7B 12 00 00 01"
> 
> Please note that this address has its group bit clear.
> 
>  This notation is also defined in the "FDDI MEDIA ACCESS CONTROL-2 
> (MAC-2)" (X3T9/92-120) document although that book does not have a need 
> to use the MSB form and it's skipped.

Here's a possible patch to vsprintf to add %pMF to print
FDDI bit-reversed dash separated addresses.

vsprintf.o increases by 90 bytes.
Perhaps it's not worth that.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d4996cf..96f1987 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/bitrev.h>
 #include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -682,10 +683,18 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	char *p = mac_addr;
 	int i;
 
-	for (i = 0; i < 6; i++) {
-		p = pack_hex_byte(p, addr[i]);
-		if (fmt[0] == 'M' && i != 5)
-			*p++ = ':';
+	if (fmt[1] == 'F') {		/* FDDI canonical format */
+		for (i = 0; i < 6; i++) {
+			p = pack_hex_byte(p, bitrev8(addr[i]));
+			if (fmt[0] == 'M' && i != 5)
+				*p++ = '-';
+		}
+	} else {
+		for (i = 0; i < 6; i++) {
+			p = pack_hex_byte(p, addr[i]);
+			if (fmt[0] == 'M' && i != 5)
+				*p++ = ':';
+		}
 	}
 	*p = '\0';
 
@@ -896,6 +905,10 @@ static char *uuid_string(char *buf, char *end, const u8 *addr,
  * - 'M' For a 6-byte MAC address, it prints the address in the
  *       usual colon-separated hex notation
  * - 'm' For a 6-byte MAC address, it prints the hex address without colons
+ * - 'MF' For a 6-byte MAC FDDI address, it prints the address
+ *       with a dash-separated hex notation with bit reversed bytes
+ * - 'mF' For a 6-byte MAC FDDI address, it prints the address
+ *       in hex notation without separators with bit reversed bytes
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
@@ -939,6 +952,7 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return resource_string(buf, end, ptr, spec, fmt);
 	case 'M':			/* Colon separated: 00:01:02:03:04:05 */
 	case 'm':			/* Contiguous: 000102030405 */
+					/* [mM]F (FDDI, bit reversed) */
 		return mac_address_string(buf, end, ptr, spec, fmt);
 	case 'I':			/* Formatted IP supported
 					 * 4:	1.2.3.4
