From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Sun, 14 Oct 2007 04:40:46 +0100
Message-ID: <200710140440.47386.vda.linux@googlemail.com>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org> <20071011.194543.75428024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/+YEH2JqKwgOhKB"
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	sam@ravnborg.org, paulus@samba.org, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55742 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbXJNDk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 23:40:56 -0400
Received: by ug-out-1314.google.com with SMTP id z38so751594ugc
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2007 20:40:53 -0700 (PDT)
In-Reply-To: <20071011.194543.75428024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_/+YEH2JqKwgOhKB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 12 October 2007 03:45, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 11 Oct 2007 19:22:33 -0700
> 
> > With net-2.6.24 (pulled yesterday) applied:
> > 
> > g5:/usr/src/25> ml arch/powerpc/boot/inflate.o
> >   Using ARCH=powerpc CROSS_COMPILE=
> >   CHK     include/linux/version.h
> >   CHK     include/linux/utsrelease.h
> >   CALL    scripts/checksyscalls.sh
> >   BOOTCC  arch/powerpc/boot/inflate.o
> > arch/powerpc/boot/inflate.c:920:19: errno.h: No such file or directory
> > arch/powerpc/boot/inflate.c:921:18: slab.h: No such file or directory
> > arch/powerpc/boot/inflate.c:922:21: vmalloc.h: No such file or directory
> > arch/powerpc/boot/inflate.c: In function `zlib_inflate_blob':
> > arch/powerpc/boot/inflate.c:928: error: syntax error before '*' token
> 
> The only thing we touched in zlib is in the patch below.
> 
> I suspect the lib/zlib_inflate/inflate.c changes, I had no idea that
> some pieces of code try to use this into userspace.
> 
> I supposed a hacky fix is to add __KERNEL__ ifdef protection around
> zlib_inflate_blob() and those troublesome includes.  A nicer fix is
> probably to change the zlib_inflate_blob() interface to pass in
> pointers to alloc() and free() routines instead of calling kernel ones
> directly.
> 
> Denys?
> 
> commit 8336793baf962163c9fab5a3f39614295fdbab27
> Author: Denys Vlasenko <vda.linux@googlemail.com>
> Date:   Sun Sep 30 17:56:49 2007 -0700
> 
>     [ZLIB]: Move bnx2 driver gzip unpacker into zlib.
>     
>     Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
>     Acked-by: Michael Chan <mchan@broadcom.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Please find updated patch in attachment.
Compile-tested.
--
vda

--Boundary-00=_/+YEH2JqKwgOhKB
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="new.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="new.diff"

--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2761,48 +2761,6 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-/* To be moved to generic lib/ */
-static int
-bnx2_gunzip(void *gunzip_buf, unsigned sz, u8 *zbuf, int len)
-{
-	struct z_stream_s *strm;
-	int rc;
-
-	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
-	 * is stripped */
-
-	rc = -ENOMEM;
-	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
-	if (strm == NULL)
-		goto gunzip_nomem2;
-	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
-	if (strm->workspace == NULL)
-		goto gunzip_nomem3;
-
-	strm->next_in = zbuf;
-	strm->avail_in = len;
-	strm->next_out = gunzip_buf;
-	strm->avail_out = sz;
-
-	rc = zlib_inflateInit2(strm, -MAX_WBITS);
-	if (rc == Z_OK) {
-		rc = zlib_inflate(strm, Z_FINISH);
-		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
-		if (rc == Z_STREAM_END)
-			rc = sz - strm->avail_out;
-		else
-			rc = -EINVAL;
-		zlib_inflateEnd(strm);
-	} else
-		rc = -EINVAL;
-
-	kfree(strm->workspace);
-gunzip_nomem3:
-	kfree(strm);
-gunzip_nomem2:
-	return rc;
-}
-
 static void
 load_rv2p_fw(struct bnx2 *bp, u32 *rv2p_code, u32 rv2p_code_len,
 	u32 rv2p_proc)
@@ -2858,7 +2816,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 		text = vmalloc(FW_BUF_SIZE);
 		if (!text)
 			return -ENOMEM;
-		rc = bnx2_gunzip(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
+		rc = zlib_inflate_blob(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
 		if (rc < 0) {
 			vfree(text);
 			return rc;
@@ -2935,14 +2893,14 @@ bnx2_init_cpus(struct bnx2 *bp)
 	text = vmalloc(FW_BUF_SIZE);
 	if (!text)
 		return -ENOMEM;
-	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
+	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
 	if (rc < 0) {
 		vfree(text);
 		goto init_cpu_err;
 	}
 	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC1);
 
-	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
+	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
 	if (rc < 0) {
 		vfree(text);
 		goto init_cpu_err;
--- a/include/linux/zlib.h
+++ b/include/linux/zlib.h
@@ -82,7 +82,7 @@
 struct internal_state;
 
 typedef struct z_stream_s {
-    Byte    *next_in;   /* next input byte */
+    const Byte *next_in;   /* next input byte */
     uInt     avail_in;  /* number of bytes available at next_in */
     uLong    total_in;  /* total nb of input bytes read so far */
 
@@ -699,4 +699,8 @@ extern int zlib_inflateInit2(z_streamp strm, int  windowBits);
     struct internal_state {int dummy;}; /* hack for buggy compilers */
 #endif
 
+/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
+ * return len or negative error code. */
+extern int zlib_inflate_blob(void *dst, unsigned dst_sz, const void *src, unsigned src_sz);
+
 #endif /* _ZLIB_H */
--- a/lib/zlib_inflate/inffast.c
+++ b/lib/zlib_inflate/inffast.c
@@ -69,22 +69,22 @@
 void inflate_fast(z_streamp strm, unsigned start)
 {
     struct inflate_state *state;
-    unsigned char *in;      /* local strm->next_in */
-    unsigned char *last;    /* while in < last, enough input available */
-    unsigned char *out;     /* local strm->next_out */
-    unsigned char *beg;     /* inflate()'s initial strm->next_out */
-    unsigned char *end;     /* while out < end, enough space available */
+    const unsigned char *in;    /* local strm->next_in */
+    const unsigned char *last;  /* while in < last, enough input available */
+    unsigned char *out;         /* local strm->next_out */
+    unsigned char *beg;         /* inflate()'s initial strm->next_out */
+    unsigned char *end;         /* while out < end, enough space available */
 #ifdef INFLATE_STRICT
     unsigned dmax;              /* maximum distance from zlib header */
 #endif
     unsigned wsize;             /* window size or zero if not using window */
     unsigned whave;             /* valid bytes in the window */
     unsigned write;             /* window write index */
-    unsigned char *window;  /* allocated sliding window, if wsize != 0 */
+    unsigned char *window;      /* allocated sliding window, if wsize != 0 */
     unsigned long hold;         /* local strm->hold */
     unsigned bits;              /* local strm->bits */
-    code const *lcode;      /* local strm->lencode */
-    code const *dcode;      /* local strm->distcode */
+    code const *lcode;          /* local strm->lencode */
+    code const *dcode;          /* local strm->distcode */
     unsigned lmask;             /* mask for first level of length codes */
     unsigned dmask;             /* mask for first level of distance codes */
     code this;                  /* retrieved table entry */
@@ -92,7 +92,7 @@ void inflate_fast(z_streamp strm, unsigned start)
                                 /*  window position, window bytes to copy */
     unsigned len;               /* match length, unused bytes */
     unsigned dist;              /* match distance */
-    unsigned char *from;    /* where to copy match from */
+    unsigned char *from;        /* where to copy match from */
 
     /* copy state to local variables */
     state = (struct inflate_state *)strm->state;
--- a/lib/zlib_inflate/inflate.c
+++ b/lib/zlib_inflate/inflate.c
@@ -332,14 +332,14 @@ static int zlib_inflateSyncPacket(z_streamp strm)
 int zlib_inflate(z_streamp strm, int flush)
 {
     struct inflate_state *state;
-    unsigned char *next;    /* next input */
-    unsigned char *put;     /* next output */
+    const unsigned char *next;  /* next input */
+    unsigned char *put;         /* next output */
     unsigned have, left;        /* available input and output */
     unsigned long hold;         /* bit buffer */
     unsigned bits;              /* bits in bit buffer */
     unsigned in, out;           /* save starting available input and output */
     unsigned copy;              /* number of stored or match bytes to copy */
-    unsigned char *from;    /* where to copy match bytes from */
+    unsigned char *from;        /* where to copy match bytes from */
     code this;                  /* current decoding table entry */
     code last;                  /* parent table entry */
     unsigned len;               /* length to copy for repeats, bits to drop */
@@ -897,7 +897,7 @@ int zlib_inflateIncomp(z_stream *z)
 
     /* Setup some variables to allow misuse of updateWindow */
     z->avail_out = 0;
-    z->next_out = z->next_in + z->avail_in;
+    z->next_out = (unsigned char*)z->next_in + z->avail_in;
 
     zlib_updatewindow(z, z->avail_in);
 
--- a/lib/zlib_inflate/inflate_blob.c
+++ b/lib/zlib_inflate/inflate_blob.c
@@ -0,0 +1,42 @@
+/* inflate_blob.c -- decompression utility function
+ * Copyright (C) 2007 Denys Vlasenko
+ */
+
+#include <linux/zutil.h>
+#include <linux/slab.h>
+
+/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
+ * return len or negative error code. */
+int zlib_inflate_blob(void *gunzip_buf, unsigned sz, const void *buf, unsigned len)
+{
+	const u8 *zbuf = buf;
+	struct z_stream_s strm; /* it's fairly small */
+	int rc;
+
+	strm.workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	if (strm.workspace == NULL)
+		return -ENOMEM;
+
+	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
+	 * expected to be stripped from input */
+
+	strm.next_in = zbuf;
+	strm.avail_in = len;
+	strm.next_out = gunzip_buf;
+	strm.avail_out = sz;
+
+	rc = zlib_inflateInit2(&strm, -MAX_WBITS);
+	if (rc == Z_OK) {
+		rc = zlib_inflate(&strm, Z_FINISH);
+		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
+		if (rc == Z_STREAM_END)
+			rc = sz - strm.avail_out;
+		else
+			rc = -EINVAL;
+		zlib_inflateEnd(&strm);
+	} else
+		rc = -EINVAL;
+
+	kfree(strm.workspace);
+	return rc;
+}
--- a/lib/zlib_inflate/Makefile
+++ b/lib/zlib_inflate/Makefile
@@ -16,4 +16,4 @@
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate.o
 
 zlib_inflate-objs := inffast.o inflate.o \
-		     inftrees.o inflate_syms.o
+		     inftrees.o inflate_blob.o inflate_syms.o
--- a/lib/zlib_inflate/inflate_syms.c
+++ b/lib/zlib_inflate/inflate_syms.c
@@ -16,4 +16,5 @@ EXPORT_SYMBOL(zlib_inflateInit2);
 EXPORT_SYMBOL(zlib_inflateEnd);
 EXPORT_SYMBOL(zlib_inflateReset);
 EXPORT_SYMBOL(zlib_inflateIncomp); 
+EXPORT_SYMBOL(zlib_inflate_blob);
 MODULE_LICENSE("GPL");

--Boundary-00=_/+YEH2JqKwgOhKB--
