From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] gretap: don't do MTU discovery
Date: Fri, 26 Oct 2012 16:05:15 -0700
Message-ID: <20121026160515.1f37592e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34318 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934216Ab2JZXGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 19:06:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This came up during review of VXLAN.

Since gretap is a L2 tunnel, and it is not necessarily in the same IP
network space as there is no way to safely do MTU discovery.
The IP address in the inner header may not be reachable or conflict
with the IP address visible to the kernel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ip_gre.c	2012-10-26 15:50:39.579955151 -0700
+++ b/net/ipv4/ip_gre.c	2012-10-26 15:58:31.667213979 -0700
@@ -765,7 +765,6 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    gre_hlen;
 	__be32 dst;
-	int    mtu;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    skb_checksum_help(skb))
@@ -853,44 +852,54 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 	}
 
 	df = tiph->frag_off;
-	if (df)
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len - tunnel->hlen;
-	else
-		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
-
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-
-	if (skb->protocol == htons(ETH_P_IP)) {
-		df |= (old_iph->frag_off&htons(IP_DF));
-
-		if ((old_iph->frag_off&htons(IP_DF)) &&
-		    mtu < ntohs(old_iph->tot_len)) {
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
-			goto tx_error;
+	if (dev->type == ARPHRD_IPGRE) {
+		unsigned int mtu;
+
+		if (df)
+			mtu = dst_mtu(&rt->dst)
+				- dev->hard_header_len - tunnel->hlen;
+		else
+			mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
+
+		if (skb_dst(skb))
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb),
+						       NULL, skb, mtu);
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			df |= (old_iph->frag_off&htons(IP_DF));
+
+			if ((old_iph->frag_off&htons(IP_DF)) &&
+			    mtu < ntohs(old_iph->tot_len)) {
+				icmp_send(skb, ICMP_DEST_UNREACH,
+					  ICMP_FRAG_NEEDED, htonl(mtu));
+				ip_rt_put(rt);
+				goto tx_error;
+			}
 		}
-	}
 #if IS_ENABLED(CONFIG_IPV6)
-	else if (skb->protocol == htons(ETH_P_IPV6)) {
-		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
-		if (rt6 && mtu < dst_mtu(skb_dst(skb)) && mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr &&
-			     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
-			    rt6->rt6i_dst.plen == 128) {
-				rt6->rt6i_flags |= RTF_MODIFIED;
-				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
+			if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
+			    mtu >= IPV6_MIN_MTU) {
+				if ((tunnel->parms.iph.daddr &&
+				     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+				    rt6->rt6i_dst.plen == 128) {
+					rt6->rt6i_flags |= RTF_MODIFIED;
+					dst_metric_set(skb_dst(skb),
+						       RTAX_MTU, mtu);
+				}
 			}
-		}
 
-		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-			ip_rt_put(rt);
-			goto tx_error;
+			if (mtu >= IPV6_MIN_MTU &&
+			    mtu < skb->len - tunnel->hlen + gre_hlen) {
+				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+				ip_rt_put(rt);
+				goto tx_error;
+			}
 		}
-	}
 #endif
+	}
 
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
