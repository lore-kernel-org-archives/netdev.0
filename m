From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] Misc IPv6 Updates
Date: Wed, 10 Nov 2004 03:00:26 -0500 (EST)
Message-ID: <20041110.030026.29809367.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Here're changeset at:
  bk://bk.skbuff.net:20610/linux-2.6-inet6-misc/

Note:
 1. Bug#3717 will be closed next week, after my returning to Japan.
 2. Since there're some points to retain ipv6_addr_cmp(),
    let's introduce fast ipv6_addr_equal() and use it
    where appropriate. (please double check.)
 3. I'm not so worring about alignment because
    we already have ipv6_addr_any() etc.

If you're unhappy with this, let me re-create changesets.
Thank you.

HEADLINES
---------
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix unresolved symbol timer_bug_msg.
ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org
 [IPV6] introduce lightweight IPv6 address comparison function.
ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Use ipv6_addr_equal() where appropriate.


DIFFSTATS
---------
 include/net/ipv6.h             |    9 +++++++++
 include/net/tcp.h              |   16 +++++++++++-----
 net/ipv4/tcp_timer.c           |    7 ++++++-
 net/ipv6/addrconf.c            |   10 +++++-----
 net/ipv6/anycast.c             |   10 +++++-----
 net/ipv6/datagram.c            |    2 +-
 net/ipv6/ip6_fib.c             |    4 ++--
 net/ipv6/ip6_flowlabel.c       |    2 +-
 net/ipv6/ip6_output.c          |    4 ++--
 net/ipv6/ip6_tunnel.c          |   10 +++++-----
 net/ipv6/mcast.c               |   37 ++++++++++++++++++-------------------
 net/ipv6/ndisc.c               |    2 +-
 net/ipv6/netfilter/ip6_queue.c |    4 ++--
 net/ipv6/netfilter/ip6t_rt.c   |    4 ++--
 net/ipv6/raw.c                 |    8 ++++----
 net/ipv6/reassembly.c          |    8 ++++----
 net/ipv6/route.c               |    8 ++++----
 net/ipv6/tcp_ipv6.c            |   16 ++++++++--------
 net/ipv6/udp.c                 |   12 ++++++------
 net/ipv6/xfrm6_policy.c        |    6 +++---
 net/ipv6/xfrm6_state.c         |    6 +++---
 net/sctp/ipv6.c                |    2 +-
 22 files changed, 103 insertions(+), 84 deletions(-)


CHANGESETS
----------
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix unresolved symbol timer_bug_msg.
 
 Closed: Bug#3717 (by John Goerzen <goerzen@complete.org>)
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-11-10 16:44:58 +09:00
+++ b/include/net/tcp.h	2004-11-10 16:44:58 +09:00
@@ -965,7 +965,9 @@
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
 extern unsigned int tcp_current_mss(struct sock *sk, int large);
 
-extern const char timer_bug_msg[];
+#ifdef TCP_DEBUG
+extern const char tcp_timer_bug_msg[];
+#endif
 
 /* tcp_diag.c */
 extern void tcp_get_info(struct sock *, struct tcp_info *);
@@ -998,7 +1000,9 @@
 #endif
 		break;
 	default:
-		printk(timer_bug_msg);
+#ifdef TCP_DEBUG
+		printk(tcp_timer_bug_msg);
+#endif
 		return;
 	};
 
@@ -1033,7 +1037,9 @@
 		break;
 
 	default:
-		printk(timer_bug_msg);
+#ifdef TCP_DEBUG
+		printk(tcp_timer_bug_msg);
+#endif
 	};
 }
 
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2004-11-10 16:44:58 +09:00
+++ b/net/ipv4/tcp_timer.c	2004-11-10 16:44:58 +09:00
@@ -36,7 +36,9 @@
 static void tcp_delack_timer(unsigned long);
 static void tcp_keepalive_timer (unsigned long data);
 
-const char timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
+#ifdef TCP_DEBUG
+const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
+#endif
 
 /*
  * Using different timers for retransmit, delayed acks and probes
@@ -651,3 +653,6 @@
 EXPORT_SYMBOL(tcp_delete_keepalive_timer);
 EXPORT_SYMBOL(tcp_init_xmit_timers);
 EXPORT_SYMBOL(tcp_reset_keepalive_timer);
+#ifdef TCP_DEBUG
+EXPORT_SYMBOL(tcp_timer_bug_msg);
+#endif

ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org
 [IPV6] introduce lightweight IPv6 address comparison function.
 
 It is not optimal to use ipv6_addr_cmp() for simple address
 comparison, which checks if two addresses are equal.
 Based on idea from Dave Craig <dwcraig@qualcomm.com>.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	2004-11-10 16:45:02 +09:00
+++ b/include/net/ipv6.h	2004-11-10 16:45:02 +09:00
@@ -296,6 +296,15 @@
 }
 #endif
 
+static inline int ipv6_addr_equal(const struct in6_addr *a1,
+				  const struct in6_addr *a2)
+{
+	return (a1->s6_addr32[0] == a2->s6_addr32[0] &&
+		a1->s6_addr32[1] == a2->s6_addr32[1] &&
+		a1->s6_addr32[2] == a2->s6_addr32[2] &&
+		a1->s6_addr32[3] == a2->s6_addr32[3]);
+}
+
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1] | 

ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Use ipv6_addr_equal() where appropriate.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-11-10 16:45:07 +09:00
+++ b/include/net/tcp.h	2004-11-10 16:45:07 +09:00
@@ -361,8 +361,8 @@
 #define TCP_IPV6_MATCH(__sk, __saddr, __daddr, __ports, __dif)	   \
 	(((*((__u32 *)&(inet_sk(__sk)->dport)))== (__ports))   	&& \
 	 ((__sk)->sk_family		== AF_INET6)		&& \
-	 !ipv6_addr_cmp(&inet6_sk(__sk)->daddr, (__saddr))	&& \
-	 !ipv6_addr_cmp(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
+	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&& \
+	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 
 /* These can have wildcards, don't try too hard. */
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/addrconf.c	2004-11-10 16:45:07 +09:00
@@ -921,7 +921,7 @@
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
+		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    !(ifp->flags&IFA_F_TENTATIVE)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))
@@ -940,7 +940,7 @@
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ipv6_addr_cmp(&ifp->addr, addr) == 0) {
+		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
 				break;
 		}
@@ -956,7 +956,7 @@
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ipv6_addr_cmp(&ifp->addr, addr) == 0) {
+		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {
 				in6_ifa_hold(ifp);
@@ -992,7 +992,7 @@
 		return 1;
 
 	if (sk2_rcv_saddr6 &&
-	    !ipv6_addr_cmp(sk_rcv_saddr6, sk2_rcv_saddr6))
+	    ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))
 		return 1;
 
 	if (addr_type == IPV6_ADDR_MAPPED &&
@@ -1630,7 +1630,7 @@
 	read_lock_bh(&idev->lock);
 	for (ifp = idev->addr_list; ifp; ifp=ifp->if_next) {
 		if (ifp->prefix_len == plen &&
-		    (!memcmp(pfx, &ifp->addr, sizeof(struct in6_addr)))) {
+		    ipv6_addr_equal(pfx, &ifp->addr)) {
 			in6_ifa_hold(ifp);
 			read_unlock_bh(&idev->lock);
 			
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/anycast.c	2004-11-10 16:45:07 +09:00
@@ -205,7 +205,7 @@
 	prev_pac = NULL;
 	for (pac = np->ipv6_ac_list; pac; pac = pac->acl_next) {
 		if ((ifindex == 0 || pac->acl_ifindex == ifindex) &&
-		     ipv6_addr_cmp(&pac->acl_addr, addr) == 0)
+		     ipv6_addr_equal(&pac->acl_addr, addr))
 			break;
 		prev_pac = pac;
 	}
@@ -278,7 +278,7 @@
 	for (pac=np->ipv6_ac_list; pac; pac=pac->acl_next) {
 		if (ifindex && pac->acl_ifindex != ifindex)
 			continue;
-		found = ipv6_addr_cmp(&pac->acl_addr, addr) == 0;
+		found = ipv6_addr_equal(&pac->acl_addr, addr);
 		if (found)
 			break;
 	}
@@ -320,7 +320,7 @@
 	}
 
 	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
-		if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0) {
+		if (ipv6_addr_equal(&aca->aca_addr, addr)) {
 			aca->aca_users++;
 			err = 0;
 			goto out;
@@ -384,7 +384,7 @@
 	write_lock_bh(&idev->lock);
 	prev_aca = NULL;
 	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
-		if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0)
+		if (ipv6_addr_equal(&aca->aca_addr, addr))
 			break;
 		prev_aca = aca;
 	}
@@ -436,7 +436,7 @@
 	if (idev) {
 		read_lock_bh(&idev->lock);
 		for (aca = idev->ac_list; aca; aca = aca->aca_next)
-			if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0)
+			if (ipv6_addr_equal(&aca->aca_addr, addr))
 				break;
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
diff -Nru a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/datagram.c	2004-11-10 16:45:07 +09:00
@@ -190,7 +190,7 @@
 	}
 
 	ip6_dst_store(sk, dst,
-		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 		      &np->daddr : NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_fib.c	2004-11-10 16:45:07 +09:00
@@ -451,8 +451,8 @@
 
 			if (iter->rt6i_dev == rt->rt6i_dev &&
 			    iter->rt6i_idev == rt->rt6i_idev &&
-			    ipv6_addr_cmp(&iter->rt6i_gateway,
-					   &rt->rt6i_gateway) == 0) {
+			    ipv6_addr_equal(&iter->rt6i_gateway,
+					    &rt->rt6i_gateway)) {
 				if (!(iter->rt6i_flags&RTF_EXPIRES))
 					return -EEXIST;
 				iter->rt6i_expires = rt->rt6i_expires;
diff -Nru a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
--- a/net/ipv6/ip6_flowlabel.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_flowlabel.c	2004-11-10 16:45:07 +09:00
@@ -500,7 +500,7 @@
 					goto release;
 
 				err = -EINVAL;
-				if (ipv6_addr_cmp(&fl1->dst, &fl->dst) ||
+				if (!ipv6_addr_equal(&fl1->dst, &fl->dst) ||
 				    ipv6_opt_cmp(fl1->opt, fl->opt))
 					goto release;
 
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_output.c	2004-11-10 16:45:07 +09:00
@@ -768,9 +768,9 @@
 				 */
 	
 			if (((rt->rt6i_dst.plen != 128 ||
-			      ipv6_addr_cmp(&fl->fl6_dst, &rt->rt6i_dst.addr))
+			      !ipv6_addr_equal(&fl->fl6_dst, &rt->rt6i_dst.addr))
 			     && (np->daddr_cache == NULL ||
-				 ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
+				 !ipv6_addr_equal(&fl->fl6_dst, np->daddr_cache)))
 			    || (fl->oif && fl->oif != (*dst)->dev->ifindex)) {
 				*dst = NULL;
 			} else
diff -Nru a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_tunnel.c	2004-11-10 16:45:07 +09:00
@@ -133,8 +133,8 @@
 	struct ip6_tnl *t;
 
 	for (t = tnls_r_l[h0 ^ h1]; t; t = t->next) {
-		if (!ipv6_addr_cmp(local, &t->parms.laddr) &&
-		    !ipv6_addr_cmp(remote, &t->parms.raddr) &&
+		if (ipv6_addr_equal(local, &t->parms.laddr) &&
+		    ipv6_addr_equal(remote, &t->parms.raddr) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
@@ -284,8 +284,8 @@
 		return -EINVAL;
 
 	for (t = *ip6ip6_bucket(p); t; t = t->next) {
-		if (!ipv6_addr_cmp(local, &t->parms.laddr) &&
-		    !ipv6_addr_cmp(remote, &t->parms.raddr)) {
+		if (ipv6_addr_equal(local, &t->parms.laddr) &&
+		    ipv6_addr_equal(remote, &t->parms.raddr)) {
 			*pt = t;
 			return (create ? -EEXIST : 0);
 		}
@@ -602,7 +602,7 @@
 static inline int
 ip6ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)
 {
-	return !ipv6_addr_cmp(&t->parms.raddr, &hdr->saddr);
+	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
 
 /**
diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/mcast.c	2004-11-10 16:45:07 +09:00
@@ -247,7 +247,7 @@
 	write_lock_bh(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list; (mc_lst = *lnk) !=NULL ; lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
-		    ipv6_addr_cmp(&mc_lst->addr, addr) == 0) {
+		    ipv6_addr_equal(&mc_lst->addr, addr)) {
 			struct net_device *dev;
 
 			*lnk = mc_lst->next;
@@ -369,7 +369,7 @@
 	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
 		if (pgsr->gsr_interface && pmc->ifindex != pgsr->gsr_interface)
 			continue;
-		if (ipv6_addr_cmp(&pmc->addr, group) == 0)
+		if (ipv6_addr_equal(&pmc->addr, group))
 			break;
 	}
 	if (!pmc)		/* must have a prior join */
@@ -485,7 +485,7 @@
 	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
 		if (pmc->ifindex != gsf->gf_interface)
 			continue;
-		if (ipv6_addr_cmp(&pmc->addr, group) == 0)
+		if (ipv6_addr_equal(&pmc->addr, group))
 			break;
 	}
 	if (!pmc)		/* must have a prior join */
@@ -556,7 +556,7 @@
 	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
 		if (pmc->ifindex != gsf->gf_interface)
 			continue;
-		if (ipv6_addr_cmp(group, &pmc->addr) == 0)
+		if (ipv6_addr_equal(group, &pmc->addr))
 			break;
 	}
 	if (!pmc)		/* must have a prior join */
@@ -603,7 +603,7 @@
 
 	read_lock(&ipv6_sk_mc_lock);
 	for (mc = np->ipv6_mc_list; mc; mc = mc->next) {
-		if (ipv6_addr_cmp(&mc->addr, mc_addr) == 0)
+		if (ipv6_addr_equal(&mc->addr, mc_addr))
 			break;
 	}
 	if (!mc) {
@@ -617,7 +617,7 @@
 		int i;
 
 		for (i=0; i<psl->sl_count; i++) {
-			if (ipv6_addr_cmp(&psl->sl_addr[i], src_addr) == 0)
+			if (ipv6_addr_equal(&psl->sl_addr[i], src_addr))
 				break;
 		}
 		if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count)
@@ -740,7 +740,7 @@
 	write_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
 	for (pmc=idev->mc_tomb; pmc; pmc=pmc->next) {
-		if (ipv6_addr_cmp(&pmc->mca_addr, pmca) == 0)
+		if (ipv6_addr_equal(&pmc->mca_addr, pmca))
 			break;
 		pmc_prev = pmc;
 	}
@@ -816,7 +816,7 @@
 	}
 
 	for (mc = idev->mc_list; mc; mc = mc->next) {
-		if (ipv6_addr_cmp(&mc->mca_addr, addr) == 0) {
+		if (ipv6_addr_equal(&mc->mca_addr, addr)) {
 			mc->mca_users++;
 			write_unlock_bh(&idev->lock);
 			ip6_mc_add_src(idev, &mc->mca_addr, MCAST_EXCLUDE, 0,
@@ -878,7 +878,7 @@
 
 	write_lock_bh(&idev->lock);
 	for (map = &idev->mc_list; (ma=*map) != NULL; map = &ma->next) {
-		if (ipv6_addr_cmp(&ma->mca_addr, addr) == 0) {
+		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
 			if (--ma->mca_users == 0) {
 				*map = ma->next;
 				write_unlock_bh(&idev->lock);
@@ -953,7 +953,7 @@
 	if (idev) {
 		read_lock_bh(&idev->lock);
 		for (mc = idev->mc_list; mc; mc=mc->next) {
-			if (ipv6_addr_cmp(&mc->mca_addr, group) == 0)
+			if (ipv6_addr_equal(&mc->mca_addr, group))
 				break;
 		}
 		if (mc) {
@@ -962,8 +962,7 @@
 
 				spin_lock_bh(&mc->mca_lock);
 				for (psf=mc->mca_sources;psf;psf=psf->sf_next) {
-					if (ipv6_addr_cmp(&psf->sf_addr,
-					    src_addr) == 0)
+					if (ipv6_addr_equal(&psf->sf_addr, src_addr))
 						break;
 				}
 				if (psf)
@@ -1040,7 +1039,7 @@
 		if (scount == nsrcs)
 			break;
 		for (i=0; i<nsrcs; i++)
-			if (ipv6_addr_cmp(&srcs[i], &psf->sf_addr) == 0) {
+			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				psf->sf_gsresp = 1;
 				scount++;
 				break;
@@ -1135,7 +1134,7 @@
 	} else {
 		for (ma = idev->mc_list; ma; ma=ma->next) {
 			if (group_type != IPV6_ADDR_ANY &&
-			    ipv6_addr_cmp(group, &ma->mca_addr) != 0)
+			    !ipv6_addr_equal(group, &ma->mca_addr))
 				continue;
 			spin_lock_bh(&ma->mca_lock);
 			if (ma->mca_flags & MAF_TIMER_RUNNING) {
@@ -1200,7 +1199,7 @@
 
 	read_lock_bh(&idev->lock);
 	for (ma = idev->mc_list; ma; ma=ma->next) {
-		if (ipv6_addr_cmp(&ma->mca_addr, addrp) == 0) {
+		if (ipv6_addr_equal(&ma->mca_addr, addrp)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
 				atomic_dec(&ma->mca_refcnt);
@@ -1695,7 +1694,7 @@
 
 	psf_prev = NULL;
 	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
-		if (ipv6_addr_cmp(&psf->sf_addr, psfsrc) == 0)
+		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
 	}
@@ -1735,7 +1734,7 @@
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
 	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
-		if (ipv6_addr_cmp(pmca, &pmc->mca_addr) == 0)
+		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
 	if (!pmc) {
@@ -1790,7 +1789,7 @@
 
 	psf_prev = NULL;
 	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
-		if (ipv6_addr_cmp(&psf->sf_addr, psfsrc) == 0)
+		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
 	}
@@ -1859,7 +1858,7 @@
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
 	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
-		if (ipv6_addr_cmp(pmca, &pmc->mca_addr) == 0)
+		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
 	if (!pmc) {
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ndisc.c	2004-11-10 16:45:07 +09:00
@@ -1219,7 +1219,7 @@
 		return;
 	}
 
-	if (ipv6_addr_cmp(dest, target) == 0) {
+	if (ipv6_addr_equal(dest, target)) {
 		on_link = 1;
 	} else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING 
diff -Nru a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
--- a/net/ipv6/netfilter/ip6_queue.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/netfilter/ip6_queue.c	2004-11-10 16:45:07 +09:00
@@ -376,8 +376,8 @@
 	 */
 	if (e->info->hook == NF_IP_LOCAL_OUT) {
 		struct ipv6hdr *iph = e->skb->nh.ipv6h;
-		if (ipv6_addr_cmp(&iph->daddr, &e->rt_info.daddr) ||
-		    ipv6_addr_cmp(&iph->saddr, &e->rt_info.saddr))
+		if (!ipv6_addr_equal(&iph->daddr, &e->rt_info.daddr) ||
+		    !ipv6_addr_equal(&iph->saddr, &e->rt_info.saddr))
 			return ip6_route_me_harder(e->skb);
 	}
 	return 0;
diff -Nru a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
--- a/net/ipv6/netfilter/ip6t_rt.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/netfilter/ip6t_rt.c	2004-11-10 16:45:07 +09:00
@@ -209,7 +209,7 @@
 
 				BUG_ON(ap == NULL);
 
-				if (!ipv6_addr_cmp(ap, &rtinfo->addrs[i])) {
+				if (ipv6_addr_equal(ap, &rtinfo->addrs[i])) {
 					DEBUGP("i=%d temp=%d;\n",i,temp);
 					i++;
 				}
@@ -236,7 +236,7 @@
 							&_addr);
 				BUG_ON(ap == NULL);
 
-				if (ipv6_addr_cmp(ap, &rtinfo->addrs[temp]))
+				if (!ipv6_addr_equal(ap, &rtinfo->addrs[temp]))
 					break;
 			}
 			DEBUGP("temp=%d #%d\n", temp, rtinfo->addrnr);
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/raw.c	2004-11-10 16:45:07 +09:00
@@ -90,11 +90,11 @@
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			if (!ipv6_addr_any(&np->daddr) &&
-			    ipv6_addr_cmp(&np->daddr, rmt_addr))
+			    !ipv6_addr_equal(&np->daddr, rmt_addr))
 				continue;
 
 			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
+				if (ipv6_addr_equal(&np->rcv_saddr, loc_addr))
 					goto found;
 				if (is_multicast &&
 				    inet6_mc_check(sk, loc_addr, rmt_addr))
@@ -668,7 +668,7 @@
 		 * sk->sk_dst_cache.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    !ipv6_addr_cmp(daddr, &np->daddr))
+		    ipv6_addr_equal(daddr, &np->daddr))
 			daddr = &np->daddr;
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
@@ -775,7 +775,7 @@
 	}
 done:
 	ip6_dst_store(sk, dst,
-		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 		      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
diff -Nru a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
--- a/net/ipv6/reassembly.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/reassembly.c	2004-11-10 16:45:07 +09:00
@@ -342,8 +342,8 @@
 #ifdef CONFIG_SMP
 	for (fq = ip6_frag_hash[hash]; fq; fq = fq->next) {
 		if (fq->id == fq_in->id && 
-		    !ipv6_addr_cmp(&fq_in->saddr, &fq->saddr) &&
-		    !ipv6_addr_cmp(&fq_in->daddr, &fq->daddr)) {
+		    ipv6_addr_equal(&fq_in->saddr, &fq->saddr) &&
+		    ipv6_addr_equal(&fq_in->daddr, &fq->daddr)) {
 			atomic_inc(&fq->refcnt);
 			write_unlock(&ip6_frag_lock);
 			fq_in->last_in |= COMPLETE;
@@ -406,8 +406,8 @@
 	read_lock(&ip6_frag_lock);
 	for(fq = ip6_frag_hash[hash]; fq; fq = fq->next) {
 		if (fq->id == id && 
-		    !ipv6_addr_cmp(src, &fq->saddr) &&
-		    !ipv6_addr_cmp(dst, &fq->daddr)) {
+		    ipv6_addr_equal(src, &fq->saddr) &&
+		    ipv6_addr_equal(dst, &fq->daddr)) {
 			atomic_inc(&fq->refcnt);
 			read_unlock(&ip6_frag_lock);
 			return fq;
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/route.c	2004-11-10 16:45:07 +09:00
@@ -1006,7 +1006,7 @@
 			     rt->rt6i_dev->ifindex != rtmsg->rtmsg_ifindex))
 				continue;
 			if (rtmsg->rtmsg_flags&RTF_GATEWAY &&
-			    ipv6_addr_cmp(&rtmsg->rtmsg_gateway, &rt->rt6i_gateway))
+			    !ipv6_addr_equal(&rtmsg->rtmsg_gateway, &rt->rt6i_gateway))
 				continue;
 			if (rtmsg->rtmsg_metric &&
 			    rtmsg->rtmsg_metric != rt->rt6i_metric)
@@ -1057,13 +1057,13 @@
 	 *	is a bit fuzzy and one might need to check all default
 	 *	routers.
 	 */
-	if (ipv6_addr_cmp(saddr, &rt->rt6i_gateway)) {
+	if (!ipv6_addr_equal(saddr, &rt->rt6i_gateway)) {
 		if (rt->rt6i_flags & RTF_DEFAULT) {
 			struct rt6_info *rt1;
 
 			read_lock(&rt6_lock);
 			for (rt1 = ip6_routing_table.leaf; rt1; rt1 = rt1->u.next) {
-				if (!ipv6_addr_cmp(saddr, &rt1->rt6i_gateway)) {
+				if (ipv6_addr_equal(saddr, &rt1->rt6i_gateway)) {
 					dst_hold(&rt1->u.dst);
 					dst_release(&rt->u.dst);
 					read_unlock(&rt6_lock);
@@ -1262,7 +1262,7 @@
 	write_lock_bh(&rt6_lock);
 	for (rt = fn->leaf; rt; rt=rt->u.next) {
 		if (dev == rt->rt6i_dev &&
-		    ipv6_addr_cmp(&rt->rt6i_gateway, addr) == 0)
+		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
 			break;
 	}
 	if (rt)
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2004-11-10 16:45:07 +09:00
@@ -262,7 +262,7 @@
 			
 			score = 1;
 			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (ipv6_addr_cmp(&np->rcv_saddr, daddr))
+				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
 					continue;
 				score++;
 			}
@@ -321,8 +321,8 @@
 
 		if(*((__u32 *)&(tw->tw_dport))	== ports	&&
 		   sk->sk_family		== PF_INET6) {
-			if(!ipv6_addr_cmp(&tw->tw_v6_daddr, saddr)	&&
-			   !ipv6_addr_cmp(&tw->tw_v6_rcv_saddr, daddr)	&&
+			if(ipv6_addr_equal(&tw->tw_v6_daddr, saddr)	&&
+			   ipv6_addr_equal(&tw->tw_v6_rcv_saddr, daddr)	&&
 			   (!sk->sk_bound_dev_if || sk->sk_bound_dev_if == dif))
 				goto hit;
 		}
@@ -406,8 +406,8 @@
 	     prev = &req->dl_next) {
 		if (req->rmt_port == rport &&
 		    req->class->family == AF_INET6 &&
-		    !ipv6_addr_cmp(&req->af.v6_req.rmt_addr, raddr) &&
-		    !ipv6_addr_cmp(&req->af.v6_req.loc_addr, laddr) &&
+		    ipv6_addr_equal(&req->af.v6_req.rmt_addr, raddr) &&
+		    ipv6_addr_equal(&req->af.v6_req.loc_addr, laddr) &&
 		    (!req->af.v6_req.iif || req->af.v6_req.iif == iif)) {
 			BUG_TRAP(req->sk == NULL);
 			*prevp = prev;
@@ -463,8 +463,8 @@
 
 		if(*((__u32 *)&(tw->tw_dport))	== ports	&&
 		   sk2->sk_family		== PF_INET6	&&
-		   !ipv6_addr_cmp(&tw->tw_v6_daddr, saddr)	&&
-		   !ipv6_addr_cmp(&tw->tw_v6_rcv_saddr, daddr)	&&
+		   ipv6_addr_equal(&tw->tw_v6_daddr, saddr)	&&
+		   ipv6_addr_equal(&tw->tw_v6_rcv_saddr, daddr)	&&
 		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
 			struct tcp_opt *tp = tcp_sk(sk);
 
@@ -610,7 +610,7 @@
 	}
 
 	if (tp->ts_recent_stamp &&
-	    ipv6_addr_cmp(&np->daddr, &usin->sin6_addr)) {
+	    !ipv6_addr_equal(&np->daddr, &usin->sin6_addr)) {
 		tp->ts_recent = 0;
 		tp->ts_recent_stamp = 0;
 		tp->write_seq = 0;
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/udp.c	2004-11-10 16:45:07 +09:00
@@ -171,12 +171,12 @@
 				score++;
 			}
 			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (ipv6_addr_cmp(&np->rcv_saddr, daddr))
+				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
 					continue;
 				score++;
 			}
 			if (!ipv6_addr_any(&np->daddr)) {
-				if (ipv6_addr_cmp(&np->daddr, saddr))
+				if (!ipv6_addr_equal(&np->daddr, saddr))
 					continue;
 				score++;
 			}
@@ -395,14 +395,14 @@
 					continue;
 			}
 			if (!ipv6_addr_any(&np->daddr) &&
-			    ipv6_addr_cmp(&np->daddr, rmt_addr))
+			    !ipv6_addr_equal(&np->daddr, rmt_addr))
 				continue;
 
 			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
 				continue;
 
 			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
+				if (ipv6_addr_equal(&np->rcv_saddr, loc_addr))
 					return s;
 				continue;
 			}
@@ -732,7 +732,7 @@
 		 * sk->sk_dst_cache.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    !ipv6_addr_cmp(daddr, &np->daddr))
+		    ipv6_addr_equal(daddr, &np->daddr))
 			daddr = &np->daddr;
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
@@ -840,7 +840,7 @@
 
 	if (dst)
 		ip6_dst_store(sk, dst,
-			      !ipv6_addr_cmp(&fl->fl6_dst, &np->daddr) ?
+			      ipv6_addr_equal(&fl->fl6_dst, &np->daddr) ?
 			      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/xfrm6_policy.c	2004-11-10 16:45:07 +09:00
@@ -68,8 +68,8 @@
 		ipv6_addr_prefix(&fl_src_prefix,
 				 &fl->fl6_src,
 				 xdst->u.rt6.rt6i_src.plen);
-		if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
-		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
+		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
+		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
 		    __xfrm6_bundle_ok(xdst, fl)) {
 			dst_clone(dst);
 			break;
@@ -123,7 +123,7 @@
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
-	if (ipv6_addr_cmp(remote, &fl->fl6_dst)) {
+	if (!ipv6_addr_equal(remote, &fl->fl6_dst)) {
 		struct flowi fl_tunnel;
 
 		memset(&fl_tunnel, 0, sizeof(fl_tunnel));
diff -Nru a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
--- a/net/ipv6/xfrm6_state.c	2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/xfrm6_state.c	2004-11-10 16:45:07 +09:00
@@ -55,7 +55,7 @@
 	list_for_each_entry(x, xfrm6_state_afinfo.state_byspi+h, byspi) {
 		if (x->props.family == AF_INET6 &&
 		    spi == x->id.spi &&
-		    !ipv6_addr_cmp((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
+		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
 		    proto == x->id.proto) {
 			xfrm_state_hold(x);
 			return x;
@@ -76,10 +76,10 @@
 
 	list_for_each_entry(x, xfrm6_state_afinfo.state_bydst+h, bydst) {
 		if (x->props.family == AF_INET6 &&
-		    !ipv6_addr_cmp((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
+		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
 		    mode == x->props.mode &&
 		    proto == x->id.proto &&
-		    !ipv6_addr_cmp((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6) &&
+		    ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr *)x->props.saddr.a6) &&
 		    reqid == x->props.reqid &&
 		    x->km.state == XFRM_STATE_ACQ &&
 		    !x->id.spi) {
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2004-11-10 16:45:07 +09:00
+++ b/net/sctp/ipv6.c	2004-11-10 16:45:07 +09:00
@@ -461,7 +461,7 @@
 		}
 		return 0;
 	}
-	if (ipv6_addr_cmp(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
+	if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
 		return 0;
 	/* If this is a linklocal address, compare the scope_id. */
 	if (ipv6_addr_type(&addr1->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
