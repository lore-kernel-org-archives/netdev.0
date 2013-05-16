From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: nf_{log,queue}: fix compilation without CONFIG_PROC_FS
Date: Thu, 16 May 2013 17:55:18 +0200
Message-ID: <1368719721-7470-2-git-send-email-pablo@netfilter.org>
References: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following compilation error:

net/netfilter/nf_log.c:373:38: error: 'struct netns_nf' has no member named 'proc_netfilter'

if procfs is not set.

The netns support for nf_log, nfnetlink_log and nfnetlink_queue_core
requires CONFIG_PROC_FS in the removal path of their respective
/proc interface since net->nf.proc_netfilter is undefined in that
case.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_log.c               |    5 ++++-
 net/netfilter/nfnetlink_log.c        |    2 ++
 net/netfilter/nfnetlink_queue_core.c |    2 ++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 388656d..757951d 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -368,17 +368,20 @@ static int __net_init nf_log_net_init(struct net *net)
 	return 0;
 
 out_sysctl:
+#ifdef CONFIG_PROC_FS
 	/* For init_net: errors will trigger panic, don't unroll on error. */
 	if (!net_eq(net, &init_net))
 		remove_proc_entry("nf_log", net->nf.proc_netfilter);
-
+#endif
 	return ret;
 }
 
 static void __net_exit nf_log_net_exit(struct net *net)
 {
 	netfilter_log_sysctl_exit(net);
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("nf_log", net->nf.proc_netfilter);
+#endif
 }
 
 static struct pernet_operations nf_log_net_ops = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index faf1e93..d83d881 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1045,7 +1045,9 @@ static int __net_init nfnl_log_net_init(struct net *net)
 
 static void __net_exit nfnl_log_net_exit(struct net *net)
 {
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("nfnetlink_log", net->nf.proc_netfilter);
+#endif
 }
 
 static struct pernet_operations nfnl_log_net_ops = {
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 2e0e835..4e27fa0 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1285,7 +1285,9 @@ static int __net_init nfnl_queue_net_init(struct net *net)
 
 static void __net_exit nfnl_queue_net_exit(struct net *net)
 {
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("nfnetlink_queue", net->nf.proc_netfilter);
+#endif
 }
 
 static struct pernet_operations nfnl_queue_net_ops = {
-- 
1.7.10.4

