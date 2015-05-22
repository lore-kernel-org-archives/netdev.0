From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: nfnetlink_{log,queue}: Register pernet in first place
Date: Fri, 22 May 2015 12:34:04 +0200
Message-ID: <1432290846-4310-2-git-send-email-pablo@netfilter.org>
References: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francesco Ruggeri <fruggeri@aristanetworks.com>

nfnetlink_{log,queue}_init() register the netlink callback nf*_rcv_nl_event
before registering the pernet_subsys, but the callback relies on data
structures allocated by pernet init functions.

When nfnetlink_{log,queue} is loaded, if a netlink message is received after
the netlink callback is registered but before the pernet_subsys is registered,
the kernel will panic in the sequence

nfulnl_rcv_nl_event
  nfnl_log_pernet
    net_generic
      BUG_ON(id == 0)  where id is nfnl_log_net_id.

The panic can be easily reproduced in 4.0.3 by:

while true ;do modprobe nfnetlink_log ; rmmod nfnetlink_log ; done &
while true ;do ip netns add dummy ; ip netns del dummy ; done &

This patch moves register_pernet_subsys to earlier in nfnetlink_log_init.

Notice that the BUG_ON hit in 4.0.3 was recently removed in 2591ffd308
["netns: remove BUG_ONs from net_generic()"].

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c        |   19 ++++++++++---------
 net/netfilter/nfnetlink_queue_core.c |   18 +++++++++---------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3ad9126..4ef1fae 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1073,7 +1073,13 @@ static struct pernet_operations nfnl_log_net_ops = {
 
 static int __init nfnetlink_log_init(void)
 {
-	int status = -ENOMEM;
+	int status;
+
+	status = register_pernet_subsys(&nfnl_log_net_ops);
+	if (status < 0) {
+		pr_err("failed to register pernet ops\n");
+		goto out;
+	}
 
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
@@ -1088,28 +1094,23 @@ static int __init nfnetlink_log_init(void)
 		goto cleanup_subsys;
 	}
 
-	status = register_pernet_subsys(&nfnl_log_net_ops);
-	if (status < 0) {
-		pr_err("failed to register pernet ops\n");
-		goto cleanup_logger;
-	}
 	return status;
 
-cleanup_logger:
-	nf_log_unregister(&nfulnl_logger);
 cleanup_subsys:
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
+	unregister_pernet_subsys(&nfnl_log_net_ops);
+out:
 	return status;
 }
 
 static void __exit nfnetlink_log_fini(void)
 {
-	unregister_pernet_subsys(&nfnl_log_net_ops);
 	nf_log_unregister(&nfulnl_logger);
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
 	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
+	unregister_pernet_subsys(&nfnl_log_net_ops);
 }
 
 MODULE_DESCRIPTION("netfilter userspace logging");
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0b98c74..11c7682 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1317,7 +1317,13 @@ static struct pernet_operations nfnl_queue_net_ops = {
 
 static int __init nfnetlink_queue_init(void)
 {
-	int status = -ENOMEM;
+	int status;
+
+	status = register_pernet_subsys(&nfnl_queue_net_ops);
+	if (status < 0) {
+		pr_err("nf_queue: failed to register pernet ops\n");
+		goto out;
+	}
 
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfqnl_subsys);
@@ -1326,19 +1332,13 @@ static int __init nfnetlink_queue_init(void)
 		goto cleanup_netlink_notifier;
 	}
 
-	status = register_pernet_subsys(&nfnl_queue_net_ops);
-	if (status < 0) {
-		pr_err("nf_queue: failed to register pernet ops\n");
-		goto cleanup_subsys;
-	}
 	register_netdevice_notifier(&nfqnl_dev_notifier);
 	nf_register_queue_handler(&nfqh);
 	return status;
 
-cleanup_subsys:
-	nfnetlink_subsys_unregister(&nfqnl_subsys);
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+out:
 	return status;
 }
 
@@ -1346,9 +1346,9 @@ static void __exit nfnetlink_queue_fini(void)
 {
 	nf_unregister_queue_handler();
 	unregister_netdevice_notifier(&nfqnl_dev_notifier);
-	unregister_pernet_subsys(&nfnl_queue_net_ops);
 	nfnetlink_subsys_unregister(&nfqnl_subsys);
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+	unregister_pernet_subsys(&nfnl_queue_net_ops);
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
-- 
1.7.10.4

