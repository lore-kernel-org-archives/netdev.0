From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] net: Toeplitz library functions
Date: Thu, 19 Dec 2013 16:41:48 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312191635460.9677@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: haiyangz@microsoft.com, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:63066 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab3LTAlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:41:49 -0500
Received: by mail-ob0-f201.google.com with SMTP id wp4so436177obc.0
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 16:41:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce Toeplitz hash functions. Toeplitz is a hash used primarily in
NICs to perform RSS flow steering.  This is a software implementation
of that. In order to make the hash calculation efficient, we precompute
the possible hash values for each inidividual byte of input. The input
length is up to 36 bytes, so we make an array of cache[36][256].

The implementation was verified against MSDN "Verify RSS hash" sample
values.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/toeplitz.h | 38 +++++++++++++++++++++++++++++
 net/Kconfig            |  4 ++++
 net/core/Makefile      |  1 +
 net/core/toeplitz.c    | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 108 insertions(+)
 create mode 100644 include/net/toeplitz.h
 create mode 100644 net/core/toeplitz.c

diff --git a/include/net/toeplitz.h b/include/net/toeplitz.h
new file mode 100644
index 0000000..89ab1c1
--- /dev/null
+++ b/include/net/toeplitz.h
@@ -0,0 +1,38 @@
+#ifndef __NET_TOEPLITZ_H
+#define __NET_TOEPLITZ_H
+
+/*
+ * This is include file for Toeplitz hash library.
+ *
+ * In order to make the hash computation reasonably efficient we pre-compute
+ * the set of possible values for each input byte. The maximum input is 36
+ * bytes, each byte has 256 possible values, and each value is 32 bits
+ * (4 bytes)-- so the lookup table is 40960 bytes. Using the lookup table
+ * seems to be at least 10x faster than computing the hash on the fly.
+ */
+
+#define TOEPLITZ_KEY_LEN 40
+#define TOEPLITZ_MAX_INPUT (TOEPLITZ_KEY_LEN - 4)
+
+struct toeplitz {
+	u8 key_vals[TOEPLITZ_KEY_LEN];
+	u32 key_cache[TOEPLITZ_MAX_INPUT][256];
+};
+
+static inline u32
+toeplitz_hash(const u8 *bytes,
+	      struct toeplitz *toeplitz, int n)
+{
+	int i;
+	u32 result = 0;
+
+	for (i = 0; i < n; i++)
+		result ^= toeplitz->key_cache[i][bytes[i]];
+
+        return result;
+};
+
+extern struct toeplitz *toeplitz_alloc(void);
+extern void toeplitz_init(struct toeplitz *toeplitz, u8 *key_vals);
+
+#endif /* __NET_TOEPLITZ_H */
diff --git a/net/Kconfig b/net/Kconfig
index d334678..9c70861 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -255,6 +255,10 @@ config BQL
 	select DQL
 	default y
 
+config NET_TOEPLITZ
+	boolean
+	default n
+
 config BPF_JIT
 	bool "enable BPF Just In Time compiler"
 	depends on HAVE_BPF_JIT
diff --git a/net/core/Makefile b/net/core/Makefile
index b33b996..e48fa29 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -22,3 +22,4 @@ obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NETPRIO_CGROUP) += netprio_cgroup.o
+obj-$(CONFIG_NET_TOEPLITZ) += toeplitz.o
diff --git a/net/core/toeplitz.c b/net/core/toeplitz.c
new file mode 100644
index 0000000..52a3ae7
--- /dev/null
+++ b/net/core/toeplitz.c
@@ -0,0 +1,65 @@
+/*
+ * Toeplitz hash implementation. See include/net/toeplitz.h
+ *
+ * Copyright (c) 2013, Tom Herbert <therbert@google.com>
+ */
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/random.h>
+#include <net/toeplitz.h>
+
+struct toeplitz *toeplitz_alloc(void)
+{
+	return kmalloc(sizeof(struct toeplitz), GFP_KERNEL);
+}
+
+static u32 toeplitz_get_kval(u8 *key, unsigned int idx)
+{
+	u32 v, r;
+	int off, rem;
+
+	off = idx >> 3;
+	rem = idx & 7;
+
+	v = (((u32)key[off]) << 24) +
+	    (((u32)key[off + 1]) << 16) +
+	    (((u32)key[off + 2]) << 8) +
+	    (((u32)key[off + 3]));
+
+	r = v << rem | (u32)key[off + 4] >> (8 - rem);
+	return r;
+}
+
+void toeplitz_init(struct toeplitz *toeplitz, u8 *key_vals)
+{
+	int i;
+	unsigned long a, j;
+	unsigned int result = 0;
+
+	/* Set up key val table */
+	if (key_vals) {
+		for (i = 0; i < TOEPLITZ_KEY_LEN; i++) {
+			toeplitz->key_vals[i] = key_vals[i];
+		}
+	} else {
+		prandom_bytes(toeplitz->key_vals, TOEPLITZ_KEY_LEN);
+	}
+
+	/* Set up key cache table */
+	for (i = 0; i < TOEPLITZ_MAX_INPUT; i++) {
+		for (j = 0; j < 256; j++) {
+			result = 0;
+			for (a = find_first_bit(&j, 8); a < 8;
+			    a = find_next_bit(&j, 8, a + 1)) {
+				unsigned idx = a + (i * 8);
+#ifdef __LITTLE_ENDIAN
+			        idx ^= 7;
+#endif
+				result ^= toeplitz_get_kval(toeplitz->key_vals,
+							    idx);
+			}
+			toeplitz->key_cache[i][j] = result;
+		}
+	}
+}
-- 
1.8.5.1
