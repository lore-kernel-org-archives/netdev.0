From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 04/10]: [IPV6]: Replace dst_output by ip6_dst_output
Date: Fri, 11 Nov 2005 04:19:23 +0100
Message-ID: <43740DBB.4060108@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="04.diff"
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[IPV6]: Replace dst_output by ip6_dst_output

Preparation for netfilter IPsec support.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit acfa963b047cbda6a8350f122da90f1e84bf4938
tree b545b44a3074377283a2b491a5f7ae60b19ed914
parent 9271210c937a55a2e5dcba05df078e1c43b81d6c
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:11:14 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:11:14 +0100

 include/net/dst.h                |    1 +
 net/ipv6/ip6_input.c             |    4 ++--
 net/ipv6/ip6_output.c            |    7 ++++---
 net/ipv6/ip6_tunnel.c            |    2 +-
 net/ipv6/ndisc.c                 |    8 ++++----
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/raw.c                   |    2 +-
 7 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 07f552b..4886f25 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -237,6 +237,7 @@ static inline int dst_output(struct sk_b
 }
 
 #define ip_dst_output	dst_output
+#define ip6_dst_output	dst_output
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 6e34804..c3d32a2 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -250,9 +250,9 @@ int ip6_mc_input(struct sk_buff *skb)
 			
 			if (deliver) {
 				skb2 = skb_clone(skb, GFP_ATOMIC);
-				dst_output(skb2);
+				ip6_dst_output(skb2);
 			} else {
-				dst_output(skb);
+				ip6_dst_output(skb);
 				return 0;
 			}
 		}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 614296a..14e00f4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -230,7 +230,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	if ((skb->len <= mtu) || ipfragok) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
-				dst_output);
+				ip6_dst_output);
 	}
 
 	if (net_ratelimit())
@@ -308,7 +308,7 @@ static int ip6_call_ra_chain(struct sk_b
 
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
-	return dst_output(skb);
+	return ip6_dst_output(skb);
 }
 
 int ip6_forward(struct sk_buff *skb)
@@ -1176,7 +1176,8 @@ int ip6_push_pending_frames(struct sock 
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	              ip6_dst_output);
 	if (err) {
 		if (err > 0)
 			err = np->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cf94372..0642cf1 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -745,7 +745,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip6_dst_output);
 
 	if (err == NET_XMIT_SUCCESS || err == NET_XMIT_CN) {
 		stats->tx_bytes += pkt_len;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 305d9ee..287170f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -499,7 +499,7 @@ static void ndisc_send_na(struct net_dev
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -582,7 +582,7 @@ void ndisc_send_ns(struct net_device *de
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -654,7 +654,7 @@ void ndisc_send_rs(struct net_device *de
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTROUTERSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -1438,7 +1438,7 @@ void ndisc_send_redirect(struct sk_buff 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTREDIRECTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index b03e87a..8579eaa 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -161,7 +161,7 @@ static void send_reset(struct sk_buff *o
 						   sizeof(struct tcphdr), 0));
 
 	NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+		ip6_dst_output);
 }
 
 static inline void
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a1265a3..130684c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -579,7 +579,7 @@ static int rawv6_send_hdrinc(struct sock
 
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);		
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+		      ip6_dst_output);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	if (err)
