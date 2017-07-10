From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net] samples/bpf: fix a build issue
Date: Mon, 10 Jul 2017 13:12:24 -0700
Message-ID: <20170710201224.1071186-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Yonghong Song <yhs@localhost.localdomain>
To: <ast@fb.com>, <daniel@iogearbox.net>, <brakmo@fb.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33323 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752324AbdGJUM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 16:12:28 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6AK9Rwf011301
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 13:12:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bmd628pn6-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 13:12:27 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 170bd39665ac11e78c18ade1b876fb2a-9f1e5150 for <netdev@vger.kernel.org>;        Mon,
 10 Jul 2017 13:12:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@localhost.localdomain>

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

Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h
and move it to samples/bpf/ directory so that it can used by
both selftests/bpf and samples/bpf. The existing samples/bpf/bpf_helpers.h
is already used by both.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 {tools/testing/selftests => samples}/bpf/bpf_endian.h | 14 ++++++++++++++
 tools/testing/selftests/bpf/Makefile                  |  3 ++-
 2 files changed, 16 insertions(+), 1 deletion(-)
 rename {tools/testing/selftests => samples}/bpf/bpf_endian.h (73%)

diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/samples/bpf/bpf_endian.h
similarity index 73%
rename from tools/testing/selftests/bpf/bpf_endian.h
rename to samples/bpf/bpf_endian.h
index 487cbfb..74af266 100644
--- a/tools/testing/selftests/bpf/bpf_endian.h
+++ b/samples/bpf/bpf_endian.h
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
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 2ca51a8..f263c6b 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -8,7 +8,8 @@ ifneq ($(wildcard $(GENHDR)),)
   GENFLAGS := -DHAVE_GENHDR
 endif
 
-CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include
+CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include \
+	-I../../../../samples/bpf
 LDLIBS += -lcap -lelf
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs \
-- 
2.9.4
