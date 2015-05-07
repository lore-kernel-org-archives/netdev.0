From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 3/7] netns: rename peernet2id() to peernet2id_alloc()
Date: Thu,  7 May 2015 11:02:49 +0200
Message-ID: <1430989373-4515-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: tgraf@suug.ch, davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43499 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbEGJDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:03:04 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a following commit, a new function will be introduced to only lookup for
a nsid (no allocation if the nsid doesn't exist). To avoid confusion, the
existing function is renamed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---

v2: no change

 drivers/net/vxlan.c         | 2 +-
 include/net/net_namespace.h | 2 +-
 net/core/net_namespace.c    | 4 ++--
 net/core/rtnetlink.c        | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3517ab0aa803..48341ae49012 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -336,7 +336,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (!net_eq(dev_net(vxlan->dev), vxlan->net) &&
 	    nla_put_s32(skb, NDA_LINK_NETNSID,
-			peernet2id(dev_net(vxlan->dev), vxlan->net)))
+			peernet2id_alloc(dev_net(vxlan->dev), vxlan->net)))
 		goto nla_put_failure;
 
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index f733656404de..6d1e2eae32fb 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -271,7 +271,7 @@ static inline struct net *read_pnet(const possible_net_t *pnet)
 #define __net_initconst	__initconst
 #endif
 
-int peernet2id(struct net *net, struct net *peer);
+int peernet2id_alloc(struct net *net, struct net *peer);
 struct net *get_net_ns_by_id(struct net *net, int id);
 
 struct pernet_operations {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 37c68bb72db3..9c806ac569f9 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -202,13 +202,13 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
 /* This function returns the id of a peer netns. If no id is assigned, one will
  * be allocated and returned.
  */
-int peernet2id(struct net *net, struct net *peer)
+int peernet2id_alloc(struct net *net, struct net *peer)
 {
 	bool alloc = atomic_read(&peer->count) == 0 ? false : true;
 
 	return __peernet2id(net, peer, alloc);
 }
-EXPORT_SYMBOL(peernet2id);
+EXPORT_SYMBOL(peernet2id_alloc);
 
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 666e0928ba40..83e08323fdcd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1204,7 +1204,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
 
 		if (!net_eq(dev_net(dev), link_net)) {
-			int id = peernet2id(dev_net(dev), link_net);
+			int id = peernet2id_alloc(dev_net(dev), link_net);
 
 			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
 				goto nla_put_failure;
-- 
2.2.2
