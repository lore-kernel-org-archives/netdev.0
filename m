From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: [PATCH 1/1] netfilter: Fix kernel panic in nfulnl_rcv_nl_event
Date: Sun, 17 May 2015 14:30:31 -0700
Message-ID: <20150517213031.4ABD2480853@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, dvlasenk@redhat.com,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	pablo@netfilter.org, fruggeri@arista.com
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nfnetlink_log_init registers netlink callback nfulnl_rcv_nl_event before
registering the pernet_subsys, but the callback relies on data structures
allocated by pernet init functions.
When nfnetlink_log is loaded, if a netlink message is received after
the netlink callback is registered but before the pernet_subsys is
registered, the kernel will panic in the sequence

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
---
 net/netfilter/nfnetlink_log.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3ad9126..536ced5 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1075,6 +1075,12 @@ static int __init nfnetlink_log_init(void)
 {
 	int status = -ENOMEM;
 
+	status = register_pernet_subsys(&nfnl_log_net_ops);
+	if (status < 0) {
+		pr_err("failed to register pernet ops\n");
+		goto out;
+	}
+
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
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
-- 
1.8.1.4

