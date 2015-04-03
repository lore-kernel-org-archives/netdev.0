From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] netns: don't allocate an id for dead netns
Date: Fri,  3 Apr 2015 12:02:37 +0200
Message-ID: <1428055357-15289-2-git-send-email-nicolas.dichtel@6wind.com>
References: <551E63B9.9050208@6wind.com>
 <1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57420 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbbDCKC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 06:02:58 -0400
In-Reply-To: <1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, let's explain the problem.
Suppose you have an ipip interface that stands in the netns foo and its link
part in the netns bar (so the netns bar has an nsid into the netns foo).
Now, you remove the netns bar:
 - the bar nsid into the netns foo is removed
 - the netns exit method of ipip is called, thus our ipip iface is removed:
   => a netlink message is built in the netns foo to advertise this deletion
   => this netlink message requests an nsid for bar, thus a new nsid is
      allocated for bar and never removed.

This patch adds a check in peernet2id() so that an id cannot be allocated for
a netns which is currently destroyed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index cb5290b8c428..70d3450588b2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -198,8 +198,10 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
  */
 int peernet2id(struct net *net, struct net *peer)
 {
-	int id = __peernet2id(net, peer, true);
+	bool alloc = atomic_read(&peer->count) == 0 ? false : true;
+	int id;
 
+	id = __peernet2id(net, peer, alloc);
 	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
 }
 EXPORT_SYMBOL(peernet2id);
-- 
2.2.2
