From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 5/6] bpf: lru: Lower the PERCPU_NR_SCANS from 16 to 4
Date: Fri, 14 Apr 2017 10:30:29 -0700
Message-ID: <20170414173030.2853860-6-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58145 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754139AbdDNRad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:33 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHMVcu016626
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 29tp48tret-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:32 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 0ea6d628213811e78efd0002c99331b0-b31f39a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After doing map_perf_test with a much bigger
BPF_F_NO_COMMON_LRU map, the perf report shows a
lot of time spent in rotating the inactive list (i.e.
__bpf_lru_list_rotate_inactive):
> map_perf_test 32 8 10000 1000000 | awk '{sum += $3}END{print sum}'
19644783 (19M/s)
> map_perf_test 32 8 10000000 10000000 |  awk '{sum += $3}END{print sum}'
6283930 (6.28M/s)

By inactive, it usually means the element is not in cache.  Hence,
there is a need to tune the PERCPU_NR_SCANS value.

This patch finds a better number of elements to
scan during each list rotation.  The PERCPU_NR_SCANS (which
is defined the same as PERCPU_FREE_TARGET) decreases
from 16 elements to 4 elements.  This change only
affects the BPF_F_NO_COMMON_LRU map.

The test_lru_dist does not show meaningful difference
between 16 and 4.  Our production L4 load balancer which uses
the LRU map for conntrack-ing also shows little change in cache
hit rate.  Since both benchmark and production data show no
cache-hit difference, PERCPU_NR_SCANS is lowered from 16 to 4.
We can consider making it configurable if we find a usecase
later that shows another value works better and/or use
a different rotation strategy.

After this change:
> map_perf_test 32 8 10000000 10000000 |  awk '{sum += $3}END{print sum}'
9240324 (9.2M/s)

i.e. 6.28M/s -> 9.2M/s

The test_lru_dist has not shown meaningful difference:
> test_lru_dist zipf.100k.a1_01.out 4000 1:
nr_misses: 31575 (Before) vs 31566 (After)

> test_lru_dist zipf.100k.a0_01.out 40000 1
nr_misses: 67036 (Before) vs 67031 (After)

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/bpf_lru_list.c                  | 2 +-
 tools/testing/selftests/bpf/test_lru_map.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index f62d1d56f41d..e6ef4401a138 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -13,7 +13,7 @@
 #define LOCAL_FREE_TARGET		(128)
 #define LOCAL_NR_SCANS			LOCAL_FREE_TARGET
 
-#define PERCPU_FREE_TARGET		(16)
+#define PERCPU_FREE_TARGET		(4)
 #define PERCPU_NR_SCANS			PERCPU_FREE_TARGET
 
 /* Helpers to get the local list index */
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 87c05e5bdfdd..8c10c9180c1a 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -22,7 +22,7 @@
 #include "bpf_util.h"
 
 #define LOCAL_FREE_TARGET	(128)
-#define PERCPU_FREE_TARGET	(16)
+#define PERCPU_FREE_TARGET	(4)
 
 static int nr_cpus;
 
-- 
2.9.3
