From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Fri, 30 May 2014 18:47:58 +0930
Message-ID: <53884CC6.2000000@davidnewall.com>
References: <53803488.6000400@davidnewall.com>	<20140524.134356.992924324126016022.davem@davemloft.net>	<53815623.8020506@davidnewall.com> <20140529.153424.1310751217059624351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, fw@strlen.de, stephen@networkplumber.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org, bsd@redhat.com,
	vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140529.153424.1310751217059624351.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/05/14 08:04, David Miller wrote:
> You really need to check the return value as this can perform allocations,
> GFP_ATOMIC ones in fact.
>
> Also, why are we not bumping the statistics any more?  I didn't see a
> discussion of that in this thread.

I was only restoring the code as it was before the commit.  Maybe this, 
(instead of the previous patch of br_netfilter.c,) to keep the (added) 
check on pskb_may_pull's return value and incremented statistics?

--- br_netfilter.c	2014-05-30 18:01:40.221868365 +0930
+++ br_netfilter.c.orig	2014-05-30 18:17:39.697425383 +0930
@@ -253,73 +253,6 @@ static inline void nf_bridge_update_prot
  		skb->protocol = htons(ETH_P_PPP_SES);
  }
  
-/* When handing a packet over to the IP layer
- * check whether we have a skb that is in the
- * expected format
- */
-
-static int br_parse_ip_options(struct sk_buff *skb)
-{
-	struct ip_options *opt;
-	const struct iphdr *iph;
-	struct net_device *dev = skb->dev;
-	u32 len;
-
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto inhdr_error;
-
-	iph = ip_hdr(skb);
-	opt = &(IPCB(skb)->opt);
-
-	/* Basic sanity checks */
-	if (iph->ihl < 5 || iph->version != 4)
-		goto inhdr_error;
-
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		goto inhdr_error;
-
-	iph = ip_hdr(skb);
-	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
-		goto inhdr_error;
-
-	len = ntohs(iph->tot_len);
-	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
-		goto drop;
-	} else if (len < (iph->ihl*4))
-		goto inhdr_error;
-
-	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
-		goto drop;
-	}
-
-	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-	if (iph->ihl == 5)
-		return 0;
-
-	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
-	if (ip_options_compile(dev_net(dev), opt, skb))
-		goto inhdr_error;
-
-	/* Check correct handling of SRR option */
-	if (unlikely(opt->srr)) {
-		struct in_device *in_dev = __in_dev_get_rcu(dev);
-		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
-			goto drop;
-
-		if (ip_options_rcv_srr(skb))
-			goto drop;
-	}
-
-	return 0;
-
-inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
-drop:
-	return -1;
-}
-
  /* Fill in the header for fragmented IP packets handled by
   * the IPv4 connection tracking code.
   */
@@ -679,6 +612,8 @@ static unsigned int br_nf_pre_routing(co
  {
  	struct net_bridge_port *p;
  	struct net_bridge *br;
+	const struct iphdr *iph;
+	struct net_device *dev = skb->dev;
  	__u32 len = nf_bridge_encap_header_len(skb);
  
  	if (unlikely(!pskb_may_pull(skb, len)))
@@ -704,9 +639,35 @@ static unsigned int br_nf_pre_routing(co
  		return NF_ACCEPT;
  
  	nf_bridge_pull_encap_header_rcsum(skb);
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
+
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, 4 * iph->ihl))
+		goto inhdr_error;
+
+	iph = ip_hdr(skb);
+	if (ip_fast_csum((__u8 *) iph, iph->ihl) != 0)
+		goto inhdr_error;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len) {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		return NF_DROP;
+	} else if (len < (iph->ihl*4))
+		goto inhdr_error;
  
-	if (br_parse_ip_options(skb))
+	if (pskb_trim_rcsum(skb, len)) {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
  		return NF_DROP;
+	}
+
+	/* BUG: Should really parse the IP options here. */
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
  
  	nf_bridge_put(skb->nf_bridge);
  	if (!nf_bridge_alloc(skb))
@@ -720,6 +681,10 @@ static unsigned int br_nf_pre_routing(co
  		br_nf_pre_routing_finish);
  
  	return NF_STOLEN;
+
+inhdr_error:
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	return NF_DROP;
  }
  
  
@@ -806,9 +771,6 @@ static unsigned int br_nf_forward_ip(con
  		nf_bridge->mask |= BRNF_PKT_TYPE;
  	}
  
-	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
-		return NF_DROP;
-
  	/* The physdev module checks on this */
  	nf_bridge->mask |= BRNF_BRIDGED;
  	nf_bridge->physoutdev = skb->dev;
@@ -862,19 +824,14 @@ static unsigned int br_nf_forward_arp(co
  #if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV4)
  static int br_nf_dev_queue_xmit(struct sk_buff *skb)
  {
-	int ret;
-
  	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
  	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
  	    !skb_is_gso(skb)) {
-		if (br_parse_ip_options(skb))
-			/* Drop invalid packet */
-			return NF_DROP;
-		ret = ip_fragment(skb, br_dev_queue_push_xmit);
+		/* BUG: Should really parse the IP options here. */
+		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+		return ip_fragment(skb, br_dev_queue_push_xmit);
  	} else
-		ret = br_dev_queue_push_xmit(skb);
-
-	return ret;
+		return br_dev_queue_push_xmit(skb);
  }
  #else
  static int br_nf_dev_queue_xmit(struct sk_buff *skb)

