From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 15/15] ipv6: Pass struct net into nf_ct_frag6_gather
Date: Sun, 14 Jun 2015 22:13:13 -0500
Message-ID: <1434337993-6248-15-git-send-email-ebiederm@xmission.com>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make it explicit which network namespace the packets are being
reassembled in, don't make nf_cf_frag6_gather guess.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h | 2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c     | 4 +---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c   | 3 ++-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index 27666d8a0bd0..fb7da5bb76cc 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -5,7 +5,7 @@ void nf_defrag_ipv6_enable(void);
 
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
-struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
+struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user);
 void nf_ct_frag6_consume_orig(struct sk_buff *skb);
 
 struct inet_frags_ctl;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6f187c8d8a1b..05b07d25012c 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -563,12 +563,10 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 	return 0;
 }
 
-struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
+struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct sk_buff *clone;
 	struct net_device *dev = skb->dev;
-	struct net *net = skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
-				       : dev_net(skb->dev);
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 8f656cc141f5..5f443551a6d5 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -64,7 +64,8 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 #endif
 
-	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(state->hook, skb));
+	reasm = nf_ct_frag6_gather(state->net, skb,
+				   nf_ct6_defrag_user(state->hook, skb));
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
-- 
2.2.1

