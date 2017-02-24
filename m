From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] rds: fix memory leak error
Date: Fri, 24 Feb 2017 04:28:01 -0500
Message-ID: <1487928481-1022-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When the function register_netdevice_notifier fails, the memory
allocated by kmem_cache_create should be freed by the function
kmem_cache_destroy.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/tcp.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 57bb523..5438f67 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -641,12 +641,12 @@ static int rds_tcp_init(void)
 	ret = register_netdevice_notifier(&rds_tcp_dev_notifier);
 	if (ret) {
 		pr_warn("could not register rds_tcp_dev_notifier\n");
-		goto out;
+		goto out_slab;
 	}
 
 	ret = register_pernet_subsys(&rds_tcp_net_ops);
 	if (ret)
-		goto out_slab;
+		goto out_notifier;
 
 	ret = rds_tcp_recv_init();
 	if (ret)
@@ -664,9 +664,10 @@ static int rds_tcp_init(void)
 	rds_tcp_recv_exit();
 out_pernet:
 	unregister_pernet_subsys(&rds_tcp_net_ops);
-out_slab:
+out_notifier:
 	if (unregister_netdevice_notifier(&rds_tcp_dev_notifier))
 		pr_warn("could not unregister rds_tcp_dev_notifier\n");
+out_slab:
 	kmem_cache_destroy(rds_tcp_conn_slab);
 out:
 	return ret;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
