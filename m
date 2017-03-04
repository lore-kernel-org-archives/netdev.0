From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 2/3] rds: tcp: Reorder initialization sequence in rds_tcp_init to avoid races
Date: Sat,  4 Mar 2017 08:57:34 -0800
Message-ID: <9dedc81f93d999405fddd9f67fff3e15f3d69b39.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Cc: syzkaller@googlegroups.com, rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        santosh.shilimkar@oracle.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35692 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751539AbdCEMRz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:17:55 -0500
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Order of initialization in rds_tcp_init needs to be done so
that resources are set up and destroyed in the correct synchronization
sequence with both the data path, as well as netns create/destroy
path. Specifically,

- we must call register_pernet_subsys and get the rds_tcp_netid
  before calling register_netdevice_notifier, otherwise we risk
  the sequence
    1. register_netdevice_notifier sets up netdev notifier callback
    2. rds_tcp_dev_event -> rds_tcp_kill_sock uses netid 0, and finds
       the wrong rtn, resulting in a panic with string that is of the form:

  BUG: unable to handle kernel NULL pointer dereference at 000000000000000d
  IP: rds_tcp_kill_sock+0x3a/0x1d0 [rds_tcp]
         :

- the rds_tcp_incoming_slab kmem_cache must be initialized before the
  datapath starts up. The latter can happen any time after the
  pernet_subsys registration of rds_tcp_net_ops, whose -> init
  function sets up the listen socket. If the rds_tcp_incoming_slab has
  not been set up at that time, a panic of the form below may be
  encountered

  BUG: unable to handle kernel NULL pointer dereference at 0000000000000014
  IP: kmem_cache_alloc+0x90/0x1c0
     :
  rds_tcp_data_recv+0x1e7/0x370 [rds_tcp]
  tcp_read_sock+0x96/0x1c0
  rds_tcp_recv_path+0x65/0x80 [rds_tcp]
     :

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 65c8e3b..fbf807a 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -638,19 +638,19 @@ static int rds_tcp_init(void)
 		goto out;
 	}
 
-	ret = register_netdevice_notifier(&rds_tcp_dev_notifier);
-	if (ret) {
-		pr_warn("could not register rds_tcp_dev_notifier\n");
+	ret = rds_tcp_recv_init();
+	if (ret)
 		goto out_slab;
-	}
 
 	ret = register_pernet_subsys(&rds_tcp_net_ops);
 	if (ret)
-		goto out_notifier;
+		goto out_recv;
 
-	ret = rds_tcp_recv_init();
-	if (ret)
+	ret = register_netdevice_notifier(&rds_tcp_dev_notifier);
+	if (ret) {
+		pr_warn("could not register rds_tcp_dev_notifier\n");
 		goto out_pernet;
+	}
 
 	rds_trans_register(&rds_tcp_transport);
 
@@ -660,9 +660,8 @@ static int rds_tcp_init(void)
 
 out_pernet:
 	unregister_pernet_subsys(&rds_tcp_net_ops);
-out_notifier:
-	if (unregister_netdevice_notifier(&rds_tcp_dev_notifier))
-		pr_warn("could not unregister rds_tcp_dev_notifier\n");
+out_recv:
+	rds_tcp_recv_exit();
 out_slab:
 	kmem_cache_destroy(rds_tcp_conn_slab);
 out:
-- 
1.7.1
