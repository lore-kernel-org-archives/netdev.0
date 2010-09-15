From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Wed, 15 Sep 2010 13:32:09 -0400
Message-ID: <20100915173209.GB9086@stratus.com>
References: <20100830200917.GA10754@stratus.com>
 <1283204118.2405.32.camel@edumazet-laptop>
 <20100830232147.GB10754@stratus.com>
 <1283232031.2405.38.camel@edumazet-laptop>
 <20100831082444.GB29281@gondor.apana.org.au>
 <1283246271.2550.35.camel@edumazet-laptop>
 <20100831123641.GA31017@gondor.apana.org.au>
 <20100901165743.GB17843@stratus.com>
 <20100903044941.GA28300@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bandan Das <bandan.das@stratus.com>, bunk@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100903044941.GA28300@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On  0, Herbert Xu <herbert@gondor.hengli.com.au> wrote:
> 
> 1. Only parse options if ihl > 5.
> 2. Please audit the IP stack to ensure that this does not mangle
> the packet.  We should not write to the packet here.
> 3. Please check whether SRR is handled correctly (see ip_rcv_options).
> 
> This should go into a helper function as this isn't the only entry
> point from the bridge into the IP stack.
> 
> Also it may be worth considering whether we should replace
> ip_fragment here with something that only refragments a frag_list
> since the only time we want to fragment here is if we reassembled
> an IP datagram due to netfilter.
> 
Sorry for the late response. Here's a patch that I put up based on Herbert's
suggestions. I ofcourse don't see the problem anymore after 
commit 87f94b4e91dc042620c527f3c30c37e5127ef757 but a generic helper such as this 
can be used anytime the bridge code is sending a packet over to the IP layer. 
Compile tested only but based on responses, will test it before submitting a 
final change. Also added it at two places where I know we do send a packet over to
the IP layer. I will add it at other places later as I come across them.


diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 137f232..0a1f929 100644
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
+	if(unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		goto inhdr_error;
+
+	len = ntohs(iph->tot_len);
+	if(skb->len < len) {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		goto drop;
+	} else if (len < (iph->ihl*4))
+		goto inhdr_error;
+
+	if (pskb_trim_rcsum(skb, len)){
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		goto drop;
+	}
+
+	/* Zero out the CB buffer if no options present */
+	if (iph->ihl == 5){
+		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+		return 0;
+	}
+
+	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
+	if(ip_options_compile(dev_net(dev), opt, skb))
+		goto inhdr_error;
+
+	/* Check correct handling of SRR option */
+	if (unlikely(opt->srr)) {
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
+		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
+			goto drop;
+
+		if(ip_options_rcv_srr(skb))
+			goto drop;
+	}
+
+	return 0;
+
+ inhdr_error:
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+ drop:
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
+		if(br_parse_ip_options(skb))
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
Bandan
