From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 3/15] wireless/orinoco: encapsulate direct
	hardware operations
Date: Tue, 26 Oct 2004 14:43:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098816189.3663.47.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Encapsulate direct hardware operations so those symbols
    don't need to be exported

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/hermes.c.3-direct-ops	2004-10-25 15:36:28.669981112 -0400
+++ b/drivers/net/wireless/hermes.c	2004-10-25 15:49:38.064974832 -0400
@@ -48,6 +48,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/net.h>
 #include <asm/errno.h>
 
 #include "hermes.h"
@@ -83,6 +84,32 @@
 
 #endif /* ! HERMES_DEBUG */
 
+static int hermes_init_direct(hermes_t *hw);
+static int hermes_docmd_wait_direct(hermes_t *hw, u16 cmd, u16 parm0,
+				    struct hermes_response *resp);
+static int hermes_allocate_direct(hermes_t *hw, u16 size, u16 *fid);
+static int hermes_bap_seek(hermes_t *hw, int bap, u16 id, u16 offset);
+static int hermes_bap_pread_direct(hermes_t *hw, int bap,
+				   void *buf, unsigned len,
+				   u16 id, u16 offset);
+static int hermes_bap_pwrite_direct(hermes_t *hw, int bap,
+				    const void *buf, unsigned len,
+				    u16 id, u16 offset);
+static int hermes_read_ltv_direct(hermes_t *hw, int bap, u16 rid,
+				  unsigned bufsize, u16 *length, void *buf);
+static int hermes_write_ltv_direct(hermes_t *hw, int bap, u16 rid, 
+				   u16 length, const void *value);
+
+static const struct hermes_ops hermes_ops_direct = {
+	.init = hermes_init_direct,
+	.docmd_wait = hermes_docmd_wait_direct,
+	.allocate = hermes_allocate_direct,
+	.read_ltv = hermes_read_ltv_direct,
+	.write_ltv = hermes_write_ltv_direct,
+	.bap_pread = hermes_bap_pread_direct,
+	.bap_pwrite = hermes_bap_pwrite_direct
+};
+
 
 /*
  * Internal functions
@@ -130,6 +157,7 @@
 	hw->io_space = io_space;
 	hw->reg_spacing = reg_spacing;
 	hw->inten = 0x0;
+	hw->ops = &hermes_ops_direct;
 
 #ifdef HERMES_DEBUG_BUFFER
 	hw->dbufp = 0;
@@ -138,7 +166,7 @@
 #endif
 }
 
-int hermes_init(hermes_t *hw)
+static int hermes_init_direct(hermes_t *hw)
 {
 	u16 status, reg;
 	int err = 0;
@@ -176,7 +204,7 @@
 	reg = hermes_read_regn(hw, EVSTAT);
 	hermes_write_regn(hw, EVACK, reg);
 
-	/* We don't use hermes_docmd_wait here, because the reset wipes
+	/* We don't use hermes_docmd_wait_direct here, because the reset wipes
 	   the magic constant in SWSUPPORT0 away, and it gets confused */
 	err = hermes_issue_cmd(hw, HERMES_CMD_INIT, 0);
 	if (err)
@@ -224,8 +252,8 @@
  * Returns: < 0 on internal error, 0 on success, > 0 on error returned by the firmware
  *
  * Callable from any context, but locking is your problem. */
-int hermes_docmd_wait(hermes_t *hw, u16 cmd, u16 parm0,
-		      struct hermes_response *resp)
+static int hermes_docmd_wait_direct(hermes_t *hw, u16 cmd, u16 parm0,
+				    struct hermes_response *resp)
 {
 	int err;
 	int k;
@@ -290,7 +318,7 @@
 	return err;
 }
 
-int hermes_allocate(hermes_t *hw, u16 size, u16 *fid)
+static int hermes_allocate_direct(hermes_t *hw, u16 size, u16 *fid)
 {
 	int err = 0;
 	int k;
@@ -299,7 +327,7 @@
 	if ( (size < HERMES_ALLOC_LEN_MIN) || (size > HERMES_ALLOC_LEN_MAX) )
 		return -EINVAL;
 
-	err = hermes_docmd_wait(hw, HERMES_CMD_ALLOC, size, NULL);
+	err = hermes_docmd_wait_direct(hw, HERMES_CMD_ALLOC, size, NULL);
 	if (err) {
 		return err;
 	}
@@ -397,7 +425,7 @@
 		if (reg & HERMES_OFFSET_BUSY) {
 			return -ETIMEDOUT;
 		}
- 
+
 		return -EIO;		/* error or wrong offset */
 	}
 
@@ -410,8 +438,8 @@
  *
  * Returns: < 0 on internal failure (errno), 0 on success, > 0 on error from firmware
  */
-int hermes_bap_pread(hermes_t *hw, int bap, void *buf, unsigned len,
-		     u16 id, u16 offset)
+static int hermes_bap_pread_direct(hermes_t *hw, int bap,
+				   void *buf, unsigned len, u16 id, u16 offset)
 {
 	int dreg = bap ? HERMES_DATA1 : HERMES_DATA0;
 	int err = 0;
@@ -436,8 +464,9 @@
  *
  * Returns: < 0 on internal failure (errno), 0 on success, > 0 on error from firmware
  */
-int hermes_bap_pwrite(hermes_t *hw, int bap, const void *buf, unsigned len,
-		      u16 id, u16 offset)
+static int hermes_bap_pwrite_direct(hermes_t *hw, int bap,
+				    const void *buf, unsigned len,
+				    u16 id, u16 offset)
 {
 	int dreg = bap ? HERMES_DATA1 : HERMES_DATA0;
 	int err = 0;
@@ -464,8 +493,8 @@
  * practice.
  *
  * Callable from user or bh context.  */
-int hermes_read_ltv(hermes_t *hw, int bap, u16 rid, unsigned bufsize,
-		    u16 *length, void *buf)
+static int hermes_read_ltv_direct(hermes_t *hw, int bap, u16 rid,
+				  unsigned bufsize, u16 *length, void *buf)
 {
 	int err = 0;
 	int dreg = bap ? HERMES_DATA1 : HERMES_DATA0;
@@ -475,7 +504,7 @@
 	if ( (bufsize < 0) || (bufsize % 2) )
 		return -EINVAL;
 
-	err = hermes_docmd_wait(hw, HERMES_CMD_ACCESS, rid, NULL);
+	err = hermes_docmd_wait_direct(hw, HERMES_CMD_ACCESS, rid, NULL);
 	if (err)
 		return err;
 
@@ -486,7 +515,7 @@
 	rlength = hermes_read_reg(hw, dreg);
 
 	if (! rlength)
-		return -ENOENT;
+		return -ENODATA;
 
 	rtype = hermes_read_reg(hw, dreg);
 
@@ -510,8 +539,8 @@
 	return 0;
 }
 
-int hermes_write_ltv(hermes_t *hw, int bap, u16 rid, 
-		     u16 length, const void *value)
+static int hermes_write_ltv_direct(hermes_t *hw, int bap, u16 rid, 
+				   u16 length, const void *value)
 {
 	int dreg = bap ? HERMES_DATA1 : HERMES_DATA0;
 	int err = 0;
@@ -531,21 +560,13 @@
 
 	hermes_write_words(hw, dreg, value, count);
 
-	err = hermes_docmd_wait(hw, HERMES_CMD_ACCESS | HERMES_CMD_WRITE, 
+	err = hermes_docmd_wait_direct(hw, HERMES_CMD_ACCESS | HERMES_CMD_WRITE, 
 				rid, NULL);
 
 	return err;
 }
 
 EXPORT_SYMBOL(hermes_struct_init);
-EXPORT_SYMBOL(hermes_init);
-EXPORT_SYMBOL(hermes_docmd_wait);
-EXPORT_SYMBOL(hermes_allocate);
-
-EXPORT_SYMBOL(hermes_bap_pread);
-EXPORT_SYMBOL(hermes_bap_pwrite);
-EXPORT_SYMBOL(hermes_read_ltv);
-EXPORT_SYMBOL(hermes_write_ltv);
 
 static int __init init_hermes(void)
 {
--- a/drivers/net/wireless/hermes.h.3-direct-ops	2004-10-25 14:44:04.557958792 -0400
+++ b/drivers/net/wireless/hermes.h	2004-10-25 15:52:32.134512240 -0400
@@ -191,6 +191,8 @@
 #define	HERMES_RXSTAT_TUNNEL		(0x4000)	/* bridge-tunnel encoded frame */
 #define	HERMES_RXSTAT_WMP		(0x6000)	/* Wavelan-II Management Protocol frame */
 
+#define HERMES_RXSTAT_GET_MACPORT(s)	(((s) & HERMES_RXSTAT_MACPORT) >> 8)
+
 struct hermes_tx_descriptor {
 	u16 status;
 	u16 reserved1;
@@ -340,7 +342,25 @@
 #ifdef __KERNEL__
 
 /* Timeouts */
-#define HERMES_BAP_BUSY_TIMEOUT (500) /* In iterations of ~1us */
+#define HERMES_BAP_BUSY_TIMEOUT (10000) /* In iterations of ~1us */
+
+struct hermes;
+
+/* Functions to access hardware */
+struct hermes_ops {
+	int (*init)(struct hermes *hw);
+	int (*docmd_wait)(struct hermes *hw, u16 cmd, u16 parm0,
+			  struct hermes_response *resp);
+	int (*allocate)(struct hermes *hw, u16 size, u16 *fid);
+	int (*read_ltv)(struct hermes *hw, int bap, u16 rid, unsigned buflen,
+			u16 *length, void *buf);
+	int (*write_ltv)(struct hermes *hw, int bap, u16 rid,
+			 u16 length, const void *value);
+	int (*bap_pread)(struct hermes *hw, int bap, void *buf, unsigned len,
+			 u16 id, u16 offset);
+	int (*bap_pwrite)(struct hermes *hw, int bap, const void *buf,
+			  unsigned len, u16 id, u16 offset);
+};
 
 /* Basic control structure */
 typedef struct hermes {
@@ -353,6 +373,8 @@
 #define HERMES_32BIT_REGSPACING	1
 
 	u16 inten; /* Which interrupts should be enabled? */
+	const struct hermes_ops *ops;
+	void *priv;
 
 #ifdef HERMES_DEBUG_BUFFER
 	struct hermes_debug_entry dbuf[HERMES_DEBUG_BUFSIZE];
@@ -375,21 +397,44 @@
 #define hermes_write_regn(hw, name, val) hermes_write_reg((hw), HERMES_##name, (val))
 
 /* Function prototypes */
-void hermes_struct_init(hermes_t *hw, ulong address, int io_space,
-			int reg_spacing);
-int hermes_init(hermes_t *hw);
-int hermes_docmd_wait(hermes_t *hw, u16 cmd, u16 parm0,
-		      struct hermes_response *resp);
-int hermes_allocate(hermes_t *hw, u16 size, u16 *fid);
-
-int hermes_bap_pread(hermes_t *hw, int bap, void *buf, unsigned len,
-		       u16 id, u16 offset);
-int hermes_bap_pwrite(hermes_t *hw, int bap, const void *buf, unsigned len,
-			u16 id, u16 offset);
-int hermes_read_ltv(hermes_t *hw, int bap, u16 rid, unsigned buflen,
-		    u16 *length, void *buf);
-int hermes_write_ltv(hermes_t *hw, int bap, u16 rid,
-		      u16 length, const void *value);
+void hermes_struct_init(hermes_t *hw, ulong address, int io_space, int reg_spacing);
+
+static inline int hermes_init(hermes_t *hw)
+{
+	return hw->ops->init(hw);
+}
+static inline int hermes_docmd_wait(hermes_t *hw, u16 cmd, u16 parm0,
+				    struct hermes_response *resp)
+{
+	return hw->ops->docmd_wait(hw, cmd, parm0, resp);
+}
+static inline int hermes_allocate(hermes_t *hw, u16 size, u16 *fid)
+{
+	return hw->ops->allocate(hw, size, fid);
+}
+
+static inline int hermes_bap_pread(hermes_t *hw, int bap,
+				   void *buf, unsigned len,
+				   u16 id, s32 offset)
+{
+	return hw->ops->bap_pread(hw, bap, buf, len, id, offset);
+}
+static inline int hermes_bap_pwrite(hermes_t *hw, int bap,
+				    const void *buf, unsigned len,
+				    u16 id, u16 offset)
+{
+	return hw->ops->bap_pwrite(hw, bap, buf, len, id, offset);
+}
+static inline int hermes_read_ltv(hermes_t *hw, int bap, u16 rid,
+				  unsigned buflen, u16 *length, void *buf)
+{
+	return hw->ops->read_ltv(hw, bap, rid, buflen, length, buf);
+}
+static inline int hermes_write_ltv(hermes_t *hw, int bap, u16 rid,
+				   u16 length, const void *value)
+{
+	return hw->ops->write_ltv(hw, bap, rid, length, value);
+}
 
 /* Inline functions */
 
