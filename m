From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/47] netfilter: Remove duplicated rcu_read_lock.
Date: Mon,  4 Sep 2017 00:25:45 +0200
Message-ID: <1504477589-12045-4-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taehee Yoo <ap420073@gmail.com>

This patch removes duplicate rcu_read_lock().

1. IPVS part:

According to Julian Anastasov's mention, contexts of ipvs are described
at: http://marc.info/?l=netfilter-devel&m=149562884514072&w=2, in summary:

 - packet RX/TX: does not need locks because packets come from hooks.
 - sync msg RX: backup server uses RCU locks while registering new
   connections.
 - ip_vs_ctl.c: configuration get/set, RCU locks needed.
 - xt_ipvs.c: It is a netfilter match, running from hook context.

As result, rcu_read_lock and rcu_read_unlock can be removed from:

 - ip_vs_core.c: all
 - ip_vs_ctl.c:
   - only from ip_vs_has_real_service
 - ip_vs_ftp.c: all
 - ip_vs_proto_sctp.c: all
 - ip_vs_proto_tcp.c: all
 - ip_vs_proto_udp.c: all
 - ip_vs_xmit.c: all (contains only packet processing)

2. Netfilter part:

There are three types of functions that are guaranteed the rcu_read_lock().
First, as result, functions are only called by nf_hook():

 - nf_conntrack_broadcast_help(), pptp_expectfn(), set_expected_rtp_rtcp().
 - tcpmss_reverse_mtu(), tproxy_laddr4(), tproxy_laddr6().
 - match_lookup_rt6(), check_hlist(), hashlimit_mt_common().
 - xt_osf_match_packet().

Second, functions that caller already held the rcu_read_lock().
 - destroy_conntrack(), ctnetlink_conntrack_event().
 - ctnl_timeout_find_get(), nfqnl_nf_hook_drop().

Third, functions that are mixed with type1 and type2.

These functions are called by nf_hook() also these are called by
ordinary functions that already held the rcu_read_lock():

 - __ctnetlink_glue_build(), ctnetlink_expect_event().
 - ctnetlink_proto_size().

Applied files are below:

- nf_conntrack_broadcast.c, nf_conntrack_core.c, nf_conntrack_netlink.c.
- nf_conntrack_pptp.c, nf_conntrack_sip.c, nfnetlink_cttimeout.c.
- nfnetlink_queue.c, xt_TCPMSS.c, xt_TPROXY.c, xt_addrtype.c.
- xt_connlimit.c, xt_hashlimit.c, xt_osf.c

Detailed calltrace can be found at:
http://marc.info/?l=netfilter-devel&m=149667610710350&w=2

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c        |  8 ------
 net/netfilter/ipvs/ip_vs_ctl.c         |  3 ---
 net/netfilter/ipvs/ip_vs_ftp.c         |  2 --
 net/netfilter/ipvs/ip_vs_proto_sctp.c  | 11 ++------
 net/netfilter/ipvs/ip_vs_proto_tcp.c   | 10 +-------
 net/netfilter/ipvs/ip_vs_proto_udp.c   | 10 +-------
 net/netfilter/ipvs/ip_vs_xmit.c        | 46 +++-------------------------------
 net/netfilter/nf_conntrack_broadcast.c |  2 --
 net/netfilter/nf_conntrack_core.c      |  3 ---
 net/netfilter/nf_conntrack_netlink.c   | 12 ---------
 net/netfilter/nf_conntrack_pptp.c      |  2 --
 net/netfilter/nf_conntrack_sip.c       |  6 +----
 net/netfilter/nfnetlink_cttimeout.c    |  2 --
 net/netfilter/nfnetlink_queue.c        |  2 --
 net/netfilter/xt_TCPMSS.c              |  2 --
 net/netfilter/xt_TPROXY.c              |  4 ---
 net/netfilter/xt_addrtype.c            |  3 ---
 net/netfilter/xt_connlimit.c           |  3 ---
 net/netfilter/xt_hashlimit.c           |  8 +++---
 net/netfilter/xt_osf.c                 |  2 --
 20 files changed, 13 insertions(+), 128 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e31956b58aba..2ff9d9070c95 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -125,14 +125,12 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		rcu_read_lock();
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
 		s->cnt.inpkts++;
 		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
-		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
@@ -159,14 +157,12 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		rcu_read_lock();
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
 		s->cnt.outpkts++;
 		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
-		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
@@ -1222,7 +1218,6 @@ static struct ip_vs_conn *__ip_vs_rs_conn_out(unsigned int hooknum,
 	if (!pptr)
 		return NULL;
 
-	rcu_read_lock();
 	dest = ip_vs_find_real_service(ipvs, af, iph->protocol,
 				       &iph->saddr, pptr[0]);
 	if (dest) {
@@ -1237,7 +1232,6 @@ static struct ip_vs_conn *__ip_vs_rs_conn_out(unsigned int hooknum,
 						  pptr[0], pptr[1]);
 		}
 	}
-	rcu_read_unlock();
 
 	return cp;
 }
@@ -1689,11 +1683,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 			if (dest) {
 				struct ip_vs_dest_dst *dest_dst;
 
-				rcu_read_lock();
 				dest_dst = rcu_dereference(dest->dest_dst);
 				if (dest_dst)
 					mtu = dst_mtu(dest_dst->dst_cache);
-				rcu_read_unlock();
 			}
 			if (mtu > 68 + sizeof(struct iphdr))
 				mtu -= sizeof(struct iphdr);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 1fa3c2307b6e..4f940d7eb2f7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -550,18 +550,15 @@ bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
 	/* Check for "full" addressed entries */
 	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) {
 		if (dest->port == dport &&
 		    dest->af == af &&
 		    ip_vs_addr_equal(af, &dest->addr, daddr) &&
 		    (dest->protocol == protocol || dest->vfwmark)) {
 			/* HIT */
-			rcu_read_unlock();
 			return true;
 		}
 	}
-	rcu_read_unlock();
 
 	return false;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index fb780be76d15..3e17d32b629d 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -269,13 +269,11 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			 * hopefully it will succeed on the retransmitted
 			 * packet.
 			 */
-			rcu_read_lock();
 			mangled = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 							   iph->ihl * 4,
 							   start - data,
 							   end - start,
 							   buf, buf_len);
-			rcu_read_unlock();
 			if (mangled) {
 				ip_vs_nfct_expect_related(skb, ct, n_cp,
 							  IPPROTO_TCP, 0, 0);
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3ffad4adaddf..e1efa446b305 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -38,7 +38,6 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
-	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
@@ -53,7 +52,6 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -67,11 +65,9 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else
 				*verdict = NF_DROP;
-			rcu_read_unlock();
 			return 0;
 		}
 	}
-	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
@@ -526,12 +522,10 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = sctp_app_hashkey(cp->vport);
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(inc, &ipvs->sctp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
 					"%s:%u to app %s on port %u\n",
@@ -544,11 +538,10 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
-			goto out;
+			break;
 		}
 	}
-	rcu_read_unlock();
-out:
+
 	return result;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 12dc8d5bc37d..121a321b91be 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -63,7 +63,6 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	}
 
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
-	rcu_read_lock();
 
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
@@ -80,7 +79,6 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -95,11 +93,9 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else
 				*verdict = NF_DROP;
-			rcu_read_unlock();
 			return 0;
 		}
 	}
-	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
@@ -661,12 +657,10 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = tcp_app_hashkey(cp->vport);
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(inc, &ipvs->tcp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -680,12 +674,10 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
-			goto out;
+			break;
 		}
 	}
-	rcu_read_unlock();
 
-  out:
 	return result;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index e494e9a88c7f..30e11cd6aa8a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -53,7 +53,6 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
-	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
@@ -69,7 +68,6 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -84,11 +82,9 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else
 				*verdict = NF_DROP;
-			rcu_read_unlock();
 			return 0;
 		}
 	}
-	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
@@ -410,12 +406,10 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = udp_app_hashkey(cp->vport);
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(inc, &ipvs->udp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -429,12 +423,10 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 			cp->app = inc;
 			if (inc->init_conn)
 				result = inc->init_conn(inc, cp);
-			goto out;
+			break;
 		}
 	}
-	rcu_read_unlock();
 
-  out:
 	return result;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 2eab1e0400f4..90d396814798 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -678,7 +678,6 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, iph->daddr,
 			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
@@ -689,14 +688,12 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
  tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -710,7 +707,6 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	if (__ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, NULL,
 				  &iph->daddr, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
@@ -720,14 +716,12 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
  tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -746,7 +740,6 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
@@ -815,14 +808,12 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
 
   tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -837,7 +828,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !ipvsh->fragoffs)) {
 		__be16 _pt, *p;
@@ -906,7 +896,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return rc;
@@ -914,7 +903,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error:
 	LeaveFunction(10);
 	kfree_skb(skb);
-	rcu_read_unlock();
 	return NF_STOLEN;
 }
 #endif
@@ -1035,7 +1023,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt(ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
@@ -1043,10 +1030,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
 	if (local < 0)
 		goto tx_error;
-	if (local) {
-		rcu_read_unlock();
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
-	}
 
 	rt = skb_rtable(skb);
 	tdev = rt->dst.dev;
@@ -1095,7 +1080,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip_local_out(net, skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -1104,7 +1088,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
   tx_error:
 	if (!IS_ERR(skb))
 		kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -1127,7 +1110,6 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
 				      &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
@@ -1136,10 +1118,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      IP_VS_RT_MODE_TUNNEL);
 	if (local < 0)
 		goto tx_error;
-	if (local) {
-		rcu_read_unlock();
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
-	}
 
 	rt = (struct rt6_info *) skb_dst(skb);
 	tdev = rt->dst.dev;
@@ -1185,7 +1165,6 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		ip6_local_out(cp->ipvs->net, skb->sk, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 
@@ -1194,7 +1173,6 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 tx_error:
 	if (!IS_ERR(skb))
 		kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -1213,17 +1191,14 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
 	if (local < 0)
 		goto tx_error;
-	if (local) {
-		rcu_read_unlock();
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
-	}
 
 	ip_send_check(ip_hdr(skb));
 
@@ -1231,14 +1206,12 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
   tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -1252,7 +1225,6 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
 				      &cp->daddr.in6,
 				      NULL, ipvsh, 0,
@@ -1261,23 +1233,19 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      IP_VS_RT_MODE_KNOWN_NH);
 	if (local < 0)
 		goto tx_error;
-	if (local) {
-		rcu_read_unlock();
+	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
-	}
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
 
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
-	rcu_read_unlock();
 
 	LeaveFunction(10);
 	return NF_STOLEN;
 
 tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
@@ -1322,7 +1290,6 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
 				   NULL, iph);
 	if (local < 0)
@@ -1368,12 +1335,10 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
-	rcu_read_unlock();
 	goto out;
 
   tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	rc = NF_STOLEN;
   out:
 	LeaveFunction(10);
@@ -1414,7 +1379,6 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt_mode = (hooknum != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	rcu_read_lock();
 	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
 				      &cp->daddr.in6, NULL, ipvsh, 0, rt_mode);
 	if (local < 0)
@@ -1460,12 +1424,10 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->ignore_df = 1;
 
 	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
-	rcu_read_unlock();
 	goto out;
 
 tx_error:
 	kfree_skb(skb);
-	rcu_read_unlock();
 	rc = NF_STOLEN;
 out:
 	LeaveFunction(10);
diff --git a/net/netfilter/nf_conntrack_broadcast.c b/net/netfilter/nf_conntrack_broadcast.c
index 4e99cca61612..ecc3ab784633 100644
--- a/net/netfilter/nf_conntrack_broadcast.c
+++ b/net/netfilter/nf_conntrack_broadcast.c
@@ -40,7 +40,6 @@ int nf_conntrack_broadcast_help(struct sk_buff *skb,
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		goto out;
 
-	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(rt->dst.dev);
 	if (in_dev != NULL) {
 		for_primary_ifa(in_dev) {
@@ -50,7 +49,6 @@ int nf_conntrack_broadcast_help(struct sk_buff *skb,
 			}
 		} endfor_ifa(in_dev);
 	}
-	rcu_read_unlock();
 
 	if (mask == 0)
 		goto out;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 9979f46c81dc..69746928cc0a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -407,13 +407,10 @@ destroy_conntrack(struct nf_conntrack *nfct)
 		nf_ct_tmpl_free(ct);
 		return;
 	}
-	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->destroy)
 		l4proto->destroy(ct);
 
-	rcu_read_unlock();
-
 	local_bh_disable();
 	/* Expectations will have been removed in clean_from_lists,
 	 * except TFTP can create an expectation on the first packet,
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7999e70c3bfb..4dba71de4de7 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -539,13 +539,11 @@ static inline size_t ctnetlink_proto_size(const struct nf_conn *ct)
 	struct nf_conntrack_l4proto *l4proto;
 	size_t len = 0;
 
-	rcu_read_lock();
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	len += l3proto->nla_size;
 
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	len += l4proto->nla_size;
-	rcu_read_unlock();
 
 	return len;
 }
@@ -664,7 +662,6 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	nfmsg->version	= NFNETLINK_V0;
 	nfmsg->res_id	= 0;
 
-	rcu_read_lock();
 	zone = nf_ct_zone(ct);
 
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
@@ -736,8 +733,6 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	    && ctnetlink_dump_mark(skb, ct) < 0)
 		goto nla_put_failure;
 #endif
-	rcu_read_unlock();
-
 	nlmsg_end(skb, nlh);
 	err = nfnetlink_send(skb, net, item->portid, group, item->report,
 			     GFP_ATOMIC);
@@ -747,7 +742,6 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	return 0;
 
 nla_put_failure:
-	rcu_read_unlock();
 	nlmsg_cancel(skb, nlh);
 nlmsg_failure:
 	kfree_skb(skb);
@@ -2213,7 +2207,6 @@ static int __ctnetlink_glue_build(struct sk_buff *skb, struct nf_conn *ct)
 	const struct nf_conntrack_zone *zone;
 	struct nlattr *nest_parms;
 
-	rcu_read_lock();
 	zone = nf_ct_zone(ct);
 
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
@@ -2272,11 +2265,9 @@ static int __ctnetlink_glue_build(struct sk_buff *skb, struct nf_conn *ct)
 #endif
 	if (ctnetlink_dump_labels(skb, ct) < 0)
 		goto nla_put_failure;
-	rcu_read_unlock();
 	return 0;
 
 nla_put_failure:
-	rcu_read_unlock();
 	return -ENOSPC;
 }
 
@@ -2661,17 +2652,14 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	nfmsg->version	    = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
 
-	rcu_read_lock();
 	if (ctnetlink_exp_dump_expect(skb, exp) < 0)
 		goto nla_put_failure;
-	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
 	nfnetlink_send(skb, net, item->portid, group, item->report, GFP_ATOMIC);
 	return 0;
 
 nla_put_failure:
-	rcu_read_unlock();
 	nlmsg_cancel(skb, nlh);
 nlmsg_failure:
 	kfree_skb(skb);
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 6959e93063d4..11562f2a08bb 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -113,7 +113,6 @@ static void pptp_expectfn(struct nf_conn *ct,
 	/* Can you see how rusty this code is, compared with the pre-2.6.11
 	 * one? That's what happened to my shiny newnat of 2002 ;( -HW */
 
-	rcu_read_lock();
 	nf_nat_pptp_expectfn = rcu_dereference(nf_nat_pptp_hook_expectfn);
 	if (nf_nat_pptp_expectfn && ct->master->status & IPS_NAT_MASK)
 		nf_nat_pptp_expectfn(ct, exp);
@@ -136,7 +135,6 @@ static void pptp_expectfn(struct nf_conn *ct,
 			pr_debug("not found\n");
 		}
 	}
-	rcu_read_unlock();
 }
 
 static int destroy_sibling_or_exp(struct net *net, struct nf_conn *ct,
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index d38af4274335..4dbb5bad4363 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -884,7 +884,6 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 	tuple.dst.u3		= *daddr;
 	tuple.dst.u.udp.port	= port;
 
-	rcu_read_lock();
 	do {
 		exp = __nf_ct_expect_find(net, nf_ct_zone(ct), &tuple);
 
@@ -918,10 +917,8 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 			goto err1;
 	}
 
-	if (skip_expect) {
-		rcu_read_unlock();
+	if (skip_expect)
 		return NF_ACCEPT;
-	}
 
 	rtp_exp = nf_ct_expect_alloc(ct);
 	if (rtp_exp == NULL)
@@ -952,7 +949,6 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 err2:
 	nf_ct_expect_put(rtp_exp);
 err1:
-	rcu_read_unlock();
 	return ret;
 }
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 400e9ae97153..7ce9e86d374c 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -505,7 +505,6 @@ ctnl_timeout_find_get(struct net *net, const char *name)
 {
 	struct ctnl_timeout *timeout, *matching = NULL;
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(timeout, &net->nfct_timeout_list, head) {
 		if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
 			continue;
@@ -521,7 +520,6 @@ ctnl_timeout_find_get(struct net *net, const char *name)
 		break;
 	}
 err:
-	rcu_read_unlock();
 	return matching;
 }
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 16fa04086880..7c543bfbf624 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -928,7 +928,6 @@ static unsigned int nfqnl_nf_hook_drop(struct net *net)
 	unsigned int instances = 0;
 	int i;
 
-	rcu_read_lock();
 	for (i = 0; i < INSTANCE_BUCKETS; i++) {
 		struct nfqnl_instance *inst;
 		struct hlist_head *head = &q->instance_table[i];
@@ -938,7 +937,6 @@ static unsigned int nfqnl_nf_hook_drop(struct net *net)
 			instances++;
 		}
 	}
-	rcu_read_unlock();
 
 	return instances;
 }
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index c64aca611ac5..9dae4d665965 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -62,11 +62,9 @@ static u_int32_t tcpmss_reverse_mtu(struct net *net,
 		memset(fl6, 0, sizeof(*fl6));
 		fl6->daddr = ipv6_hdr(skb)->saddr;
 	}
-	rcu_read_lock();
 	ai = nf_get_afinfo(family);
 	if (ai != NULL)
 		ai->route(net, (struct dst_entry **)&rt, &fl, false);
-	rcu_read_unlock();
 
 	if (rt != NULL) {
 		mtu = dst_mtu(&rt->dst);
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d767e35fff6b..2b74f37132fc 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -70,13 +70,11 @@ tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
 		return user_laddr;
 
 	laddr = 0;
-	rcu_read_lock();
 	indev = __in_dev_get_rcu(skb->dev);
 	for_primary_ifa(indev) {
 		laddr = ifa->ifa_local;
 		break;
 	} endfor_ifa(indev);
-	rcu_read_unlock();
 
 	return laddr ? laddr : daddr;
 }
@@ -391,7 +389,6 @@ tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
 		return user_laddr;
 	laddr = NULL;
 
-	rcu_read_lock();
 	indev = __in6_dev_get(skb->dev);
 	if (indev) {
 		read_lock_bh(&indev->lock);
@@ -404,7 +401,6 @@ tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
 		}
 		read_unlock_bh(&indev->lock);
 	}
-	rcu_read_unlock();
 
 	return laddr ? laddr : daddr;
 }
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index e329dabde35f..3b2be2ae6987 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -47,8 +47,6 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 	if (dev)
 		flow.flowi6_oif = dev->ifindex;
 
-	rcu_read_lock();
-
 	afinfo = nf_get_afinfo(NFPROTO_IPV6);
 	if (afinfo != NULL) {
 		const struct nf_ipv6_ops *v6ops;
@@ -63,7 +61,6 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 	} else {
 		route_err = 1;
 	}
-	rcu_read_unlock();
 
 	if (route_err)
 		return XT_ADDRTYPE_UNREACHABLE;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index b8fd4ab762ed..97589b8a2a40 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -144,7 +144,6 @@ static unsigned int check_hlist(struct net *net,
 	unsigned int length = 0;
 
 	*addit = true;
-	rcu_read_lock();
 
 	/* check the saved connections */
 	hlist_for_each_entry_safe(conn, n, head, node) {
@@ -179,8 +178,6 @@ static unsigned int check_hlist(struct net *net,
 		length++;
 	}
 
-	rcu_read_unlock();
-
 	return length;
 }
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 762e1874f28b..ffdb611e54a2 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -659,12 +659,12 @@ hashlimit_mt_common(const struct sk_buff *skb, struct xt_action_param *par,
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
 
-	rcu_read_lock_bh();
+	local_bh_disable();
 	dh = dsthash_find(hinfo, &dst);
 	if (dh == NULL) {
 		dh = dsthash_alloc_init(hinfo, &dst, &race);
 		if (dh == NULL) {
-			rcu_read_unlock_bh();
+			local_bh_enable();
 			goto hotdrop;
 		} else if (race) {
 			/* Already got an entry, update expiration timeout */
@@ -689,12 +689,12 @@ hashlimit_mt_common(const struct sk_buff *skb, struct xt_action_param *par,
 		/* below the limit */
 		dh->rateinfo.credit -= cost;
 		spin_unlock(&dh->lock);
-		rcu_read_unlock_bh();
+		local_bh_enable();
 		return !(cfg->mode & XT_HASHLIMIT_INVERT);
 	}
 
 	spin_unlock(&dh->lock);
-	rcu_read_unlock_bh();
+	local_bh_enable();
 	/* default match is underlimit - so over the limit, we need to invert */
 	return cfg->mode & XT_HASHLIMIT_INVERT;
 
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 71cfa9551d08..36e14b1f061d 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -226,7 +226,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 				sizeof(struct tcphdr), optsize, opts);
 	}
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(kf, &xt_osf_fingers[df], finger_entry) {
 		int foptsize, optnum;
 
@@ -340,7 +339,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 		    info->loglevel == XT_OSF_LOGLEVEL_FIRST)
 			break;
 	}
-	rcu_read_unlock();
 
 	if (!fcount && (info->flags & XT_OSF_LOG))
 		nf_log_packet(net, xt_family(p), xt_hooknum(p), skb, xt_in(p),
-- 
2.1.4


