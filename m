From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Wed, 20 Jan 2010 21:21:06 +0000
Message-ID: <4B5773C2.2010000@simon.arlott.org.uk>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>    <4B55D372.4020807@gmail.com> <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCPMSS target is dropping SYN packets where:
  1) There is data, or
  2) The data offset makes the TCP header larger than
  the packet.

Both of these result in an error level printk.

This change fixes the drop of SYN packets with data
(because the MSS option can safely be modified) and
passes packets with no MSS option instead of adding
one (which is not valid).

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
Tested mangle OUTPUT rule with IPv4 and IPv6.
SYN with data not tested.

 net/netfilter/xt_TCPMSS.c |   82 +++++++-------------------------------------
 1 files changed, 13 insertions(+), 69 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eda64c1..3648761 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -41,7 +41,7 @@ optlen(const u_int8_t *opt, unsigned int offset)
 		return opt[offset+1];
 }
 
-static int
+static unsigned int
 tcpmss_mangle_packet(struct sk_buff *skb,
 		     const struct xt_tcpmss_info *info,
 		     unsigned int in_mtu,
@@ -50,27 +50,18 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 {
 	struct tcphdr *tcph;
 	unsigned int tcplen, i;
-	__be16 oldval;
 	u16 newmss;
 	u8 *opt;
 
 	if (!skb_make_writable(skb, skb->len))
-		return -1;
+		return NF_DROP;
 
 	tcplen = skb->len - tcphoff;
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 
-	/* Since it passed flags test in tcp match, we know it is is
-	   not a fragment, and has data >= tcp header length.  SYN
-	   packets should not contain data: if they did, then we risk
-	   running over MTU, sending Frag Needed and breaking things
-	   badly. --RR */
-	if (tcplen != tcph->doff*4) {
-		if (net_ratelimit())
-			printk(KERN_ERR "xt_TCPMSS: bad length (%u bytes)\n",
-			       skb->len);
-		return -1;
-	}
+	/* Header cannot be larger than the packet */
+	if (tcplen < tcph->doff*4)
+		return NF_DROP;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
@@ -78,13 +69,13 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 				printk(KERN_ERR "xt_TCPMSS: "
 				       "unknown or invalid path-MTU (%u)\n",
 				       dst_mtu(skb_dst(skb)));
-			return -1;
+			return NF_DROP;
 		}
 		if (in_mtu <= minlen) {
 			if (net_ratelimit())
 				printk(KERN_ERR "xt_TCPMSS: unknown or "
 				       "invalid path-MTU (%u)\n", in_mtu);
-			return -1;
+			return NF_DROP;
 		}
 		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
 	} else
@@ -103,7 +94,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 			 * on MSS being set correctly.
 			 */
 			if (oldmss <= newmss)
-				return 0;
+				return XT_CONTINUE;
 
 			opt[i+2] = (newmss & 0xff00) >> 8;
 			opt[i+3] = newmss & 0x00ff;
@@ -111,40 +102,12 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 			inet_proto_csum_replace2(&tcph->check, skb,
 						 htons(oldmss), htons(newmss),
 						 0);
-			return 0;
+			return XT_CONTINUE;
 		}
 	}
 
-	/*
-	 * MSS Option not found ?! add it..
-	 */
-	if (skb_tailroom(skb) < TCPOLEN_MSS) {
-		if (pskb_expand_head(skb, 0,
-				     TCPOLEN_MSS - skb_tailroom(skb),
-				     GFP_ATOMIC))
-			return -1;
-		tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
-	}
-
-	skb_put(skb, TCPOLEN_MSS);
-
-	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
-	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
-
-	inet_proto_csum_replace2(&tcph->check, skb,
-				 htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
-	opt[0] = TCPOPT_MSS;
-	opt[1] = TCPOLEN_MSS;
-	opt[2] = (newmss & 0xff00) >> 8;
-	opt[3] = newmss & 0x00ff;
-
-	inet_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
-
-	oldval = ((__be16 *)tcph)[6];
-	tcph->doff += TCPOLEN_MSS/4;
-	inet_proto_csum_replace2(&tcph->check, skb,
-				 oldval, ((__be16 *)tcph)[6], 0);
-	return TCPOLEN_MSS;
+	/* MSS Option not found */
+	return XT_CONTINUE;
 }
 
 static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
@@ -177,22 +140,11 @@ static unsigned int
 tcpmss_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	struct iphdr *iph = ip_hdr(skb);
-	__be16 newlen;
-	int ret;
 
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
+	return tcpmss_mangle_packet(skb, par->targinfo,
 				   tcpmss_reverse_mtu(skb, PF_INET),
 				   iph->ihl * 4,
 				   sizeof(*iph) + sizeof(struct tcphdr));
-	if (ret < 0)
-		return NF_DROP;
-	if (ret > 0) {
-		iph = ip_hdr(skb);
-		newlen = htons(ntohs(iph->tot_len) + ret);
-		csum_replace2(&iph->check, iph->tot_len, newlen);
-		iph->tot_len = newlen;
-	}
-	return XT_CONTINUE;
 }
 
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
@@ -202,23 +154,15 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	u8 nexthdr;
 	int tcphoff;
-	int ret;
 
 	nexthdr = ipv6h->nexthdr;
 	tcphoff = ipv6_skip_exthdr(skb, sizeof(*ipv6h), &nexthdr);
 	if (tcphoff < 0)
 		return NF_DROP;
-	ret = tcpmss_mangle_packet(skb, par->targinfo,
+	return tcpmss_mangle_packet(skb, par->targinfo,
 				   tcpmss_reverse_mtu(skb, PF_INET6),
 				   tcphoff,
 				   sizeof(*ipv6h) + sizeof(struct tcphdr));
-	if (ret < 0)
-		return NF_DROP;
-	if (ret > 0) {
-		ipv6h = ipv6_hdr(skb);
-		ipv6h->payload_len = htons(ntohs(ipv6h->payload_len) + ret);
-	}
-	return XT_CONTINUE;
 }
 #endif
 
-- 
1.6.3.3

-- 
Simon Arlott
