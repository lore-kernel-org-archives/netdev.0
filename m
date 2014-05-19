From: David Newall <davidn@davidnewall.com>
Subject: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Mon, 19 May 2014 22:28:37 +0930
Message-ID: <5379FFFD.1050705@davidnewall.com>
References: <537621AC.1060409@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:56248 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbaESM6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 08:58:43 -0400
In-Reply-To: <537621AC.1060409@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having received no feedback of substance from netdev, I now address my 
previous email to a wider audience for discussion and in preparation for 
submitting a patch based closely on that below.

This email is not addressed to Bandan Das <bandan.das@stratus.com>, who 
is the author of the commit I propose reverting, as his email address is 
no longer current.  I believe I have otherwise addressed all appropriate 
recipients and will circulate a formal patch to the same recipients if 
no adverse comments are received.  (That would surprise me.)


-------- Original Message --------
Subject: 	Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : 
Sanitize skb before it enters the IP stack)
Date: 	Sat, 17 May 2014 00:03:16 +0930
From: 	David Newall <davidn@davidnewall.com>
To: 	Lukas Tribus <luky-37@hotmail.com>, Eric Dumazet 
<eric.dumazet@gmail.com>, Netdev <netdev@vger.kernel.org>
CC: 	fw@strlen.de <fw@strlen.de>



We should revert commit 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge
: Sanitize skb before it enters the IP stack) because it corrupts IP
packets with RR or TS options set, only partially updating the IP header
and leaving an incorrect checksum.

The argument for introducing the change is at lkml.org/lkml/2010/8/30/391:

The bridge layer can overwrite the IPCB using the
BR_INPUT_SKB_CB macro. In br_nf_dev_queue_xmit,
if we recieve a packet greater in size than the bridge
device MTU, we call ip_fragment which in turn will lead to
icmp_send calling ip_options_echo if the DF flag is set.
ip_options_echo will then incorrectly try to parse the IPCB as
IP options resulting in a buffer overflow.
This change refills the CB area back with IP
options before ip_fragment calls icmp_send. If we fail parsing,
we zero out the IPCB area to guarantee that the stack does
not get corrupted.

A bridge should not fragment packets; an *ethernet* bridge should not
need to.  Fragmenting packets is the job of higher level protocol.

--- br_netfilter.c	2014-01-20 13:10:07.000000000 +1030
+++ br_netfilter.c.prop	2014-05-16 23:07:57.975386905 +0930
@@ -253,73 +253,6 @@
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
@@ -679,6 +612,7 @@
  {
  	struct net_bridge_port *p;
  	struct net_bridge *br;
+	const struct iphdr *iph;
  	__u32 len = nf_bridge_encap_header_len(skb);
  
  	if (unlikely(!pskb_may_pull(skb, len)))
@@ -704,9 +638,29 @@
  		return NF_ACCEPT;
  
  	nf_bridge_pull_encap_header_rcsum(skb);
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
  
-	if (br_parse_ip_options(skb))
-		return NF_DROP;
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
+	if (skb->len < len || len < 4 * iph->ihl)
+		goto inhdr_error;
+
+	pskb_trim_rcsum(skb, len);
+
+	/* BUG: Should really parse the IP options here. */
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
  
  	nf_bridge_put(skb->nf_bridge);
  	if (!nf_bridge_alloc(skb))
@@ -720,6 +674,10 @@
  		br_nf_pre_routing_finish);
  
  	return NF_STOLEN;
+
+inhdr_error:
+//      IP_INC_STATS_BH(IpInHdrErrors);
+	return NF_DROP;
  }
  
  
@@ -806,9 +764,6 @@
  		nf_bridge->mask |= BRNF_PKT_TYPE;
  	}
  
-	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
-		return NF_DROP;
-
  	/* The physdev module checks on this */
  	nf_bridge->mask |= BRNF_BRIDGED;
  	nf_bridge->physoutdev = skb->dev;
@@ -862,19 +817,14 @@
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
