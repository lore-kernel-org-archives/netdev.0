From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] bridge/netfilter: avoid unused label warning
Date: Thu, 08 Oct 2015 14:30:15 +0200
Message-ID: <5180534.sSnu9AX8xS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the ARM mini2440_defconfig, the bridge netfilter code gets
built with both CONFIG_NF_DEFRAG_IPV4 and CONFIG_NF_DEFRAG_IPV6
disabled, which leads to a harmless gcc warning:

net/bridge/br_netfilter_hooks.c: In function 'br_nf_dev_queue_xmit':
net/bridge/br_netfilter_hooks.c:792:2: warning: label 'drop' defined but not used [-Wunused-label]

This gets rid of the warning by cleaning up the code to avoid
the respective #ifdefs causing this problem, and replacing them
with if(IS_ENABLED()) checks. I have verified that the resulting
object code is unchanged, and an additional advantage is that
we now get compile coverage of the unused functions in more
configurations.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: dd302b59bde0 ("netfilter: bridge: don't leak skb in error paths")
---
Version 2:

Rebased to git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 13f03671c88d..18905d4781db 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -111,7 +111,6 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 /* largest possible L2 header, see br_nf_dev_queue_xmit() */
 #define NF_BRIDGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) || IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 struct brnf_frag_data {
 	char mac[NF_BRIDGE_MAX_MAC_HEADER_LENGTH];
 	u8 encap_size;
@@ -121,7 +120,6 @@ struct brnf_frag_data {
 };
 
 static DEFINE_PER_CPU(struct brnf_frag_data, brnf_frag_data_storage);
-#endif
 
 static void nf_bridge_info_free(struct sk_buff *skb)
 {
@@ -666,7 +664,6 @@ static unsigned int br_nf_forward_arp(void *priv,
 	return NF_STOLEN;
 }
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) || IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct brnf_frag_data *data;
@@ -696,9 +693,7 @@ static int br_nf_push_frag_xmit_sk(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	return br_nf_push_frag_xmit(net, sk, skb);
 }
-#endif
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 static int
 br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		  int (*output)(struct sock *, struct sk_buff *))
@@ -716,7 +711,6 @@ br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 	return ip_do_fragment(sk, skb, output);
 }
-#endif
 
 static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
@@ -739,11 +733,11 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 
 	nf_bridge = nf_bridge_info_get(skb);
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) &&
+	    skb->protocol == htons(ETH_P_IP)) {
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv4(net, skb))
@@ -765,9 +759,8 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 
 		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit_sk);
 	}
-#endif
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
-	if (skb->protocol == htons(ETH_P_IPV6)) {
+	if (IS_ENABLED(CONFIG_NF_DEFRAG_IPV6) &&
+	    skb->protocol == htons(ETH_P_IPV6)) {
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 		struct brnf_frag_data *data;
 
@@ -791,7 +784,6 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
-#endif
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(net, sk, skb);
  drop:
