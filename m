From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 1/7] netns: returns always an id in __peernet2id()
Date: Thu,  7 May 2015 11:02:47 +0200
Message-ID: <1430989373-4515-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: tgraf@suug.ch, davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43486 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbEGJDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:03:04 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All callers of this function expect a nsid, not an error.
Thus, returns NETNSA_NSID_NOT_ASSIGNED in case of error so that callers
don't have to convert the error to NETNSA_NSID_NOT_ASSIGNED.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---

v2: reword the commit log

 net/core/net_namespace.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04ad36fc..294d38742e2a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -192,10 +192,12 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
 	if (id > 0)
 		return id;
 
-	if (alloc)
-		return alloc_netid(net, peer, -1);
+	if (alloc) {
+		id = alloc_netid(net, peer, -1);
+		return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
+	}
 
-	return -ENOENT;
+	return NETNSA_NSID_NOT_ASSIGNED;
 }
 
 /* This function returns the id of a peer netns. If no id is assigned, one will
@@ -204,10 +206,8 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
 int peernet2id(struct net *net, struct net *peer)
 {
 	bool alloc = atomic_read(&peer->count) == 0 ? false : true;
-	int id;
 
-	id = __peernet2id(net, peer, alloc);
-	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
+	return __peernet2id(net, peer, alloc);
 }
 EXPORT_SYMBOL(peernet2id);
 
@@ -554,13 +554,10 @@ static int rtnl_net_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
 	rth = nlmsg_data(nlh);
 	rth->rtgen_family = AF_UNSPEC;
 
-	if (nsid >= 0) {
+	if (nsid >= 0)
 		id = nsid;
-	} else {
+	else
 		id = __peernet2id(net, peer, false);
-		if  (id < 0)
-			id = NETNSA_NSID_NOT_ASSIGNED;
-	}
 	if (nla_put_s32(skb, NETNSA_NSID, id))
 		goto nla_put_failure;
 
-- 
2.2.2
