From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 17:14:00 -0700
Message-ID: <1397520840.4222.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397502396.4222.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.152225.1983723140136958968.davem@davemloft.net>
	 <1397510604.4222.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.185152.204599887297456936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.185152.204599887297456936.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 18:51 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Apr 2014 14:23:24 -0700
> 
> > I was trying to cook a not too invasive patch.
> > 
> > Changing ip_local_out() means changing dst_output() / nf_hook()  and
> > hundred of call sites.
> > 
> > Unless I misunderstood you ?
> 
> You could make ip_local_out(skb) be __ip_local_out(skb, skb->sk) and
> make tunnel output use __ip_local_out().

OK lets try ;)

Zhan, could you try following patch, thanks !

 drivers/net/vxlan.c                 |    4 ++--
 include/net/dst.h                   |   14 +++++++++++---
 include/net/inet6_connection_sock.h |    2 +-
 include/net/inet_connection_sock.h  |    2 +-
 include/net/ip.h                    |   13 +++++++++----
 include/net/ip_tunnels.h            |    2 +-
 net/core/dst.c                      |    4 ++--
 net/dccp/output.c                   |    2 +-
 net/ipv4/ip_output.c                |   16 ++++++++--------
 net/ipv4/ip_tunnel.c                |    2 +-
 net/ipv4/ip_tunnel_core.c           |    4 ++--
 net/ipv4/route.c                    |    4 ++--
 net/ipv4/tcp_output.c               |    2 +-
 net/ipv6/inet6_connection_sock.c    |    3 +--
 net/ipv6/sit.c                      |    5 +++--
 net/l2tp/l2tp_core.c                |    4 ++--
 net/l2tp/l2tp_ip.c                  |    2 +-
 net/openvswitch/vport-gre.c         |    2 +-
 net/sctp/protocol.c                 |    2 +-
 19 files changed, 51 insertions(+), 38 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c55e316373a1..82355d5d155a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1755,8 +1755,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	if (err)
 		return err;
 
-	return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df,
-			     false);
+	return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
+			     tos, ttl, df, false);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
diff --git a/include/net/dst.h b/include/net/dst.h
index 46ed958e0c6e..71c60f42be48 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -45,7 +45,7 @@ struct dst_entry {
 	void			*__pad1;
 #endif
 	int			(*input)(struct sk_buff *);
-	int			(*output)(struct sk_buff *);
+	int			(*output)(struct sock *sk, struct sk_buff *skb);
 
 	unsigned short		flags;
 #define DST_HOST		0x0001
@@ -367,7 +367,11 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 	return child;
 }
 
-int dst_discard(struct sk_buff *skb);
+int dst_discard_sk(struct sock *sk, struct sk_buff *skb);
+static inline int dst_discard(struct sk_buff *skb)
+{
+	return dst_discard_sk(skb->sk, skb);
+}
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev, int initial_ref,
 		int initial_obsolete, unsigned short flags);
 void __dst_free(struct dst_entry *dst);
@@ -449,9 +453,13 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 }
 
 /* Output packet to network from transport.  */
+static inline int dst_output_sk(struct sock *sk, struct sk_buff *skb)
+{
+	return skb_dst(skb)->output(sk, skb);
+}
 static inline int dst_output(struct sk_buff *skb)
 {
-	return skb_dst(skb)->output(skb);
+	return dst_output_sk(skb->sk, skb);
 }
 
 /* Input packet from network to transport.  */
diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index f981ba7adeed..74af137304be 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -40,7 +40,7 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
+int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 
 struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index c55aeed41ace..7a4313887568 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -36,7 +36,7 @@ struct tcp_congestion_ops;
  * (i.e. things that depend on the address family)
  */
 struct inet_connection_sock_af_ops {
-	int	    (*queue_xmit)(struct sk_buff *skb, struct flowi *fl);
+	int	    (*queue_xmit)(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	void	    (*sk_rx_dst_set)(struct sock *sk, const struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 25064c28e059..3ec2b0fb9d83 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -104,14 +104,19 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	   struct net_device *orig_dev);
 int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
-int ip_output(struct sk_buff *skb);
-int ip_mc_output(struct sk_buff *skb);
+int ip_output(struct sock *sk, struct sk_buff *skb);
+int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
-int ip_local_out(struct sk_buff *skb);
-int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
+int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
+static inline int ip_local_out(struct sk_buff *skb)
+{
+	return ip_local_out_sk(skb->sk, skb);
+}
+
+int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
 void ip_init(void);
 int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 		   int getfrag(void *from, char *to, int offset, int len,
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index e77c10405d51..a4daf9eb8562 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -153,7 +153,7 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 }
 
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
-int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
+int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index ca4231ec7347..7443c2725c9c 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -142,12 +142,12 @@ loop:
 	mutex_unlock(&dst_gc_mutex);
 }
 
-int dst_discard(struct sk_buff *skb)
+int dst_discard_sk(struct sock *sk, struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return 0;
 }
-EXPORT_SYMBOL(dst_discard);
+EXPORT_SYMBOL(dst_discard_sk);
 
 const u32 dst_default_metrics[RTAX_MAX + 1] = {
 	/* This initializer is needed to force linker to place this variable
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 8876078859da..0248e8a3460c 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -138,7 +138,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
-		err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
+		err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 		return net_xmit_eval(err);
 	}
 	return -ENOBUFS;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1a0755fea491..1cbeba5edff9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -101,17 +101,17 @@ int __ip_local_out(struct sk_buff *skb)
 		       skb_dst(skb)->dev, dst_output);
 }
 
-int ip_local_out(struct sk_buff *skb)
+int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 
 	err = __ip_local_out(skb);
 	if (likely(err == 1))
-		err = dst_output(skb);
+		err = dst_output_sk(sk, skb);
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ip_local_out);
+EXPORT_SYMBOL_GPL(ip_local_out_sk);
 
 static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
 {
@@ -226,9 +226,8 @@ static int ip_finish_output(struct sk_buff *skb)
 		return ip_finish_output2(skb);
 }
 
-int ip_mc_output(struct sk_buff *skb)
+int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 {
-	struct sock *sk = skb->sk;
 	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->dst.dev;
 
@@ -287,7 +286,7 @@ int ip_mc_output(struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-int ip_output(struct sk_buff *skb)
+int ip_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 
@@ -315,9 +314,9 @@ static void ip_copy_addrs(struct iphdr *iph, const struct flowi4 *fl4)
 	       sizeof(fl4->saddr) + sizeof(fl4->daddr));
 }
 
-int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
+/* Note: skb->sk can be different from sk, in case of tunnels */
+int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 {
-	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_rcu *inet_opt;
 	struct flowi4 *fl4;
@@ -389,6 +388,7 @@ packet_routed:
 	ip_select_ident_more(skb, &rt->dst, sk,
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
+	/* TODO : should we use skb->sk here instead of sk ? */
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e77381d1df9a..484d0ce27ef7 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -670,7 +670,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		return;
 	}
 
-	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
+	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr, protocol,
 			    tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index e0c2b1d2ea4e..bcf206c79005 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -46,7 +46,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 
-int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
+int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
@@ -76,7 +76,7 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 	iph->ttl	=	ttl;
 	__ip_select_ident(iph, &rt->dst, (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
-	err = ip_local_out(skb);
+	err = ip_local_out_sk(sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		pkt_len = 0;
 	return pkt_len;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 34d094cadb11..f2279d4470c4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1129,7 +1129,7 @@ static void ipv4_link_failure(struct sk_buff *skb)
 		dst_set_expires(&rt->dst, 0);
 }
 
-static int ip_rt_bug(struct sk_buff *skb)
+static int ip_rt_bug(struct sock *sk, struct sk_buff *skb)
 {
 	pr_debug("%s: %pI4 -> %pI4, %s\n",
 		 __func__, &ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
@@ -2218,7 +2218,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 
 		new->__use = 1;
 		new->input = dst_discard;
-		new->output = dst_discard;
+		new->output = dst_discard_sk;
 
 		new->dev = ort->dst.dev;
 		if (new->dev)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 699fb102e971..025e25093984 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -981,7 +981,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
 			      tcp_skb_pcount(skb));
 
-	err = icsk->icsk_af_ops->queue_xmit(skb, &inet->cork.fl);
+	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 	if (likely(err <= 0))
 		return err;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index c9138189415a..d4ade34ab375 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -224,9 +224,8 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	return dst;
 }
 
-int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
+int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused)
 {
-	struct sock *sk = skb->sk;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi6 fl6;
 	struct dst_entry *dst;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1693c8d885f0..8da8268d65f8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -974,8 +974,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto out;
 	}
 
-	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
-			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
+	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
+			    IPPROTO_IPV6, tos, ttl, df,
+			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 47f7a5490555..a4e37d7158dc 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1131,10 +1131,10 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	skb->local_df = 1;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (tunnel->sock->sk_family == PF_INET6 && !tunnel->v4mapped)
-		error = inet6_csk_xmit(skb, NULL);
+		error = inet6_csk_xmit(tunnel->sock, skb, NULL);
 	else
 #endif
-		error = ip_queue_xmit(skb, fl);
+		error = ip_queue_xmit(tunnel->sock, skb, fl);
 
 	/* Update stats */
 	if (error >= 0) {
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0b44d855269c..3397fe6897c0 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -487,7 +487,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 xmit:
 	/* Queue the packet to IP for output */
-	rc = ip_queue_xmit(skb, &inet->cork.fl);
+	rc = ip_queue_xmit(sk, skb, &inet->cork.fl);
 	rcu_read_unlock();
 
 error:
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index a3d6951602db..ebb6e2442554 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -174,7 +174,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	skb->local_df = 1;
 
-	return iptunnel_xmit(rt, skb, fl.saddr,
+	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
 			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
 			     OVS_CB(skb)->tun_key->ipv4_tos,
 			     OVS_CB(skb)->tun_key->ipv4_ttl, df, false);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4e1d0fcb028e..c09757fbf803 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -957,7 +957,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 
 	SCTP_INC_STATS(sock_net(&inet->sk), SCTP_MIB_OUTSCTPPACKS);
 
-	return ip_queue_xmit(skb, &transport->fl);
+	return ip_queue_xmit(&inet->sk, skb, &transport->fl);
 }
 
 static struct sctp_af sctp_af_inet;
