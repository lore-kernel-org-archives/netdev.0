From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sparc: bpf_jit_comp: can call module_free() from
 any context
Date: Fri, 17 May 2013 15:12:34 -0700
Message-ID: <1368828754.3301.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:58142 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756272Ab3EQWMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 18:12:36 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so3672438pbc.40
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 15:12:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

module_free()/vfree() takes care of details, we no longer need a wrapper
and a work_struct.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 arch/sparc/net/bpf_jit_comp.c |   20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index d36a85e..d116bcd 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -785,9 +785,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 			break;
 		}
 		if (proglen == oldproglen) {
-			image = module_alloc(max_t(unsigned int,
-						   proglen,
-						   sizeof(struct work_struct)));
+			image = module_alloc(proglen);
 			if (!image)
 				goto out;
 		}
@@ -806,20 +804,8 @@ out:
 	return;
 }
 
-static void jit_free_defer(struct work_struct *arg)
-{
-	module_free(NULL, arg);
-}
-
-/* run from softirq, we must use a work_struct to call
- * module_free() from process context
- */
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
-
-		INIT_WORK(work, jit_free_defer);
-		schedule_work(work);
-	}
+	if (fp->bpf_func != sk_run_filter)
+		module_free(NULL, fp->bpf_func);
 }
