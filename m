From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv6: drop unused "dev" arg of icmpv6_send()
Date: Thu, 18 Feb 2010 20:25:24 +0200
Message-ID: <20100218182524.GD21184@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:60887 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab0BRSZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:25:25 -0500
Received: by fxm20 with SMTP id 20so9329107fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 10:25:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dunno, what was the idea, it wasn't used for a long time.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    2 +-
 include/linux/icmpv6.h                  |    3 +--
 net/ipv4/ip_gre.c                       |    2 +-
 net/ipv6/exthdrs.c                      |    2 +-
 net/ipv6/icmp.c                         |    5 ++---
 net/ipv6/ip6_input.c                    |    3 +--
 net/ipv6/ip6_output.c                   |   11 +++++------
 net/ipv6/ip6_tunnel.c                   |    6 +++---
 net/ipv6/mip6.c                         |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c        |    2 +-
 net/ipv6/reassembly.c                   |    2 +-
 net/ipv6/route.c                        |    4 ++--
 net/ipv6/sit.c                          |    2 +-
 net/ipv6/tunnel6.c                      |    4 ++--
 net/ipv6/udp.c                          |    5 ++---
 net/ipv6/xfrm6_output.c                 |    2 +-
 net/netfilter/ipvs/ip_vs_core.c         |    5 ++---
 net/netfilter/ipvs/ip_vs_xmit.c         |   10 +++++-----
 18 files changed, 33 insertions(+), 39 deletions(-)

--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1374,7 +1374,7 @@ static void ipoib_cm_skb_reap(struct work_struct *work)
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6))
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, priv->dev);
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 #endif
 		dev_kfree_skb_any(skb);
 
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -174,8 +174,7 @@ struct icmp6_filter {
 
 extern void				icmpv6_send(struct sk_buff *skb,
 						    u8 type, u8 code,
-						    __u32 info, 
-						    struct net_device *dev);
+						    __u32 info);
 
 extern int				icmpv6_init(void);
 extern int				icmpv6_err_convert(u8 type, u8 code,
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -793,7 +793,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 
 		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
 		}
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -481,7 +481,7 @@ looped_back:
 			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
-				    0, skb->dev);
+				    0);
 			kfree_skb(skb);
 			return -1;
 		}
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -114,7 +114,7 @@ static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
  */
 void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
 {
-	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
+	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos);
 	kfree_skb(skb);
 }
 
@@ -300,8 +300,7 @@ static inline void mip6_addr_swap(struct sk_buff *skb) {}
 /*
  *	Send an ICMP message in response to a packet in error
  */
-void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
-		 struct net_device *dev)
+void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	struct inet6_dev *idev = NULL;
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -216,8 +216,7 @@ resubmit:
 				IP6_INC_STATS_BH(net, idev,
 						 IPSTATS_MIB_INUNKNOWNPROTOS);
 				icmpv6_send(skb, ICMPV6_PARAMPROB,
-					    ICMPV6_UNK_NEXTHDR, nhoff,
-					    skb->dev);
+					    ICMPV6_UNK_NEXTHDR, nhoff);
 			}
 		} else
 			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -267,7 +267,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if (net_ratelimit())
 		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
-	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
@@ -441,8 +441,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (hdr->hop_limit <= 1) {
 		/* Force OUTPUT device used as source address */
 		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
-			    0, skb->dev);
+		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT, 0);
 		IP6_INC_STATS_BH(net,
 				 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
 
@@ -504,7 +503,7 @@ int ip6_forward(struct sk_buff *skb)
 			goto error;
 		if (addrtype & IPV6_ADDR_LINKLOCAL) {
 			icmpv6_send(skb, ICMPV6_DEST_UNREACH,
-				ICMPV6_NOT_NEIGHBOUR, 0, skb->dev);
+				    ICMPV6_NOT_NEIGHBOUR, 0);
 			goto error;
 		}
 	}
@@ -512,7 +511,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (skb->len > dst_mtu(dst)) {
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_mtu(dst), skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_mtu(dst));
 		IP6_INC_STATS_BH(net,
 				 ip6_dst_idev(dst), IPSTATS_MIB_INTOOBIGERRORS);
 		IP6_INC_STATS_BH(net,
@@ -627,7 +626,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 */
 	if (!skb->local_df) {
 		skb->dev = skb_dst(skb)->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -622,7 +622,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (rt && rt->rt6i_dev)
 			skb2->dev = rt->rt6i_dev;
 
-		icmpv6_send(skb2, rel_type, rel_code, rel_info, skb2->dev);
+		icmpv6_send(skb2, rel_type, rel_code, rel_info);
 
 		if (rt)
 			dst_release(&rt->u.dst);
@@ -1014,7 +1014,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
 		if (tel->encap_limit == 0) {
 			icmpv6_send(skb, ICMPV6_PARAMPROB,
-				    ICMPV6_HDR_FIELD, offset + 2, skb->dev);
+				    ICMPV6_HDR_FIELD, offset + 2);
 			return -1;
 		}
 		encap_limit = tel->encap_limit - 1;
@@ -1033,7 +1033,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
 	if (err != 0) {
 		if (err == -EMSGSIZE)
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		return -1;
 	}
 
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -56,7 +56,7 @@ static inline void *mip6_padn(__u8 *data, __u8 padlen)
 
 static inline void mip6_param_prob(struct sk_buff *skb, u8 code, int pos)
 {
-	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
+	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos);
 }
 
 static int mip6_mh_len(int type)
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -169,7 +169,7 @@ send_unreach(struct net *net, struct sk_buff *skb_in, unsigned char code,
 	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
 		skb_in->dev = net->loopback_dev;
 
-	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0, NULL);
+	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
 }
 
 static unsigned int
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -228,7 +228,7 @@ static void ip6_frag_expire(unsigned long data)
 	   pointer directly, device might already disappeared.
 	 */
 	fq->q.fragments->dev = dev;
-	icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0, dev);
+	icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0);
 out_rcu_unlock:
 	rcu_read_unlock();
 out:
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -909,7 +909,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 {
 	struct rt6_info *rt;
 
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0, skb->dev);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);
 
 	rt = (struct rt6_info *) skb_dst(skb);
 	if (rt) {
@@ -1884,7 +1884,7 @@ static int ip6_pkt_drop(struct sk_buff *skb, u8 code, int ipstats_mib_noroutes)
 			      ipstats_mib_noroutes);
 		break;
 	}
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0, skb->dev);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0);
 	kfree_skb(skb);
 	return 0;
 }
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -743,7 +743,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 		if (skb->len > mtu) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
 		}
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -98,7 +98,7 @@ static int tunnel6_rcv(struct sk_buff *skb)
 		if (!handler->handler(skb))
 			return 0;
 
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, skb->dev);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 drop:
 	kfree_skb(skb);
@@ -116,7 +116,7 @@ static int tunnel46_rcv(struct sk_buff *skb)
 		if (!handler->handler(skb))
 			return 0;
 
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, skb->dev);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 drop:
 	kfree_skb(skb);
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -680,12 +680,11 @@ static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
 int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	struct udphdr *uh;
-	struct net_device *dev = skb->dev;
 	struct in6_addr *saddr, *daddr;
 	u32 ulen = 0;
-	struct net *net = dev_net(skb->dev);
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto short_packet;
@@ -744,7 +743,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS,
 				proto == IPPROTO_UDPLITE);
 
-		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 		kfree_skb(skb);
 		return 0;
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -38,7 +38,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 
 	if (!skb->local_df && skb->len > mtu) {
 		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
 	}
 
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -512,8 +512,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
-		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0,
-			    skb->dev);
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 	else
 #endif
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
@@ -1021,7 +1020,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 						icmpv6_send(skb,
 							    ICMPV6_DEST_UNREACH,
 							    ICMPV6_PORT_UNREACH,
-							    0, skb->dev);
+							    0);
 					else
 #endif
 						icmp_send(skb,
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -311,7 +311,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	mtu = dst_mtu(&rt->u.dst);
 	if (skb->len > mtu) {
 		dst_release(&rt->u.dst);
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
@@ -454,7 +454,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	mtu = dst_mtu(&rt->u.dst);
 	if (skb->len > mtu) {
 		dst_release(&rt->u.dst);
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
 		goto tx_error;
@@ -672,7 +672,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
 	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->u.dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -814,7 +814,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
 	if (skb->len > mtu) {
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->u.dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -965,7 +965,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	mtu = dst_mtu(&rt->u.dst);
 	if (skb->len > mtu) {
 		dst_release(&rt->u.dst);
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
 	}
