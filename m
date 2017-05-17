From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 15:18:05 -0700
Message-ID: <20170517221805.1593973-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38627 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754434AbdEQWSH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 18:18:07 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4HMAIcP018501
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 15:18:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2agsuxhbph-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 15:18:06 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 b30a4c063b4e11e7856d0002c9931860-321368f0 for <netdev@vger.kernel.org>;        Wed,
 17 May 2017 15:18:05 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0a5539f66133 ("bpf: Provide a linux/types.h override
for bpf selftests.") caused a build failure for tools/testing/selftest/bpf
because of some missing types:
    $ make -C tools/testing/selftests/bpf/
    ...
    In file included from /home/yhs/work/net-next/tools/testing/selftests/bpf/test_pkt_access.c:8:
    ../../../include/uapi/linux/bpf.h:170:3: error: unknown type name '__aligned_u64'
                    __aligned_u64   key;
    ...
    /usr/include/linux/swab.h:160:8: error: unknown type name '__always_inline'
    static __always_inline __u16 __swab16p(const __u16 *p)
    ...
The type __aligned_u64 is defined in linux:include/uapi/linux/types.h.

The fix is to copy missing type definition into
tools/testing/selftests/bpf/include/uapi/linux/types.h.
Adding additional include "string.h" resolves __always_inline issue.

Fixes: 0a5539f66133 ("bpf: Provide a linux/types.h override for bpf selftests.")
Signed-off-by: Yonghong Song <yhs@fb.com>
---
 tools/testing/selftests/bpf/include/uapi/linux/types.h | 16 ++++++++++++++++
 tools/testing/selftests/bpf/test_pkt_access.c          |  1 +
 2 files changed, 17 insertions(+)

diff --git a/tools/testing/selftests/bpf/include/uapi/linux/types.h b/tools/testing/selftests/bpf/include/uapi/linux/types.h
index fbd16a7..5184184 100644
--- a/tools/testing/selftests/bpf/include/uapi/linux/types.h
+++ b/tools/testing/selftests/bpf/include/uapi/linux/types.h
@@ -3,4 +3,20 @@
 
 #include <asm-generic/int-ll64.h>
 
+/* copied from linux:include/uapi/linux/types.h */
+#define __bitwise
+typedef __u16 __bitwise __le16;
+typedef __u16 __bitwise __be16;
+typedef __u32 __bitwise __le32;
+typedef __u32 __bitwise __be32;
+typedef __u64 __bitwise __le64;
+typedef __u64 __bitwise __be64;
+
+typedef __u16 __bitwise __sum16;
+typedef __u32 __bitwise __wsum;
+
+#define __aligned_u64 __u64 __attribute__((aligned(8)))
+#define __aligned_be64 __be64 __attribute__((aligned(8)))
+#define __aligned_le64 __le64 __attribute__((aligned(8)))
+
 #endif /* _UAPI_LINUX_TYPES_H */
diff --git a/tools/testing/selftests/bpf/test_pkt_access.c b/tools/testing/selftests/bpf/test_pkt_access.c
index 39387bb..6e11ba1 100644
--- a/tools/testing/selftests/bpf/test_pkt_access.c
+++ b/tools/testing/selftests/bpf/test_pkt_access.c
@@ -5,6 +5,7 @@
  * License as published by the Free Software Foundation.
  */
 #include <stddef.h>
+#include <string.h>
 #include <linux/bpf.h>
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
-- 
2.9.3
