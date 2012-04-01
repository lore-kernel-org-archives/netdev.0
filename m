From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sun, 1 Apr 2012 12:21:58 +0900
Message-ID: <201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com>
	<1333227549.2325.4051.camel@edumazet-glaptop>
	<20120331213423.GA21219@redhat.com>
	<CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
	<CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com
To: levinsasha928@gmail.com, oleg@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:64977 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab2DADWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 23:22:02 -0400
In-Reply-To: <CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha Levin wrote:
> While it seems that 9p is the culprit, I have to point out that this
> bug is easily reproducible, and it happens each time due to a
> call_usermode_helper() call. Other than that 9p behaves perfectly and
> I'd assume that I'd be seeing other things break besides
> call_usermode_helper() related ones.

I think one of below two patches can catch the bug if this is a usermodehelper
related bug. Please try.

----- Patch 1 -----
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 01394b6..3e63319 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -571,7 +571,7 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 	 * flag, for khelper thread is already waiting for the thread at
 	 * wait_for_completion() in do_fork().
 	 */
-	if (wait != UMH_NO_WAIT && current == kmod_thread_locker) {
+	if (WARN_ON(wait != UMH_NO_WAIT && current == kmod_thread_locker)) {
 		retval = -EBUSY;
 		goto out;
 	}


----- Patch 2 -----
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 9efeae6..1350670 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -48,10 +48,10 @@ static inline int request_module_nowait(const char *name, ...) { return -ENOSYS;
 struct cred;
 struct file;
 
-#define UMH_NO_WAIT	0	/* don't wait at all */
-#define UMH_WAIT_EXEC	1	/* wait for the exec, but not the process */
-#define UMH_WAIT_PROC	2	/* wait for the process to complete */
-#define UMH_KILLABLE	4	/* wait for EXEC/PROC killable */
+#define UMH_NO_WAIT	0x10	/* don't wait at all */
+#define UMH_WAIT_EXEC	0x11	/* wait for the exec, but not the process */
+#define UMH_WAIT_PROC	0x12	/* wait for the process to complete */
+#define UMH_KILLABLE	0x04	/* wait for EXEC/PROC killable */
 
 struct subprocess_info {
 	struct work_struct work;
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 957a7aa..ecfd3d5 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -483,6 +483,18 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 	DECLARE_COMPLETION_ONSTACK(done);
 	int retval = 0;
 
+	if (unlikely(wait == -1 || wait == 0 || wait == 1)) {
+		WARN(1, "Requesting for usermode helper with hardcoded wait "
+		     "flag. Change to use UMH_* symbols and recompile, or "
+		     "this request will fail on Linux 3.4.\n");
+		if (wait == -1)
+			wait = UMH_NO_WAIT;
+		else if (wait == 0)
+			wait = UMH_WAIT_EXEC;
+		else
+			wait = UMH_WAIT_PROC;
+	}
+
 	helper_lock();
 	if (sub_info->path[0] == '\0')
 		goto out;
