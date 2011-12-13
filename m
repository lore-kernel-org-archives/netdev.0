From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] rtnetlink: rtnl_link_register() sanity test
Date: Tue, 13 Dec 2011 22:38:00 +0100
Message-ID: <1323812280.2846.9.camel@edumazet-laptop>
References: <1323808281-9967-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <20111213.160810.785264274549847462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35823 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab1LMViH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 16:38:07 -0500
Received: by faar15 with SMTP id r15so662556faa.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 13:38:06 -0800 (PST)
In-Reply-To: <20111213.160810.785264274549847462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before adding a struct rtnl_link_ops into link_ops list, check it doesnt
clash with a prior one.

Based on a previous patch from Alexander Smirnov

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/core/rtnetlink.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9083e82..dbf2dda 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -273,6 +273,17 @@ EXPORT_SYMBOL_GPL(rtnl_unregister_all);
 
 static LIST_HEAD(link_ops);
 
+static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
+{
+	const struct rtnl_link_ops *ops;
+
+	list_for_each_entry(ops, &link_ops, list) {
+		if (!strcmp(ops->kind, kind))
+			return ops;
+	}
+	return NULL;
+}
+
 /**
  * __rtnl_link_register - Register rtnl_link_ops with rtnetlink.
  * @ops: struct rtnl_link_ops * to register
@@ -285,6 +296,9 @@ static LIST_HEAD(link_ops);
  */
 int __rtnl_link_register(struct rtnl_link_ops *ops)
 {
+	if (rtnl_link_ops_get(ops->kind))
+		return -EEXIST;
+
 	if (!ops->dellink)
 		ops->dellink = unregister_netdevice_queue;
 
@@ -351,17 +365,6 @@ void rtnl_link_unregister(struct rtnl_link_ops *ops)
 }
 EXPORT_SYMBOL_GPL(rtnl_link_unregister);
 
-static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
-{
-	const struct rtnl_link_ops *ops;
-
-	list_for_each_entry(ops, &link_ops, list) {
-		if (!strcmp(ops->kind, kind))
-			return ops;
-	}
-	return NULL;
-}
-
 static size_t rtnl_link_get_size(const struct net_device *dev)
 {
 	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
