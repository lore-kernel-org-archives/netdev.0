From: kaber@trash.net
Subject: [PATCH 4/8] IPVS: fix NULL ptr dereference in ip_vs_ctl.c ip_vs_genl_dump_daemons()
Date: Tue,  5 Apr 2011 15:04:15 +0200
Message-ID: <1302008659-21141-5-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

ipvsadm -ln --daemon will trigger a Null pointer exception because
ip_vs_genl_dump_daemons() uses skb_net() instead of skb_sknet().

To prevent others from NULL ptr a check is made in ip_vs.h skb_net().

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/ip_vs.h            |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 30b49ed..4d1b71a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -52,7 +52,7 @@ static inline struct net *skb_net(const struct sk_buff *skb)
 	 */
 	if (likely(skb->dev && skb->dev->nd_net))
 		return dev_net(skb->dev);
-	if (skb_dst(skb)->dev)
+	if (skb_dst(skb) && skb_dst(skb)->dev)
 		return dev_net(skb_dst(skb)->dev);
 	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
 		      __func__, __LINE__);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 33733c8..ae47090 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3120,7 +3120,7 @@ nla_put_failure:
 static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
-	struct net *net = skb_net(skb);
+	struct net *net = skb_sknet(skb);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&__ip_vs_mutex);
-- 
1.7.2.3

