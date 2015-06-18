From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Thu, 18 Jun 2015 09:45:07 -0500
Message-ID: <87fv5p2hzg.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506172216440.2649@ja.home.ssi.bg>
	<87wpz25a2q.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506180055030.3621@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57588 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932508AbbFROu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:50:27 -0400
In-Reply-To: <alpine.LFD.2.11.1506180055030.3621@ja.home.ssi.bg> (Julian
	Anastasov's message of "Thu, 18 Jun 2015 01:01:36 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cc' list trimmed as this is not longer about the original patch
submission.

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Wed, 17 Jun 2015, Eric W. Biederman wrote:
>
>> p.s.  I do have my patch that I can toss in your direction if you are
>> interested.
>
> 	Of course... I'll be able to check it after 8 hours...


My incremental patch for ipvs on top of everything else I have pushed
out looks like this:

From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 12 Jun 2015 18:34:12 -0500
Subject: [PATCH] ipvs: Pass struct net down to where it is needed and used

Pass struct net down to where it is used and stop guessing
which network namespace should be used.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                     |  45 +++---------
 net/netfilter/ipvs/ip_vs_conn.c         |  11 ++-
 net/netfilter/ipvs/ip_vs_core.c         | 118 ++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_ftp.c          |   8 +--
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   9 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   8 +--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_xmit.c         |  51 ++++++++------
 net/netfilter/xt_ipvs.c                 |   2 +-
 10 files changed, 108 insertions(+), 154 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4e3731ee4eac..a556d14cff70 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -35,37 +35,6 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 	return net->ipvs;
 }
 
-/* Get net ptr from skb in traffic cases
- * use skb_sknet when call is from userland (ioctl or netlink)
- */
-static inline struct net *skb_net(const struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-#ifdef CONFIG_IP_VS_DEBUG
-	/*
-	 * This is used for debug only.
-	 * Start with the most likely hit
-	 * End with BUG
-	 */
-	if (likely(skb->dev && dev_net(skb->dev)))
-		return dev_net(skb->dev);
-	if (skb_dst(skb) && skb_dst(skb)->dev)
-		return dev_net(skb_dst(skb)->dev);
-	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
-		      __func__, __LINE__);
-	if (likely(skb->sk && sock_net(skb->sk)))
-		return sock_net(skb->sk);
-	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
-		__func__, __LINE__);
-	BUG();
-#else
-	return dev_net(skb->dev ? : skb_dst(skb)->dev);
-#endif
-#else
-	return &init_net;
-#endif
-}
-
 static inline struct net *skb_sknet(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_NS
@@ -441,19 +410,19 @@ struct ip_vs_protocol {
 
 	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
 
-	int (*conn_schedule)(int af, struct sk_buff *skb,
+	int (*conn_schedule)(struct net *net, int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp,
 			     struct ip_vs_iphdr *iph);
 
 	struct ip_vs_conn *
-	(*conn_in_get)(int af,
+	(*conn_in_get)(struct net *net, int af,
 		       const struct sk_buff *skb,
 		       const struct ip_vs_iphdr *iph,
 		       int inverse);
 
 	struct ip_vs_conn *
-	(*conn_out_get)(int af,
+	(*conn_out_get)(struct net *net, int af,
 			const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph,
 			int inverse);
@@ -1179,13 +1148,15 @@ static inline void ip_vs_conn_fill_param(struct net *net, int af, int protocol,
 struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
 struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
-struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+struct ip_vs_conn * ip_vs_conn_in_get_proto(struct net *net, int af,
+					    const struct sk_buff *skb,
 					    const struct ip_vs_iphdr *iph,
 					    int inverse);
 
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
-struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+struct ip_vs_conn * ip_vs_conn_out_get_proto(struct net *net, int af,
+					     const struct sk_buff *skb,
 					     const struct ip_vs_iphdr *iph,
 					     int inverse);
 
@@ -1215,7 +1186,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 const char *ip_vs_state_name(__u16 proto, int state);
 
-void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
+void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
 int ip_vs_check_template(struct ip_vs_conn *ct);
 void ip_vs_random_dropentry(struct net *net);
 int ip_vs_conn_init(void);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b0f7b626b56d..4deb4a0d2247 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -314,12 +314,11 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 }
 
 static int
-ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_fill_param_proto(struct net *net, int af, const struct sk_buff *skb,
 			    const struct ip_vs_iphdr *iph,
 			    int inverse, struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
-	struct net *net = skb_net(skb);
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
@@ -335,12 +334,12 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 }
 
 struct ip_vs_conn *
-ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_in_get_proto(struct net *net, int af, const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(net, af, skb, iph, inverse, &p))
 		return NULL;
 
 	return ip_vs_conn_in_get(&p);
@@ -439,12 +438,12 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 }
 
 struct ip_vs_conn *
-ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+ip_vs_conn_out_get_proto(struct net *net, int af, const struct sk_buff *skb,
 			 const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(net, af, skb, iph, inverse, &p))
 		return NULL;
 
 	return ip_vs_conn_out_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2ea140c9a81c..4dec27e135cc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -112,7 +112,7 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
@@ -146,7 +146,7 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
@@ -439,7 +439,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Do not schedule replies from local real server.
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (cp = pp->conn_in_get(svc->af, skb, iph, 1))) {
+	    (cp = pp->conn_in_get(svc->net, svc->af, skb, iph, 1))) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
@@ -518,7 +518,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 {
 	__be16 _ports[2], *pptr;
 #ifdef CONFIG_SYSCTL
-	struct net *net;
 	struct netns_ipvs *ipvs;
 	int unicast;
 #endif
@@ -529,19 +528,17 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 #ifdef CONFIG_SYSCTL
-	net = skb_net(skb);
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
 		unicast = ipv6_addr_type(&iph->daddr.in6) & IPV6_ADDR_UNICAST;
 	else
 #endif
-		unicast = (inet_addr_type(net, iph->daddr.ip) == RTN_UNICAST);
+		unicast = (inet_addr_type(svc->net, iph->daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	ipvs = net_ipvs(net);
+	ipvs = net_ipvs(svc->net);
 	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
 		int ret;
 		struct ip_vs_conn *cp;
@@ -598,11 +595,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6) {
-		if (!skb->dev) {
-			struct net *net_ = dev_net(skb_dst(skb)->dev);
-
-			skb->dev = net_->loopback_dev;
-		}
+		if (!skb->dev)
+			skb->dev = svc->net->loopback_dev;
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 	} else
 #endif
@@ -613,9 +607,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 #ifdef CONFIG_SYSCTL
 
-static int sysctl_snat_reroute(struct sk_buff *skb)
+static int sysctl_snat_reroute(struct net *net)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	return ipvs->sysctl_snat_reroute;
 }
 
@@ -632,7 +626,7 @@ static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
 
 #else
 
-static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
+static int sysctl_snat_reroute(struct net *net) { return 0; }
 static int sysctl_nat_icmp_send(struct net *net) { return 0; }
 static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
 
@@ -652,12 +646,13 @@ static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
 	return IP_DEFRAG_VS_OUT;
 }
 
-static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
+static inline int ip_vs_gather_frags(struct net *net, struct sk_buff *skb,
+				     u_int32_t user)
 {
 	int err;
 
 	local_bh_disable();
-	err = ip_defrag(skb_net(skb), skb, user);
+	err = ip_defrag(net, skb, user);
 	local_bh_enable();
 	if (!err)
 		ip_send_check(ip_hdr(skb));
@@ -665,10 +660,10 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
-static int ip_vs_route_me_harder(int af, struct sk_buff *skb,
+static int ip_vs_route_me_harder(struct net *net, int af, struct sk_buff *skb,
 				 unsigned int hooknum)
 {
-	if (!sysctl_snat_reroute(skb))
+	if (!sysctl_snat_reroute(net))
 		return 0;
 	/* Reroute replies only to remote clients (FORWARD and LOCAL_OUT) */
 	if (NF_INET_LOCAL_IN == hooknum)
@@ -836,7 +831,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 #endif
 		ip_vs_nat_icmp(skb, pp, cp, 1);
 
-	if (ip_vs_route_me_harder(af, skb, hooknum))
+	if (ip_vs_route_me_harder(ip_vs_conn_net(cp), af, skb, hooknum))
 		goto out;
 
 	/* do the statistics and put it back */
@@ -860,7 +855,7 @@ out:
  *	Find any that might be relevant, check against existing connections.
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
-static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
+static int ip_vs_out_icmp(struct net *net, struct sk_buff *skb, int *related,
 			  unsigned int hooknum)
 {
 	struct iphdr *iph;
@@ -876,7 +871,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(net, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -925,7 +920,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	ip_vs_fill_ip4hdr(cih, &ciph);
 	ciph.len += offset;
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
+	cp = pp->conn_out_get(net, AF_INET, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -935,7 +930,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
+static int ip_vs_out_icmp_v6(struct net *net, struct sk_buff *skb, int *related,
 			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
 	struct icmp6hdr	_icmph, *ic;
@@ -989,7 +984,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, &ciph, 1);
+	cp = pp->conn_out_get(net, AF_INET6, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1115,7 +1110,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_vs_route_me_harder(af, skb, hooknum))
+	if (ip_vs_route_me_harder(ip_vs_conn_net(cp), af, skb, hooknum))
 		goto drop;
 
 	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
@@ -1143,9 +1138,8 @@ drop:
  *	Check if outgoing packet belongs to the established ip_vs_conn.
  */
 static unsigned int
-ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
+ip_vs_out(struct net *net, unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1170,7 +1164,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(!skb_dst(skb)))
 		return NF_ACCEPT;
 
-	net = skb_net(skb);
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
@@ -1179,7 +1172,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_out_icmp_v6(skb, &related,
+			int verdict = ip_vs_out_icmp_v6(net, skb, &related,
 							hooknum, &iph);
 
 			if (related)
@@ -1189,7 +1182,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
-			int verdict = ip_vs_out_icmp(skb, &related, hooknum);
+			int verdict = ip_vs_out_icmp(net, skb, &related, hooknum);
 
 			if (related)
 				return verdict;
@@ -1205,7 +1198,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (af == AF_INET)
 #endif
 		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
-			if (ip_vs_gather_frags(skb,
+			if (ip_vs_gather_frags(net, skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
@@ -1215,7 +1208,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(af, skb, &iph, 0);
+	cp = pp->conn_out_get(net, af, skb, &iph, 0);
 
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
@@ -1274,7 +1267,7 @@ static unsigned int
 ip_vs_reply4(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET);
+	return ip_vs_out(state->net, state->hook, skb, AF_INET);
 }
 
 /*
@@ -1285,7 +1278,7 @@ static unsigned int
 ip_vs_local_reply4(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET);
+	return ip_vs_out(state->net, state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1299,7 +1292,7 @@ static unsigned int
 ip_vs_reply6(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET6);
+	return ip_vs_out(state->net, state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1310,7 +1303,7 @@ static unsigned int
 ip_vs_local_reply6(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET6);
+	return ip_vs_out(state->net, state->hook, skb, AF_INET6);
 }
 
 #endif
@@ -1322,9 +1315,8 @@ ip_vs_local_reply6(void *priv, struct sk_buff *skb,
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
 static int
-ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
+ip_vs_in_icmp(struct net *net, struct sk_buff *skb, int *related, unsigned int hooknum)
 {
-	struct net *net = NULL;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -1339,7 +1331,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(net, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -1373,8 +1365,6 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (cih == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
-	net = skb_net(skb);
-
 	/* Special case for errors for IPIP packets */
 	ipip = false;
 	if (cih->protocol == IPPROTO_IPIP) {
@@ -1410,7 +1400,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, ipip ? 0 : 1);
+	cp = pp->conn_in_get(net, AF_INET, skb, &ciph, ipip ? 0 : 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1443,7 +1433,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
 				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
-			ipv4_update_pmtu(skb, dev_net(skb->dev),
+			ipv4_update_pmtu(skb, net,
 					 mtu, 0, 0, 0, 0);
 			/* Client uses PMTUD? */
 			if (!(frag_off & htons(IP_DF)))
@@ -1495,10 +1485,9 @@ out:
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
+static int ip_vs_in_icmp_v6(struct net *net, struct sk_buff *skb, int *related,
 			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
-	struct net *net = NULL;
 	struct ipv6hdr _ip6h, *ip6h;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
@@ -1547,7 +1536,6 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	if (ciph.protocol < 0)
 		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
 
-	net = skb_net(skb);
 	pd = ip_vs_proto_data_get(net, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
@@ -1563,7 +1551,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	/* The embedded headers contain source and dest in reverse order
 	 * if not from localhost
 	 */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
+	cp = pp->conn_in_get(net, AF_INET6, skb, &ciph,
 			     (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1);
 
 	if (!cp)
@@ -1598,9 +1586,8 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
  *	and send it on its way...
  */
 static unsigned int
-ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
+ip_vs_in(struct net *net, unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1629,7 +1616,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		return NF_ACCEPT;
 	}
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
@@ -1650,7 +1636,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
+			int verdict = ip_vs_in_icmp_v6(net, skb, &related, hooknum,
 						       &iph);
 
 			if (related)
@@ -1660,7 +1646,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
-			int verdict = ip_vs_in_icmp(skb, &related, hooknum);
+			int verdict = ip_vs_in_icmp(net, skb, &related, hooknum);
 
 			if (related)
 				return verdict;
@@ -1674,7 +1660,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(af, skb, &iph, 0);
+	cp = pp->conn_in_get(net, af, skb, &iph, 0);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs &&
@@ -1695,7 +1681,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		int v;
 
 		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!pp->conn_schedule(net, af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
@@ -1767,7 +1753,7 @@ static unsigned int
 ip_vs_remote_request4(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET);
+	return ip_vs_in(state->net, state->hook, skb, AF_INET);
 }
 
 /*
@@ -1778,7 +1764,7 @@ static unsigned int
 ip_vs_local_request4(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET);
+	return ip_vs_in(state->net, state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1791,7 +1777,7 @@ static unsigned int
 ip_vs_remote_request6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET6);
+	return ip_vs_in(state->net, state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1802,7 +1788,7 @@ static unsigned int
 ip_vs_local_request6(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET6);
+	return ip_vs_in(state->net, state->hook, skb, AF_INET6);
 }
 
 #endif
@@ -1822,19 +1808,17 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	int r;
-	struct net *net;
 	struct netns_ipvs *ipvs;
 
 	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
+	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp(skb, &r, state->hook);
+	return ip_vs_in_icmp(state->net, skb, &r, state->hook);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1843,7 +1827,6 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	int r;
-	struct net *net;
 	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iphdr;
 
@@ -1852,12 +1835,11 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
+	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, state->hook, &iphdr);
+	return ip_vs_in_icmp_v6(state->net, skb, &r, state->hook, &iphdr);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 5d3daae98bf0..eed97263e733 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -181,7 +181,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
-	struct net *net;
 
 	*diff = 0;
 
@@ -289,9 +288,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 * would be adjusted twice.
 		 */
 
-		net = skb_net(skb);
 		cp->app_data = NULL;
-		ip_vs_tcp_conn_listen(net, n_cp);
+		ip_vs_tcp_conn_listen(n_cp);
 		ip_vs_conn_put(n_cp);
 		return ret;
 	}
@@ -320,7 +318,6 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
-	struct net *net;
 
 	/* no diff required for incoming packets */
 	*diff = 0;
@@ -413,8 +410,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	/*
 	 *	Move tunnel to listen state
 	 */
-	net = skb_net(skb);
-	ip_vs_tcp_conn_listen(net, n_cp);
+	ip_vs_tcp_conn_listen(n_cp);
 	ip_vs_conn_put(n_cp);
 
 	return 1;
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5de3dd312c0f..437d96d43597 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -56,13 +56,12 @@ ah_esp_conn_fill_param_proto(struct net *net, int af,
 }
 
 static struct ip_vs_conn *
-ah_esp_conn_in_get(int af, const struct sk_buff *skb,
+ah_esp_conn_in_get(struct net *net, int af, const struct sk_buff *skb,
 		   const struct ip_vs_iphdr *iph,
 		   int inverse)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct net *net = skb_net(skb);
 
 	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
 	cp = ip_vs_conn_in_get(&p);
@@ -84,12 +83,11 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-ah_esp_conn_out_get(int af, const struct sk_buff *skb,
+ah_esp_conn_out_get(struct net *net, int af, const struct sk_buff *skb,
 		    const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct net *net = skb_net(skb);
 
 	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
 	cp = ip_vs_conn_out_get(&p);
@@ -107,7 +105,8 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 
 
 static int
-ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+ah_esp_conn_schedule(struct net *net, int af, struct sk_buff *skb,
+		     struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp,
 		     struct ip_vs_iphdr *iph)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 5b84c0b56642..8baf1eddeed8 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -9,11 +9,11 @@
 #include <net/ip_vs.h>
 
 static int
-sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+sctp_conn_schedule(struct net *net, int af, struct sk_buff *skb,
+		   struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
 		   struct ip_vs_iphdr *iph)
 {
-	struct net *net;
 	struct ip_vs_service *svc;
 	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
@@ -32,7 +32,6 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		return 0;
 	}
 
-	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	rcu_read_lock();
 	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8e92beb0cca9..7651ef2c9a87 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -32,11 +32,11 @@
 #include <net/ip_vs.h>
 
 static int
-tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+tcp_conn_schedule(struct net *net, int af, struct sk_buff *skb,
+		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
 		  struct ip_vs_iphdr *iph)
 {
-	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct netns_ipvs *ipvs;
@@ -46,7 +46,6 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		*verdict = NF_DROP;
 		return 0;
 	}
-	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	rcu_read_lock();
@@ -653,8 +652,9 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 /*
  *	Set LISTEN timeout. (ip_vs_conn_put will setup timer)
  */
-void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
+void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp)
 {
+	struct net *net = ip_vs_conn_net(cp);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 
 	spin_lock_bh(&cp->lock);
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index b62a3c0ff9bf..6eb0c3be3859 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -29,11 +29,11 @@
 #include <net/ip6_checksum.h>
 
 static int
-udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+udp_conn_schedule(struct net *net, int af, struct sk_buff *skb,
+		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
 		  struct ip_vs_iphdr *iph)
 {
-	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 
@@ -43,7 +43,6 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		*verdict = NF_DROP;
 		return 0;
 	}
-	net = skb_net(skb);
 	rcu_read_lock();
 	svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
 				 &iph->daddr, uh->dest);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9f8130b33c32..6146f5461431 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -213,14 +213,13 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
 		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 }
 
-static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
+static inline bool ensure_mtu_is_adequate(struct net *net, int skb_af,
+					  int rt_mode,
 					  struct ip_vs_iphdr *ipvsh,
 					  struct sk_buff *skb, int mtu)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (skb_af == AF_INET6) {
-		struct net *net = dev_net(skb_dst(skb)->dev);
-
 		if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
 			if (!skb->dev)
 				skb->dev = net->loopback_dev;
@@ -234,7 +233,7 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 	} else
 #endif
 	{
-		struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+		struct netns_ipvs *ipvs = net_ipvs(net);
 
 		/* If we're going to tunnel the packet and pmtu discovery
 		 * is disabled, we'll just fragment it anyway
@@ -257,11 +256,11 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 
 /* Get route to destination or remote server */
 static int
-__ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt(struct net *net, int skb_af, struct sk_buff *skb,
+		   struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr,
 		   struct ip_vs_iphdr *ipvsh)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
 	int mtu;
@@ -337,7 +336,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
+	if (!ensure_mtu_is_adequate(net, skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
 
 	skb_dst_drop(skb);
@@ -403,11 +402,11 @@ out_err:
  * Get route to destination or remote server
  */
 static int
-__ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt_v6(struct net *net, int skb_af, struct sk_buff *skb,
+		      struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
 		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
 	struct dst_entry *dst;
@@ -485,7 +484,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
+	if (!ensure_mtu_is_adequate(net, skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
 
 	skb_dst_drop(skb);
@@ -592,7 +591,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
+	if (__ip_vs_get_out_rt(ip_vs_conn_net(cp), cp->af, skb, NULL,
+			       iph->daddr,
 			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
 
@@ -622,7 +622,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &ipvsh->daddr.in6, NULL,
+	if (__ip_vs_get_out_rt_v6(ip_vs_conn_net(cp), cp->af, skb, NULL,
+				  &ipvsh->daddr.in6, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
@@ -669,7 +670,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	was_input = rt_is_input_route(skb_rtable(skb));
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				   cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
@@ -757,7 +759,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -928,7 +931,7 @@ int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct net *net = skb_net(skb);
+	struct net *net = ip_vs_conn_net(cp);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
@@ -945,7 +948,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				   cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
@@ -1039,7 +1043,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1126,7 +1131,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				   cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
@@ -1165,7 +1171,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1234,7 +1241,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
+	local = __ip_vs_get_out_rt(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				   cp->daddr.ip, rt_mode,
 				   NULL, iph);
 	if (local < 0)
 		goto tx_error;
@@ -1326,7 +1334,8 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(ip_vs_conn_net(cp), cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      NULL, ipvsh, 0, rt_mode);
 	if (local < 0)
 		goto tx_error;
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 8d47c3780fda..16884904b70b 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, &iph, 1 /* inverse */);
+	cp = pp->conn_out_get(par->net, family, skb, &iph, 1 /* inverse */);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;
-- 
2.2.1
