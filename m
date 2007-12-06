From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Reduce stack used by lib/hexdump.c
Date: Thu, 06 Dec 2007 13:52:27 -0800
Message-ID: <1196977948.10819.135.camel@localhost>
References: <1196359724.22120.22.camel@localhost>
	 <20071129102400.dac158d8.randy.dunlap@oracle.com>
	 <1196361860.22120.27.camel@localhost> <474F0A68.1080809@oracle.com>
	 <1196369873.22120.69.camel@localhost> <474F28EB.20608@oracle.com>
	 <Pine.LNX.4.64.0711292206450.3089@fbirervta.pbzchgretzou.qr>
	 <1196378922.22120.72.camel@localhost>
	 <20071205160133.0766c4f5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jengelh@computergmbh.de, Kyle Moffett <mrmacman_g4@mac.com>,
	randy.dunlap@oracle.com, linux-kernel@vger.kernel.org,
	"Ted Ts'o" <tytso@mit.edu>, Andreas Dilger <adilger@clusterfs.com>,
	Dave Kleikamp <shaggy@austin.ibm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	David Woodhouse <dwmw2@infradead.org>,
	Eric Sandeen <sandeen@redhat.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Jeff Garzik <jgarzik@pobox.com>, Mingming Cao <cmm@us.ibm.com>,
	Stephen Tweedie <sct@redhat.com>, Zhu Yi <yi.zhu@intel.com>,
	ipw3945-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net, linux-ext4@vger.kernel.org,
	linux-mtd@lists.infradead.org, linux-scsi@vger.kernel.org,
	linux-usb-devel@lists.sourceforge.net,
	linux-usb-users@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20071205160133.0766c4f5.akpm@linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-12-05 at 16:01 -0800, Andrew Morton wrote:
> No, I think print_hex_dump() is too low-level to be doing allocations. 
> For example, one could easily choose to call print_hex_dump() at oops time,
> and then what happens if we oops in kmalloc() (as we often do...)?
> 
> You could trim linebuf[] to 80 chars or so.  Extra points for making it
> very clear when someone tries to exceed that - strcpy(linebuf, "stop being
> stupid").

No extra points, but here's a revised patch to hexdump against
Linus' current:

hex_dump_to_buffer:
	Removes casts to type for non-1 group sizes
		Used by: fs/ext(3|4)super.c, fs/jfs
		If someone really dislikes this change, please say so.
		I think casting to type in a hex dump odd, especially
		for mixed type structures.
		If you want an array of type dumper, it probably
		shouldn't be called hex_dump_to_buffer.
	Groups by arbitrary size

print_hex_dump:
	Removes rowsize argument
	Reduces linebuf stack use to ~120 bytes
		prefix:25 + address:20 + data:48 + ascii:20)
	Aligns multiline ascii output
	Changes return to size_t, number of bytes actually output

include/linux/kernel.h
	Removes hex_asc define
	Updates hex_dump prototypes

The rest are trivial conversions to new argument list.
	
size before:
   text    data     bss     dec     hex filename
   1142       0       0    1142     476 lib/hexdump.o

size after:
   text    data     bss     dec     hex filename
    823       0       0     823     337 lib/hexdump.o

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/kernel.h                      |   13 +-
 lib/hexdump.c                               |  164 ++++++++++++---------------
 drivers/mtd/ubi/debug.c                     |    2 +-
 drivers/mtd/ubi/io.c                        |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    4 +-
 drivers/scsi/ide-scsi.c                     |    8 +-
 drivers/usb/gadget/file_storage.c           |    4 +-
 fs/ext3/super.c                             |    6 +-
 fs/ext4/super.c                             |    6 +-
 fs/jffs2/wbuf.c                             |    4 +-
 fs/jfs/jfs_imap.c                           |    2 +-
 fs/jfs/jfs_logmgr.c                         |    6 +-
 fs/jfs/jfs_metapage.c                       |    2 +-
 fs/jfs/jfs_txnmgr.c                         |    8 +-
 fs/jfs/xattr.c                              |    4 +-
 16 files changed, 110 insertions(+), 129 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 94bc996..ab45524 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -248,15 +248,14 @@ enum {
 	DUMP_PREFIX_ADDRESS,
 	DUMP_PREFIX_OFFSET
 };
-extern void hex_dump_to_buffer(const void *buf, size_t len,
-				int rowsize, int groupsize,
-				char *linebuf, size_t linebuflen, bool ascii);
+extern size_t hex_dump_to_buffer(const void *buf, size_t len,
+				 size_t rowsize, size_t groupsize,
+				 char *linebuf, size_t linebuflen, bool ascii);
 extern void print_hex_dump(const char *level, const char *prefix_str,
-				int prefix_type, int rowsize, int groupsize,
-				const void *buf, size_t len, bool ascii);
+			   int prefix_type, size_t groupsize,
+			   const void *buf, size_t len, bool ascii);
 extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
-			const void *buf, size_t len);
-#define hex_asc(x)	"0123456789abcdef"[x]
+				 const void *buf, size_t len);
 
 #define pr_emerg(fmt, arg...) \
 	printk(KERN_EMERG fmt, ##arg)
diff --git a/lib/hexdump.c b/lib/hexdump.c
index 3435465..df82012 100644
--- a/lib/hexdump.c
+++ b/lib/hexdump.c
@@ -12,18 +12,21 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 
+#define ROWSIZE ((size_t)16)
+#define MAX_PREFIX_LEN ((size_t)20)
+
 /**
  * hex_dump_to_buffer - convert a blob of data to "hex ASCII" in memory
  * @buf: data blob to dump
  * @len: number of bytes in the @buf
- * @rowsize: number of bytes to print per line; must be 16 or 32
+ * @rowsize: maximum number of bytes to output (aligns ascii)
  * @groupsize: number of bytes to print at a time (1, 2, 4, 8; default = 1)
  * @linebuf: where to put the converted data
  * @linebuflen: total size of @linebuf, including space for terminating NUL
  * @ascii: include ASCII after the hex output
  *
  * hex_dump_to_buffer() works on one "line" of output at a time, i.e.,
- * 16 or 32 bytes of input data converted to hex + ASCII output.
+ * input data converted to hex + ASCII output.
  *
  * Given a buffer of u8 data, hex_dump_to_buffer() converts the input data
  * to a hex + ASCII dump at the supplied memory location.
@@ -31,85 +34,54 @@
  *
  * E.g.:
  *   hex_dump_to_buffer(frame->data, frame->len, 16, 1,
- *			linebuf, sizeof(linebuf), 1);
+ *			linebuf, sizeof(linebuf), true);
  *
  * example output buffer:
  * 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
  */
-void hex_dump_to_buffer(const void *buf, size_t len, int rowsize,
-			int groupsize, char *linebuf, size_t linebuflen,
-			bool ascii)
+size_t hex_dump_to_buffer(const void *buf, size_t len,
+			  size_t rowsize, size_t groupsize,
+			  char *linebuf, size_t linebuflen, bool ascii)
 {
 	const u8 *ptr = buf;
-	u8 ch;
-	int j, lx = 0;
-	int ascii_column;
-
-	if (rowsize != 16 && rowsize != 32)
-		rowsize = 16;
-
+	int i, lx = 0;
+	size_t ascii_column;
+	size_t ngroups;
 	if (!len)
 		goto nil;
-	if (len > rowsize)		/* limit to one line at a time */
-		len = rowsize;
-	if ((len % groupsize) != 0)	/* no mixed size output */
-		groupsize = 1;
-
-	switch (groupsize) {
-	case 8: {
-		const u64 *ptr8 = buf;
-		int ngroups = len / groupsize;
-
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%16.16llx ", (unsigned long long)*(ptr8 + j));
-		ascii_column = 17 * ngroups + 2;
-		break;
-	}
-
-	case 4: {
-		const u32 *ptr4 = buf;
-		int ngroups = len / groupsize;
-
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%8.8x ", *(ptr4 + j));
-		ascii_column = 9 * ngroups + 2;
-		break;
-	}
 
-	case 2: {
-		const u16 *ptr2 = buf;
-		int ngroups = len / groupsize;
+	if (groupsize == 0)
+		groupsize = 1;
+	else if (groupsize > rowsize)
+		groupsize = rowsize;
 
-		for (j = 0; j < ngroups; j++)
-			lx += scnprintf(linebuf + lx, linebuflen - lx,
-				"%4.4x ", *(ptr2 + j));
-		ascii_column = 5 * ngroups + 2;
-		break;
-	}
+	ngroups = rowsize / groupsize;
+	ascii_column = (2 * groupsize + 1) * ngroups + 2;
+	if (len > (ngroups * groupsize))
+		len = ngroups * groupsize;
 
-	default:
-		for (j = 0; (j < rowsize) && (j < len) && (lx + 4) < linebuflen;
-		     j++) {
-			ch = ptr[j];
-			linebuf[lx++] = hex_asc(ch >> 4);
-			linebuf[lx++] = hex_asc(ch & 0x0f);
+	for (i = 0; i < len; i++) {
+		if (i && (i % groupsize) == 0)
 			linebuf[lx++] = ' ';
-		}
-		ascii_column = 3 * rowsize + 2;
-		break;
+		lx += scnprintf(linebuf + lx, linebuflen - lx,
+				"%02x", ptr[i] & 0xff);
 	}
+
 	if (!ascii)
 		goto nil;
 
 	while (lx < (linebuflen - 1) && lx < (ascii_column - 1))
 		linebuf[lx++] = ' ';
-	for (j = 0; (j < rowsize) && (j < len) && (lx + 2) < linebuflen; j++)
-		linebuf[lx++] = (isascii(ptr[j]) && isprint(ptr[j])) ? ptr[j]
-				: '.';
+
+	for (i = 0; i < len && (lx + 2) < linebuflen; i++) {
+		if (i > 0 && groupsize > 1 && (i % groupsize) == 0)
+			linebuf[lx++] = ' ';
+		linebuf[lx++] = (isascii(ptr[i]) && isprint(ptr[i]))
+			? ptr[i] : '.';
+	}
 nil:
-	linebuf[lx++] = '\0';
+	linebuf[lx] = '\0';
+	return len;
 }
 EXPORT_SYMBOL(hex_dump_to_buffer);
 
@@ -120,7 +92,6 @@ EXPORT_SYMBOL(hex_dump_to_buffer);
  *  caller supplies trailing spaces for alignment if desired
  * @prefix_type: controls whether prefix of an offset, address, or none
  *  is printed (%DUMP_PREFIX_OFFSET, %DUMP_PREFIX_ADDRESS, %DUMP_PREFIX_NONE)
- * @rowsize: number of bytes to print per line; must be 16 or 32
  * @groupsize: number of bytes to print at a time (1, 2, 4, 8; default = 1)
  * @buf: data blob to dump
  * @len: number of bytes in the @buf
@@ -131,48 +102,60 @@ EXPORT_SYMBOL(hex_dump_to_buffer);
  * leading prefix.
  *
  * print_hex_dump() works on one "line" of output at a time, i.e.,
- * 16 or 32 bytes of input data converted to hex + ASCII output.
+ * 16 bytes of input data converted to hex + ASCII output.
  * print_hex_dump() iterates over the entire input @buf, breaking it into
- * "line size" chunks to format and print.
+ * groups of up to 16 byte chunks to format and print.
  *
  * E.g.:
- *   print_hex_dump(KERN_DEBUG, "raw data: ", DUMP_PREFIX_ADDRESS,
- *		16, 1, frame->data, frame->len, 1);
+ *   print_hex_dump(KERN_DEBUG, "raw data: ", DUMP_PREFIX_ADDRESS, 1,
+ *		    frame->data, frame->len, 1);
  *
  * Example output using %DUMP_PREFIX_OFFSET and 1-byte mode:
- * 0009ab42: 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
- * Example output using %DUMP_PREFIX_ADDRESS and 4-byte mode:
- * ffffffff88089af0: 73727170 77767574 7b7a7978 7f7e7d7c  pqrstuvwxyz{|}~.
+ * 00000000: 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f  @ABCDEFGHIJKLMNO
+ * Example output using %DUMP_PREFIX_ADDRESS and 4-byte mode on BE 64 bit:
+ * ffffffff88089af0: 70717273 74757677 78797a7b 7c7d7e7f  pqrs tuvw xyz{ |}~.
+ * Example output using %DUMP_PREFIX_ADDRESS and 5-byte mode on LE 32 bit:
+ * 88089af0: 7071727374 7576777879 7a7b7d7d7e  pqrst uvwxy z{|}~
  */
+
 void print_hex_dump(const char *level, const char *prefix_str, int prefix_type,
-			int rowsize, int groupsize,
-			const void *buf, size_t len, bool ascii)
+		    size_t groupsize, const void *buf, size_t len, bool ascii)
 {
 	const u8 *ptr = buf;
-	int i, linelen, remaining = len;
-	unsigned char linebuf[200];
-
-	if (rowsize != 16 && rowsize != 32)
-		rowsize = 16;
-
-	for (i = 0; i < len; i += rowsize) {
-		linelen = min(remaining, rowsize);
-		remaining -= rowsize;
-		hex_dump_to_buffer(ptr + i, linelen, rowsize, groupsize,
-				linebuf, sizeof(linebuf), ascii);
+	size_t i;
+	size_t linelen;
+	size_t prefix_len = strlen(prefix_str);
+	unsigned char linebuf[sizeof(KERN_INFO) +
+			      MAX_PREFIX_LEN +
+			      (2 * sizeof(void *) + 4) +
+			      (3 * ROWSIZE) +
+			      (3 * ROWSIZE / 2) + 1];
+	if (prefix_len > MAX_PREFIX_LEN)
+		prefix_len = MAX_PREFIX_LEN;
+
+	i = 0;
+	while (i < len) {
+		size_t bytes;
+		linelen = min(len - i, ROWSIZE);
+		bytes = hex_dump_to_buffer(ptr + i, linelen, ROWSIZE, groupsize,
+					   linebuf, sizeof(linebuf), ascii);
 
 		switch (prefix_type) {
 		case DUMP_PREFIX_ADDRESS:
-			printk("%s%s%*p: %s\n", level, prefix_str,
-				(int)(2 * sizeof(void *)), ptr + i, linebuf);
+			printk("%s%-.*s%*p: %s\n", level,
+			       prefix_len, prefix_str,
+			       (int)(2 * sizeof(void *)), ptr + i, linebuf);
 			break;
 		case DUMP_PREFIX_OFFSET:
-			printk("%s%s%.8x: %s\n", level, prefix_str, i, linebuf);
+			printk("%s%-.*s%.8x: %s\n", level,
+			       prefix_len, prefix_str, i, linebuf);
 			break;
 		default:
-			printk("%s%s%s\n", level, prefix_str, linebuf);
+			printk("%s%-.*s%s\n", level,
+			       prefix_len, prefix_str, linebuf);
 			break;
 		}
+		i += bytes;
 	}
 }
 EXPORT_SYMBOL(print_hex_dump);
@@ -187,12 +170,11 @@ EXPORT_SYMBOL(print_hex_dump);
  * @len: number of bytes in the @buf
  *
  * Calls print_hex_dump(), with log level of KERN_DEBUG,
- * rowsize of 16, groupsize of 1, and ASCII output included.
+ * groupsize of 1, and ASCII output included.
  */
 void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
-			const void *buf, size_t len)
+			  const void *buf, size_t len)
 {
-	print_hex_dump(KERN_DEBUG, prefix_str, prefix_type, 16, 1,
-			buf, len, 1);
+	print_hex_dump(KERN_DEBUG, prefix_str, prefix_type, 1, buf, len, true);
 }
 EXPORT_SYMBOL(print_hex_dump_bytes);
diff --git a/drivers/mtd/ubi/debug.c b/drivers/mtd/ubi/debug.c
index 56956ec..d99c4d5 100644
--- a/drivers/mtd/ubi/debug.c
+++ b/drivers/mtd/ubi/debug.c
@@ -42,7 +42,7 @@ void ubi_dbg_dump_ec_hdr(const struct ubi_ec_hdr *ec_hdr)
 	dbg_msg("data_offset    %d",    be32_to_cpu(ec_hdr->data_offset));
 	dbg_msg("hdr_crc        %#08x", be32_to_cpu(ec_hdr->hdr_crc));
 	dbg_msg("erase counter header hexdump:");
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 32, 1,
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 1,
 		       ec_hdr, UBI_EC_HDR_SIZE, 1);
 }
 
diff --git a/drivers/mtd/ubi/io.c b/drivers/mtd/ubi/io.c
index 7c304ee..20cf7b2 100644
--- a/drivers/mtd/ubi/io.c
+++ b/drivers/mtd/ubi/io.c
@@ -1243,7 +1243,7 @@ static int paranoid_check_all_ff(struct ubi_device *ubi, int pnum, int offset,
 fail:
 	ubi_err("paranoid check failed for PEB %d", pnum);
 	dbg_msg("hex dump of the %d-%d region", offset, offset + len);
-	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 32, 1,
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 1,
 		       ubi->dbg_peb_buf, len, 1);
 	err = 1;
 error:
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4bdf237..563c30f 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -184,8 +184,8 @@ static void iwl_print_hex_dump(int level, void *p, u32 len)
 	if (!(iwl_debug_level & level))
 		return;
 
-	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 16, 1,
-			p, len, 1);
+	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 1,
+		       p, len, 1);
 #endif
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 8f85564..150f6e4 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -183,8 +183,8 @@ static void iwl_print_hex_dump(int level, void *p, u32 len)
 	if (!(iwl_debug_level & level))
 		return;
 
-	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 16, 1,
-			p, len, 1);
+	print_hex_dump(KERN_DEBUG, "iwl data: ", DUMP_PREFIX_OFFSET, 1,
+		       p, len, 1);
 #endif
 }
 
diff --git a/drivers/scsi/ide-scsi.c b/drivers/scsi/ide-scsi.c
index 7a835a3..cc2da8a 100644
--- a/drivers/scsi/ide-scsi.c
+++ b/drivers/scsi/ide-scsi.c
@@ -272,7 +272,7 @@ static int idescsi_check_condition(ide_drive_t *drive, struct request *failed_co
 	pc->scsi_cmd = ((idescsi_pc_t *) failed_command->special)->scsi_cmd;
 	if (test_bit(IDESCSI_LOG_CMD, &scsi->log)) {
 		printk ("ide-scsi: %s: queue cmd = ", drive->name);
-		print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 16, 1, pc->c,
+		print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 1, pc->c,
 			       6, 0);
 	}
 	rq->rq_disk = scsi->disk;
@@ -328,7 +328,7 @@ static int idescsi_end_request (ide_drive_t *drive, int uptodate, int nrsecs)
 		idescsi_pc_t *opc = (idescsi_pc_t *) rq->buffer;
 		if (log) {
 			printk ("ide-scsi: %s: wrap up check %lu, rst = ", drive->name, opc->scsi_cmd->serial_number);
-			print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 16, 1,
+			print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 1,
 				       pc->buffer, 16, 0);
 		}
 		memcpy((void *) opc->scsi_cmd->sense_buffer, pc->buffer, SCSI_SENSE_BUFFERSIZE);
@@ -808,11 +808,11 @@ static int idescsi_queue (struct scsi_cmnd *cmd,
 
 	if (test_bit(IDESCSI_LOG_CMD, &scsi->log)) {
 		printk ("ide-scsi: %s: que %lu, cmd = ", drive->name, cmd->serial_number);
-		print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 16, 1,
+		print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 1,
 			       cmd->cmnd, cmd->cmd_len, 0);
 		if (memcmp(pc->c, cmd->cmnd, cmd->cmd_len)) {
 			printk ("ide-scsi: %s: que %lu, tsl = ", drive->name, cmd->serial_number);
-			print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 16, 1,
+			print_hex_dump(KERN_CONT, "", DUMP_PREFIX_NONE, 1,
 				       pc->c, 12, 0);
 		}
 	}
diff --git a/drivers/usb/gadget/file_storage.c b/drivers/usb/gadget/file_storage.c
index 1d174dc..e690949 100644
--- a/drivers/usb/gadget/file_storage.c
+++ b/drivers/usb/gadget/file_storage.c
@@ -723,7 +723,7 @@ static void dump_msg(struct fsg_dev *fsg, const char *label,
 	if (length < 512) {
 		DBG(fsg, "%s, length %u:\n", label, length);
 		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET,
-				16, 1, buf, length, 0);
+			       1, buf, length, 0);
 	}
 }
 
@@ -741,7 +741,7 @@ static void dump_msg(struct fsg_dev *fsg, const char *label,
 static void dump_cdb(struct fsg_dev *fsg)
 {
 	print_hex_dump(KERN_DEBUG, "SCSI CDB: ", DUMP_PREFIX_NONE,
-			16, 1, fsg->cmnd, fsg->cmnd_size, 0);
+		       1, fsg->cmnd, fsg->cmnd_size, 0);
 }
 
 #else
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index de55da9..f5022a3 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -464,9 +464,9 @@ static void ext3_destroy_inode(struct inode *inode)
 	if (!list_empty(&(EXT3_I(inode)->i_orphan))) {
 		printk("EXT3 Inode %p: orphan list check failed!\n",
 			EXT3_I(inode));
-		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 16, 4,
-				EXT3_I(inode), sizeof(struct ext3_inode_info),
-				false);
+		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 4,
+			       EXT3_I(inode), sizeof(struct ext3_inode_info),
+			       false);
 		dump_stack();
 	}
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 8031dc0..edd6a80 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -517,9 +517,9 @@ static void ext4_destroy_inode(struct inode *inode)
 	if (!list_empty(&(EXT4_I(inode)->i_orphan))) {
 		printk("EXT4 Inode %p: orphan list check failed!\n",
 			EXT4_I(inode));
-		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 16, 4,
-				EXT4_I(inode), sizeof(struct ext4_inode_info),
-				true);
+		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 4,
+			       EXT4_I(inode), sizeof(struct ext4_inode_info),
+			       true);
 		dump_stack();
 	}
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
diff --git a/fs/jffs2/wbuf.c b/fs/jffs2/wbuf.c
index d1d4f27..c03977e 100644
--- a/fs/jffs2/wbuf.c
+++ b/fs/jffs2/wbuf.c
@@ -248,11 +248,11 @@ static int jffs2_verify_write(struct jffs2_sb_info *c, unsigned char *buf,
 
 	printk(KERN_WARNING "Write verify error (ECC %s) at %08x. Wrote:\n",
 	       eccstr, c->wbuf_ofs);
-	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 16, 1,
+	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 1,
 		       c->wbuf, c->wbuf_pagesize, 0);
 
 	printk(KERN_WARNING "Read back:\n");
-	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 16, 1,
+	print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET, 1,
 		       c->wbuf_verify, c->wbuf_pagesize, 0);
 
 	return -EIO;
diff --git a/fs/jfs/jfs_imap.c b/fs/jfs/jfs_imap.c
index 3870ba8..c22907d 100644
--- a/fs/jfs/jfs_imap.c
+++ b/fs/jfs/jfs_imap.c
@@ -890,7 +890,7 @@ int diFree(struct inode *ip)
 	 * the map.
 	 */
 	if (iagno >= imap->im_nextiag) {
-		print_hex_dump(KERN_ERR, "imap: ", DUMP_PREFIX_ADDRESS, 16, 4,
+		print_hex_dump(KERN_ERR, "imap: ", DUMP_PREFIX_ADDRESS, 4,
 			       imap, 32, 0);
 		jfs_error(ip->i_sb,
 			  "diFree: inum = %d, iagno = %d, nextiag = %d",
diff --git a/fs/jfs/jfs_logmgr.c b/fs/jfs/jfs_logmgr.c
index 15a3974..a54e19f 100644
--- a/fs/jfs/jfs_logmgr.c
+++ b/fs/jfs/jfs_logmgr.c
@@ -1627,15 +1627,15 @@ void jfs_flush_journal(struct jfs_log *log, int wait)
 			if (lp->xflag & COMMIT_PAGE) {
 				struct metapage *mp = (struct metapage *)lp;
 				print_hex_dump(KERN_ERR, "metapage: ",
-					       DUMP_PREFIX_ADDRESS, 16, 4,
+					       DUMP_PREFIX_ADDRESS, 4,
 					       mp, sizeof(struct metapage), 0);
 				print_hex_dump(KERN_ERR, "page: ",
-					       DUMP_PREFIX_ADDRESS, 16,
+					       DUMP_PREFIX_ADDRESS,
 					       sizeof(long), mp->page,
 					       sizeof(struct page), 0);
 			} else
 				print_hex_dump(KERN_ERR, "tblock:",
-					       DUMP_PREFIX_ADDRESS, 16, 4,
+					       DUMP_PREFIX_ADDRESS, 4,
 					       lp, sizeof(struct tblock), 0);
 		}
 	}
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index f5cd8d3..9e5fb41 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -461,7 +461,7 @@ add_failed:
 	printk(KERN_ERR "JFS: bio_add_page failed unexpectedly\n");
 	goto skip;
 dump_bio:
-	print_hex_dump(KERN_ERR, "JFS: dump of bio: ", DUMP_PREFIX_ADDRESS, 16,
+	print_hex_dump(KERN_ERR, "JFS: dump of bio: ", DUMP_PREFIX_ADDRESS,
 		       4, bio, sizeof(*bio), 0);
 skip:
 	bio_put(bio);
diff --git a/fs/jfs/jfs_txnmgr.c b/fs/jfs/jfs_txnmgr.c
index e7c60ae..a105198 100644
--- a/fs/jfs/jfs_txnmgr.c
+++ b/fs/jfs/jfs_txnmgr.c
@@ -830,14 +830,14 @@ struct tlock *txLock(tid_t tid, struct inode *ip, struct metapage * mp,
 	/* assert(jfs_ip->fileset == AGGREGATE_I); */
 	if (jfs_ip->fileset != AGGREGATE_I) {
 		printk(KERN_ERR "txLock: trying to lock locked page!");
-		print_hex_dump(KERN_ERR, "ip: ", DUMP_PREFIX_ADDRESS, 16, 4,
+		print_hex_dump(KERN_ERR, "ip: ", DUMP_PREFIX_ADDRESS, 4,
 			       ip, sizeof(*ip), 0);
-		print_hex_dump(KERN_ERR, "mp: ", DUMP_PREFIX_ADDRESS, 16, 4,
+		print_hex_dump(KERN_ERR, "mp: ", DUMP_PREFIX_ADDRESS, 4,
 			       mp, sizeof(*mp), 0);
 		print_hex_dump(KERN_ERR, "Locker's tblock: ",
-			       DUMP_PREFIX_ADDRESS, 16, 4, tid_to_tblock(tid),
+			       DUMP_PREFIX_ADDRESS, 4, tid_to_tblock(tid),
 			       sizeof(struct tblock), 0);
-		print_hex_dump(KERN_ERR, "Tlock: ", DUMP_PREFIX_ADDRESS, 16, 4,
+		print_hex_dump(KERN_ERR, "Tlock: ", DUMP_PREFIX_ADDRESS, 4,
 			       tlck, sizeof(*tlck), 0);
 		BUG();
 	}
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index 9b7f2cd..43c0d70 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -590,8 +590,8 @@ static int ea_get(struct inode *inode, struct ea_buffer *ea_buf, int min_size)
       size_check:
 	if (EALIST_SIZE(ea_buf->xattr) != ea_size) {
 		printk(KERN_ERR "ea_get: invalid extended attribute\n");
-		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1,
-				     ea_buf->xattr, ea_size, 1);
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 1,
+			       ea_buf->xattr, ea_size, 1);
 		ea_release(inode, ea_buf);
 		rc = -EIO;
 		goto clean_up;


