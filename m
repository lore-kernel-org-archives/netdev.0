From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/23] nfnetlink: add nfnl_dereference_protected helper
Date: Fri, 18 Dec 2015 21:26:48 +0100
Message-ID: <1450470409-31427-23-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57993 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965226AbbLRUeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9CBA310226E
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5EF51DA860
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C471BDA861
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:08 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

to avoid overly long line in followup patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 28591fa..aebf5cd 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -33,6 +33,10 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NETFILTER);
 
+#define nfnl_dereference_protected(id) \
+	rcu_dereference_protected(table[(id)].subsys, \
+				  lockdep_nfnl_is_held((id)))
+
 static char __initdata nfversion[] = "0.30";
 
 static struct {
@@ -208,8 +212,7 @@ replay:
 		} else {
 			rcu_read_unlock();
 			nfnl_lock(subsys_id);
-			if (rcu_dereference_protected(table[subsys_id].subsys,
-				lockdep_is_held(&table[subsys_id].mutex)) != ss ||
+			if (nfnl_dereference_protected(subsys_id) != ss ||
 			    nfnetlink_find_client(type, ss) != nc)
 				err = -EAGAIN;
 			else if (nc->call)
@@ -299,15 +302,13 @@ replay:
 	skb->sk = oskb->sk;
 
 	nfnl_lock(subsys_id);
-	ss = rcu_dereference_protected(table[subsys_id].subsys,
-				       lockdep_is_held(&table[subsys_id].mutex));
+	ss = nfnl_dereference_protected(subsys_id);
 	if (!ss) {
 #ifdef CONFIG_MODULES
 		nfnl_unlock(subsys_id);
 		request_module("nfnetlink-subsys-%d", subsys_id);
 		nfnl_lock(subsys_id);
-		ss = rcu_dereference_protected(table[subsys_id].subsys,
-					       lockdep_is_held(&table[subsys_id].mutex));
+		ss = nfnl_dereference_protected(subsys_id);
 		if (!ss)
 #endif
 		{
-- 
2.1.4
