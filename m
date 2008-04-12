From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-2.6.26]: IPv6 Updates
Date: Sat, 12 Apr 2008 13:49:09 +0900 (JST)
Message-ID: <20080412.134909.53979908.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33337 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbYDLEr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 00:47:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following changes on top of net-2.6.26 tree:
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-misc-20080412b

Thank you.

---

HEADLINES
---------

    [IPV6]: Kill several warnings without CONFIG_IPV6_MROUTE.
    [IPV6] SIT: Sparse: Use NULL pointer instead of 0.
    [IPV6]: Sparse: Reuse previous delaration where appropriate.
    [IPV6] FIB_RULE: Sparse: fib6_rules_cleanup() is of void.
    [IPV6]: Use ipv6_addr_equal() instead of !ipv6_addr_cmp().
    [IPV6]: Use XOR and OR rather than mutiple ands for ipv6 address comparisons.
    [IPV6] ADDRCONF: Uninline ipv6_addr_hash().
    [IPV6] ADDRCONF: Uninline ipv6_isatap_eui64().
    [IPV6]: Make address arguments const.
    [IPV6]: Define constants for link-local multicast addresses.
    [IPV6]: Use in6addr_any where appropriate.
    [IPV6] MIP6: Use our standard definitions for paddings.
    [IPV6]: Check length of optval provided by user in setsockopt().
    [IPV6]: Check length of int/boolean optval provided by user in setsockopt().
    [IPV6] MROUTE: Adjust IPV6 multicast routing module to use mroute6 header declarations.
    [IPv6]: Change IPv6 unspecified destination address to ::1 for raw and un-connected sockets
    [IPV6]: Fix IPV6_RECVERR for connected raw sockets.

DIFFSTAT
--------

 include/linux/in6.h      |    8 ++++
 include/net/addrconf.h   |   87 ++++++++++++----------------------------------
 include/net/ip6_route.h  |    6 ++-
 include/net/ipv6.h       |   26 ++++++--------
 include/net/mip6.h       |    3 --
 include/net/ndisc.h      |   14 ++++---
 net/ipv6/addrconf.c      |   82 +++++++++++++++++++++++++++++--------------
 net/ipv6/fib6_rules.c    |    2 +
 net/ipv6/ip6_input.c     |   26 ++++++--------
 net/ipv6/ip6_output.c    |    2 +
 net/ipv6/ip6mr.c         |   37 +++++++-------------
 net/ipv6/ipv6_sockglue.c |   81 ++++++++++++++++++++++++++++++++++++-------
 net/ipv6/mcast.c         |   60 ++++++++++++++------------------
 net/ipv6/mip6.c          |    4 +-
 net/ipv6/ndisc.c         |   27 +++++++-------
 net/ipv6/raw.c           |   20 ++++-------
 net/ipv6/route.c         |    6 ++-
 net/ipv6/sit.c           |    2 +
 net/ipv6/tcp_ipv6.c      |    4 +-
 net/ipv6/udp.c           |    5 ++-
 20 files changed, 264 insertions(+), 238 deletions(-)

CHANGESETS
----------

commit aba6096b21e151bc55da74605fe77b92cfcccb12
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:41:26 2008 +0900

    [IPV6]: Kill several warnings without CONFIG_IPV6_MROUTE.
    
    Pointed out by Andrew Morton <akpm@linux-foundation.org>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 09a3201..4e5c861 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -262,21 +262,23 @@ int ip6_mc_input(struct sk_buff *skb)
 			 * is for MLD (0x0000).
 			 */
 			if ((ptr[2] | ptr[3]) == 0) {
+				deliver = 0;
+
 				if (!ipv6_ext_hdr(nexthdr)) {
 					/* BUG */
-					goto discard;
+					goto out;
 				}
 				offset = ipv6_skip_exthdr(skb, sizeof(*hdr),
 							  &nexthdr);
 				if (offset < 0)
-					goto discard;
+					goto out;
 
 				if (nexthdr != IPPROTO_ICMPV6)
-					goto discard;
+					goto out;
 
 				if (!pskb_may_pull(skb, (skb_network_header(skb) +
 						   offset + 1 - skb->data)))
-					goto discard;
+					goto out;
 
 				icmp6 = (struct icmp6hdr *)(skb_network_header(skb) + offset);
 
@@ -285,12 +287,9 @@ int ip6_mc_input(struct sk_buff *skb)
 				case ICMPV6_MGM_REPORT:
 				case ICMPV6_MGM_REDUCTION:
 				case ICMPV6_MLD2_REPORT:
+					deliver = 1;
 					break;
-				default:
-					/* Bogus */
-					goto discard;
 				}
-				deliver = 1;
 				goto out;
 			}
 			/* unknown RA - process it normally */
@@ -308,15 +307,14 @@ int ip6_mc_input(struct sk_buff *skb)
 			ip6_mr_input(skb2);
 		}
 	}
-#endif
 out:
-	if (likely(deliver)) {
+#endif
+	if (likely(deliver))
 		ip6_input(skb);
-		return 0;
+	else {
+		/* discard */
+		kfree_skb(skb);
 	}
-discard:
-	/* discard */
-	kfree_skb(skb);
 
 	return 0;
 }

---
commit 02e10b90cd478bda81b4644102b0009bcd1d14ab
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:41:27 2008 +0900

    [IPV6] SIT: Sparse: Use NULL pointer instead of 0.
    
    | net/ipv6/sit.c:382:42: warning: Using plain integer as NULL pointer
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cc16fe0..91e46fb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -379,7 +379,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 		dev_put(dev);
 	} else {
 		ipip6_tunnel_unlink(netdev_priv(dev));
-		ipip6_tunnel_del_prl(netdev_priv(dev), 0);
+		ipip6_tunnel_del_prl(netdev_priv(dev), NULL);
 		dev_put(dev);
 	}
 }

---
commit a9f83bf3858672164ed531cbc60ee9082d21d53f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:41:28 2008 +0900

    [IPV6]: Sparse: Reuse previous delaration where appropriate.
    
    | net/ipv6/ipv6_sockglue.c:162:16: warning: symbol 'net' shadows an earlier one
    | net/ipv6/ipv6_sockglue.c:111:13: originally declared here
    | net/ipv6/ipv6_sockglue.c:175:16: warning: symbol 'net' shadows an earlier one
    | net/ipv6/ipv6_sockglue.c:111:13: originally declared here
    | net/ipv6/ip6mr.c:1241:10: warning: symbol 'ret' shadows an earlier one
    | net/ipv6/ip6mr.c:1163:6: originally declared here
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index da673ef..4330421 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1238,7 +1238,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 #ifdef CONFIG_IPV6_PIMSM_V2
 	case MRT6_PIM:
 	{
-		int v, ret;
+		int v;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
 		v = !!v;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9962410..bf96953 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -159,8 +159,6 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 			if (sk->sk_protocol == IPPROTO_TCP) {
 				struct inet_connection_sock *icsk = inet_csk(sk);
-				struct net *net = sock_net(sk);
-
 				local_bh_disable();
 				sock_prot_inuse_add(net, sk->sk_prot, -1);
 				sock_prot_inuse_add(net, &tcp_prot, 1);
@@ -172,7 +170,6 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 				tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 			} else {
 				struct proto *prot = &udp_prot;
-				struct net *net = sock_net(sk);
 
 				if (sk->sk_protocol == IPPROTO_UDPLITE)
 					prot = &udplite_prot;

---
commit ff4e1fb0be7386e97580d50f09a804b33b58377a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:41:28 2008 +0900

    [IPV6] FIB_RULE: Sparse: fib6_rules_cleanup() is of void.
    
    | net/ipv6/fib6_rules.c:319:2: warning: returning void-valued expression
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index cac5807..8d05527 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -316,5 +316,5 @@ int __init fib6_rules_init(void)
 
 void fib6_rules_cleanup(void)
 {
-	return unregister_pernet_subsys(&fib6_rules_net_ops);
+	unregister_pernet_subsys(&fib6_rules_net_ops);
 }

---
commit caad295fed8b652c67159911d11c65d476351d2f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:07 2008 +0900

    [IPV6]: Use ipv6_addr_equal() instead of !ipv6_addr_cmp().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9241583..ed99380 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2951,7 +2951,7 @@ int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
-		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
+		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    (ifp->flags & IFA_F_HOMEADDRESS)) {
 			ret = 1;
 			break;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8ebf6de..80eab71 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -543,7 +543,7 @@ static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 		return NULL;
 
 	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, addr) == 0)
+		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, addr))
 			return &tp->md5sig_info->keys6[i].base;
 	}
 	return NULL;
@@ -632,7 +632,7 @@ static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
 	int i;
 
 	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, peer) == 0) {
+		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, peer)) {
 			/* Free the key */
 			kfree(tp->md5sig_info->keys6[i].base.key);
 			tp->md5sig_info->entries6--;

---
commit fed85383ac34d82e96f227ce49ce68117cec23a0
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 11 20:17:55 2008 +0900

    [IPV6]: Use XOR and OR rather than mutiple ands for ipv6 address comparisons.
    
    ipv6_addr_equal(), ipv6_addr_v4mapped(),
    ipv6_addr_is_ll_all_{nodes,routers}(),
    ipv6_masked_addr_cmp()
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index bdcc863..1dc9d03 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -240,18 +240,16 @@ static inline int ipv6_addr_is_multicast(const struct in6_addr *addr)
 
 static inline int ipv6_addr_is_ll_all_nodes(const struct in6_addr *addr)
 {
-	return (addr->s6_addr32[0] == htonl(0xff020000) &&
-		addr->s6_addr32[1] == 0 &&
-		addr->s6_addr32[2] == 0 &&
-		addr->s6_addr32[3] == htonl(0x00000001));
+	return (((addr->s6_addr32[0] ^ htonl(0xff020000)) |
+		addr->s6_addr32[1] | addr->s6_addr32[2] |
+		(addr->s6_addr32[3] ^ htonl(0x00000001))) == 0);
 }
 
 static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 {
-	return (addr->s6_addr32[0] == htonl(0xff020000) &&
-		addr->s6_addr32[1] == 0 &&
-		addr->s6_addr32[2] == 0 &&
-		addr->s6_addr32[3] == htonl(0x00000002));
+	return (((addr->s6_addr32[0] ^ htonl(0xff020000)) |
+		addr->s6_addr32[1] | addr->s6_addr32[2] |
+		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0);
 }
 
 static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5738c1c..a0c285b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -280,12 +280,10 @@ static inline int
 ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
 		     const struct in6_addr *a2)
 {
-	unsigned int i;
-
-	for (i = 0; i < 4; i++)
-		if ((a1->s6_addr32[i] ^ a2->s6_addr32[i]) & m->s6_addr32[i])
-			return 1;
-	return 0;
+	return (!!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
+		   ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
+		   ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
+		   ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3])));
 }
 
 static inline void ipv6_addr_copy(struct in6_addr *a1, const struct in6_addr *a2)
@@ -320,10 +318,10 @@ static inline void ipv6_addr_set(struct in6_addr *addr,
 static inline int ipv6_addr_equal(const struct in6_addr *a1,
 				  const struct in6_addr *a2)
 {
-	return (a1->s6_addr32[0] == a2->s6_addr32[0] &&
-		a1->s6_addr32[1] == a2->s6_addr32[1] &&
-		a1->s6_addr32[2] == a2->s6_addr32[2] &&
-		a1->s6_addr32[3] == a2->s6_addr32[3]);
+	return (((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
+		 (a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
+		 (a1->s6_addr32[2] ^ a2->s6_addr32[2]) |
+		 (a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0);
 }
 
 static inline int __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
@@ -371,8 +369,8 @@ static inline int ipv6_addr_any(const struct in6_addr *a)
 
 static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 {
-	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 &&
-		 a->s6_addr32[2] == htonl(0x0000ffff));
+	return ((a->s6_addr32[0] | a->s6_addr32[1] |
+		 (a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0);
 }
 
 /*

---
commit 3eb84f49290461e2b83d6e8ee1f3f0e504340c8b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:08 2008 +0900

    [IPV6] ADDRCONF: Uninline ipv6_addr_hash().
    
    The function is only used in net/ipv6/addrconf.c.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 1dc9d03..1ba4e5b 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -189,25 +189,6 @@ static inline void in6_ifa_put(struct inet6_ifaddr *ifp)
 #define in6_ifa_hold(ifp)	atomic_inc(&(ifp)->refcnt)
 
 
-/*
- *	Hash function taken from net_alias.c
- */
-
-static __inline__ u8 ipv6_addr_hash(const struct in6_addr *addr)
-{	
-	__u32 word;
-
-	/* 
-	 * We perform the hash function over the last 64 bits of the address
-	 * This will include the IEEE address token on links that support it.
-	 */
-
-	word = (__force u32)(addr->s6_addr32[2] ^ addr->s6_addr32[3]);
-	word ^= (word >> 16);
-	word ^= (word >> 8);
-
-	return ((word ^ (word >> 4)) & 0x0f);
-}
 
 /*
  *	compute link-local solicited-node multicast address
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ed99380..b17fafc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -541,6 +541,25 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 	*ifap = ifp;
 }
 
+/*
+ *	Hash function taken from net_alias.c
+ */
+static u8 ipv6_addr_hash(const struct in6_addr *addr)
+{
+	__u32 word;
+
+	/*
+	 * We perform the hash function over the last 64 bits of the address
+	 * This will include the IEEE address token on links that support it.
+	 */
+
+	word = (__force u32)(addr->s6_addr32[2] ^ addr->s6_addr32[3]);
+	word ^= (word >> 16);
+	word ^= (word >> 8);
+
+	return ((word ^ (word >> 4)) & 0x0f);
+}
+
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *

---
commit dfd982baff01c18e3e1717c97fdac79c28f105ce
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:09 2008 +0900

    [IPV6] ADDRCONF: Uninline ipv6_isatap_eui64().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 1ba4e5b..8317c1b 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -233,20 +233,7 @@ static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0);
 }
 
-static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
-{
-	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
-		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
-		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
-		  ipv4_is_anycast_6to4(addr) || ipv4_is_private_192(addr) ||
-		  ipv4_is_test_198(addr) || ipv4_is_multicast(addr) ||
-		  ipv4_is_lbcast(addr)) ? 0x00 : 0x02;
-	eui[1] = 0;
-	eui[2] = 0x5E;
-	eui[3] = 0xFE;
-	memcpy (eui+4, &addr, 4);
-	return 0;
-}
+extern int __ipv6_isatap_ifid(u8 *eui, __be32 addr);
 
 static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b17fafc..d15f3e0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1494,6 +1494,29 @@ static int addrconf_ifid_infiniband(u8 *eui, struct net_device *dev)
 	return 0;
 }
 
+int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
+{
+	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
+		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
+		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
+		  ipv4_is_anycast_6to4(addr) || ipv4_is_private_192(addr) ||
+		  ipv4_is_test_198(addr) || ipv4_is_multicast(addr) ||
+		  ipv4_is_lbcast(addr)) ? 0x00 : 0x02;
+	eui[1] = 0;
+	eui[2] = 0x5E;
+	eui[3] = 0xFE;
+	memcpy(eui + 4, &addr, 4);
+	return 0;
+}
+EXPORT_SYMBOL(__ipv6_isatap_ifid);
+
+static int addrconf_ifid_sit(u8 *eui, struct net_device *dev)
+{
+	if (dev->priv_flags & IFF_ISATAP)
+		return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
+	return -1;
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1506,8 +1529,7 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
 	case ARPHRD_SIT:
-		if (dev->priv_flags & IFF_ISATAP)
-			return ipv6_isatap_eui64(eui, *(__be32 *)dev->dev_addr);
+		return addrconf_ifid_sit(eui, dev);
 	}
 	return -1;
 }

---
commit 9acd9f3ae92d0dc0ca7504fb48c1040e8bbc39fe
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:10 2008 +0900

    [IPV6]: Make address arguments const.
    
    - net/ipv6/addrconf.c:
    	ipv6_get_ifaddr(), ipv6_dev_get_saddr()
    - net/ipv6/mcast.c:
    	ipv6_sock_mc_join(), ipv6_sock_mc_drop(),
    	inet6_mc_check(),
    	ipv6_dev_mc_inc(), __ipv6_dev_mc_dec(), ipv6_dev_mc_dec(),
    	ipv6_chk_mcast_addr()
    - net/ipv6/route.c:
    	rt6_lookup(), icmp6_dst_alloc()
    - net/ipv6/ip6_output.c:
    	ip6_nd_hdr()
    - net/ipv6/ndisc.c:
    	ndisc_send_ns(), ndisc_send_rs(), ndisc_send_redirect(),
    	ndisc_get_neigh(), __ndisc_send()
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 8317c1b..92af23d 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -76,12 +76,12 @@ extern int			ipv6_chk_prefix(struct in6_addr *addr,
 						struct net_device *dev);
 
 extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
-						 struct in6_addr *addr,
+						 const struct in6_addr *addr,
 						 struct net_device *dev,
 						 int strict);
 
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
-					       struct in6_addr *daddr,
+					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
 extern int			ipv6_get_lladdr(struct net_device *dev,
@@ -105,25 +105,27 @@ extern u32			ipv6_addr_label(const struct in6_addr *addr,
 /*
  *	multicast prototypes (mcast.c)
  */
-extern int ipv6_sock_mc_join(struct sock *sk, int ifindex, 
-		  struct in6_addr *addr);
-extern int ipv6_sock_mc_drop(struct sock *sk, int ifindex, 
-		  struct in6_addr *addr);
+extern int ipv6_sock_mc_join(struct sock *sk, int ifindex,
+			     const struct in6_addr *addr);
+extern int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
+			     const struct in6_addr *addr);
 extern void ipv6_sock_mc_close(struct sock *sk);
-extern int inet6_mc_check(struct sock *sk, struct in6_addr *mc_addr,
-		struct in6_addr *src_addr);
+extern int inet6_mc_check(struct sock *sk,
+			  const struct in6_addr *mc_addr,
+			  const struct in6_addr *src_addr);
 
-extern int ipv6_dev_mc_inc(struct net_device *dev, struct in6_addr *addr);
-extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
-extern int ipv6_dev_mc_dec(struct net_device *dev, struct in6_addr *addr);
+extern int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr);
+extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr);
+extern int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr);
 extern void ipv6_mc_up(struct inet6_dev *idev);
 extern void ipv6_mc_down(struct inet6_dev *idev);
 extern void ipv6_mc_init_dev(struct inet6_dev *idev);
 extern void ipv6_mc_destroy_dev(struct inet6_dev *idev);
 extern void addrconf_dad_failure(struct inet6_ifaddr *ifp);
 
-extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
-		struct in6_addr *src_addr);
+extern int ipv6_chk_mcast_addr(struct net_device *dev,
+			       const struct in6_addr *group,
+			       const struct in6_addr *src_addr);
 extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);
 
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9080076..9313491 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -61,13 +61,13 @@ extern int			ip6_ins_rt(struct rt6_info *);
 extern int			ip6_del_rt(struct rt6_info *);
 
 extern struct rt6_info		*rt6_lookup(struct net *net,
-					    struct in6_addr *daddr,
-					    struct in6_addr *saddr,
+					    const struct in6_addr *daddr,
+					    const struct in6_addr *saddr,
 					    int oif, int flags);
 
 extern struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 					 struct neighbour *neigh,
-					 struct in6_addr *addr);
+					 const struct in6_addr *addr);
 extern int icmp6_dst_gc(int *more);
 
 extern void fib6_force_start_gc(struct net *net);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a0c285b..49c4898 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -451,8 +451,8 @@ extern int			ip6_xmit(struct sock *sk,
 extern int			ip6_nd_hdr(struct sock *sk,
 					   struct sk_buff *skb,
 					   struct net_device *dev,
-					   struct in6_addr *saddr,
-					   struct in6_addr *daddr,
+					   const struct in6_addr *saddr,
+					   const struct in6_addr *daddr,
 					   int proto, int len);
 
 extern int			ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 1642423..9c451ff 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -94,17 +94,17 @@ extern int			ndisc_rcv(struct sk_buff *skb);
 
 extern void			ndisc_send_ns(struct net_device *dev,
 					      struct neighbour *neigh,
-					      struct in6_addr *solicit,
-					      struct in6_addr *daddr,
-					      struct in6_addr *saddr);
+					      const struct in6_addr *solicit,
+					      const struct in6_addr *daddr,
+					      const struct in6_addr *saddr);
 
 extern void			ndisc_send_rs(struct net_device *dev,
-					      struct in6_addr *saddr,
-					      struct in6_addr *daddr);
+					      const struct in6_addr *saddr,
+					      const struct in6_addr *daddr);
 
 extern void			ndisc_send_redirect(struct sk_buff *skb,
 						    struct neighbour *neigh,
-						    struct in6_addr *target);
+						    const struct in6_addr *target);
 
 extern int			ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir);
 
@@ -134,7 +134,7 @@ extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
 extern void 			inet6_ifinfo_notify(int event,
 						    struct inet6_dev *idev);
 
-static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, struct in6_addr *addr)
+static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, const struct in6_addr *addr)
 {
 
 	if (dev)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d15f3e0..4048c2b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -940,7 +940,7 @@ struct ipv6_saddr_score {
 };
 
 struct ipv6_saddr_dst {
-	struct in6_addr *addr;
+	const struct in6_addr *addr;
 	int ifindex;
 	int scope;
 	int label;
@@ -1074,7 +1074,7 @@ out:
 }
 
 int ipv6_dev_get_saddr(struct net_device *dst_dev,
-		       struct in6_addr *daddr, unsigned int prefs,
+		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
 	struct ipv6_saddr_score scores[2],
@@ -1309,7 +1309,7 @@ int ipv6_chk_prefix(struct in6_addr *addr, struct net_device *dev)
 
 EXPORT_SYMBOL(ipv6_chk_prefix);
 
-struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
+struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr * ifp;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c0dbe54..0af2e05 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -286,7 +286,7 @@ EXPORT_SYMBOL(ip6_xmit);
  */
 
 int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
-	       struct in6_addr *saddr, struct in6_addr *daddr,
+	       const struct in6_addr *saddr, const struct in6_addr *daddr,
 	       int proto, int len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 2e6a53f..0a0132a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -127,8 +127,6 @@ static struct in6_addr mld2_all_mcr = MLD2_ALL_MCR_INIT;
 /* Big mc list lock for all the sockets */
 static DEFINE_RWLOCK(ipv6_sk_mc_lock);
 
-int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
-
 static void igmp6_join_group(struct ifmcaddr6 *ma);
 static void igmp6_leave_group(struct ifmcaddr6 *ma);
 static void igmp6_timer_handler(unsigned long data);
@@ -177,7 +175,7 @@ int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
  *	socket join on multicast group
  */
 
-int ipv6_sock_mc_join(struct sock *sk, int ifindex, struct in6_addr *addr)
+int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct net_device *dev = NULL;
 	struct ipv6_mc_socklist *mc_lst;
@@ -252,7 +250,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 /*
  *	socket leave on multicast group
  */
-int ipv6_sock_mc_drop(struct sock *sk, int ifindex, struct in6_addr *addr)
+int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst, **lnk;
@@ -664,8 +662,8 @@ done:
 	return err;
 }
 
-int inet6_mc_check(struct sock *sk, struct in6_addr *mc_addr,
-	struct in6_addr *src_addr)
+int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
+		   const struct in6_addr *src_addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc;
@@ -871,7 +869,7 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 /*
  *	device multicast group inc (add if not found)
  */
-int ipv6_dev_mc_inc(struct net_device *dev, struct in6_addr *addr)
+int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct ifmcaddr6 *mc;
 	struct inet6_dev *idev;
@@ -942,7 +940,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, struct in6_addr *addr)
 /*
  *	device multicast group del
  */
-int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr)
+int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct ifmcaddr6 *ma, **map;
 
@@ -967,7 +965,7 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr)
 	return -ENOENT;
 }
 
-int ipv6_dev_mc_dec(struct net_device *dev, struct in6_addr *addr)
+int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = in6_dev_get(dev);
 	int err;
@@ -1012,8 +1010,8 @@ int ipv6_is_mld(struct sk_buff *skb, int nexthdr)
 /*
  *	check if the interface/address pair is valid
  */
-int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
-	struct in6_addr *src_addr)
+int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
+			const struct in6_addr *src_addr)
 {
 	struct inet6_dev *idev;
 	struct ifmcaddr6 *mc;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3295d8..5b9ad5e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -442,8 +442,9 @@ static void pndisc_destructor(struct pneigh_entry *n)
  */
 static void __ndisc_send(struct net_device *dev,
 			 struct neighbour *neigh,
-			 struct in6_addr *daddr, struct in6_addr *saddr,
-			 struct icmp6hdr *icmp6h, struct in6_addr *target,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr,
+			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
 			 int llinfo)
 {
 	struct flowi fl;
@@ -529,12 +530,13 @@ static void __ndisc_send(struct net_device *dev,
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   struct in6_addr *daddr, struct in6_addr *solicited_addr,
-		   int router, int solicited, int override, int inc_opt)
+			  const struct in6_addr *daddr,
+			  const struct in6_addr *solicited_addr,
+			  int router, int solicited, int override, int inc_opt)
 {
 	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
-	struct in6_addr *src_addr;
+	const struct in6_addr *src_addr;
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
 	};
@@ -564,8 +566,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 }
 
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
-		   struct in6_addr *solicit,
-		   struct in6_addr *daddr, struct in6_addr *saddr)
+		   const struct in6_addr *solicit,
+		   const struct in6_addr *daddr, const struct in6_addr *saddr)
 {
 	struct in6_addr addr_buf;
 	struct icmp6hdr icmp6h = {
@@ -584,8 +586,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
-void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
-		   struct in6_addr *daddr)
+void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
+		   const struct in6_addr *daddr)
 {
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_ROUTER_SOLICITATION,
@@ -1447,7 +1449,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
-			 struct in6_addr *target)
+			 const struct in6_addr *target)
 {
 	struct net_device *dev = skb->dev;
 	struct net *net = dev_net(dev);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 269b760..6293cb9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -556,8 +556,8 @@ out:
 
 }
 
-struct rt6_info *rt6_lookup(struct net *net, struct in6_addr *daddr,
-			    struct in6_addr *saddr, int oif, int strict)
+struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
+			    const struct in6_addr *saddr, int oif, int strict)
 {
 	struct flowi fl = {
 		.oif = oif,
@@ -925,7 +925,7 @@ static DEFINE_SPINLOCK(icmp6_dst_lock);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 				  struct neighbour *neigh,
-				  struct in6_addr *addr)
+				  const struct in6_addr *addr)
 {
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);

---
commit f3ee4010e84452aa133e5163e6cfabc52b194e94
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:11 2008 +0900

    [IPV6]: Define constants for link-local multicast addresses.
    
    - Define link-local all-node / all-router multicast addresses.
    - Remove ipv6_addr_all_nodes() and ipv6_addr_all_routers().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in6.h b/include/linux/in6.h
index e6aa8de..bc49204 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -48,6 +48,14 @@ extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
+#ifdef __KERNEL__
+extern const struct in6_addr in6addr_linklocal_allnodes;
+#define IN6ADDR_LINKLOCAL_ALLNODES_INIT	\
+		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
+extern const struct in6_addr in6addr_linklocal_allrouters;
+#define IN6ADDR_LINKLOCAL_ALLROUTERS_INIT \
+		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+#endif
 
 struct sockaddr_in6 {
 	unsigned short int	sin6_family;    /* AF_INET6 */
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 92af23d..0a2f037 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -205,17 +205,6 @@ static inline void addrconf_addr_solict_mult(const struct in6_addr *addr,
 		      htonl(0xFF000000) | addr->s6_addr32[3]);
 }
 
-
-static inline void ipv6_addr_all_nodes(struct in6_addr *addr)
-{
-	ipv6_addr_set(addr, htonl(0xFF020000), 0, 0, htonl(0x1));
-}
-
-static inline void ipv6_addr_all_routers(struct in6_addr *addr)
-{
-	ipv6_addr_set(addr, htonl(0xFF020000), 0, 0, htonl(0x2));
-}
-
 static inline int ipv6_addr_is_multicast(const struct in6_addr *addr)
 {
 	return (addr->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4048c2b..7df04d2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -222,6 +222,8 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
+const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
 
 /* Check if a valid qdisc is available */
 static inline int addrconf_qdisc_ok(struct net_device *dev)
@@ -321,7 +323,6 @@ EXPORT_SYMBOL(in6_dev_finish_destroy);
 static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
-	struct in6_addr maddr;
 
 	ASSERT_RTNL();
 
@@ -406,8 +407,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
 	/* Join all-node multicast group */
-	ipv6_addr_all_nodes(&maddr);
-	ipv6_dev_mc_inc(dev, &maddr);
+	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
 	return ndev;
 }
@@ -433,18 +433,15 @@ static void dev_forward_change(struct inet6_dev *idev)
 {
 	struct net_device *dev;
 	struct inet6_ifaddr *ifa;
-	struct in6_addr addr;
 
 	if (!idev)
 		return;
 	dev = idev->dev;
 	if (dev && (dev->flags & IFF_MULTICAST)) {
-		ipv6_addr_all_routers(&addr);
-
 		if (idev->cnf.forwarding)
-			ipv6_dev_mc_inc(dev, &addr);
+			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 		else
-			ipv6_dev_mc_dec(dev, &addr);
+			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
 	}
 	for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
 		if (ifa->flags&IFA_F_TENTATIVE)
@@ -2654,8 +2651,6 @@ static void addrconf_rs_timer(unsigned long data)
 
 	spin_lock(&ifp->lock);
 	if (ifp->probes++ < ifp->idev->cnf.rtr_solicits) {
-		struct in6_addr all_routers;
-
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_timer(ifp, AC_RS,
 				   (ifp->probes == ifp->idev->cnf.rtr_solicits) ?
@@ -2663,9 +2658,7 @@ static void addrconf_rs_timer(unsigned long data)
 				   ifp->idev->cnf.rtr_solicit_interval);
 		spin_unlock(&ifp->lock);
 
-		ipv6_addr_all_routers(&all_routers);
-
-		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
+		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
 	} else {
 		spin_unlock(&ifp->lock);
 		/*
@@ -2806,16 +2799,12 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
-		struct in6_addr all_routers;
-
-		ipv6_addr_all_routers(&all_routers);
-
 		/*
 		 *	If a host as already performed a random delay
 		 *	[...] as part of DAD [...] there is no need
 		 *	to delay again before sending the first RS
 		 */
-		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
+		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
 
 		spin_lock_bh(&ifp->lock);
 		ifp->probes = 1;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 0a0132a..c2dc2e2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1766,10 +1766,9 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	struct inet6_dev *idev;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	struct in6_addr *snd_addr;
+	const struct in6_addr *snd_addr;
 	struct in6_addr *addrp;
 	struct in6_addr addr_buf;
-	struct in6_addr all_routers;
 	int err, len, payload_len, full_len;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
@@ -1780,11 +1779,10 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	IP6_INC_STATS(__in6_dev_get(dev),
 		      IPSTATS_MIB_OUTREQUESTS);
 	rcu_read_unlock();
-	snd_addr = addr;
-	if (type == ICMPV6_MGM_REDUCTION) {
-		snd_addr = &all_routers;
-		ipv6_addr_all_routers(&all_routers);
-	}
+	if (type == ICMPV6_MGM_REDUCTION)
+		snd_addr = &in6addr_linklocal_allrouters;
+	else
+		snd_addr = addr;
 
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
 	payload_len = len + sizeof(ra);
@@ -2309,24 +2307,19 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 {
 	struct ifmcaddr6 *i;
-	struct in6_addr maddr;
 
 	/* Deactivate timers */
 	ipv6_mc_down(idev);
 
 	/* Delete all-nodes address. */
-	ipv6_addr_all_nodes(&maddr);
-
 	/* We cannot call ipv6_dev_mc_dec() directly, our caller in
 	 * addrconf.c has NULL'd out dev->ip6_ptr so in6_dev_get() will
 	 * fail.
 	 */
-	__ipv6_dev_mc_dec(idev, &maddr);
+	__ipv6_dev_mc_dec(idev, &in6addr_linklocal_allnodes);
 
-	if (idev->cnf.forwarding) {
-		ipv6_addr_all_routers(&maddr);
-		__ipv6_dev_mc_dec(idev, &maddr);
-	}
+	if (idev->cnf.forwarding)
+		__ipv6_dev_mc_dec(idev, &in6addr_linklocal_allrouters);
 
 	write_lock_bh(&idev->lock);
 	while ((i = idev->mc_list) != NULL) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5b9ad5e..2c74885 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -818,10 +818,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		is_router = !!idev->cnf.forwarding;
 
 	if (dad) {
-		struct in6_addr maddr;
-
-		ipv6_addr_all_nodes(&maddr);
-		ndisc_send_na(dev, NULL, &maddr, &msg->target,
+		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &msg->target,
 			      is_router, 0, (ifp != NULL), 1);
 		goto out;
 	}

---
commit d7aabf22efb50e6d52ed953ed2a43996152a7fb0
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:11 2008 +0900

    [IPV6]: Use in6addr_any where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7df04d2..e93fa62 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2745,7 +2745,6 @@ static void addrconf_dad_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
 	struct inet6_dev *idev = ifp->idev;
-	struct in6_addr unspec;
 	struct in6_addr mcaddr;
 
 	read_lock_bh(&idev->lock);
@@ -2774,9 +2773,8 @@ static void addrconf_dad_timer(unsigned long data)
 	read_unlock_bh(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
-	memset(&unspec, 0, sizeof(unspec));
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &unspec);
+	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any);
 out:
 	in6_ifa_put(ifp);
 }
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index c2dc2e2..54f91ef 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1404,6 +1404,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	struct sk_buff *skb;
 	struct mld2_report *pmr;
 	struct in6_addr addr_buf;
+	const struct in6_addr *saddr;
 	int err;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
@@ -1422,10 +1423,11 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 		 * use unspecified address as the source address
 		 * when a valid link-local address is not available.
 		 */
-		memset(&addr_buf, 0, sizeof(addr_buf));
-	}
+		saddr = &in6addr_any;
+	} else
+		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, &addr_buf, &mld2_all_mcr, NEXTHDR_HOP, 0);
+	ip6_nd_hdr(sk, skb, dev, saddr, &mld2_all_mcr, NEXTHDR_HOP, 0);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
@@ -1766,7 +1768,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	struct inet6_dev *idev;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	const struct in6_addr *snd_addr;
+	const struct in6_addr *snd_addr, *saddr;
 	struct in6_addr *addrp;
 	struct in6_addr addr_buf;
 	int err, len, payload_len, full_len;
@@ -1805,10 +1807,11 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		 * use unspecified address as the source address
 		 * when a valid link-local address is not available.
 		 */
-		memset(&addr_buf, 0, sizeof(addr_buf));
-	}
+		saddr = &in6addr_any;
+	} else
+		saddr = &addr_buf;
 
-	ip6_nd_hdr(sk, skb, dev, &addr_buf, snd_addr, NEXTHDR_HOP, payload_len);
+	ip6_nd_hdr(sk, skb, dev, saddr, snd_addr, NEXTHDR_HOP, payload_len);
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
@@ -1819,7 +1822,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	addrp = (struct in6_addr *) skb_put(skb, sizeof(struct in6_addr));
 	ipv6_addr_copy(addrp, addr);
 
-	hdr->icmp6_cksum = csum_ipv6_magic(&addr_buf, snd_addr, len,
+	hdr->icmp6_cksum = csum_ipv6_magic(saddr, snd_addr, len,
 					   IPPROTO_ICMPV6,
 					   csum_partial((__u8 *) hdr, len, 0));
 

---
commit 7f1eced8b0a001c4d5a8cfa5ac7b5cbc89fedab8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 10 15:42:12 2008 +0900

    [IPV6] MIP6: Use our standard definitions for paddings.
    
    MIP6_OPT_PAD_X are actually for paddings in destination
    option header.  Replace them with our standard IPV6_TLV_PADX.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/mip6.h b/include/net/mip6.h
index 6327261..a83ad19 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -28,9 +28,6 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 
-#define MIP6_OPT_PAD_1	0
-#define MIP6_OPT_PAD_N	1
-
 /*
  * Mobility Header
  */
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 42403c6..ad1cc5b 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -44,9 +44,9 @@ static inline void *mip6_padn(__u8 *data, __u8 padlen)
 	if (!data)
 		return NULL;
 	if (padlen == 1) {
-		data[0] = MIP6_OPT_PAD_1;
+		data[0] = IPV6_TLV_PAD0;
 	} else if (padlen > 1) {
-		data[0] = MIP6_OPT_PAD_N;
+		data[0] = IPV6_TLV_PADN;
 		data[1] = padlen - 2;
 		if (padlen > 2)
 			memset(data+2, 0, data[1]);

---
commit a28398ba6112be28c6a92aacf06aca1979b454b7
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Mon Apr 7 09:42:07 2008 +0800

    [IPV6]: Check length of optval provided by user in setsockopt().
    
    Check length of setsockopt's optval, which provided by user, before copy it
    from user space.
    For POSIX compliant, return -EINVAL for setsockopt of short lengths.
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bf96953..bd3fb12 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -449,6 +449,9 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
+		if (optlen < sizeof(struct ipv6_mreq))
+			goto e_inval;
+
 		retv = -EPROTO;
 		if (inet_sk(sk)->is_icsk)
 			break;
@@ -468,7 +471,7 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
-		if (optlen != sizeof(struct ipv6_mreq))
+		if (optlen < sizeof(struct ipv6_mreq))
 			goto e_inval;
 
 		retv = -EFAULT;
@@ -487,6 +490,9 @@ done:
 		struct group_req greq;
 		struct sockaddr_in6 *psin6;
 
+		if (optlen < sizeof(struct group_req))
+			goto e_inval;
+
 		retv = -EFAULT;
 		if (copy_from_user(&greq, optval, sizeof(struct group_req)))
 			break;
@@ -511,7 +517,7 @@ done:
 		struct group_source_req greqs;
 		int omode, add;
 
-		if (optlen != sizeof(struct group_source_req))
+		if (optlen < sizeof(struct group_source_req))
 			goto e_inval;
 		if (copy_from_user(&greqs, optval, sizeof(greqs))) {
 			retv = -EFAULT;

---
commit b2a9d7c2f8ab151fff78db06f1ae9b22a856e95e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Apr 12 12:59:42 2008 +0900

    [IPV6]: Check length of int/boolean optval provided by user in setsockopt().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bd3fb12..2f1244d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -16,7 +16,6 @@
  *
  *	FIXME: Make the setsockopt code POSIX compliant: That is
  *
- *	o	Return -EINVAL for setsockopt of short lengths
  *	o	Truncate getsockopt returns
  *	o	Return an optlen of the truncated length if need be
  *
@@ -114,8 +113,13 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 	if (optval == NULL)
 		val=0;
-	else if (get_user(val, (int __user *) optval))
-		return -EFAULT;
+	else {
+		if (optlen >= sizeof(int)) {
+			if (get_user(val, (int __user *) optval))
+				return -EFAULT;
+		} else
+			val = 0;
+	}
 
 	valbool = (val!=0);
 
@@ -127,6 +131,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	switch (optname) {
 
 	case IPV6_ADDRFORM:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val == PF_INET) {
 			struct ipv6_txoptions *opt;
 			struct sk_buff *pktopt;
@@ -201,63 +207,86 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		goto e_inval;
 
 	case IPV6_V6ONLY:
-		if (inet_sk(sk)->num)
+		if (optlen < sizeof(int) ||
+		    inet_sk(sk)->num)
 			goto e_inval;
 		np->ipv6only = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_RECVPKTINFO:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxinfo = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292PKTINFO:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxoinfo = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_RECVHOPLIMIT:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxhlim = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292HOPLIMIT:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxohlim = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_RECVRTHDR:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.srcrt = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292RTHDR:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.osrcrt = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_RECVHOPOPTS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.hopopts = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292HOPOPTS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.ohopopts = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_RECVDSTOPTS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.dstopts = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292DSTOPTS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.odstopts = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_TCLASS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val < -1 || val > 0xff)
 			goto e_inval;
 		np->tclass = val;
@@ -265,11 +294,15 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		break;
 
 	case IPV6_RECVTCLASS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxtclass = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_FLOWINFO:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->rxopt.bits.rxflow = valbool;
 		retv = 0;
 		break;
@@ -288,9 +321,9 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
 			break;
 
-		retv = -EINVAL;
-		if (optlen & 0x7 || optlen > 8 * 255)
-			break;
+		if (optlen < sizeof(struct ipv6_opt_hdr) ||
+		    optlen & 0x7 || optlen > 8 * 255)
+			goto e_inval;
 
 		opt = ipv6_renew_options(sk, np->opt, optname,
 					 (struct ipv6_opt_hdr __user *)optval,
@@ -408,6 +441,8 @@ done:
 		break;
 	}
 	case IPV6_UNICAST_HOPS:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val > 255 || val < -1)
 			goto e_inval;
 		np->hop_limit = val;
@@ -417,6 +452,8 @@ done:
 	case IPV6_MULTICAST_HOPS:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val > 255 || val < -1)
 			goto e_inval;
 		np->mcast_hops = val;
@@ -424,6 +461,8 @@ done:
 		break;
 
 	case IPV6_MULTICAST_LOOP:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->mc_loop = valbool;
 		retv = 0;
 		break;
@@ -431,6 +470,8 @@ done:
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
+		if (optlen < sizeof(int))
+			goto e_inval;
 
 		if (val) {
 			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
@@ -591,27 +632,37 @@ done:
 		break;
 	}
 	case IPV6_ROUTER_ALERT:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		retv = ip6_ra_control(sk, val, NULL);
 		break;
 	case IPV6_MTU_DISCOVER:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val<0 || val>3)
 			goto e_inval;
 		np->pmtudisc = val;
 		retv = 0;
 		break;
 	case IPV6_MTU:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		if (val && val < IPV6_MIN_MTU)
 			goto e_inval;
 		np->frag_size = val;
 		retv = 0;
 		break;
 	case IPV6_RECVERR:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->recverr = valbool;
 		if (!val)
 			skb_queue_purge(&sk->sk_error_queue);
 		retv = 0;
 		break;
 	case IPV6_FLOWINFO_SEND:
+		if (optlen < sizeof(int))
+			goto e_inval;
 		np->sndflow = valbool;
 		retv = 0;
 		break;
@@ -631,6 +682,9 @@ done:
 		unsigned int pref = 0;
 		unsigned int prefmask = ~0;
 
+		if (optlen < sizeof(int))
+			goto e_inval;
+
 		retv = -EINVAL;
 
 		/* check PUBLIC/TMP/PUBTMP_DEFAULT conflicts */

---
commit 6ac7eb0868ccc9a2c597d6fd0b1ea09dcdc396ed
Author: Rami Rosen <ramirose@gmail.com>
Date:   Thu Apr 10 12:40:10 2008 +0300

    [IPV6] MROUTE: Adjust IPV6 multicast routing module to use mroute6 header declarations.
    
    - This patch adjusts IPv6 multicast routing module, net/ipv6/ip6mr.c,
    to use mroute6 header definitions instead of mroute.
     (MFC6_LINES instead of MFC_LINES, MAXMIFS instead of MAXVIFS, mifi_t
    instead of vifi_t.)
    
    - In addition, inclusion of some headers was removed as it is not needed.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4330421..94ede69 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -27,27 +27,18 @@
 #include <linux/fcntl.h>
 #include <linux/stat.h>
 #include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
-#include <linux/igmp.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
-#include <net/ip.h>
 #include <net/protocol.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/icmp.h>
-#include <net/udp.h>
 #include <net/raw.h>
-#include <net/route.h>
 #include <linux/notifier.h>
 #include <linux/if_arp.h>
-#include <linux/netfilter_ipv4.h>
-#include <net/ipip.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
 
@@ -83,7 +74,7 @@ static int mroute_do_pim;
 #define mroute_do_pim 0
 #endif
 
-static struct mfc6_cache *mfc6_cache_array[MFC_LINES];	/* Forwarding cache	*/
+static struct mfc6_cache *mfc6_cache_array[MFC6_LINES];	/* Forwarding cache	*/
 
 static struct mfc6_cache *mfc_unres_queue;		/* Queue of unresolved entries */
 static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
@@ -102,7 +93,7 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 static struct kmem_cache *mrt_cachep __read_mostly;
 
 static int ip6_mr_forward(struct sk_buff *skb, struct mfc6_cache *cache);
-static int ip6mr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
+static int ip6mr_cache_report(struct sk_buff *pkt, mifi_t mifi, int assert);
 static int ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm);
 
 #ifdef CONFIG_IPV6_PIMSM_V2
@@ -597,9 +588,9 @@ static void ip6mr_update_thresholds(struct mfc6_cache *cache, unsigned char *ttl
 {
 	int vifi;
 
-	cache->mfc_un.res.minvif = MAXVIFS;
+	cache->mfc_un.res.minvif = MAXMIFS;
 	cache->mfc_un.res.maxvif = 0;
-	memset(cache->mfc_un.res.ttls, 255, MAXVIFS);
+	memset(cache->mfc_un.res.ttls, 255, MAXMIFS);
 
 	for (vifi = 0; vifi < maxvif; vifi++) {
 		if (MIF_EXISTS(vifi) && ttls[vifi] && ttls[vifi] < 255) {
@@ -700,7 +691,7 @@ static struct mfc6_cache *ip6mr_cache_alloc(void)
 	if (c == NULL)
 		return NULL;
 	memset(c, 0, sizeof(*c));
-	c->mfc_un.res.minvif = MAXVIFS;
+	c->mfc_un.res.minvif = MAXMIFS;
 	return c;
 }
 
@@ -753,7 +744,7 @@ static void ip6mr_cache_resolve(struct mfc6_cache *uc, struct mfc6_cache *c)
  *	Called under mrt_lock.
  */
 
-static int ip6mr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
+static int ip6mr_cache_report(struct sk_buff *pkt, mifi_t mifi, int assert)
 {
 	struct sk_buff *skb;
 	struct mrt6msg *msg;
@@ -815,7 +806,7 @@ static int ip6mr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 
 	msg->im6_mbz = 0;
 	msg->im6_msgtype = assert;
-	msg->im6_mif = vifi;
+	msg->im6_mif = mifi;
 	msg->im6_pad = 0;
 	ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
 	ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
@@ -848,7 +839,7 @@ static int ip6mr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
  */
 
 static int
-ip6mr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
+ip6mr_cache_unresolved(mifi_t mifi, struct sk_buff *skb)
 {
 	int err;
 	struct mfc6_cache *c;
@@ -883,7 +874,7 @@ ip6mr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		/*
 		 *	Reflect first query at pim6sd
 		 */
-		if ((err = ip6mr_cache_report(skb, vifi, MRT6MSG_NOCACHE)) < 0) {
+		if ((err = ip6mr_cache_report(skb, mifi, MRT6MSG_NOCACHE)) < 0) {
 			/* If the report failed throw the cache entry
 			   out - Brad Parker
 			 */
@@ -992,11 +983,11 @@ static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 {
 	int line;
 	struct mfc6_cache *uc, *c, **cp;
-	unsigned char ttls[MAXVIFS];
+	unsigned char ttls[MAXMIFS];
 	int i;
 
-	memset(ttls, 255, MAXVIFS);
-	for (i = 0; i < MAXVIFS; i++) {
+	memset(ttls, 255, MAXMIFS);
+	for (i = 0; i < MAXMIFS; i++) {
 		if (IF_ISSET(i, &mfc->mf6cc_ifset))
 			ttls[i] = 1;
 
@@ -1188,7 +1179,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 			return -EINVAL;
 		if (copy_from_user(&vif, optval, sizeof(vif)))
 			return -EFAULT;
-		if (vif.mif6c_mifi >= MAXVIFS)
+		if (vif.mif6c_mifi >= MAXMIFS)
 			return -ENFILE;
 		rtnl_lock();
 		ret = mif6_add(&vif, sk == mroute6_socket);

---
commit 876c7f41961dc5172b03cbf2dca65f05003f28a0
Author: Brian Haley <Brian.Haley@hp.com>
Date:   Fri Apr 11 00:38:24 2008 -0400

    [IPv6]: Change IPv6 unspecified destination address to ::1 for raw and un-connected sockets
    
    This patch fixes a difference between IPv4 and IPv6 when sending packets
    to the unspecified address (either 0.0.0.0 or ::) when using raw or
    un-connected UDP sockets.  There are two cases where IPv6 either fails
    to send anything, or sends with the destination address set to ::.  For
    example:
    
    --> ping -c1 0.0.0.0
    PING 0.0.0.0 (127.0.0.1) 56(84) bytes of data.
    64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.032 ms
    
    --> ping6 -c1 ::
    PING ::(::) 56 data bytes
    ping: sendmsg: Invalid argument
    
    Doing a sendto("0.0.0.0") reveals:
    
    10:55:01.495090 IP localhost.32780 > localhost.7639: UDP, length 100
    
    Doing a sendto("::") reveals:
    
    10:56:13.262478 IP6 fe80::217:8ff:fe7d:4718.32779 > ::.7639: UDP, length 100
    
    If you issue a connect() first in the UDP case, it will be sent to ::1,
    similar to what happens with TCP.
    
    This restores the BSD-ism.
    
    Signed-off-by: Brian Haley <brian.haley@hp.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 088b80b..059298b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -805,15 +805,6 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		fl.fl6_flowlabel = np->flow_label;
 	}
 
-	if (ipv6_addr_any(daddr)) {
-		/*
-		 * unspecified destination address
-		 * treated as error... is this correct ?
-		 */
-		fl6_sock_release(flowlabel);
-		return(-EINVAL);
-	}
-
 	if (fl.oif == 0)
 		fl.oif = sk->sk_bound_dev_if;
 
@@ -846,7 +837,10 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (err)
 		goto out;
 
-	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	if (!ipv6_addr_any(daddr))
+		ipv6_addr_copy(&fl.fl6_dst, daddr);
+	else
+		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 30ef7dc..1fd784f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -752,7 +752,10 @@ do_udp_sendmsg:
 	opt = ipv6_fixup_options(&opt_space, opt);
 
 	fl.proto = sk->sk_protocol;
-	ipv6_addr_copy(&fl.fl6_dst, daddr);
+	if (!ipv6_addr_any(daddr))
+		ipv6_addr_copy(&fl.fl6_dst, daddr);
+	else
+		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.fl_ip_sport = inet->sport;

---
commit 05f175cdcf9d3615c1633615d87891ebfb729401
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 11 23:51:26 2008 +0900

    [IPV6]: Fix IPV6_RECVERR for connected raw sockets.
    
    Based on patch from Dmitry Butskoy <buc@odusz.so-cdu.ru>.
    
    Closes: 10437
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 059298b..6193b12 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -357,8 +357,10 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 	if (sk != NULL) {
-		saddr = &ipv6_hdr(skb)->saddr;
-		daddr = &ipv6_hdr(skb)->daddr;
+		/* Note: ipv6_hdr(skb) != skb->data */
+		struct ipv6hdr *ip6h = (struct ipv6hdr *)skb->data;
+		saddr = &ip6h->saddr;
+		daddr = &ip6h->daddr;
 		net = dev_net(skb->dev);
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
