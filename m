From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Sat, 24 May 2014 15:26:24 +0930
Message-ID: <53803488.6000400@davidnewall.com>
References: <537A6E5C.6090602@pandora.be>	<537C5A6C.3030809@davidnewall.com>	<537CF5A2.3080401@pandora.be> <20140521.161841.1806439174351824310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, stephen@networkplumber.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	Bandan Das <bsd@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>, bdschuym@pandora.be
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140521.161841.1806439174351824310.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/05/14 05:48, David Miller wrote:
> From: Bart De Schuymer<bdschuym@pandora.be>
> Date: Wed, 21 May 2014 20:51:14 +0200
> > There's no reason why they should overlap in the cb: it's 48 bytes
> > big, so big enough to hold both struct br_input_skb_cb and struct
> > inet_skb_parm. The original problem was introduced when
> > BR_INPUT_SKB_CB was introduced (around Feb 27, 2010), so fixing
> > BR_INPUT_SKB_CB seems most appropriate to me.
>
> So you are suggesting the patch below will fix everything?


First, of course I was wrong about ip overflowing the cb area.  Even I 
thought that was unlikely.  I've reread the code, much more carefully, 
and spotted where I went wrong.

I've added the change that David Miller provided, to those which I am 
proposing, and minimally tested them by pinging through a bridge with RR 
set.  No surprise: it works.

The patch now reverts the commit and mitigates the original problem by 
ensuring bridge's use of cb does not overlap ip's.

--- linux-source-3.13.0/net/bridge/br_netfilter.c.orig	2014-05-17 00:12:23.418906498 +0930
+++ linux-source-3.13.0/net/bridge/br_netfilter.c	2014-05-17 01:04:43.540972961 +0930
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
@@ -679,6 +612,7 @@ static unsigned int br_nf_pre_routing(co
  {
  	struct net_bridge_port *p;
  	struct net_bridge *br;
+	const struct iphdr *iph;
  	__u32 len = nf_bridge_encap_header_len(skb);
  
  	if (unlikely(!pskb_may_pull(skb, len)))
@@ -704,10 +638,30 @@ static unsigned int br_nf_pre_routing(co
  		return NF_ACCEPT;
  
  	nf_bridge_pull_encap_header_rcsum(skb);
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		return NF_DROP;
  
-	if (br_parse_ip_options(skb))
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return NF_DROP;
+
+	if (!pskb_may_pull(skb, 4 * iph->ihl))
  		return NF_DROP;
  
+	iph = ip_hdr(skb);
+	if (ip_fast_csum((__u8 *) iph, iph->ihl) != 0)
+		return NF_DROP;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len || len < 4 * iph->ihl)
+		return NF_DROP;
+
+	pskb_trim_rcsum(skb, len);
+
+	/* BUG: Should really parse the IP options here. */
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+
  	nf_bridge_put(skb->nf_bridge);
  	if (!nf_bridge_alloc(skb))
  		return NF_DROP;
@@ -806,9 +760,6 @@ static unsigned int br_nf_forward_ip(con
  		nf_bridge->mask |= BRNF_PKT_TYPE;
  	}
  
-	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
-		return NF_DROP;
-
  	/* The physdev module checks on this */
  	nf_bridge->mask |= BRNF_BRIDGED;
  	nf_bridge->physoutdev = skb->dev;
@@ -862,19 +813,14 @@ static unsigned int br_nf_forward_arp(co
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
--- linux-source-3.13.0/net/ipv4/ip_options.c.orig	2014-05-16 18:11:10.260370554 +0930
+++ linux-source-3.13.0/net/ipv4/ip_options.c	2014-05-17 01:01:56.738277137 +0930
@@ -475,7 +475,6 @@ error:
  	}
  	return -EINVAL;
  }
-EXPORT_SYMBOL(ip_options_compile);
  
  /*
   *	Undo all the changes done by ip_options_compile().
@@ -658,4 +657,3 @@ int ip_options_rcv_srr(struct sk_buff *s
  	}
  	return 0;
  }
-EXPORT_SYMBOL(ip_options_rcv_srr);
--- /usr/src/linux-source-3.13.0/net/bridge/br_private.h.orig	2014-05-24 13:51:09.269709831 +0930
+++ /usr/src/linux-source-3.13.0/net/bridge/br_private.h	2014-05-24 13:53:20.243551927 +0930
@@ -18,6 +18,7 @@
  #include <linux/netpoll.h>
  #include <linux/u64_stats_sync.h>
  #include <net/route.h>
+#include <net/ip.h>
  #include <linux/if_vlan.h>
  
  #define BR_HASH_BITS 8
@@ -304,6 +305,7 @@ struct net_bridge
  };
  
  struct br_input_skb_cb {
+	struct inet_skb_parm ip;	/* we don't interfere with ip's use of cb area */
  	struct net_device *brdev;
  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
  	int igmp;

