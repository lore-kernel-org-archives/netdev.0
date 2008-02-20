From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 8/8] Jhash in too big for inlining, move under lib/
Date: Wed, 20 Feb 2008 15:47:18 +0200
Message-ID: <1203515238-22848-9-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54344 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674AbYBTNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:21 -0500
In-Reply-To: <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmlinux.o:
 62 functions changed, 66 bytes added, 10935 bytes removed, diff: -1086=
9

=2E..+ these to lib/jhash.o:
 jhash_3words: 112
 jhash2: 276
 jhash: 475

select for networking code might need a more fine-grained approach.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/infiniband/Kconfig |    1 +
 drivers/net/Kconfig        |    1 +
 fs/Kconfig                 |    1 +
 fs/dlm/Kconfig             |    1 +
 fs/gfs2/Kconfig            |    1 +
 include/linux/jhash.h      |   99 +-----------------------------------=
-
 init/Kconfig               |    2 +
 lib/Kconfig                |    6 ++
 lib/Makefile               |    1 +
 lib/jhash.c                |  116 ++++++++++++++++++++++++++++++++++++=
++++++++
 net/Kconfig                |    1 +
 11 files changed, 134 insertions(+), 96 deletions(-)
 create mode 100644 lib/jhash.c

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index a5dc78a..421ab71 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -2,6 +2,7 @@ menuconfig INFINIBAND
 	tristate "InfiniBand support"
 	depends on PCI || BROKEN
 	depends on HAS_IOMEM
+	select JHASH
 	---help---
 	  Core support for InfiniBand (IB).  Make sure to also select
 	  any protocols you wish to use as well as drivers for your
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..8257648 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2496,6 +2496,7 @@ config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on PCI
 	select FW_LOADER
+	select JHASH
 	help
 	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
 	  adapters.
diff --git a/fs/Kconfig b/fs/Kconfig
index d731282..693fe71 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1667,6 +1667,7 @@ config NFSD
 	select LOCKD
 	select SUNRPC
 	select EXPORTFS
+	select JHASH
 	select NFSD_V2_ACL if NFSD_V3_ACL
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
 	select NFSD_TCP if NFSD_V4
diff --git a/fs/dlm/Kconfig b/fs/dlm/Kconfig
index 2dbb422..f27a99a 100644
--- a/fs/dlm/Kconfig
+++ b/fs/dlm/Kconfig
@@ -4,6 +4,7 @@ menuconfig DLM
 	depends on SYSFS && (IPV6 || IPV6=3Dn)
 	select CONFIGFS_FS
 	select IP_SCTP
+	select JHASH
 	help
 	A general purpose distributed lock manager for kernel or userspace
 	applications.
diff --git a/fs/gfs2/Kconfig b/fs/gfs2/Kconfig
index de8e64c..b9dcabf 100644
--- a/fs/gfs2/Kconfig
+++ b/fs/gfs2/Kconfig
@@ -3,6 +3,7 @@ config GFS2_FS
 	depends on EXPERIMENTAL
 	select FS_POSIX_ACL
 	select CRC32
+	select JHASH
 	help
 	  A cluster filesystem.
=20
diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index 2a2f99f..14200c6 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -1,25 +1,6 @@
 #ifndef _LINUX_JHASH_H
 #define _LINUX_JHASH_H
=20
-/* jhash.h: Jenkins hash support.
- *
- * Copyright (C) 1996 Bob Jenkins (bob_jenkins@burtleburtle.net)
- *
- * http://burtleburtle.net/bob/hash/
- *
- * These are the credits from Bob's sources:
- *
- * lookup2.c, by Bob Jenkins, December 1996, Public Domain.
- * hash(), hash2(), hash3, and mix() are externally useful functions.
- * Routines to test the hash are included if SELF_TEST is defined.
- * You can use this free for any purpose.  It has no warranty.
- *
- * Copyright (C) 2003 David S. Miller (davem@redhat.com)
- *
- * I've modified Bob's hash to be useful in the Linux kernel, and
- * any bugs present are surely my fault.  -DaveM
- */
-
 /* NOTE: Arguments are modified. */
 #define __jhash_mix(a, b, c) \
 { \
@@ -41,77 +22,12 @@
  * of bytes.  No alignment or length assumptions are made about
  * the input key.
  */
-static inline u32 jhash(const void *key, u32 length, u32 initval)
-{
-	u32 a, b, c, len;
-	const u8 *k =3D key;
-
-	len =3D length;
-	a =3D b =3D JHASH_GOLDEN_RATIO;
-	c =3D initval;
-
-	while (len >=3D 12) {
-		a +=3D (k[0] +((u32)k[1]<<8) +((u32)k[2]<<16) +((u32)k[3]<<24));
-		b +=3D (k[4] +((u32)k[5]<<8) +((u32)k[6]<<16) +((u32)k[7]<<24));
-		c +=3D (k[8] +((u32)k[9]<<8) +((u32)k[10]<<16)+((u32)k[11]<<24));
-
-		__jhash_mix(a,b,c);
-
-		k +=3D 12;
-		len -=3D 12;
-	}
-
-	c +=3D length;
-	switch (len) {
-	case 11: c +=3D ((u32)k[10]<<24);
-	case 10: c +=3D ((u32)k[9]<<16);
-	case 9 : c +=3D ((u32)k[8]<<8);
-	case 8 : b +=3D ((u32)k[7]<<24);
-	case 7 : b +=3D ((u32)k[6]<<16);
-	case 6 : b +=3D ((u32)k[5]<<8);
-	case 5 : b +=3D k[4];
-	case 4 : a +=3D ((u32)k[3]<<24);
-	case 3 : a +=3D ((u32)k[2]<<16);
-	case 2 : a +=3D ((u32)k[1]<<8);
-	case 1 : a +=3D k[0];
-	};
-
-	__jhash_mix(a,b,c);
-
-	return c;
-}
+extern u32 jhash(const void *key, u32 length, u32 initval);
=20
 /* A special optimized version that handles 1 or more of u32s.
  * The length parameter here is the number of u32s in the key.
  */
-static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
-{
-	u32 a, b, c, len;
-
-	a =3D b =3D JHASH_GOLDEN_RATIO;
-	c =3D initval;
-	len =3D length;
-
-	while (len >=3D 3) {
-		a +=3D k[0];
-		b +=3D k[1];
-		c +=3D k[2];
-		__jhash_mix(a, b, c);
-		k +=3D 3; len -=3D 3;
-	}
-
-	c +=3D length * 4;
-
-	switch (len) {
-	case 2 : b +=3D k[1];
-	case 1 : a +=3D k[0];
-	};
-
-	__jhash_mix(a,b,c);
-
-	return c;
-}
-
+extern u32 jhash2(const u32 *k, u32 length, u32 initval);
=20
 /* A special ultra-optimized versions that knows they are hashing exac=
tly
  * 3, 2 or 1 word(s).
@@ -119,16 +35,7 @@ static inline u32 jhash2(const u32 *k, u32 length, =
u32 initval)
  * NOTE: In partilar the "c +=3D length; __jhash_mix(a,b,c);" normally
  *       done at the end is not done here.
  */
-static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
-{
-	a +=3D JHASH_GOLDEN_RATIO;
-	b +=3D JHASH_GOLDEN_RATIO;
-	c +=3D initval;
-
-	__jhash_mix(a, b, c);
-
-	return c;
-}
+extern u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval);
=20
 static inline u32 jhash_2words(u32 a, u32 b, u32 initval)
 {
diff --git a/init/Kconfig b/init/Kconfig
index 824d48c..3210626 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -601,6 +601,7 @@ config FUTEX
 	bool "Enable futex support" if EMBEDDED
 	default y
 	select RT_MUTEXES
+	select JHASH
 	help
 	  Disabling this option will cause the kernel to be built without
 	  support for "fast userspace mutexes".  The resulting kernel may not
@@ -718,6 +719,7 @@ config PROFILING
=20
 config MARKERS
 	bool "Activate markers"
+	select JHASH
 	help
 	  Place an empty function call at each marker site. Can be
 	  dynamically changed for a probe function.
diff --git a/lib/Kconfig b/lib/Kconfig
index ba3d104..23d5507 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -85,6 +85,12 @@ config GENERIC_ALLOCATOR
 	boolean
=20
 #
+# Jenkins has support is selected if needed
+#
+config JHASH
+	boolean
+
+#
 # reed solomon support is select'ed if needed
 #
 config REED_SOLOMON
diff --git a/lib/Makefile b/lib/Makefile
index 23de261..a100a49 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_CRC32)	+=3D crc32.o
 obj-$(CONFIG_CRC7)	+=3D crc7.o
 obj-$(CONFIG_LIBCRC32C)	+=3D libcrc32c.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) +=3D genalloc.o
+obj-$(CONFIG_JHASH)	+=3D jhash.o
=20
 obj-$(CONFIG_ZLIB_INFLATE) +=3D zlib_inflate/
 obj-$(CONFIG_ZLIB_DEFLATE) +=3D zlib_deflate/
diff --git a/lib/jhash.c b/lib/jhash.c
new file mode 100644
index 0000000..ee4083f
--- /dev/null
+++ b/lib/jhash.c
@@ -0,0 +1,116 @@
+/* jhash.c: Jenkins hash support.
+ *
+ * Copyright (C) 1996 Bob Jenkins (bob_jenkins@burtleburtle.net)
+ *
+ * http://burtleburtle.net/bob/hash/
+ *
+ * These are the credits from Bob's sources:
+ *
+ * lookup2.c, by Bob Jenkins, December 1996, Public Domain.
+ * hash(), hash2(), hash3, and mix() are externally useful functions.
+ * Routines to test the hash are included if SELF_TEST is defined.
+ * You can use this free for any purpose.  It has no warranty.
+ *
+ * Copyright (C) 2003 David S. Miller (davem@redhat.com)
+ *
+ * I've modified Bob's hash to be useful in the Linux kernel, and
+ * any bugs present are surely my fault.  -DaveM
+ */
+#include <linux/kernel.h>
+#include <linux/jhash.h>
+#include <linux/module.h>
+
+/* The most generic version, hashes an arbitrary sequence
+ * of bytes.  No alignment or length assumptions are made about
+ * the input key.
+ */
+u32 jhash(const void *key, u32 length, u32 initval)
+{
+	u32 a, b, c, len;
+	const u8 *k =3D key;
+
+	len =3D length;
+	a =3D b =3D JHASH_GOLDEN_RATIO;
+	c =3D initval;
+
+	while (len >=3D 12) {
+		a +=3D (k[0] +((u32)k[1]<<8) +((u32)k[2]<<16) +((u32)k[3]<<24));
+		b +=3D (k[4] +((u32)k[5]<<8) +((u32)k[6]<<16) +((u32)k[7]<<24));
+		c +=3D (k[8] +((u32)k[9]<<8) +((u32)k[10]<<16)+((u32)k[11]<<24));
+
+		__jhash_mix(a,b,c);
+
+		k +=3D 12;
+		len -=3D 12;
+	}
+
+	c +=3D length;
+	switch (len) {
+	case 11: c +=3D ((u32)k[10]<<24);
+	case 10: c +=3D ((u32)k[9]<<16);
+	case 9 : c +=3D ((u32)k[8]<<8);
+	case 8 : b +=3D ((u32)k[7]<<24);
+	case 7 : b +=3D ((u32)k[6]<<16);
+	case 6 : b +=3D ((u32)k[5]<<8);
+	case 5 : b +=3D k[4];
+	case 4 : a +=3D ((u32)k[3]<<24);
+	case 3 : a +=3D ((u32)k[2]<<16);
+	case 2 : a +=3D ((u32)k[1]<<8);
+	case 1 : a +=3D k[0];
+	};
+
+	__jhash_mix(a,b,c);
+
+	return c;
+}
+EXPORT_SYMBOL(jhash);
+
+/* A special optimized version that handles 1 or more of u32s.
+ * The length parameter here is the number of u32s in the key.
+ */
+u32 jhash2(const u32 *k, u32 length, u32 initval)
+{
+	u32 a, b, c, len;
+
+	a =3D b =3D JHASH_GOLDEN_RATIO;
+	c =3D initval;
+	len =3D length;
+
+	while (len >=3D 3) {
+		a +=3D k[0];
+		b +=3D k[1];
+		c +=3D k[2];
+		__jhash_mix(a, b, c);
+		k +=3D 3; len -=3D 3;
+	}
+
+	c +=3D length * 4;
+
+	switch (len) {
+	case 2 : b +=3D k[1];
+	case 1 : a +=3D k[0];
+	};
+
+	__jhash_mix(a,b,c);
+
+	return c;
+}
+EXPORT_SYMBOL(jhash2);
+
+/* A special ultra-optimized versions that knows they are hashing exac=
tly
+ * 3, 2 or 1 word(s).
+ *
+ * NOTE: In partilar the "c +=3D length; __jhash_mix(a,b,c);" normally
+ *       done at the end is not done here.
+ */
+u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
+{
+	a +=3D JHASH_GOLDEN_RATIO;
+	b +=3D JHASH_GOLDEN_RATIO;
+	c +=3D initval;
+
+	__jhash_mix(a, b, c);
+
+	return c;
+}
+EXPORT_SYMBOL(jhash_3words);
diff --git a/net/Kconfig b/net/Kconfig
index 6627c6a..0749381 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -6,6 +6,7 @@ menu "Networking"
=20
 config NET
 	bool "Networking support"
+	select JHASH
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support eve=
n
--=20
1.5.2.2

