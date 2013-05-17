From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next]  x86: bpf_jit_comp: can call module_free() from
 any context
Date: Thu, 16 May 2013 22:45:30 -0700
Message-ID: <1368769530.3301.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:38143 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab3EQFpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 01:45:31 -0400
Received: by mail-da0-f42.google.com with SMTP id r6so858641dad.1
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 22:45:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It looks like we can call module_free()/vfree() from softirq context,
so no longer need a wrapper and a work_struct.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>
---
 arch/x86/net/bpf_jit_comp.c |   20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f66b540..c0212db 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -717,9 +717,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
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
@@ -738,20 +736,8 @@ out:
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
