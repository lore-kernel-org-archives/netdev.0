From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 3/4] net/ipv4 - Convert IP4 address class macros
	to inline functions
Date: Mon, 19 Nov 2007 22:45:10 -0800
Message-ID: <1195541110.4675.96.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2518 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656AbXKTGpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:45:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions ipv4_is_<type>(__be32 addr)

Adds some type safety and arguably some readability

No change in compiled image size

Signed-off-by: Joe Perches <joe@perches.com>

---

 net/ipv4/arp.c          |    2 +-
 net/ipv4/datagram.c     |    2 +-
 net/ipv4/devinet.c      |    4 ++--
 net/ipv4/fib_frontend.c |    6 +++---
 net/ipv4/igmp.c         |   12 ++++++------
 net/ipv4/ip_gre.c       |   20 ++++++++++----------
 net/ipv4/ipmr.c         |    6 +++---
 net/ipv4/raw.c          |    2 +-
 net/ipv4/route.c        |   44 ++++++++++++++++++++++----------------------
 net/ipv4/udp.c          |    2 +-
 10 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 36d6798..aa76b98 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -797,7 +797,7 @@ static int arp_process(struct sk_buff *skb)
  *	Check for bad requests for 127.x.x.x and requests for multicast
  *	addresses.  If this is one such, delete it.
  */
-	if (LOOPBACK(tip) || MULTICAST(tip))
+	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		goto out;
 
 /*
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 0301dd4..303fca7 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -40,7 +40,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	oif = sk->sk_bound_dev_if;
 	saddr = inet->saddr;
-	if (MULTICAST(usin->sin_addr.s_addr)) {
+	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
 		if (!oif)
 			oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 55d199e..f82a8b0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -408,7 +408,7 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 		in_dev_hold(in_dev);
 		ifa->ifa_dev = in_dev;
 	}
-	if (LOOPBACK(ifa->ifa_local))
+	if (ipv4_is_loopback(ifa->ifa_local))
 		ifa->ifa_scope = RT_SCOPE_HOST;
 	return inet_insert_ifa(ifa);
 }
@@ -580,7 +580,7 @@ static __inline__ int inet_abc_len(__be32 addr)
 {
 	int rc = -1;	/* Something else, probably a multicast. */
 
-	if (ZERONET(addr))
+	if (ipv4_is_zeronet(addr))
 		rc = 0;
 	else {
 		__u32 haddr = ntohl(addr);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 732d8f0..db549d0 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -162,9 +162,9 @@ unsigned inet_addr_type(__be32 addr)
 	unsigned ret = RTN_BROADCAST;
 	struct fib_table *local_table;
 
-	if (ZERONET(addr) || BADCLASS(addr))
+	if (ipv4_is_zeronet(addr) || ipv4_is_badclass(addr))
 		return RTN_BROADCAST;
-	if (MULTICAST(addr))
+	if (ipv4_is_multicast(addr))
 		return RTN_MULTICAST;
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -682,7 +682,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 	if (ifa->ifa_broadcast && ifa->ifa_broadcast != htonl(0xFFFFFFFF))
 		fib_magic(RTM_NEWROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 
-	if (!ZERONET(prefix) && !(ifa->ifa_flags&IFA_F_SECONDARY) &&
+	if (!ipv4_is_zeronet(prefix) && !(ifa->ifa_flags&IFA_F_SECONDARY) &&
 	    (prefix != addr || ifa->ifa_prefixlen < 32)) {
 		fib_magic(RTM_NEWROUTE, dev->flags&IFF_LOOPBACK ? RTN_LOCAL :
 			  RTN_UNICAST, prefix, ifa->ifa_prefixlen, prim);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c560a93..b0f8905 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1742,7 +1742,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	int ifindex;
 	int count = 0;
 
-	if (!MULTICAST(addr))
+	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -1855,7 +1855,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	int leavegroup = 0;
 	int i, j, rv;
 
-	if (!MULTICAST(addr))
+	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -1985,7 +1985,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	struct ip_sf_socklist *newpsl, *psl;
 	int leavegroup = 0;
 
-	if (!MULTICAST(addr))
+	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 	if (msf->imsf_fmode != MCAST_INCLUDE &&
 	    msf->imsf_fmode != MCAST_EXCLUDE)
@@ -2068,7 +2068,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
 
-	if (!MULTICAST(addr))
+	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -2130,7 +2130,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (psin->sin_family != AF_INET)
 		return -EINVAL;
 	addr = psin->sin_addr.s_addr;
-	if (!MULTICAST(addr))
+	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -2180,7 +2180,7 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	struct ip_sf_socklist *psl;
 	int i;
 
-	if (!MULTICAST(loc_addr))
+	if (!ipv4_is_multicast(loc_addr))
 		return 1;
 
 	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 02b02a8..a4323cf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -176,7 +176,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(__be32 remote, __be32 local, __be3
 	}
 	for (t = tunnels_l[h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr ||
-		     (local == t->parms.iph.daddr && MULTICAST(local))) {
+		     (local == t->parms.iph.daddr && ipv4_is_multicast(local))) {
 			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
 				return t;
 		}
@@ -201,7 +201,7 @@ static struct ip_tunnel **__ipgre_bucket(struct ip_tunnel_parm *parms)
 
 	if (local)
 		prio |= 1;
-	if (remote && !MULTICAST(remote)) {
+	if (remote && !ipv4_is_multicast(remote)) {
 		prio |= 2;
 		h ^= HASH(remote);
 	}
@@ -367,7 +367,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 
 	read_lock(&ipgre_lock);
 	t = ipgre_tunnel_lookup(iph->daddr, iph->saddr, (flags&GRE_KEY) ? *(((__be32*)p) + (grehlen>>2) - 1) : 0);
-	if (t == NULL || t->parms.iph.daddr == 0 || MULTICAST(t->parms.iph.daddr))
+	if (t == NULL || t->parms.iph.daddr == 0 || ipv4_is_multicast(t->parms.iph.daddr))
 		goto out;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
@@ -619,7 +619,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (MULTICAST(iph->daddr)) {
+		if (ipv4_is_multicast(iph->daddr)) {
 			/* Looped back packet, drop it! */
 			if (((struct rtable*)skb->dst)->fl.iif == 0)
 				goto drop;
@@ -783,7 +783,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct rt6_info *rt6 = (struct rt6_info*)skb->dst;
 
 		if (rt6 && mtu < dst_mtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr && !MULTICAST(tunnel->parms.iph.daddr)) ||
+			if ((tunnel->parms.iph.daddr && !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
 				skb->dst->metrics[RTAX_MTU-1] = mtu;
@@ -956,7 +956,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 				t = netdev_priv(dev);
 
-				if (MULTICAST(p.iph.daddr))
+				if (ipv4_is_multicast(p.iph.daddr))
 					nflags = IFF_BROADCAST;
 				else if (p.iph.daddr)
 					nflags = IFF_POINTOPOINT;
@@ -1085,7 +1085,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 		memcpy(&iph->daddr, daddr, 4);
 		return t->hlen;
 	}
-	if (iph->daddr && !MULTICAST(iph->daddr))
+	if (iph->daddr && !ipv4_is_multicast(iph->daddr))
 		return t->hlen;
 
 	return -t->hlen;
@@ -1108,7 +1108,7 @@ static int ipgre_open(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (MULTICAST(t->parms.iph.daddr)) {
+	if (ipv4_is_multicast(t->parms.iph.daddr)) {
 		struct flowi fl = { .oif = t->parms.link,
 				    .nl_u = { .ip4_u =
 					      { .daddr = t->parms.iph.daddr,
@@ -1131,7 +1131,7 @@ static int ipgre_open(struct net_device *dev)
 static int ipgre_close(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
-	if (MULTICAST(t->parms.iph.daddr) && t->mlink) {
+	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev = inetdev_by_index(t->mlink);
 		if (in_dev) {
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
@@ -1196,7 +1196,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 		dev->flags |= IFF_POINTOPOINT;
 
 #ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (MULTICAST(iph->daddr)) {
+		if (ipv4_is_multicast(iph->daddr)) {
 			if (!iph->saddr)
 				return -EINVAL;
 			dev->flags = IFF_BROADCAST;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ba6c23c..2e396f6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -749,7 +749,7 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 		return 0;
 	}
 
-	if (!MULTICAST(mfc->mfcc_mcastgrp.s_addr))
+	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
 	c=ipmr_cache_alloc();
@@ -1461,7 +1461,7 @@ int pim_rcv_v1(struct sk_buff * skb)
 	   b. packet is not a NULL-REGISTER
 	   c. packet is not truncated
 	 */
-	if (!MULTICAST(encap->daddr) ||
+	if (!ipv4_is_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
 	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
 		goto drop;
@@ -1517,7 +1517,7 @@ static int pim_rcv(struct sk_buff * skb)
 	/* check if the inner packet is destined to mcast group */
 	encap = (struct iphdr *)(skb_transport_header(skb) +
 				 sizeof(struct pimreghdr));
-	if (!MULTICAST(encap->daddr) ||
+	if (!ipv4_is_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
 	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
 		goto drop;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 24c1d8f..217c983 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -473,7 +473,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (msg->msg_flags & MSG_DONTROUTE)
 		tos |= RTO_ONLINK;
 
-	if (MULTICAST(daddr)) {
+	if (ipv4_is_multicast(daddr)) {
 		if (!ipc.oif)
 			ipc.oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a9471b7..7b58150 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1030,7 +1030,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		return;
 
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev)
-	    || MULTICAST(new_gw) || BADCLASS(new_gw) || ZERONET(new_gw))
+	    || ipv4_is_multicast(new_gw) || ipv4_is_badclass(new_gw) || ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
@@ -1507,12 +1507,12 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (in_dev == NULL)
 		return -EINVAL;
 
-	if (MULTICAST(saddr) || BADCLASS(saddr) || LOOPBACK(saddr) ||
+	if (ipv4_is_multicast(saddr) || ipv4_is_badclass(saddr) || ipv4_is_loopback(saddr) ||
 	    skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (ZERONET(saddr)) {
-		if (!LOCAL_MCAST(daddr))
+	if (ipv4_is_zeronet(saddr)) {
+		if (!ipv4_is_local_multicast(daddr))
 			goto e_inval;
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else if (fib_validate_source(saddr, 0, tos, 0,
@@ -1554,7 +1554,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 #ifdef CONFIG_IP_MROUTE
-	if (!LOCAL_MCAST(daddr) && IN_DEV_MFORWARD(in_dev))
+	if (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
 		rth->u.dst.input = ip_mr_input;
 #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
@@ -1764,7 +1764,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
-	if (MULTICAST(saddr) || BADCLASS(saddr) || LOOPBACK(saddr))
+	if (ipv4_is_multicast(saddr) || ipv4_is_badclass(saddr) || ipv4_is_loopback(saddr))
 		goto martian_source;
 
 	if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
@@ -1773,10 +1773,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	/* Accept zero addresses only to limited broadcast;
 	 * I even do not know to fix it or not. Waiting for complains :-)
 	 */
-	if (ZERONET(saddr))
+	if (ipv4_is_zeronet(saddr))
 		goto martian_source;
 
-	if (BADCLASS(daddr) || ZERONET(daddr) || LOOPBACK(daddr))
+	if (ipv4_is_badclass(daddr) || ipv4_is_zeronet(daddr) || ipv4_is_loopback(daddr))
 		goto martian_destination;
 
 	/*
@@ -1823,7 +1823,7 @@ brd_input:
 	if (skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (ZERONET(saddr))
+	if (ipv4_is_zeronet(saddr))
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	else {
 		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
@@ -1951,7 +1951,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   Note, that multicast routers are not affected, because
 	   route cache entry is created eventually.
 	 */
-	if (MULTICAST(daddr)) {
+	if (ipv4_is_multicast(daddr)) {
 		struct in_device *in_dev;
 
 		rcu_read_lock();
@@ -1960,7 +1960,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 				ip_hdr(skb)->protocol);
 			if (our
 #ifdef CONFIG_IP_MROUTE
-			    || (!LOCAL_MCAST(daddr) && IN_DEV_MFORWARD(in_dev))
+			    || (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
 #endif
 			    ) {
 				rcu_read_unlock();
@@ -1986,14 +1986,14 @@ static inline int __mkroute_output(struct rtable **result,
 	u32 tos = RT_FL_TOS(oldflp);
 	int err = 0;
 
-	if (LOOPBACK(fl->fl4_src) && !(dev_out->flags&IFF_LOOPBACK))
+	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags&IFF_LOOPBACK))
 		return -EINVAL;
 
 	if (fl->fl4_dst == htonl(0xFFFFFFFF))
 		res->type = RTN_BROADCAST;
-	else if (MULTICAST(fl->fl4_dst))
+	else if (ipv4_is_multicast(fl->fl4_dst))
 		res->type = RTN_MULTICAST;
-	else if (BADCLASS(fl->fl4_dst) || ZERONET(fl->fl4_dst))
+	else if (ipv4_is_badclass(fl->fl4_dst) || ipv4_is_zeronet(fl->fl4_dst))
 		return -EINVAL;
 
 	if (dev_out->flags & IFF_LOOPBACK)
@@ -2073,7 +2073,7 @@ static inline int __mkroute_output(struct rtable **result,
 #ifdef CONFIG_IP_MROUTE
 		if (res->type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
-			    !LOCAL_MCAST(oldflp->fl4_dst)) {
+			    !ipv4_is_local_multicast(oldflp->fl4_dst)) {
 				rth->u.dst.input = ip_mr_input;
 				rth->u.dst.output = ip_mc_output;
 			}
@@ -2143,9 +2143,9 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 	if (oldflp->fl4_src) {
 		err = -EINVAL;
-		if (MULTICAST(oldflp->fl4_src) ||
-		    BADCLASS(oldflp->fl4_src) ||
-		    ZERONET(oldflp->fl4_src))
+		if (ipv4_is_multicast(oldflp->fl4_src) ||
+		    ipv4_is_badclass(oldflp->fl4_src) ||
+		    ipv4_is_zeronet(oldflp->fl4_src))
 			goto out;
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
@@ -2162,7 +2162,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 		 */
 
 		if (oldflp->oif == 0
-		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+		    && (ipv4_is_multicast(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2199,14 +2199,14 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 			goto out;	/* Wrong error code */
 		}
 
-		if (LOCAL_MCAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF)) {
+		if (ipv4_is_local_multicast(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF)) {
 			if (!fl.fl4_src)
 				fl.fl4_src = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
 			goto make_route;
 		}
 		if (!fl.fl4_src) {
-			if (MULTICAST(oldflp->fl4_dst))
+			if (ipv4_is_multicast(oldflp->fl4_dst))
 				fl.fl4_src = inet_select_addr(dev_out, 0,
 							      fl.fl4_scope);
 			else if (!oldflp->fl4_dst)
@@ -2489,7 +2489,7 @@ static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 #ifdef CONFIG_IP_MROUTE
 		__be32 dst = rt->rt_dst;
 
-		if (MULTICAST(dst) && !LOCAL_MCAST(dst) &&
+		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
 		    IPV4_DEVCONF_ALL(MC_FORWARDING)) {
 			int err = ipmr_get_route(skb, r, nowait);
 			if (err <= 0) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 03c400c..5eff306 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -621,7 +621,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		connected = 0;
 	}
 
-	if (MULTICAST(daddr)) {
+	if (ipv4_is_multicast(daddr)) {
 		if (!ipc.oif)
 			ipc.oif = inet->mc_index;
 		if (!saddr)


