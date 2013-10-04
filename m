From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/33] netfilter: xt_TCPMSS: lookup route from proper net namespace
Date: Fri,  4 Oct 2013 10:32:48 +0200
Message-ID: <1380875598-5250-4-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Otherwise the pmtu will be incorrect.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 62776de..e762de5 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -43,7 +43,8 @@ optlen(const u_int8_t *opt, unsigned int offset)
 		return opt[offset+1];
 }
 
-static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
+static u_int32_t tcpmss_reverse_mtu(struct net *net,
+				    const struct sk_buff *skb,
 				    unsigned int family)
 {
 	struct flowi fl;
@@ -64,7 +65,7 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
 	if (ai != NULL)
-		ai->route(&init_net, (struct dst_entry **)&rt, &fl, false);
+		ai->route(net, (struct dst_entry **)&rt, &fl, false);
 	rcu_read_unlock();
 
 	if (rt != NULL) {
@@ -107,7 +108,8 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		unsigned int in_mtu = tcpmss_reverse_mtu(skb, family);
+		struct net *net = dev_net(par->in ? par->in : par->out);
+		unsigned int in_mtu = tcpmss_reverse_mtu(net, skb, family);
 
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			net_err_ratelimited("unknown or invalid path-MTU (%u)\n",
-- 
1.7.10.4

