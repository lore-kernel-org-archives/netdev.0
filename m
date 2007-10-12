From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Thu, 11 Oct 2007 22:18:45 -0700 (PDT)
Message-ID: <20071011.221845.63126874.davem@davemloft.net>
References: <18190.61294.191189.193153@cargo.ozlabs.ibm.com>
	<20071011212539.8acafc63.akpm@linux-foundation.org>
	<20071011.215429.108742994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org, sam@ravnborg.org,
	benh@kernel.crashing.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753989AbXJLFSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 01:18:46 -0400
In-Reply-To: <20071011.215429.108742994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Oct 2007 21:54:29 -0700 (PDT)

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 11 Oct 2007 21:25:39 -0700
> 
> > On Fri, 12 Oct 2007 13:52:14 +1000 Paul Mackerras <paulus@samba.org> wrote:
> > 
> > > So Andrew, what do you think is better - arch/powerpc/boot having its
> > > own copies of the zlib_inflate stuff, or #ifdefs of some kind in
> > > lib/zlib_inflate/*.c?
> > 
> > 
> > The latter - copying code is evil.  Keeping the existing code dual-mode
> > shouldn't be too hard - it's just a matter of people knowing about it.
> > 
> > Perhaps such code should be in its own suitably-named directory, but
> > whatever.
> 
> I'll work on a fix for this.

Here is the patch I'm putting through some paces, let me know if
it solves the powerpc problem.

Thanks!

>From 95702f93bac04b7db373e57fb606a6614c5bfcb4 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Thu, 11 Oct 2007 22:15:08 -0700
Subject: [PATCH] [ZLIB]: Fix external builds of zlib_inflate code.

Move zlib_inflate_blob() out into it's own source file,
infutil.c, so that things like the powerpc zImage builder
in arch/powerpc/boot/Makefile don't end up trying to
compile it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 lib/zlib_inflate/Makefile  |    2 +-
 lib/zlib_inflate/inflate.c |   47 ------------------------------------------
 lib/zlib_inflate/infutil.c |   49 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 48 deletions(-)
 create mode 100644 lib/zlib_inflate/infutil.c

diff --git a/lib/zlib_inflate/Makefile b/lib/zlib_inflate/Makefile
index bf06548..49f8ce5 100644
--- a/lib/zlib_inflate/Makefile
+++ b/lib/zlib_inflate/Makefile
@@ -15,5 +15,5 @@
 
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate.o
 
-zlib_inflate-objs := inffast.o inflate.o \
+zlib_inflate-objs := inffast.o inflate.o infutil.o \
 		     inftrees.o inflate_syms.o
diff --git a/lib/zlib_inflate/inflate.c b/lib/zlib_inflate/inflate.c
index 0ad1ebf..f5ce87b 100644
--- a/lib/zlib_inflate/inflate.c
+++ b/lib/zlib_inflate/inflate.c
@@ -916,50 +916,3 @@ int zlib_inflateIncomp(z_stream *z)
 
     return Z_OK;
 }
-
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/vmalloc.h>
-
-/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
- * return len or negative error code. */
-int zlib_inflate_blob(void *gunzip_buf, unsigned sz, const void *buf, unsigned len)
-{
-	const u8 *zbuf = buf;
-	struct z_stream_s *strm;
-	int rc;
-
-	rc = -ENOMEM;
-	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
-	if (strm == NULL)
-		goto gunzip_nomem1;
-	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
-	if (strm->workspace == NULL)
-		goto gunzip_nomem2;
-
-	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
-	 * expected to be stripped from input */
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
-gunzip_nomem2:
-	kfree(strm);
-gunzip_nomem1:
-	return rc; /* returns Z_OK (0) if successful */
-}
diff --git a/lib/zlib_inflate/infutil.c b/lib/zlib_inflate/infutil.c
new file mode 100644
index 0000000..4824c2c
--- /dev/null
+++ b/lib/zlib_inflate/infutil.c
@@ -0,0 +1,49 @@
+#include <linux/zutil.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+
+/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
+ * return len or negative error code.
+ */
+int zlib_inflate_blob(void *gunzip_buf, unsigned int sz,
+		      const void *buf, unsigned int len)
+{
+	const u8 *zbuf = buf;
+	struct z_stream_s *strm;
+	int rc;
+
+	rc = -ENOMEM;
+	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
+	if (strm == NULL)
+		goto gunzip_nomem1;
+	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	if (strm->workspace == NULL)
+		goto gunzip_nomem2;
+
+	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
+	 * expected to be stripped from input
+	 */
+	strm->next_in = zbuf;
+	strm->avail_in = len;
+	strm->next_out = gunzip_buf;
+	strm->avail_out = sz;
+
+	rc = zlib_inflateInit2(strm, -MAX_WBITS);
+	if (rc == Z_OK) {
+		rc = zlib_inflate(strm, Z_FINISH);
+		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
+		if (rc == Z_STREAM_END)
+			rc = sz - strm->avail_out;
+		else
+			rc = -EINVAL;
+		zlib_inflateEnd(strm);
+	} else
+		rc = -EINVAL;
+
+	kfree(strm->workspace);
+gunzip_nomem2:
+	kfree(strm);
+gunzip_nomem1:
+	return rc; /* returns Z_OK (0) if successful */
+}
-- 
1.5.3.3

