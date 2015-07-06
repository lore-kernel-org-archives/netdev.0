From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 4/6] net: Modifications to ipv4 stack for VRF devices
Date: Mon,  6 Jul 2015 09:03:18 -0600
Message-ID: <1436195001-4818-5-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37757 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbGFPDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:36 -0400
Received: by igau2 with SMTP id u2so13391929iga.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:35 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the following tweaks to the IPv4 stack:
- enslaving devices to a VRF device automatically moves routes to the
  VRF table; removing the VRF master moves routes back to the main table

- the following use cases work for both Rx and Tx:
  + ICMP (ping -I <vrf-device> <ip>)
  + TCP server and client bound to VRF device
  + TCP server not bound to VRF device but working through it
    * client connections are bound to VRF device
  + UDP server and client bound to VRF device

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/flow.h            |  1 +
 include/net/inet_hashtables.h |  9 +++++++--
 include/net/route.h           |  4 ++++
 net/ipv4/fib_frontend.c       | 30 ++++++++++++++++++++----------
 net/ipv4/fib_semantics.c      | 25 ++++++++++++++++++++-----
 net/ipv4/fib_trie.c           |  7 +++++--
 net/ipv4/icmp.c               |  4 ++++
 net/ipv4/ping.c               |  3 ++-
 net/ipv4/raw.c                |  5 +++--
 net/ipv4/route.c              | 12 ++++++++++--
 net/ipv4/syncookies.c         |  4 +++-
 net/ipv4/tcp_input.c          |  6 +++++-
 net/ipv4/tcp_ipv4.c           |  6 ++++--
 net/ipv4/udp.c                |  2 ++
 14 files changed, 90 insertions(+), 28 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a159d1b3..69aaa99fdeb8 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -29,6 +29,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
+#define FLOWI_FLAG_VRFSRC		0x04
 	__u32	flowic_secid;
 };
 
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index b73c88a19dd4..e26c43823a13 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -31,6 +31,7 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/netns/hash.h>
+#include <net/vrf.h>
 
 #include <linux/atomic.h>
 #include <asm/byteorder.h>
@@ -300,10 +301,14 @@ static inline struct sock *__inet_lookup(struct net *net,
 					 struct inet_hashinfo *hashinfo,
 					 const __be32 saddr, const __be16 sport,
 					 const __be32 daddr, const __be16 dport,
-					 const int dif)
+					 int dif)
 {
 	u16 hnum = ntohs(dport);
-	struct sock *sk = __inet_lookup_established(net, hashinfo,
+	struct sock *sk;
+
+	dif = vrf_get_master_dev_idx(net, dif) ? : dif;
+
+	sk = __inet_lookup_established(net, hashinfo,
 				saddr, sport, daddr, hnum, dif);
 
 	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03afb6a..460333bab217 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -188,6 +188,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
 void ip_rt_send_redirect(struct sk_buff *skb);
 
 unsigned int inet_addr_type(struct net *net, __be32 addr);
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr);
 void ip_rt_multicast_event(struct in_device *);
@@ -250,6 +251,9 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
+	if (netif_idx_is_vrf(sock_net(sk), oif))
+		flow_flags |= FLOWI_FLAG_VRFSRC;
+
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 974fa51effca..7c73eb058c91 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,6 +45,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
+#include <net/vrf.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -212,7 +213,7 @@ void fib_flush_external(struct net *net)
  */
 static inline unsigned int __inet_dev_addr_type(struct net *net,
 						const struct net_device *dev,
-						__be32 addr)
+						__be32 addr, int rt_table)
 {
 	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
@@ -225,8 +226,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 		return RTN_MULTICAST;
 
 	rcu_read_lock();
-
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	local_table = fib_get_table(net, rt_table);
 	if (local_table) {
 		ret = RTN_UNICAST;
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
@@ -239,16 +239,24 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	return ret;
 }
 
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id)
+{
+	return __inet_dev_addr_type(net, NULL, addr, tb_id);
+}
+EXPORT_SYMBOL(inet_addr_type_table);
+
 unsigned int inet_addr_type(struct net *net, __be32 addr)
 {
-	return __inet_dev_addr_type(net, NULL, addr);
+	return __inet_dev_addr_type(net, NULL, addr, RT_TABLE_LOCAL);
 }
 EXPORT_SYMBOL(inet_addr_type);
 
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	return __inet_dev_addr_type(net, dev, addr);
+	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+
+	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
@@ -309,7 +317,9 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
+	fl4.flowi4_iif = vrf_master_dev_idx(dev);
+	if (!fl4.flowi4_iif)
+		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
@@ -761,6 +771,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
+	int tb_id = vrf_dev_table(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
@@ -775,11 +786,10 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		},
 	};
 
-	if (type == RTN_UNICAST)
-		tb = fib_new_table(net, RT_TABLE_MAIN);
-	else
-		tb = fib_new_table(net, RT_TABLE_LOCAL);
+	if (!tb_id)
+		tb_id = (type == RTN_UNICAST) ? RT_TABLE_MAIN : RT_TABLE_LOCAL;
 
+	tb = fib_new_table(net, tb_id);
 	if (!tb)
 		return;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3bfccd83551c..3c3e2006ce72 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -760,6 +760,23 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
 	return nh->nh_saddr;
 }
 
+static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
+{
+	if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
+	    fib_prefsrc != cfg->fc_dst) {
+		int tb_id = cfg->fc_table;
+
+		if (tb_id == RT_TABLE_MAIN)
+			tb_id = RT_TABLE_LOCAL;
+
+		if (inet_addr_type_table(cfg->fc_nlinfo.nl_net,
+					 fib_prefsrc, tb_id) != RTN_LOCAL) {
+			return false;
+		}
+	}
+	return true;
+}
+
 struct fib_info *fib_create_info(struct fib_config *cfg)
 {
 	int err;
@@ -940,11 +957,9 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			fi->fib_flags |= RTNH_F_LINKDOWN;
 	}
 
-	if (fi->fib_prefsrc) {
-		if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
-		    fi->fib_prefsrc != cfg->fc_dst)
-			if (inet_addr_type(net, fi->fib_prefsrc) != RTN_LOCAL)
-				goto err_inval;
+
+	if (fi->fib_prefsrc && !fib_valid_prefsrc(cfg, fi->fib_prefsrc)) {
+		goto err_inval;
 	}
 
 	change_nexthops(fi) {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ac2d828c6daa..7da901c56e35 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1421,8 +1421,11 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			    nh->nh_flags & RTNH_F_LINKDOWN &&
 			    !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
 				continue;
-			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
-				continue;
+			if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+				if (flp->flowi4_oif &&
+				    flp->flowi4_oif != nh->nh_oif)
+					continue;
+			}
 
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
 				atomic_inc(&fi->fib_clntref);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f5203fba6236..115d3c1c548f 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -96,6 +96,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
+#include <net/vrf.h>
 
 /*
  *	Build xmit assembly blocks
@@ -425,6 +426,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
+	fl4.flowi4_oif = vrf_master_dev_idx(skb->dev) ? : skb->dev->ifindex;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
@@ -458,6 +460,8 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
+	fl4->flowi4_oif = vrf_master_dev_idx(skb_in->dev) ? : skb_in->dev->ifindex;
+
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key(net, fl4);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 05ff44b758df..685fada659f5 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -44,6 +44,7 @@
 #include <net/route.h>
 #include <net/inet_common.h>
 #include <net/checksum.h>
+#include <net/vrf.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
@@ -174,7 +175,7 @@ static struct sock *ping_lookup(struct net *net, struct sk_buff *skb, u16 ident)
 	struct sock *sk = NULL;
 	struct inet_sock *isk;
 	struct hlist_nulls_node *hnode;
-	int dif = skb->dev->ifindex;
+	int dif = vrf_master_dev_idx(skb->dev) ? : skb->dev->ifindex;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		pr_debug("try to find: num = %d, daddr = %pI4, dif = %d\n",
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b8fc6e..95ef2834533d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -72,6 +72,7 @@
 #include <net/inet_common.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/vrf.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -171,6 +172,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 	struct hlist_head *head;
 	int delivered = 0;
 	struct net *net;
+	int idx = vrf_master_dev_idx(skb->dev) ? : skb->dev->ifindex;
 
 	read_lock(&raw_v4_hashinfo.lock);
 	head = &raw_v4_hashinfo.ht[hash];
@@ -179,8 +181,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 
 	net = dev_net(skb->dev);
 	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
-			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+			     iph->saddr, iph->daddr, idx);
 
 	while (sk) {
 		delivered = 1;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d0362a2de3d3..c66fdeb3a101 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -109,6 +109,7 @@
 #include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
+#include <net/vrf.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1710,7 +1711,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = dev->ifindex;
+	fl4.flowi4_iif = vrf_master_dev_idx(dev) ? : dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
@@ -2089,6 +2090,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		if (!dev_out)
 			goto out;
 
+		if (netif_is_vrf(dev_out))
+			fl4->flowi4_flags |= FLOWI_FLAG_VRFSRC;
+
 		/* RACE: Check return value of inet_select_addr instead. */
 		if (!(dev_out->flags & IFF_UP) || !__in_dev_get_rcu(dev_out)) {
 			rth = ERR_PTR(-ENETUNREACH);
@@ -2273,8 +2277,12 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 				    struct sock *sk)
 {
-	struct rtable *rt = __ip_route_output_key(net, flp4);
+	struct rtable *rt;
+
+	if (netif_idx_is_vrf(net, flp4->flowi4_oif))
+		flp4->flowi4_flags |= FLOWI_FLAG_VRFSRC;
 
+	rt = __ip_route_output_key(net, flp4);
 	if (IS_ERR(rt))
 		return rt;
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d70b1f603692..120f4406ba7a 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -348,7 +348,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->tfo_listener	= false;
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = vrf_get_master_dev_idx(sock_net(sk), skb->skb_iif);
+	if (!ireq->ir_iif)
+		ireq->ir_iif = sk->sk_bound_dev_if;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 684f095d196e..3018b4f795eb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,6 +72,7 @@
 #include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
+#include <net/vrf.h>
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
@@ -6138,7 +6139,10 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
-	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
+	inet_rsk(req)->ir_iif = vrf_get_master_dev_idx(sock_net(sk),
+						       skb->skb_iif);
+	if (!inet_rsk(req)->ir_iif)
+		inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
 
 	af_ops->init_req(req, sk, skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d7d4c2b79cf2..c03e28477275 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -682,6 +682,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sk)
 		arg.bound_dev_if = sk->sk_bound_dev_if;
+	if (!arg.bound_dev_if)
+		arg.bound_dev_if = vrf_master_dev_idx(skb_dst(skb)->dev);
 
 	arg.tos = ip_hdr(skb)->tos;
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
@@ -766,8 +768,8 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
-	if (oif)
-		arg.bound_dev_if = oif;
+	arg.bound_dev_if = oif ? : vrf_master_dev_idx(skb_dst(skb)->dev);
+
 	arg.tos = tos;
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604f9273..cf706d7898a2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -501,6 +501,8 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
 
+	dif = vrf_get_master_dev_idx(net, dif) ? : dif;
+
 	rcu_read_lock();
 	if (hslot->count > 10) {
 		hash2 = udp4_portaddr_hash(net, daddr, hnum);
-- 
2.3.2 (Apple Git-55)
