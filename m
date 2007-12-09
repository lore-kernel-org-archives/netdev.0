From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] [IPSEC]: Reinject packet instead of calling
	netfilter directly on input
Date: Sat, 08 Dec 2007 20:01:28 -0500
Message-ID: <1197162088.5528.12.camel@localhost>
References: <1196369374.4437.18.camel@localhost>
	 <20071203092144.GB22869@gondor.apana.org.au>
	 <1196685255.4515.11.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RqVYu4sDcCq08lNVF+tV"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:28337 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbXLIBBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 20:01:47 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2395710wah
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2007 17:01:46 -0800 (PST)
In-Reply-To: <1196685255.4515.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RqVYu4sDcCq08lNVF+tV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-03-12 at 07:34 -0500, jamal wrote:

> The point brought up on v6 extensions needs to be addressed. I thought
> about it a little - and it is valid as well for ipv4 options; they will
> be processed twice.
> To build up on what Patrick said, I noticed a bit still available in the
> bag right after skb->nf_trace that i could use to signal
> "options/extensions already processed". 
> If people think think this is a sane use of that very lonely bit, I will
> post patches.

And the patch included demonstrates the thought (I thought i had sent it
to the list on monday; seems only to Yoshfuji). Note, blah is not a
proper name, just an emphasis.

cheers,
jama

--=-RqVYu4sDcCq08lNVF+tV
Content-Disposition: attachment; filename=v4v6-reinject
Content-Type: text/x-patch; name=v4v6-reinject; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d39f53e..78ac7d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -288,7 +288,8 @@ struct sk_buff {
 	__u8			pkt_type:3,
 				fclone:2,
 				ipvs_property:1,
-				nf_trace:1;
+				nf_trace:1,
+				blah:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6bfc8c8..da7788f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -437,6 +437,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+	new->blah		= old->blah;
 	skb_copy_secmark(new, old);
 }
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6563139..6e1e4b0 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -348,9 +348,10 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	}
 #endif
 
-	if (iph->ihl > 5 && ip_rcv_options(skb))
+	if (iph->ihl > 5 || (!skb->blah && ip_rcv_options(skb)))
 		goto drop;
 
+	skb->blah = 1;
 	rt = (struct rtable*)skb->dst;
 	if (rt->rt_type == RTN_MULTICAST)
 		IP_INC_STATS_BH(IPSTATS_MIB_INMCASTPKTS);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 0c377a6..1271668 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -50,20 +50,25 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 
 	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+	if (async)
+		return xfrm4_rcv_encap_finish(skb);
+
 	__skb_push(skb, skb->data - skb_network_header(skb));
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-		xfrm4_rcv_encap_finish);
-	return 0;
-#else
-	if (async)
-		return xfrm4_rcv_encap_finish(skb);
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	{
+		/* make some packet-sock user (eg tcpdump) happy */
+		const unsigned char *old_mac;
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 
-	return -iph->protocol;
-#endif
+	netif_rx(skb);
+	return 0;
 }
 
 /* If it's a keepalive packet, then just eat it.
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 178aebc..2a573e7 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -158,6 +158,9 @@ static int ip6_input_finish(struct sk_buff *skb)
 	u8 hash;
 	struct inet6_dev *idev;
 
+	if (skb->blah)
+		goto ext_parse_done;
+
 	/*
 	 *	Parse extension headers
 	 */
@@ -215,6 +218,9 @@ resubmit:
 		kfree_skb(skb);
 	}
 	rcu_read_unlock();
+
+	skb->blah = 1;
+ext_parse_done:
 	return 0;
 
 discard:
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index e2c3efd..c741fba 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -33,19 +33,24 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
 		XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+	if (async)
+		return ip6_rcv_finish(skb);
+
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-		ip6_rcv_finish);
-	return -1;
-#else
-	if (async)
-		return ip6_rcv_finish(skb);
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	{
+		/* make some packet-sock user (eg tcpdump) happy */
+		const unsigned char *old_mac;
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 
-	return 1;
-#endif
+	netif_rx(skb);
+	return 0;
 }
 
 int xfrm6_rcv(struct sk_buff *skb)

--=-RqVYu4sDcCq08lNVF+tV--

