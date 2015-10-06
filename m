From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bridge/netfilter: avoid unused label warning
Date: Tue, 06 Oct 2015 21:22:12 +0200
Message-ID: <7985748.1v9Gzszd4T@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
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

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 370aa4d4cf4d..5c679ac5cdef 100644
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
@@ -691,9 +688,7 @@ static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(net, sk, skb);
 }
-#endif
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 static int
 br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		  int (*output)(struct net *, struct sock *, struct sk_buff *))
@@ -711,7 +706,6 @@ br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 	return ip_do_fragment(net, sk, skb, output);
 }
-#endif
 
 static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
@@ -734,11 +728,11 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 
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
@@ -760,9 +754,8 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 
 		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit);
 	}
-#endif
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
-	if (skb->protocol == htons(ETH_P_IPV6)) {
+	if (IS_ENABLED(CONFIG_NF_DEFRAG_IPV6) &&
+	    skb->protocol == htons(ETH_P_IPV6)) {
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 		struct brnf_frag_data *data;
 
@@ -786,7 +779,6 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
-#endif
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(net, sk, skb);
  drop:
