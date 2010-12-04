From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] vsprintf: Add %pMbt, bluetooth mac address
Date: Fri,  3 Dec 2010 18:33:03 -0800
Message-ID: <a33a0b00eeb29713a08d91156cbb2d816176f990.1291419007.git.joe@perches.com>
References: <cover.1291419007.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291419007.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bluetooth output the MAC address in reverse order.
Bluetooth memory order: 00 01 02 03 04 05 is output "05:04:03:02:01:00".

This can save overall text when bluetooth is compiled in.

Bluetooth currently uses a very slightly unsafe local function (batostr)
to output these formatted addresses.

Adding %pMbt allows the batostr function to be removed.

For x86:

$ size lib/vsprintf*.o*
   text	   data	    bss	    dec	    hex	filename
   8189	      0	      2	   8191	   1fff	lib/vsprintf.o.defconfig.new
   8150	      0	      2	   8152	   1fd8	lib/vsprintf.o.defconfig.old
  18633	     56	   3936	  22625	   5861	lib/vsprintf.o.allyesconfig.new
  18571	     56	   3920	  22547	   5813	lib/vsprintf.o.allyesconfig.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 lib/vsprintf.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index c150d3d..9346ed9 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -700,15 +700,18 @@ char *mac_address_string(char *buf, char *end, u8 *addr,
 	char *p = mac_addr;
 	int i;
 	char separator;
+	bool bluetooth = false;
 
 	if (fmt[1] == 'F') {		/* FDDI canonical format */
 		separator = '-';
 	} else {
 		separator = ':';
+		if (fmt[1] == 'b' && fmt[2] == 't')
+			bluetooth = true;
 	}
 
 	for (i = 0; i < 6; i++) {
-		p = pack_hex_byte(p, addr[i]);
+		p = pack_hex_byte(p, addr[!bluetooth ? i : 5 - i]);
 		if (fmt[0] == 'M' && i != 5)
 			*p++ = separator;
 	}
@@ -1012,6 +1015,7 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	case 'M':			/* Colon separated: 00:01:02:03:04:05 */
 	case 'm':			/* Contiguous: 000102030405 */
 					/* [mM]F (FDDI, bit reversed) */
+					/* [mM]bt (Bluetooth, index:543210) */
 		return mac_address_string(buf, end, ptr, spec, fmt);
 	case 'I':			/* Formatted IP supported
 					 * 4:	1.2.3.4
-- 
1.7.3.2.245.g03276.dirty
