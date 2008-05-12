From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 01/12] lib: create common ascii hex array
Date: Mon, 12 May 2008 12:05:34 -0700
Message-ID: <1210619134.24092.51.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-ide <linux-ide@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Jason Wessel <jason.wessel@windriver.com>,
	David Howells <dhowells@redhat.com>,
	"ralf@linux-mips.org" <ralf@linux-mips.org>,
	Paul Mundt <lethal@linux-sh.org>,
	Paul Mackerras <paulus@samba.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a common hex array in hexdump.c so everyone can use it.

Add a common hi/lo helper to avoid the shifting masking that is
done to get the upper and lower nibbles of a byte value.

Pull the pack_hex_byte helper from kgdb as it is opencoded many
places in the tree that will be consolidated.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Andrew, please drop the two patches in -mm titled:

lib-add-ascii-hex-helper-functions.patch
lib-add-ascii-hex-helper-functions-update.patch

As this patch series drops the _u8/u16/u32/u64 helpers that were close
the simple_strtol etc.  The remaining changes are all pretty trivial
and provide a nice cleanup.

 arch/sh/kernel/kgdb_stub.c |    8 --------
 drivers/pnp/support.c      |    8 ++++----
 include/linux/kernel.h     |   12 +++++++++++-
 kernel/kgdb.c              |    8 --------
 lib/hexdump.c              |    7 +++++--
 5 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/arch/sh/kernel/kgdb_stub.c b/arch/sh/kernel/kgdb_stub.c
index d453c3a..832641b 100644
--- a/arch/sh/kernel/kgdb_stub.c
+++ b/arch/sh/kernel/kgdb_stub.c
@@ -330,14 +330,6 @@ static char *ebin_to_mem(const char *buf, char *mem, int count)
 	return mem;
 }
 
-/* Pack a hex byte */
-static char *pack_hex_byte(char *pkt, int byte)
-{
-	*pkt++ = hexchars[(byte >> 4) & 0xf];
-	*pkt++ = hexchars[(byte & 0xf)];
-	return pkt;
-}
-
 /* Scan for the start char '$', read the packet and check the checksum */
 static void get_packet(char *buffer, int buflen)
 {
diff --git a/drivers/pnp/support.c b/drivers/pnp/support.c
index 3eba85e..95b076c 100644
--- a/drivers/pnp/support.c
+++ b/drivers/pnp/support.c
@@ -45,10 +45,10 @@ void pnp_eisa_id_to_string(u32 id, char *str)
 	str[0] = 'A' + ((id >> 26) & 0x3f) - 1;
 	str[1] = 'A' + ((id >> 21) & 0x1f) - 1;
 	str[2] = 'A' + ((id >> 16) & 0x1f) - 1;
-	str[3] = hex_asc((id >> 12) & 0xf);
-	str[4] = hex_asc((id >>  8) & 0xf);
-	str[5] = hex_asc((id >>  4) & 0xf);
-	str[6] = hex_asc((id >>  0) & 0xf);
+	str[3] = hex_asc_hi(id >> 8);
+	str[4] = hex_asc_lo(id >> 8);
+	str[5] = hex_asc_hi(id);
+	str[6] = hex_asc_lo(id);
 	str[7] = '\0';
 }
 
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 4d46e29..792bf0a 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -276,7 +276,17 @@ extern void print_hex_dump(const char *level, const char *prefix_str,
 				const void *buf, size_t len, bool ascii);
 extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
 			const void *buf, size_t len);
-#define hex_asc(x)	"0123456789abcdef"[x]
+
+extern const char hex_asc[];
+#define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
+#define hex_asc_hi(x)	hex_asc[((x) & 0xf0) >> 4]
+
+static inline char *pack_hex_byte(char *buf, u8 byte)
+{
+	*buf++ = hex_asc_hi(byte);
+	*buf++ = hex_asc_lo(byte);
+	return buf;
+}
 
 #define pr_emerg(fmt, arg...) \
 	printk(KERN_EMERG fmt, ##arg)
diff --git a/kernel/kgdb.c b/kernel/kgdb.c
index 39e31a0..14787de 100644
--- a/kernel/kgdb.c
+++ b/kernel/kgdb.c
@@ -346,14 +346,6 @@ static void put_packet(char *buffer)
 	}
 }
 
-static char *pack_hex_byte(char *pkt, u8 byte)
-{
-	*pkt++ = hexchars[byte >> 4];
-	*pkt++ = hexchars[byte & 0xf];
-
-	return pkt;
-}
-
 /*
  * Convert the memory pointed to by mem into hex, placing result in buf.
  * Return a pointer to the last char put in buf (null). May return an error.
diff --git a/lib/hexdump.c b/lib/hexdump.c
index 3435465..f07c0db 100644
--- a/lib/hexdump.c
+++ b/lib/hexdump.c
@@ -12,6 +12,9 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 
+const char hex_asc[] = "0123456789abcdef";
+EXPORT_SYMBOL(hex_asc);
+
 /**
  * hex_dump_to_buffer - convert a blob of data to "hex ASCII" in memory
  * @buf: data blob to dump
@@ -93,8 +96,8 @@ void hex_dump_to_buffer(const void *buf, size_t len, int rowsize,
 		for (j = 0; (j < rowsize) && (j < len) && (lx + 4) < linebuflen;
 		     j++) {
 			ch = ptr[j];
-			linebuf[lx++] = hex_asc(ch >> 4);
-			linebuf[lx++] = hex_asc(ch & 0x0f);
+			linebuf[lx++] = hex_asc_hi(ch);
+			linebuf[lx++] = hex_asc_lo(ch);
 			linebuf[lx++] = ' ';
 		}
 		ascii_column = 3 * rowsize + 2;
-- 
1.5.5.1.404.g981f6


