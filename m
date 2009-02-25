From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 8/8] wanrouter: fix sparse warnings: context imbalance
Date: Wed, 25 Feb 2009 21:33:06 +0100
Message-ID: <20090225203301.6251.49315.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:54804 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760841AbZBYUdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 15:33:12 -0500
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Attribute functions with __acquires(...) resp. __releases(...).

Fix this sparse warnings:
  net/wanrouter/wanproc.c:82:13: warning: context imbalance in 'r_start' - wrong count at exit
  net/wanrouter/wanproc.c:103:13: warning: context imbalance in 'r_stop' - unexpected unlock
  net/wanrouter/wanmain.c:765:13: warning: context imbalance in 'lock_adapter_irq' - wrong count at exit
  net/wanrouter/wanmain.c:771:13: warning: context imbalance in 'unlock_adapter_irq' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/wanrouter/wanmain.c |    8 ++++++--
 net/wanrouter/wanproc.c |    2 ++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 39701de..466e2d2 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -86,8 +86,10 @@ static int wanrouter_device_del_if(struct wan_device *wandev,
 
 static struct wan_device *wanrouter_find_device(char *name);
 static int wanrouter_delete_interface(struct wan_device *wandev, char *name);
-static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
-static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
+static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+	__acquires(lock);
+static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+	__releases(lock);
 
 
 
@@ -763,12 +765,14 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 }
 
 static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+	__acquires(lock)
 {
 	spin_lock_irqsave(lock, *smp_flags);
 }
 
 
 static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+	__releases(lock)
 {
 	spin_unlock_irqrestore(lock, *smp_flags);
 }
diff --git a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
index 267f7ff..c44d96b 100644
--- a/net/wanrouter/wanproc.c
+++ b/net/wanrouter/wanproc.c
@@ -80,6 +80,7 @@ static struct proc_dir_entry *proc_router;
  *	Iterator
  */
 static void *r_start(struct seq_file *m, loff_t *pos)
+	__acquires(kernel_lock)
 {
 	struct wan_device *wandev;
 	loff_t l = *pos;
@@ -101,6 +102,7 @@ static void *r_next(struct seq_file *m, void *v, loff_t *pos)
 }
 
 static void r_stop(struct seq_file *m, void *v)
+	__releases(kernel_lock)
 {
 	unlock_kernel();
 }

