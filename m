From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] bridge: drop netfilter fake rtable unconditionally
Date: Mon, 13 Mar 2017 17:38:17 +0100
Message-ID: <20170313163817.24447-1-fw@strlen.de>
Cc: <netfilter-devel@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas reports kernel oops during rmmod of the br_netfilter module.
Hannes debugged the oops down to a NULL rt6info->rt6i_indev.

Problem is that br_netfilter has the nasty concept of adding a fake
rtable to skb->dst; this happens in a br_netfilter prerouting hook.

A second hook (in bridge LOCAL_IN) is supposed to remove these again
before the skb is handed up the stack.

However, on module unload hooks get unregistered which means an
skb could traverse the prerouting hook that attaches the fake_rtable,
while the 'fake rtable remove' hook gets removed from the hooklist
immediately after.

Fixes: 34666d467cbf1e2e3c7 ("netfilter: bridge: move br_netfilter out of the core")
Reported-by: Andreas Karis <akaris@redhat.com>
Debugged-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 David, I know you *love* the fake_rtable turd, but I think
 this patch should go directly via net and not nf tree.
 After all, this adds to bridge and removes from the netfilter part.

 net/bridge/br_input.c           |  1 +
 net/bridge/br_netfilter_hooks.c | 21 ---------------------
 2 files changed, 1 insertion(+), 21 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 236f34244dbe..013f2290bfa5 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -30,6 +30,7 @@ EXPORT_SYMBOL(br_should_route_hook);
 static int
 br_netif_receive_skb(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	br_drop_fake_rtable(skb);
 	return netif_receive_skb(skb);
 }
 
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 95087e6e8258..fa87fbd62bb7 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -521,21 +521,6 @@ static unsigned int br_nf_pre_routing(void *priv,
 }
 
 
-/* PF_BRIDGE/LOCAL_IN ************************************************/
-/* The packet is locally destined, which requires a real
- * dst_entry, so detach the fake one.  On the way up, the
- * packet would pass through PRE_ROUTING again (which already
- * took place when the packet entered the bridge), but we
- * register an IPv4 PRE_ROUTING 'sabotage' hook that will
- * prevent this from happening. */
-static unsigned int br_nf_local_in(void *priv,
-				   struct sk_buff *skb,
-				   const struct nf_hook_state *state)
-{
-	br_drop_fake_rtable(skb);
-	return NF_ACCEPT;
-}
-
 /* PF_BRIDGE/FORWARD *************************************************/
 static int br_nf_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -908,12 +893,6 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
-		.hook = br_nf_local_in,
-		.pf = NFPROTO_BRIDGE,
-		.hooknum = NF_BR_LOCAL_IN,
-		.priority = NF_BR_PRI_BRNF,
-	},
-	{
 		.hook = br_nf_forward_ip,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_FORWARD,
-- 
2.10.2

