From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net v2] samples/bpf: fix a build issue
Date: Mon, 10 Jul 2017 14:04:28 -0700
Message-ID: <20170710210428.1292358-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <brakmo@fb.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39455 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754584AbdGJVEc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 17:04:32 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v6AL4DK8014396
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 14:04:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2bm5fq24ra-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 14:04:31 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 5cfb9fe265b311e786b193b906701649-be2ef150 for <netdev@vger.kernel.org>;        Mon,
 10 Jul 2017 14:04:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With latest net-next:
====
clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
    -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
    -Wno-compare-distinct-pointer-types \
    -Wno-gnu-variable-sized-type-not-at-end \
    -Wno-address-of-packed-member -Wno-tautological-compare \
    -Wno-unknown-warning-option \
    -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
          ^~~~~~~~~~~~~~
1 error generated.
====

net has the same issue.

Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h.
Also move bpf_helpers.h from samples/bpf to selftests/bpf and change
compiler include logic so that programs in samples/bpf can access the headers
in selftests/bpf, but not the other way around.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 samples/bpf/Makefile                                   |  1 +
 tools/testing/selftests/bpf/Makefile                   |  1 -
 tools/testing/selftests/bpf/bpf_endian.h               | 14 ++++++++++++++
 {samples => tools/testing/selftests}/bpf/bpf_helpers.h |  0
 4 files changed, 15 insertions(+), 1 deletion(-)
 rename {samples => tools/testing/selftests}/bpf/bpf_helpers.h (100%)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 9c65058..87246be 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -207,6 +207,7 @@ $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
 # useless for BPF samples.
 $(obj)/%.o: $(src)/%.c
 	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
+		-I$(srctree)/tools/testing/selftests/bpf/ \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 2ca51a8..153c3a1 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -37,6 +37,5 @@ CLANG ?= clang
 
 %.o: %.c
 	$(CLANG) -I. -I./include/uapi -I../../../include/uapi \
-		-I../../../../samples/bpf/ \
 		-Wno-compare-distinct-pointer-types \
 		-O2 -target bpf -c $< -o $@
diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/tools/testing/selftests/bpf/bpf_endian.h
index 487cbfb..74af266 100644
--- a/tools/testing/selftests/bpf/bpf_endian.h
+++ b/tools/testing/selftests/bpf/bpf_endian.h
@@ -23,11 +23,19 @@
 # define __bpf_htons(x)			__builtin_bswap16(x)
 # define __bpf_constant_ntohs(x)	___constant_swab16(x)
 # define __bpf_constant_htons(x)	___constant_swab16(x)
+# define __bpf_ntohl(x)			__builtin_bswap32(x)
+# define __bpf_htonl(x)			__builtin_bswap32(x)
+# define __bpf_constant_ntohl(x)	___constant_swab32(x)
+# define __bpf_constant_htonl(x)	___constant_swab32(x)
 #elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
 # define __bpf_ntohs(x)			(x)
 # define __bpf_htons(x)			(x)
 # define __bpf_constant_ntohs(x)	(x)
 # define __bpf_constant_htons(x)	(x)
+# define __bpf_ntohl(x)			(x)
+# define __bpf_htonl(x)			(x)
+# define __bpf_constant_ntohl(x)	(x)
+# define __bpf_constant_htonl(x)	(x)
 #else
 # error "Fix your compiler's __BYTE_ORDER__?!"
 #endif
@@ -38,5 +46,11 @@
 #define bpf_ntohs(x)				\
 	(__builtin_constant_p(x) ?		\
 	 __bpf_constant_ntohs(x) : __bpf_ntohs(x))
+#define bpf_htonl(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __bpf_constant_htonl(x) : __bpf_htonl(x))
+#define bpf_ntohl(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __bpf_constant_ntohl(x) : __bpf_ntohl(x))
 
 #endif /* __BPF_ENDIAN__ */
diff --git a/samples/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
similarity index 100%
rename from samples/bpf/bpf_helpers.h
rename to tools/testing/selftests/bpf/bpf_helpers.h
-- 
2.9.3
