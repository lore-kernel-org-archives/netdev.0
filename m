From: Gianluca Borello <g.borello@gmail.com>
Subject: [PATCH net-next] bpf: remove tail_call and get_stackid helper declarations from bpf.h
Date: Thu, 26 Oct 2017 01:47:42 +0000
Message-ID: <20171026014742.48509-1-g.borello@gmail.com>
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        Gianluca Borello <g.borello@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:48295 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZBsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:48:12 -0400
Received: by mail-pg0-f66.google.com with SMTP id v78so1437897pgb.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 18:48:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit afdb09c720b6 ("security: bpf: Add LSM hooks for bpf object related
syscall") included linux/bpf.h in linux/security.h. As a result, bpf
programs including bpf_helpers.h and some other header that ends up
pulling in also security.h, such as several examples under samples/bpf,
fail to compile because bpf_tail_call and bpf_get_stackid are now
"redefined as different kind of symbol".

>From bpf.h:

u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);

Whereas in bpf_helpers.h they are:

static void (*bpf_tail_call)(void *ctx, void *map, int index);
static int (*bpf_get_stackid)(void *ctx, void *map, int flags);

Fix this by removing the unused declaration of bpf_tail_call and moving
the declaration of bpf_get_stackid in bpf_trace.c, which is the only
place where it's needed.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      | 3 ---
 kernel/trace/bpf_trace.c | 2 ++
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 172be7faf7ba..520aeebe0d93 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -231,9 +231,6 @@ struct bpf_event_entry {
 	struct rcu_head rcu;
 };
 
-u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
-u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
-
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 int bpf_prog_calc_tag(struct bpf_prog *fp);
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b65011d320e3..136aa6bb0422 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -15,6 +15,8 @@
 #include <linux/ctype.h>
 #include "trace.h"
 
+u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+
 /**
  * trace_call_bpf - invoke BPF program
  * @call: tracepoint event
-- 
2.15.0.rc2
