From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] arm: bpf_jit: can call module_free() from any context
Date: Mon, 20 May 2013 20:05:51 +0200
Message-ID: <1369073151-25028-2-git-send-email-dborkman@redhat.com>
References: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	Mircea Gherzan <mgherzan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471Ab3ETSF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 14:05:59 -0400
In-Reply-To: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up on module_free()/vfree() that takes care of the rest, so no
longer this workaround with work_struct needed.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Mircea Gherzan <mgherzan@gmail.com>
---
 arch/arm/net/bpf_jit_32.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 1a643ee..f50d223 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -900,8 +900,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 #endif
 
 	alloc_size = 4 * ctx.idx;
-	ctx.target = module_alloc(max(sizeof(struct work_struct),
-				      alloc_size));
+	ctx.target = module_alloc(alloc_size);
 	if (unlikely(ctx.target == NULL))
 		goto out;
 
@@ -927,19 +926,8 @@ out:
 	return;
 }
 
-static void bpf_jit_free_worker(struct work_struct *work)
-{
-	module_free(NULL, work);
-}
-
 void bpf_jit_free(struct sk_filter *fp)
 {
-	struct work_struct *work;
-
-	if (fp->bpf_func != sk_run_filter) {
-		work = (struct work_struct *)fp->bpf_func;
-
-		INIT_WORK(work, bpf_jit_free_worker);
-		schedule_work(work);
-	}
+	if (fp->bpf_func != sk_run_filter)
+		module_free(NULL, fp->bpf_func);
 }
-- 
1.7.11.7
