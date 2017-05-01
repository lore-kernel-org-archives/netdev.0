From: David Miller <davem@davemloft.net>
Subject: Re: more bpf samples build breakage...
Date: Mon, 01 May 2017 15:44:52 -0400 (EDT)
Message-ID: <20170501.154452.397092029651616591.davem@davemloft.net>
References: <20170501.153005.983887567095122966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdEATo5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:44:57 -0400
In-Reply-To: <20170501.153005.983887567095122966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 01 May 2017 15:30:05 -0400 (EDT)

> 
> Inlcuding bpf_util.h into test_pkt_access.c et al. broke the build even
> more so than it already is on sparc.
> 
> The problem is we end up including all the stdio.h bits and eventually
> hit things like:
> 
> In file included from /usr/include/stdio.h:933:
> /usr/include/bits/stdio-ldbl.h:28:20: error: cannot apply asm label to function after its first use
> __LDBL_REDIR_DECL (vfprintf)
> ~~~~~~~~~~~~~~~~~~~^~~~~~~~~
> /usr/include/sys/cdefs.h:373:26: note: expanded from macro '__LDBL_REDIR_DECL'
>   extern __typeof (name) name __asm (__ASMNAME ("__nldbl_" #name));
> 
> So please let's put CLANG compiled helpers into header files
> specifically meant to be included by CLANG compiled BPF programs
> rather than the host build environment.

I'm pushing the following quick fix for this for now:

>From bc1bafbbe9b3558d7789ff151ef4f185b6ad21f3 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 1 May 2017 12:43:49 -0700
Subject: [PATCH] bpf: Move endianness BPF helpers out of bpf_util.h

We do not want to include things like stdio.h and friends into
eBPF program builds.  bpf_util.h is for host compiled programs,
so eBPF C-code helpers don't really belong there.

Add a new bpf_endian.h as a quick fix for this for now.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/bpf/bpf_endian.h      | 23 +++++++++++++++++++++++
 tools/testing/selftests/bpf/bpf_util.h        | 19 -------------------
 tools/testing/selftests/bpf/test_l4lb.c       |  2 +-
 tools/testing/selftests/bpf/test_pkt_access.c |  2 +-
 4 files changed, 25 insertions(+), 21 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/bpf_endian.h

diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/tools/testing/selftests/bpf/bpf_endian.h
new file mode 100644
index 0000000..19d0604
--- /dev/null
+++ b/tools/testing/selftests/bpf/bpf_endian.h
@@ -0,0 +1,23 @@
+#ifndef __BPF_ENDIAN__
+#define __BPF_ENDIAN__
+
+#include <asm/byteorder.h>
+
+#if __BYTE_ORDER == __LITTLE_ENDIAN
+# define __bpf_ntohs(x)		__builtin_bswap16(x)
+# define __bpf_htons(x)		__builtin_bswap16(x)
+#elif __BYTE_ORDER == __BIG_ENDIAN
+# define __bpf_ntohs(x)		(x)
+# define __bpf_htons(x)		(x)
+#else
+# error "Fix your __BYTE_ORDER?!"
+#endif
+
+#define bpf_htons(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __constant_htons(x) : __bpf_htons(x))
+#define bpf_ntohs(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __constant_ntohs(x) : __bpf_ntohs(x))
+
+#endif
diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
index 369e7d7..20ecbaa 100644
--- a/tools/testing/selftests/bpf/bpf_util.h
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -6,25 +6,6 @@
 #include <string.h>
 #include <errno.h>
 
-#include <asm/byteorder.h>
-
-#if __BYTE_ORDER == __LITTLE_ENDIAN
-# define __bpf_ntohs(x)		__builtin_bswap16(x)
-# define __bpf_htons(x)		__builtin_bswap16(x)
-#elif __BYTE_ORDER == __BIG_ENDIAN
-# define __bpf_ntohs(x)		(x)
-# define __bpf_htons(x)		(x)
-#else
-# error "Fix your __BYTE_ORDER?!"
-#endif
-
-#define bpf_htons(x)				\
-	(__builtin_constant_p(x) ?		\
-	 __constant_htons(x) : __bpf_htons(x))
-#define bpf_ntohs(x)				\
-	(__builtin_constant_p(x) ?		\
-	 __constant_ntohs(x) : __bpf_ntohs(x))
-
 static inline unsigned int bpf_num_possible_cpus(void)
 {
 	static const char *fcpu = "/sys/devices/system/cpu/possible";
diff --git a/tools/testing/selftests/bpf/test_l4lb.c b/tools/testing/selftests/bpf/test_l4lb.c
index b68b212..1e10c95 100644
--- a/tools/testing/selftests/bpf/test_l4lb.c
+++ b/tools/testing/selftests/bpf/test_l4lb.c
@@ -19,7 +19,7 @@
 #include <linux/udp.h>
 #include "bpf_helpers.h"
 #include "test_iptunnel_common.h"
-#include "bpf_util.h"
+#include "bpf_endian.h"
 
 int _version SEC("version") = 1;
 
diff --git a/tools/testing/selftests/bpf/test_pkt_access.c b/tools/testing/selftests/bpf/test_pkt_access.c
index 7113005..39387bb 100644
--- a/tools/testing/selftests/bpf/test_pkt_access.c
+++ b/tools/testing/selftests/bpf/test_pkt_access.c
@@ -14,7 +14,7 @@
 #include <linux/tcp.h>
 #include <linux/pkt_cls.h>
 #include "bpf_helpers.h"
-#include "bpf_util.h"
+#include "bpf_endian.h"
 
 #define barrier() __asm__ __volatile__("": : :"memory")
 int _version SEC("version") = 1;
-- 
2.1.2.532.g19b5d50
