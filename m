From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/7] sctp: Don't abort initialization when CONFIG_PROC_FS=n
Date: Sat, 19 Jul 2008 00:26:46 -0400
Message-ID: <12164416141753-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38481 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbYGSE2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:21 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This puts CONFIG_PROC_FS defines around the proc init/exit functions
and also avoids compiling proc.c if procfs is not supported.
Also make SCTP_DBG_OBJCNT depend on procfs.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/Kconfig    |    4 ++--
 net/sctp/Makefile   |    4 ++--
 net/sctp/protocol.c |   11 ++++++++++-
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index 0b79f86..58b3e88 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -47,11 +47,11 @@ config SCTP_DBG_MSG
 
 config SCTP_DBG_OBJCNT
 	bool "SCTP: Debug object counts"
+	depends on PROC_FS
 	help
 	  If you say Y, this will enable debugging support for counting the 
 	  type of objects that are currently allocated.  This is useful for 
-	  identifying memory leaks.   If the /proc filesystem is enabled this 
-	  debug information can be viewed by 
+	  identifying memory leaks. This debug information can be viewed by
 	  'cat /proc/net/sctp/sctp_dbg_objcnt'
 
 	  If unsure, say N
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index f5356b9..6b79473 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -9,10 +9,10 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o command.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o proc.o \
-	  auth.o
+	  output.o input.o debug.o ssnmap.o auth.o
 
 sctp-$(CONFIG_SCTP_DBG_OBJCNT) += objcnt.o
+sctp-$(CONFIG_PROC_FS) += proc.o
 sctp-$(CONFIG_SYSCTL) += sysctl.o
 
 sctp-$(subst m,y,$(CONFIG_IPV6))	+= ipv6.o
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 98c6a88..dd811a8 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -64,9 +64,12 @@
 
 /* Global data structures. */
 struct sctp_globals sctp_globals __read_mostly;
-struct proc_dir_entry	*proc_net_sctp;
 DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics) __read_mostly;
 
+#ifdef CONFIG_PROC_FS
+struct proc_dir_entry	*proc_net_sctp;
+#endif
+
 struct idr sctp_assocs_id;
 DEFINE_SPINLOCK(sctp_assocs_id_lock);
 
@@ -97,6 +100,7 @@ struct sock *sctp_get_ctl_sock(void)
 /* Set up the proc fs entry for the SCTP protocol. */
 static __init int sctp_proc_init(void)
 {
+#ifdef CONFIG_PROC_FS
 	if (!proc_net_sctp) {
 		struct proc_dir_entry *ent;
 		ent = proc_mkdir("sctp", init_net.proc_net);
@@ -131,6 +135,9 @@ out_snmp_proc_init:
 	}
 out_nomem:
 	return -ENOMEM;
+#else
+	return 0;
+#endif /* CONFIG_PROC_FS */
 }
 
 /* Clean up the proc fs entry for the SCTP protocol.
@@ -139,6 +146,7 @@ out_nomem:
  */
 static void sctp_proc_exit(void)
 {
+#ifdef CONFIG_PROC_FS
 	sctp_snmp_proc_exit();
 	sctp_eps_proc_exit();
 	sctp_assocs_proc_exit();
@@ -148,6 +156,7 @@ static void sctp_proc_exit(void)
 		proc_net_sctp = NULL;
 		remove_proc_entry("sctp", init_net.proc_net);
 	}
+#endif
 }
 
 /* Private helper to extract ipv4 address and stash them in
-- 
1.5.2.5

