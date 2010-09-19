From: Bandan Das <bandan.das@stratus.com>
Subject: [PATCH net-next-2.6] bridge : Sanitize skb before it enters the IP
 stack
Date: Sun, 19 Sep 2010 15:34:33 -0400
Message-ID: <20100919193433.GF31036@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Related dicussion here : http://lkml.org/lkml/2010/9/3/16

Introduce a function br_parse_ip_options that will audit the 
skb and possibly refill IP options before a packet enters the
IP stack. If no options are present, the function will zero out
the skb cb area so that it is not misinterpreted as options by some
unsuspecting IP layer routine. If packet consistency fails, drop it.

Signed-off-by: Bandan Das <bandan.das@stratus.com>
---
 net/bridge/br_netfilter.c |  107 ++++++++++++++++++++++++++++++++------------
 net/ipv4/ip_options.c     |    3 +-
 2 files changed, 80 insertions(+), 30 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 137f232..77f7b5f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -209,6 +209,72 @@ static inline void nf_bridge_update_protocol(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_PPP_SES);
 }
 
+/* When handing a packet over to the IP layer
+ * check whether we have a skb that is in the
+ * expected format
+ */
+
+int br_parse_ip_options(struct sk_buff *skb)
+{
+	struct ip_options *opt;
+	struct iphdr *iph;
+	struct net_device *dev = skb->dev;
+	u32 len;
+
+	iph = ip_hdr(skb);
+	opt = &(IPCB(skb)->opt);
+
+	/* Basic sanity checks */
+	if (iph->ihl < 5 || iph->version != 4)
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		goto inhdr_error;
+
+	iph = ip_hdr(skb);
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		goto inhdr_error;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len) {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		goto drop;
+	} else if (len < (iph->ihl*4))
+		goto inhdr_error;
+
+	if (pskb_trim_rcsum(skb, len)) {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		goto drop;
+	}
+
+	/* Zero out the CB buffer if no options present */
+	if (iph->ihl == 5) {
+		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+		return 0;
+	}
+
+	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
+	if (ip_options_compile(dev_net(dev), opt, skb))
+		goto inhdr_error;
+
+	/* Check correct handling of SRR option */
+	if (unlikely(opt->srr)) {
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
+		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
+			goto drop;
+
+		if (ip_options_rcv_srr(skb))
+			goto drop;
+	}
+
+	return 0;
+
+inhdr_error:
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+drop:
+	return -1;
+}
+
 /* Fill in the header for fragmented IP packets handled by
  * the IPv4 connection tracking code.
  */
@@ -549,7 +615,6 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
-	struct iphdr *iph;
 	__u32 len = nf_bridge_encap_header_len(skb);
 
 	if (unlikely(!pskb_may_pull(skb, len)))
@@ -578,28 +643,9 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 
 	nf_bridge_pull_encap_header_rcsum(skb);
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto inhdr_error;
-
-	iph = ip_hdr(skb);
-	if (iph->ihl < 5 || iph->version != 4)
-		goto inhdr_error;
-
-	if (!pskb_may_pull(skb, 4 * iph->ihl))
-		goto inhdr_error;
-
-	iph = ip_hdr(skb);
-	if (ip_fast_csum((__u8 *) iph, iph->ihl) != 0)
-		goto inhdr_error;
-
-	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < 4 * iph->ihl)
-		goto inhdr_error;
-
-	pskb_trim_rcsum(skb, len);
-
-	/* BUG: Should really parse the IP options here. */
-	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	if (br_parse_ip_options(skb))
+		/* Drop invalid packet */
+		goto out;
 
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
@@ -614,8 +660,6 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 
 	return NF_STOLEN;
 
-inhdr_error:
-//      IP_INC_STATS_BH(IpInHdrErrors);
 out:
 	return NF_DROP;
 }
@@ -759,14 +803,19 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 #if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_IPV4_MODULE)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
+	int ret;
+
 	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
 	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
 	    !skb_is_gso(skb)) {
-		/* BUG: Should really parse the IP options here. */
-		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-		return ip_fragment(skb, br_dev_queue_push_xmit);
+		if (br_parse_ip_options(skb))
+			/* Drop invalid packet */
+			return NF_DROP;
+		ret = ip_fragment(skb, br_dev_queue_push_xmit);
 	} else
-		return br_dev_queue_push_xmit(skb);
+		ret = br_dev_queue_push_xmit(skb);
+
+	return ret;
 }
 #else
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ba9836c..1906fa3 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -466,7 +466,7 @@ error:
 	}
 	return -EINVAL;
 }
-
+EXPORT_SYMBOL(ip_options_compile);
 
 /*
  *	Undo all the changes done by ip_options_compile().
@@ -646,3 +646,4 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ip_options_rcv_srr);
-- 
1.6.6.1
