From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/32] net: ip_fragment: remove BRIDGE_NETFILTER mtu special handling
Date: Mon, 15 Jun 2015 23:26:06 +0200
Message-ID: <1434403589-24796-10-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

since commit d6b915e29f4adea9
("ip_fragment: don't forward defragmented DF packet") the largest
fragment size is available in the IPCB.

Therefore we no longer need to care about 'encapsulation'
overhead of stripped PPPOE/VLAN headers since ip_do_fragment
doesn't use device mtu in such cases.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |    7 -------
 net/bridge/br_netfilter.c        |    7 +++++++
 net/ipv4/ip_output.c             |    4 ----
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index f2fdb5a..6d80fc6 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -20,13 +20,6 @@ enum nf_br_hook_priorities {
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
 
-static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
-{
-	if (skb->nf_bridge->orig_proto == BRNF_PROTO_PPPOE)
-		return PPPOE_SES_HLEN;
-	return 0;
-}
-
 int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 535f9da..1e62ae5 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -936,6 +936,13 @@ static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
 	return ip_do_fragment(sk, skb, output);
 }
 
+static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
+{
+	if (skb->nf_bridge->orig_proto == BRNF_PROTO_PPPOE)
+		return PPPOE_SES_HLEN;
+	return 0;
+}
+
 static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f5f5ef1..19d7e43 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -549,10 +549,6 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 
 	hlen = iph->ihl * 4;
 	mtu = mtu - hlen;	/* Size of data space */
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge)
-		mtu -= nf_bridge_mtu_reduction(skb);
-#endif
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
-- 
1.7.10.4

