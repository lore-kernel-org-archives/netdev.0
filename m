From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 20:50:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Following changesets make XFRM core subsystem af-independent.
Please pull following changesets from:
	<bk://bk.skbuff.net:20609/linux-2.6-xfrm-20040917/>.

HEADLINES
---------
ChangeSet@1.1925, 2004-09-17 20:13:22+09:00, yoshfuji@linux-ipv6.org
 [IPV4] replace ip_route_output_key() with ip_route_output_flow().
ChangeSet@1.1926, 2004-09-17 20:13:43+09:00, yoshfuji@linux-ipv6.org
 [XFRM] make xfrm_lookup() fully af-independent.


DIFFSTATS
---------
 include/net/route.h                    |    5 ++---
 net/atm/clip.c                         |    8 ++++----
 net/core/netfilter.c                   |    4 ++--
 net/ipv4/arp.c                         |    6 +++---
 net/ipv4/icmp.c                        |    6 +++---
 net/ipv4/igmp.c                        |    6 +++---
 net/ipv4/ip_gre.c                      |   10 +++++-----
 net/ipv4/ip_output.c                   |    2 +-
 net/ipv4/ipip.c                        |    8 ++++----
 net/ipv4/ipmr.c                        |    4 ++--
 net/ipv4/ipvs/ip_vs_xmit.c             |    6 +++---
 net/ipv4/netfilter/ip_fw_compat_masq.c |    2 +-
 net/ipv4/netfilter/ip_nat_core.c       |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c    |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c        |    6 +++---
 net/ipv4/route.c                       |   26 +++++++++++++-------------
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/xfrm4_policy.c                |    2 +-
 net/ipv6/sit.c                         |    4 ++--
 net/sctp/protocol.c                    |   30 ++++++++----------------------
 20 files changed, 63 insertions(+), 78 deletions(-)


CHANGESETS
----------
ChangeSet@1.1925, 2004-09-17 20:13:22+09:00, yoshfuji@linux-ipv6.org
 [IPV4] replace ip_route_output_key() with ip_route_output_flow().
 
 Since ip_route_output_key() is identical to ip_route_output_flow(),
 except for the lack of the sk and the flags arguments, 
 let's use the later generic one.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/route.h b/include/net/route.h
--- a/include/net/route.h	2004-09-17 20:14:58 +09:00
+++ b/include/net/route.h	2004-09-17 20:14:58 +09:00
@@ -115,8 +115,7 @@
 				       u32 src, u8 tos, struct net_device *dev);
 extern void		ip_rt_advice(struct rtable **rp, int advice);
 extern void		rt_cache_flush(int how);
-extern int		__ip_route_output_key(struct rtable **, const struct flowi *flp);
-extern int		ip_route_output_key(struct rtable **, struct flowi *flp);
+extern int		__ip_route_output_flow(struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
 extern int		ip_route_input(struct sk_buff*, u32 dst, u32 src, u8 tos, struct net_device *devin);
 extern unsigned short	ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu);
@@ -158,7 +157,7 @@
 
 	int err;
 	if (!dst || !src) {
-		err = __ip_route_output_key(rp, &fl);
+		err = __ip_route_output_flow(rp, &fl);
 		if (err)
 			return err;
 		fl.fl4_dst = (*rp)->rt_dst;
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-09-17 20:14:58 +09:00
+++ b/net/atm/clip.c	2004-09-17 20:14:58 +09:00
@@ -556,7 +556,7 @@
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
-	error = ip_route_output_key(&rt,&fl);
+	error = ip_route_output_flow(&rt, &fl, NULL, 0);
 	if (error) return error;
 	neigh = __neigh_lookup(&clip_tbl,&ip,rt->u.dst.dev,1);
 	ip_rt_put(rt);
diff -Nru a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c	2004-09-17 20:14:58 +09:00
+++ b/net/bridge/br_netfilter.c	2004-09-17 20:14:58 +09:00
@@ -168,8 +168,8 @@
  * Let us now consider the case that ip_route_input() fails:
  *
  * After a "echo '0' > /proc/sys/net/ipv4/ip_forward" ip_route_input()
- * will fail, while __ip_route_output_key() will return success. The source
- * address for __ip_route_output_key() is set to zero, so __ip_route_output_key
+ * will fail, while __ip_route_output_flow() will return success. The source
+ * address for __ip_route_output_flow() is set to zero, so __ip_route_output_flow
  * thinks we're handling a locally generated packet and won't care
  * if IP forwarding is allowed. We send a warning message to the users's
  * log telling her to put IP forwarding on.
@@ -225,7 +225,7 @@
 			{ .ip4_u = { .daddr = iph->daddr, .saddr = 0 ,
 				     .tos = RT_TOS(iph->tos)} }, .proto = 0};
 
-			if (!ip_route_output_key(&rt, &fl)) {
+			if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 				/* Bridged-and-DNAT'ed traffic doesn't
 				 * require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
diff -Nru a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c	2004-09-17 20:14:58 +09:00
+++ b/net/core/netfilter.c	2004-09-17 20:14:58 +09:00
@@ -631,7 +631,7 @@
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
 		fl.proto = iph->protocol;
-		if (ip_route_output_key(&rt, &fl) != 0)
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0)
 			return -1;
 
 		/* Drop old route. */
@@ -641,7 +641,7 @@
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
 		fl.nl_u.ip4_u.daddr = iph->saddr;
-		if (ip_route_output_key(&rt, &fl) != 0)
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0)
 			return -1;
 
 		odst = (*pskb)->dst;
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/arp.c	2004-09-17 20:14:58 +09:00
@@ -430,7 +430,7 @@
 	int flag = 0; 
 	/*unsigned long now; */
 
-	if (ip_route_output_key(&rt, &fl) < 0) 
+	if (ip_route_output_flow(&rt, &fl, NULL, 0) < 0) 
 		return 1;
 	if (rt->u.dst.dev != dev) { 
 		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
@@ -1004,7 +1004,7 @@
 		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
 							 .tos = RTO_ONLINK } } };
 		struct rtable * rt;
-		if ((err = ip_route_output_key(&rt, &fl)) != 0)
+		if ((err = ip_route_output_flow(&rt, &fl, NULL, 0)) != 0)
 			return err;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
@@ -1092,7 +1092,7 @@
 		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
 							 .tos = RTO_ONLINK } } };
 		struct rtable * rt;
-		if ((err = ip_route_output_key(&rt, &fl)) != 0)
+		if ((err = ip_route_output_flow(&rt, &fl, NULL, 0)) != 0)
 			return err;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
diff -Nru a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/icmp.c	2004-09-17 20:14:58 +09:00
@@ -403,7 +403,7 @@
 						.saddr = rt->rt_spec_dst,
 						.tos = RT_TOS(skb->nh.iph->tos) } },
 				    .proto = IPPROTO_ICMP };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			goto out_unlock;
 	}
 	if (icmpv4_xrlim_allow(rt, icmp_param->data.icmph.type,
@@ -521,7 +521,7 @@
 							 .saddr = saddr,
 							 .tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_ICMP };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 		    goto out_unlock;
 	}
 	if (ip_options_echo(&icmp_param.replyopts, skb_in))
@@ -549,7 +549,7 @@
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_ICMP };
 		ip_rt_put(rt);
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			goto out_unlock;
 	}
 
diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/igmp.c	2004-09-17 20:14:58 +09:00
@@ -286,7 +286,7 @@
 				    .nl_u = { .ip4_u = {
 				    .daddr = IGMPV3_ALL_MCR } },
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			kfree_skb(skb);
 			return NULL;
 		}
@@ -630,7 +630,7 @@
 		struct flowi fl = { .oif = dev->ifindex,
 				    .nl_u = { .ip4_u = { .daddr = dst } },
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			return -1;
 	}
 	if (rt->rt_src == 0) {
@@ -1317,7 +1317,7 @@
 		__dev_put(dev);
 	}
 
-	if (!dev && !ip_route_output_key(&rt, &fl)) {
+	if (!dev && !ip_route_output_flow(&rt, &fl, NULL, 0)) {
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
 	}
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/ip_gre.c	2004-09-17 20:14:58 +09:00
@@ -481,7 +481,7 @@
 	fl.fl4_dst = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_GRE;
-	if (ip_route_output_key(&rt, &fl)) {
+	if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 		kfree_skb(skb2);
 		return;
 	}
@@ -494,7 +494,7 @@
 		fl.fl4_dst = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(&rt, &fl) ||
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) ||
 		    rt->u.dst.dev->type != ARPHRD_IPGRE) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
@@ -751,7 +751,7 @@
 						.saddr = tiph->saddr,
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_GRE };
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error;
 		}
@@ -1103,7 +1103,7 @@
 						.tos = RT_TOS(t->parms.iph.tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			return -EADDRNOTAVAIL;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
@@ -1176,7 +1176,7 @@
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
-		if (!ip_route_output_key(&rt, &fl)) {
+		if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/ip_output.c	2004-09-17 20:14:58 +09:00
@@ -1308,7 +1308,7 @@
 					       { .sport = skb->h.th->dest,
 					         .dport = skb->h.th->source } },
 				    .proto = sk->sk_protocol };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			return;
 	}
 
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/ipip.c	2004-09-17 20:14:58 +09:00
@@ -407,7 +407,7 @@
 	fl.fl4_daddr = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_IPIP;
-	if (ip_route_output_key(&rt, &key)) {
+	if (ip_route_output_flow(&rt, &key, NULL, 0)) {
 		kfree_skb(skb2);
 		return;
 	}
@@ -420,7 +420,7 @@
 		fl.fl4_daddr = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(&rt, &fl) ||
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) ||
 		    rt->u.dst.dev->type != ARPHRD_TUNNEL) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
@@ -556,7 +556,7 @@
 						.saddr = tiph->saddr,
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -816,7 +816,7 @@
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
 		struct rtable *rt;
-		if (!ip_route_output_key(&rt, &fl)) {
+		if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/ipmr.c	2004-09-17 20:14:58 +09:00
@@ -1156,7 +1156,7 @@
 						.saddr = vif->local,
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
@@ -1165,7 +1165,7 @@
 					      { .daddr = iph->daddr,
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			goto out_free;
 	}
 
diff -Nru a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
--- a/net/ipv4/ipvs/ip_vs_xmit.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/ipvs/ip_vs_xmit.c	2004-09-17 20:14:58 +09:00
@@ -77,7 +77,7 @@
 						.tos = rtos, } },
 			};
 
-			if (ip_route_output_key(&rt, &fl)) {
+			if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, "
 					     "dest: %u.%u.%u.%u\n",
@@ -100,7 +100,7 @@
 					.tos = rtos, } },
 		};
 
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: "
 				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr));
 			return NULL;
@@ -170,7 +170,7 @@
 
 	EnterFunction(10);
 
-	if (ip_route_output_key(&rt, &fl)) {
+	if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 		IP_VS_DBG_RL("ip_vs_bypass_xmit(): ip_route_output error, "
 			     "dest: %u.%u.%u.%u\n", NIPQUAD(iph->daddr));
 		goto tx_error_icmp;
diff -Nru a/net/ipv4/netfilter/ip_fw_compat_masq.c b/net/ipv4/netfilter/ip_fw_compat_masq.c
--- a/net/ipv4/netfilter/ip_fw_compat_masq.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/netfilter/ip_fw_compat_masq.c	2004-09-17 20:14:58 +09:00
@@ -84,7 +84,7 @@
 
 		/* Pass 0 instead of saddr, since it's going to be changed
 		   anyway. */
-		if (ip_route_output_key(&rt, &fl) != 0) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0) {
 			DEBUGP("ipnat_rule_masquerade: Can't reroute.\n");
 			return NF_DROP;
 		}
diff -Nru a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
--- a/net/ipv4/netfilter/ip_nat_core.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/netfilter/ip_nat_core.c	2004-09-17 20:14:58 +09:00
@@ -213,7 +213,7 @@
 	struct rtable *rt;
 
 	/* FIXME: IPTOS_TOS(iph->tos) --RR */
-	if (ip_route_output_key(&rt, &fl) != 0) {
+	if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0) {
 		DEBUGP("do_extra_mangle: Can't get route to %u.%u.%u.%u\n",
 		       NIPQUAD(var_ip));
 		return 0;
diff -Nru a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-09-17 20:14:58 +09:00
@@ -106,7 +106,7 @@
 						.fwmark = (*pskb)->nfmark
 #endif
 					      } } };
-		if (ip_route_output_key(&rt, &fl) != 0) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0) {
 			/* Funky routing can do this. */
 			if (net_ratelimit())
 				printk("MASQUERADE:"
diff -Nru a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
--- a/net/ipv4/netfilter/ipt_REJECT.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/netfilter/ipt_REJECT.c	2004-09-17 20:14:58 +09:00
@@ -71,13 +71,13 @@
 			fl.nl_u.ip4_u.saddr = iph->daddr;
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 
-		if (ip_route_output_key(&rt, &fl) != 0)
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0)
 			return NULL;
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
 		fl.nl_u.ip4_u.daddr = iph->daddr;
-		if (ip_route_output_key(&rt, &fl) != 0)
+		if (ip_route_output_flow(&rt, &fl, NULL, 0) != 0)
 			return NULL;
 
 		odst = skb->dst;
@@ -300,7 +300,7 @@
 					      { .daddr = skb_in->nh.iph->saddr,
 						.saddr = saddr,
 						.tos = RT_TOS(tos) } } };
-		if (ip_route_output_key(&rt, &fl))
+		if (ip_route_output_flow(&rt, &fl, NULL, 0))
 			return;
 	}
 	/* RFC says return as much as we can without exceeding 576 bytes. */
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/route.c	2004-09-17 20:14:58 +09:00
@@ -2172,7 +2172,7 @@
 	goto done;
 }
 
-int __ip_route_output_key(struct rtable **rp, const struct flowi *flp)
+int __ip_route_output_flow(struct rtable **rp, const struct flowi *flp)
 {
 	unsigned hash;
 	struct rtable *rth;
@@ -2206,20 +2206,11 @@
 	return ip_route_output_slow(rp, flp);
 }
 
-int ip_route_output_key(struct rtable **rp, struct flowi *flp)
-{
-	int err;
-
-	if ((err = __ip_route_output_key(rp, flp)) != 0)
-		return err;
-	return flp->proto ? xfrm_lookup((struct dst_entry**)rp, flp, NULL, 0) : 0;
-}
-
 int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags)
 {
 	int err;
 
-	if ((err = __ip_route_output_key(rp, flp)) != 0)
+	if ((err = __ip_route_output_flow(rp, flp)) != 0)
 		return err;
 	return flp->proto ? xfrm_lookup((struct dst_entry**)rp, flp, sk, flags) : 0;
 }
@@ -2369,7 +2360,7 @@
 		if (rta[RTA_OIF - 1])
 			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
 		fl.oif = oif;
-		err = ip_route_output_key(&rt, &fl);
+		err = ip_route_output_flow(&rt, &fl, NULL, 0);
 	}
 	if (err)
 		goto out_free;
@@ -2797,4 +2788,4 @@
 
 EXPORT_SYMBOL(__ip_select_ident);
 EXPORT_SYMBOL(ip_route_input);
-EXPORT_SYMBOL(ip_route_output_key);
+EXPORT_SYMBOL(ip_route_output_flow);
diff -Nru a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
--- a/net/ipv4/syncookies.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/syncookies.c	2004-09-17 20:14:58 +09:00
@@ -184,7 +184,7 @@
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } } };
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tcp_openreq_free(req);
 			goto out; 
 		}
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv4/xfrm4_policy.c	2004-09-17 20:14:58 +09:00
@@ -19,7 +19,7 @@
 
 static int xfrm4_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
 {
-	return __ip_route_output_key((struct rtable**)dst, fl);
+	return __ip_route_output_flow((struct rtable**)dst, fl);
 }
 
 /* Check that the bundle accepts the flow and its components are
diff -Nru a/net/ipv6/sit.c b/net/ipv6/sit.c
--- a/net/ipv6/sit.c	2004-09-17 20:14:58 +09:00
+++ b/net/ipv6/sit.c	2004-09-17 20:14:58 +09:00
@@ -481,7 +481,7 @@
 						.tos = RT_TOS(tos) } },
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
-		if (ip_route_output_key(&rt, &fl)) {
+		if (ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -749,7 +749,7 @@
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
-		if (!ip_route_output_key(&rt, &fl)) {
+		if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2004-09-17 20:14:58 +09:00
+++ b/net/sctp/protocol.c	2004-09-17 20:14:58 +09:00
@@ -455,7 +455,7 @@
 			  __FUNCTION__, NIPQUAD(fl.fl4_dst),
 			  NIPQUAD(fl.fl4_src));
 
-	if (!ip_route_output_key(&rt, &fl)) {
+	if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 		dst = &rt->u.dst;
 	}
 
@@ -498,7 +498,7 @@
 
 		if (AF_INET == laddr->a.sa.sa_family) {
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
-			if (!ip_route_output_key(&rt, &fl)) {
+			if (!ip_route_output_flow(&rt, &fl, NULL, 0)) {
 				dst = &rt->u.dst;
 				goto out_unlock;
 			}

ChangeSet@1.1926, 2004-09-17 20:13:43+09:00, yoshfuji@linux-ipv6.org
 [XFRM] make xfrm_lookup() fully af-independent.
 
 This extracts af-dependent portion from xfrm_lookup() 
 and put it into net/ipv4/route.c:ip_route_output_flow(),
 the user of xfrm_lookup() in IPv4 side.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-09-17 20:15:01 +09:00
+++ b/net/ipv4/route.c	2004-09-17 20:15:01 +09:00
@@ -2212,7 +2212,16 @@
 
 	if ((err = __ip_route_output_flow(rp, flp)) != 0)
 		return err;
-	return flp->proto ? xfrm_lookup((struct dst_entry**)rp, flp, sk, flags) : 0;
+
+	if (flp->proto) {
+		if (!flp->fl4_src)
+			flp->fl4_src = (*rp)->rt_src;
+		if (!flp->fl4_dst)
+			flp->fl4_dst = (*rp)->rt_dst;
+		return xfrm_lookup((struct dst_entry **)rp, flp, sk, flags);
+	}
+
+	return 0;
 }
 
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-09-17 20:15:01 +09:00
+++ b/net/xfrm/xfrm_policy.c	2004-09-17 20:15:01 +09:00
@@ -711,25 +711,11 @@
 {
 	struct xfrm_policy *policy;
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
-	struct rtable *rt = (struct rtable*)*dst_p;
-	struct dst_entry *dst;
+	struct dst_entry *dst, *dst_orig = *dst_p;
 	int nx = 0;
 	int err;
 	u32 genid;
-	u16 family = (*dst_p)->ops->family;
-
-	switch (family) {
-	case AF_INET:
-		if (!fl->fl4_src)
-			fl->fl4_src = rt->rt_src;
-		if (!fl->fl4_dst)
-			fl->fl4_dst = rt->rt_dst;
-	case AF_INET6:
-		/* Still not clear... */
-	default:
-		/* nothing */;
-	}
-
+	u16 family = dst_orig->ops->family;
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
@@ -738,7 +724,7 @@
 
 	if (!policy) {
 		/* To accelerate a bit...  */
-		if ((rt->u.dst.flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
+		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
 			return 0;
 
 		policy = flow_cache_lookup(fl, family,
@@ -813,7 +799,7 @@
 			return 0;
 		}
 
-		dst = &rt->u.dst;
+		dst = dst_orig;
 		err = xfrm_bundle_create(policy, xfrm, nx, fl, &dst, family);
 
 		if (unlikely(err)) {
@@ -843,12 +829,12 @@
 		write_unlock_bh(&policy->lock);
 	}
 	*dst_p = dst;
-	ip_rt_put(rt);
+	dst_release(dst_orig);
 	xfrm_pol_put(policy);
 	return 0;
 
 error:
-	ip_rt_put(rt);
+	dst_release(dst_orig);
 	xfrm_pol_put(policy);
 	*dst_p = NULL;
 	return err;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
