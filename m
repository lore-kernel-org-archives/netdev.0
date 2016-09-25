From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/53] netfilter: Add the missed return value check of register_netdevice_notifier
Date: Mon, 26 Sep 2016 01:06:31 +0200
Message-ID: <1474844823-2026-22-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54606 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034676AbcIYXHl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BE33EC0B2A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AD95FDA848
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9A321DA849
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:38 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are some codes of netfilter module which did not check the return
value of register_netdevice_notifier. Add the checks now.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_netdev.c | 18 +++++++++++++-----
 net/netfilter/nfnetlink_queue.c  |  9 ++++++++-
 net/netfilter/xt_TEE.c           |  8 +++++++-
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 3e5475a833a5..38a3e8385042 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -151,12 +151,20 @@ static int __init nf_tables_netdev_init(void)
 
 	nft_register_chain_type(&nft_filter_chain_netdev);
 	ret = register_pernet_subsys(&nf_tables_netdev_net_ops);
-	if (ret < 0) {
-		nft_unregister_chain_type(&nft_filter_chain_netdev);
-		return ret;
-	}
-	register_netdevice_notifier(&nf_tables_netdev_notifier);
+	if (ret)
+		goto err1;
+
+	ret = register_netdevice_notifier(&nf_tables_netdev_notifier);
+	if (ret)
+		goto err2;
+
 	return 0;
+
+err2:
+	unregister_pernet_subsys(&nf_tables_netdev_net_ops);
+err1:
+	nft_unregister_chain_type(&nft_filter_chain_netdev);
+	return ret;
 }
 
 static void __exit nf_tables_netdev_exit(void)
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index f49f45081acb..808da34f94cd 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1522,9 +1522,16 @@ static int __init nfnetlink_queue_init(void)
 		goto cleanup_netlink_notifier;
 	}
 
-	register_netdevice_notifier(&nfqnl_dev_notifier);
+	status = register_netdevice_notifier(&nfqnl_dev_notifier);
+	if (status < 0) {
+		pr_err("nf_queue: failed to register netdevice notifier\n");
+		goto cleanup_netlink_subsys;
+	}
+
 	return status;
 
+cleanup_netlink_subsys:
+	nfnetlink_subsys_unregister(&nfqnl_subsys);
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
 	unregister_pernet_subsys(&nfnl_queue_net_ops);
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 6e57a3966dc5..0471db4032c5 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -89,6 +89,8 @@ static int tee_tg_check(const struct xt_tgchk_param *par)
 		return -EINVAL;
 
 	if (info->oif[0]) {
+		int ret;
+
 		if (info->oif[sizeof(info->oif)-1] != '\0')
 			return -EINVAL;
 
@@ -101,7 +103,11 @@ static int tee_tg_check(const struct xt_tgchk_param *par)
 		priv->notifier.notifier_call = tee_netdev_event;
 		info->priv    = priv;
 
-		register_netdevice_notifier(&priv->notifier);
+		ret = register_netdevice_notifier(&priv->notifier);
+		if (ret) {
+			kfree(priv);
+			return ret;
+		}
 	} else
 		info->priv = NULL;
 
-- 
2.1.4
