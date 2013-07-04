From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] net namespace: wrap for_each_net with rtnl_lock
Date: Thu, 4 Jul 2013 14:20:55 +0800
Message-ID: <1372918855-3815-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <serge.hallyn@canonical.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61370 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab3GDGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 02:21:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The read access to net_namespace_list with for_each_net should always
be protected with rtnl_lock agiast any adding/removing operation from
the list.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/net_namespace.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f976520..f3808ff 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -445,12 +445,14 @@ static int __register_pernet_operations(struct list_head *list,
 
 	list_add_tail(&ops->list, list);
 	if (ops->init || (ops->id && ops->size)) {
+		rtnl_lock();
 		for_each_net(net) {
 			error = ops_init(ops, net);
 			if (error)
 				goto out_undo;
 			list_add_tail(&net->exit_list, &net_exit_list);
 		}
+		rtnl_unlock();
 	}
 	return 0;
 
@@ -468,8 +470,10 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
 	LIST_HEAD(net_exit_list);
 
 	list_del(&ops->list);
+	rtnl_lock();
 	for_each_net(net)
 		list_add_tail(&net->exit_list, &net_exit_list);
+	rtnl_unlock();
 	ops_exit_list(ops, &net_exit_list);
 	ops_free_list(ops, &net_exit_list);
 }
-- 
1.7.1
