From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 03/10]: [IPV4]: Replace dst_output by ip_dst_output
Date: Fri, 11 Nov 2005 04:19:20 +0100
Message-ID: <43740DB8.2030303@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="03.diff"
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

[IPV4]: Replace dst_output by ip_dst_output

Preparation for netfilter IPsec support.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9271210c937a55a2e5dcba05df078e1c43b81d6c
tree 7f510d89a5245630e33e429c9d690de0aa2b05c9
parent dc924f62fd0611bb349e398c80ce3ffa5c3a9025
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:10:58 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:10:58 +0100

 include/net/dst.h               |    2 ++
 include/net/ipip.h              |    2 +-
 net/ipv4/igmp.c                 |    4 ++--
 net/ipv4/ip_forward.c           |    2 +-
 net/ipv4/ip_output.c            |    6 +++---
 net/ipv4/ipmr.c                 |    2 +-
 net/ipv4/ipvs/ip_vs_xmit.c      |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c |    2 +-
 net/ipv4/raw.c                  |    2 +-
 9 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 6c196a5..07f552b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -236,6 +236,8 @@ static inline int dst_output(struct sk_b
 	}
 }
 
+#define ip_dst_output	dst_output
+
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
 {
diff --git a/include/net/ipip.h b/include/net/ipip.h
index f490c3c..b267496 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -34,7 +34,7 @@ struct ip_tunnel
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
 	ip_send_check(iph);						\
 									\
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
+	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, ip_dst_output);\
 	if (err == NET_XMIT_SUCCESS || err == NET_XMIT_CN) {		\
 		stats->tx_bytes += pkt_len;				\
 		stats->tx_packets++;					\
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c6247fc..7c6bf44 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -343,7 +343,7 @@ static int igmpv3_sendpack(struct sk_buf
 	pig->csum = ip_compute_csum((void *)skb->h.igmph, igmplen);
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -674,7 +674,7 @@ static int igmp_send_report(struct in_de
 	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 0923add..486355d 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -51,7 +51,7 @@ static inline int ip_forward_finish(stru
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 int ip_forward(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b0487a2..eb6906d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -155,7 +155,7 @@ int ip_build_and_send_pkt(struct sk_buff
 
 	/* Send it out. */
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
@@ -373,7 +373,7 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 
 no_route:
 	IP_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
@@ -1264,7 +1264,7 @@ int ip_push_pending_frames(struct sock *
 
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip_dst_output);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 302b7eb..40af27f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1125,7 +1125,7 @@ static inline int ipmr_forward_finish(st
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 /*
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 3b87482..b66c3da 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -130,7 +130,7 @@ do {							\
 	(skb)->ipvs_property = 1;			\
 	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+		(rt)->u.dst.dev, ip_dst_output);	\
 } while (0)
 
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index f057025..55b601b 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -220,7 +220,7 @@ static void send_reset(struct sk_buff *o
 	nf_ct_attach(nskb, oldskb);
 
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+		ip_dst_output);
 	return;
 
  free_nskb:
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4b0d7e4..421538a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -313,7 +313,7 @@ static int raw_send_hdrinc(struct sock *
 	}
 
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+		      ip_dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
