From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] netfilter: nf_log: fix sleeping function called from
	invalid context in seq_show()
Date: Fri, 13 Nov 2009 14:36:40 +0800
Message-ID: <20091113063640.GA29012@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Yin, Kangkai" <kangkai.yin@intel.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437AbZKMGgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 01:36:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[  171.925285] BUG: sleeping function called from invalid context at kernel/mutex.c:280
[  171.925296] in_atomic(): 1, irqs_disabled(): 0, pid: 671, name: grep
[  171.925306] 2 locks held by grep/671:
[  171.925312]  #0:  (&p->lock){+.+.+.}, at: [<c10b8acd>] seq_read+0x25/0x36c
[  171.925340]  #1:  (rcu_read_lock){.+.+..}, at: [<c1391dac>] seq_start+0x0/0x44
[  171.925372] Pid: 671, comm: grep Not tainted 2.6.31.6-4-netbook #3
[  171.925380] Call Trace:
[  171.925398]  [<c105104e>] ? __debug_show_held_locks+0x1e/0x20
[  171.925414]  [<c10264ac>] __might_sleep+0xfb/0x102
[  171.925430]  [<c1461521>] mutex_lock_nested+0x1c/0x2ad
[  171.925444]  [<c1391c9e>] seq_show+0x74/0x127
[  171.925456]  [<c10b8c5c>] seq_read+0x1b4/0x36c
[  171.925469]  [<c10b8aa8>] ? seq_read+0x0/0x36c
[  171.925483]  [<c10d5c8e>] proc_reg_read+0x60/0x74
[  171.925496]  [<c10d5c2e>] ? proc_reg_read+0x0/0x74
[  171.925510]  [<c10a4468>] vfs_read+0x87/0x110
[  171.925523]  [<c10a458a>] sys_read+0x3b/0x60
[  171.925538]  [<c1002a49>] syscall_call+0x7/0xb

Fix it by replacing RCU with nf_log_mutex.

CC: Patrick McHardy <kaber@trash.net>
Reported-by: "Yin, Kangkai" <kangkai.yin@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 net/netfilter/nf_log.c |   18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

--- sound-2.6.orig/net/netfilter/nf_log.c	2009-11-13 13:47:14.000000000 +0800
+++ sound-2.6/net/netfilter/nf_log.c	2009-11-13 13:49:23.000000000 +0800
@@ -128,9 +128,8 @@ EXPORT_SYMBOL(nf_log_packet);
 
 #ifdef CONFIG_PROC_FS
 static void *seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
 {
-	rcu_read_lock();
+	mutex_lock(&nf_log_mutex);
 
 	if (*pos >= ARRAY_SIZE(nf_loggers))
 		return NULL;
@@ -149,9 +148,8 @@ static void *seq_next(struct seq_file *s
 }
 
 static void seq_stop(struct seq_file *s, void *v)
-	__releases(RCU)
 {
-	rcu_read_unlock();
+	mutex_unlock(&nf_log_mutex);
 }
 
 static int seq_show(struct seq_file *s, void *v)
@@ -161,7 +159,7 @@ static int seq_show(struct seq_file *s, 
 	struct nf_logger *t;
 	int ret;
 
-	logger = rcu_dereference(nf_loggers[*pos]);
+	logger = nf_loggers[*pos];
 
 	if (!logger)
 		ret = seq_printf(s, "%2lld NONE (", *pos);
@@ -171,22 +169,16 @@ static int seq_show(struct seq_file *s, 
 	if (ret < 0)
 		return ret;
 
-	mutex_lock(&nf_log_mutex);
 	list_for_each_entry(t, &nf_loggers_l[*pos], list[*pos]) {
 		ret = seq_printf(s, "%s", t->name);
-		if (ret < 0) {
-			mutex_unlock(&nf_log_mutex);
+		if (ret < 0)
 			return ret;
-		}
 		if (&t->list[*pos] != nf_loggers_l[*pos].prev) {
 			ret = seq_printf(s, ",");
-			if (ret < 0) {
-				mutex_unlock(&nf_log_mutex);
+			if (ret < 0)
 				return ret;
-			}
 		}
 	}
-	mutex_unlock(&nf_log_mutex);
 
 	return seq_printf(s, ")\n");
 }
