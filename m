From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, tests: fix endianness selection
Date: Thu,  8 Jun 2017 19:06:25 +0200
Message-ID: <086cffcb4e5cf48bc21be6961c16df53db9155cb.1496941264.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44454 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdFHRG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 13:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that test_l4lb was failing in selftests:

  # ./test_progs
  test_pkt_access:PASS:ipv4 77 nsec
  test_pkt_access:PASS:ipv6 44 nsec
  test_xdp:PASS:ipv4 2933 nsec
  test_xdp:PASS:ipv6 1500 nsec
  test_l4lb:PASS:ipv4 377 nsec
  test_l4lb:PASS:ipv6 544 nsec
  test_l4lb:FAIL:stats 6297600000 200000
  test_tcp_estats:PASS: 0 nsec
  Summary: 7 PASSED, 1 FAILED

Tracking down the issue actually revealed that endianness selection
in bpf_endian.h is broken when compiled with clang with bpf target.
test_pkt_access.c, test_l4lb.c is compiled with __BYTE_ORDER as
__BIG_ENDIAN, test_xdp.c as __LITTLE_ENDIAN! test_l4lb noticeably
fails, because the test accounts bytes via bpf_ntohs(ip6h->payload_len)
and bpf_ntohs(iph->tot_len), and compares them against a defined
value and given a wrong endianness, the test outcome is different,
of course.

Turns out that there are actually two bugs: i) when we do __BYTE_ORDER
comparison with __LITTLE_ENDIAN/__BIG_ENDIAN, then depending on the
include order we see different outcomes. Reason is that __BYTE_ORDER
is undefined due to missing endian.h include. Before we include the
asm/byteorder.h (e.g. through linux/in.h), then __BYTE_ORDER equals
__LITTLE_ENDIAN since both are undefined, after the include which
correctly pulls in linux/byteorder/little_endian.h, __LITTLE_ENDIAN
is defined, but given __BYTE_ORDER is still undefined, we match on
__BYTE_ORDER equals to __BIG_ENDIAN since __BIG_ENDIAN is also
undefined at that point, sigh. ii) But even that would be wrong,
since when compiling the test cases with clang, one can select between
bpfeb and bpfel targets for cross compilation. Hence, we can also not
rely on what the system's endian.h provides, but we need to look at
the compiler's defined endianness. The compiler defines __BYTE_ORDER__,
and we can match __ORDER_LITTLE_ENDIAN__ and __ORDER_BIG_ENDIAN__,
which also reflects targets bpf (native), bpfel, bpfeb correctly,
thus really only rely on that. After patch:

  # ./test_progs
  test_pkt_access:PASS:ipv4 74 nsec
  test_pkt_access:PASS:ipv6 42 nsec
  test_xdp:PASS:ipv4 2340 nsec
  test_xdp:PASS:ipv6 1461 nsec
  test_l4lb:PASS:ipv4 400 nsec
  test_l4lb:PASS:ipv6 530 nsec
  test_tcp_estats:PASS: 0 nsec
  Summary: 7 PASSED, 0 FAILED

Fixes: 43bcf707ccdc ("bpf: fix _htons occurences in test_progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/bpf_endian.h | 41 +++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/tools/testing/selftests/bpf/bpf_endian.h
index 19d0604..487cbfb 100644
--- a/tools/testing/selftests/bpf/bpf_endian.h
+++ b/tools/testing/selftests/bpf/bpf_endian.h
@@ -1,23 +1,42 @@
 #ifndef __BPF_ENDIAN__
 #define __BPF_ENDIAN__
 
-#include <asm/byteorder.h>
+#include <linux/swab.h>
 
-#if __BYTE_ORDER == __LITTLE_ENDIAN
-# define __bpf_ntohs(x)		__builtin_bswap16(x)
-# define __bpf_htons(x)		__builtin_bswap16(x)
-#elif __BYTE_ORDER == __BIG_ENDIAN
-# define __bpf_ntohs(x)		(x)
-# define __bpf_htons(x)		(x)
+/* LLVM's BPF target selects the endianness of the CPU
+ * it compiles on, or the user specifies (bpfel/bpfeb),
+ * respectively. The used __BYTE_ORDER__ is defined by
+ * the compiler, we cannot rely on __BYTE_ORDER from
+ * libc headers, since it doesn't reflect the actual
+ * requested byte order.
+ *
+ * Note, LLVM's BPF target has different __builtin_bswapX()
+ * semantics. It does map to BPF_ALU | BPF_END | BPF_TO_BE
+ * in bpfel and bpfeb case, which means below, that we map
+ * to cpu_to_be16(). We could use it unconditionally in BPF
+ * case, but better not rely on it, so that this header here
+ * can be used from application and BPF program side, which
+ * use different targets.
+ */
+#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
+# define __bpf_ntohs(x)			__builtin_bswap16(x)
+# define __bpf_htons(x)			__builtin_bswap16(x)
+# define __bpf_constant_ntohs(x)	___constant_swab16(x)
+# define __bpf_constant_htons(x)	___constant_swab16(x)
+#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
+# define __bpf_ntohs(x)			(x)
+# define __bpf_htons(x)			(x)
+# define __bpf_constant_ntohs(x)	(x)
+# define __bpf_constant_htons(x)	(x)
 #else
-# error "Fix your __BYTE_ORDER?!"
+# error "Fix your compiler's __BYTE_ORDER__?!"
 #endif
 
 #define bpf_htons(x)				\
 	(__builtin_constant_p(x) ?		\
-	 __constant_htons(x) : __bpf_htons(x))
+	 __bpf_constant_htons(x) : __bpf_htons(x))
 #define bpf_ntohs(x)				\
 	(__builtin_constant_p(x) ?		\
-	 __constant_ntohs(x) : __bpf_ntohs(x))
+	 __bpf_constant_ntohs(x) : __bpf_ntohs(x))
 
-#endif
+#endif /* __BPF_ENDIAN__ */
-- 
1.9.3
