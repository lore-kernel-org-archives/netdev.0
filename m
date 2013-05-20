From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] ppc: bpf_jit: can call module_free() from any context
Date: Mon, 20 May 2013 20:05:50 +0200
Message-ID: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471Ab3ETSF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 14:05:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Followup patch on module_free()/vfree() that takes care of the rest, so
no longer this workaround with work_struct is needed.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Matt Evans <matt@ozlabs.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index c427ae3..bf56e33 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -650,8 +650,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 
 	proglen = cgctx.idx * 4;
 	alloclen = proglen + FUNCTION_DESCR_SIZE;
-	image = module_alloc(max_t(unsigned int, alloclen,
-				   sizeof(struct work_struct)));
+	image = module_alloc(alloclen);
 	if (!image)
 		goto out;
 
@@ -688,20 +687,8 @@ out:
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
-- 
1.7.11.7
