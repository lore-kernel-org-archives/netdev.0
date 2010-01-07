From: Joe Perches <joe@perches.com>
Subject: [PATCH V3] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC addresses
Date: Thu, 07 Jan 2010 13:43:50 -0800
Message-ID: <1262900630.10429.80.camel@Joe-Laptop.home>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	 <1262888625.10429.23.camel@Joe-Laptop.home>
	 <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754118Ab0AGVnx@vger.kernel.org>
In-Reply-To: <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
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

Adds 6 bytes to object size for x86

New:
$ size lib/vsprintf.o
   text	   data	    bss	    dec	    hex	filename
   8664	      0	      2	   8666	   21da	lib/vsprintf.o
$ size lib/vsprintf.o
   text    data     bss     dec     hex filename
   8658       0       2    8660    21d4 lib/vsprintf.o

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d4996cf..dc48d2b 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/bitrev.h>
 #include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -681,11 +682,21 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
 	char *p = mac_addr;
 	int i;
+	bool bitrev;
+	char separator;
+
+	if (fmt[1] == 'F') {		/* FDDI canonical format */
+		bitrev = true;
+		separator = '-';
+	} else {
+		bitrev = false;
+		separator = ':';
+	}
 
 	for (i = 0; i < 6; i++) {
-		p = pack_hex_byte(p, addr[i]);
+		p = pack_hex_byte(p, bitrev ? bitrev8(addr[i]) : addr[i]);
 		if (fmt[0] == 'M' && i != 5)
-			*p++ = ':';
+			*p++ = separator;
 	}
 	*p = '\0';
 
@@ -896,6 +907,10 @@ static char *uuid_string(char *buf, char *end, const u8 *addr,
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
@@ -939,6 +954,7 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return resource_string(buf, end, ptr, spec, fmt);
 	case 'M':			/* Colon separated: 00:01:02:03:04:05 */
 	case 'm':			/* Contiguous: 000102030405 */
+					/* [mM]F (FDDI, bit reversed) */
 		return mac_address_string(buf, end, ptr, spec, fmt);
 	case 'I':			/* Formatted IP supported
 					 * 4:	1.2.3.4
