From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] IPV6: Updates for net-2.6.19
Date: Tue, 19 Sep 2006 00:08:26 +0900 (JST)
Message-ID: <20060919.000826.80802464.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46354 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965280AbWIRPGR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 11:06:17 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changesets available at:
	git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060918-inet6/

HEADLINES
---------

    [IPV6] NDISC: Handle NDP messages to proxied addresses.
    [IPV6]: Don't forward packets to proxied link-local address.
    [IPV6] NDISC: Avoid updating neighbor cache for proxied address in receiving NA.
    [IPV6] NDISC: Set per-entry is_router flag in Proxy NA.
    [IPV6] NDISC: Add proxy_ndp sysctl.
    [IPV6] ADDRCONF: Convert addrconf_lock to RCU.

DIFFSTAT
--------

 Documentation/networking/ip-sysctl.txt |    3 ++
 include/linux/ipv6.h                   |    2 +
 include/linux/sysctl.h                 |    1 +
 include/net/addrconf.h                 |   10 ++---
 include/net/if_inet6.h                 |    1 +
 include/net/neighbour.h                |    1 +
 net/core/neighbour.c                   |   11 ++++--
 net/core/pktgen.c                      |    4 +-
 net/ipv6/addrconf.c                    |   57 ++++++++++++++++++-----------
 net/ipv6/anycast.c                     |    4 +-
 net/ipv6/ip6_output.c                  |   62 ++++++++++++++++++++++++++++++++
 net/ipv6/ipv6_syms.c                   |    1 -
 net/ipv6/ndisc.c                       |   29 +++++++++++++--
 net/sctp/ipv6.c                        |    6 ++-
 14 files changed, 150 insertions(+), 42 deletions(-)

CHANGESETS
----------

commit 9b06d4f4593cb15872e4351e3b1bdbf69c279f68
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 17 13:55:07 2006 +0900

    [IPV6] NDISC: Handle NDP messages to proxied addresses.
    
    It is required to respond to NDP messages sent directly to the "target"
    unicast address.  Proxying node (router) is required to handle such
    messages.  To achieve this, check if the packet in forwarding patch is
    NDP message.
    
    With this patch, the proxy neighbor entries are always looked up in
    forwarding path.  We may want to optimize further.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c14ea1e..0f56e9e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -308,6 +308,46 @@ static int ip6_call_ra_chain(struct sk_b
 	return 0;
 }
 
+static int ip6_forward_proxy_check(struct sk_buff *skb)
+{
+	struct ipv6hdr *hdr = skb->nh.ipv6h;
+	u8 nexthdr = hdr->nexthdr;
+	int offset;
+
+	if (ipv6_ext_hdr(nexthdr)) {
+		offset = ipv6_skip_exthdr(skb, sizeof(*hdr), &nexthdr);
+		if (offset < 0)
+			return 0;
+	} else
+		offset = sizeof(struct ipv6hdr);
+
+	if (nexthdr == IPPROTO_ICMPV6) {
+		struct icmp6hdr *icmp6;
+
+		if (!pskb_may_pull(skb, skb->nh.raw + offset + 1 - skb->data))
+			return 0;
+
+		icmp6 = (struct icmp6hdr *)(skb->nh.raw + offset);
+
+		switch (icmp6->icmp6_type) {
+		case NDISC_ROUTER_SOLICITATION:
+		case NDISC_ROUTER_ADVERTISEMENT:
+		case NDISC_NEIGHBOUR_SOLICITATION:
+		case NDISC_NEIGHBOUR_ADVERTISEMENT:
+		case NDISC_REDIRECT:
+			/* For reaction involving unicast neighbor discovery
+			 * message destined to the proxied address, pass it to
+			 * input function.
+			 */
+			return 1;
+		default:
+			break;
+		}
+	}
+
+	return 0;
+}
+
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
 	return dst_output(skb);
@@ -362,6 +402,11 @@ int ip6_forward(struct sk_buff *skb)
 		return -ETIMEDOUT;
 	}
 
+	if (pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+		if (ip6_forward_proxy_check(skb))
+			return ip6_input(skb);
+	}
+
 	if (!xfrm6_route_forward(skb)) {
 		IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
 		goto drop;

---
commit 6d57c4f060b4d327a40bed8cd5053ba812cb0cb6
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 17 13:55:09 2006 +0900

    [IPV6]: Don't forward packets to proxied link-local address.
    
    Proxying router can't forward traffic sent to link-local address, so signal
    the sender and discard the packet. This behavior is clarified by Mobile IPv6
    specification (RFC3775) but might be required for all proxying router.
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0f56e9e..b2be749 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -345,6 +345,16 @@ static int ip6_forward_proxy_check(struc
 		}
 	}
 
+	/*
+	 * The proxying router can't forward traffic sent to a link-local
+	 * address, so signal the sender and discard the packet. This
+	 * behavior is clarified by the MIPv6 specification.
+	 */
+	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) {
+		dst_link_failure(skb);
+		return -1;
+	}
+
 	return 0;
 }
 
@@ -403,8 +413,13 @@ int ip6_forward(struct sk_buff *skb)
 	}
 
 	if (pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
-		if (ip6_forward_proxy_check(skb))
+		int proxied = ip6_forward_proxy_check(skb);
+		if (proxied > 0)
 			return ip6_input(skb);
+		else if (proxied < 0) {
+			IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
+			goto drop;
+		}
 	}
 
 	if (!xfrm6_route_forward(skb)) {

---
commit 573e856977b6d1ec90bc2cdcf4df09e3712a1f1e
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 17 13:55:11 2006 +0900

    [IPV6] NDISC: Avoid updating neighbor cache for proxied address in receiving NA.
    
    This aims at proxying router not updating neighbor cache entry for proxied
    address when it receives NA because either the proxied node is off link or
    it has already sent a NA to the proxied router.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ed01f9a..0e0d6ce 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -952,6 +952,15 @@ static void ndisc_recv_na(struct sk_buff
 		if (neigh->nud_state & NUD_FAILED)
 			goto out;
 
+		/*
+		 * Don't update the neighbor cache entry on a proxy NA from
+		 * ourselves because either the proxied node is off link or it
+		 * has already sent a NA to us.
+		 */
+		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
+		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0))
+			goto out;
+
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|

---
commit e5128fdf4ab25b9c476e1562804a1b912a48102f
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 17 13:55:13 2006 +0900

    [IPV6] NDISC: Set per-entry is_router flag in Proxy NA.
    
    We have sent NA with router flag from the node-wide forwarding
    configuration.  This is not appropriate for proxy NA, and it should be
    set according to each proxy entry's configuration.
    
    This is used by Mobile IPv6 home agent to support physical home link
    in acting as a proxy router for mobile node which is not a router,
    for example.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index bd187da..c8aacbd 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -126,6 +126,7 @@ struct pneigh_entry
 {
 	struct pneigh_entry	*next;
 	struct net_device		*dev;
+	u8			flags;
 	u8			key[0];
 };
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 89b7904..8976ce3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1541,9 +1541,14 @@ int neigh_add(struct sk_buff *skb, struc
 		lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
-			err = 0;
-			if (pneigh_lookup(tbl, dst, dev, 1) == NULL)
-				err = -ENOBUFS;
+			struct pneigh_entry *pn;
+
+			err = -ENOBUFS;
+			pn = pneigh_lookup(tbl, dst, dev, 1);
+			if (pn) {
+				pn->flags = ndm->ndm_flags;
+				err = 0;
+			}
 			goto out_dev_put;
 		}
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0e0d6ce..ddf0386 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -736,8 +736,10 @@ static void ndisc_recv_ns(struct sk_buff
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev = NULL;
 	struct neighbour *neigh;
+	struct pneigh_entry *pneigh = NULL;
 	int dad = ipv6_addr_any(saddr);
 	int inc;
+	int is_router;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING 
@@ -822,7 +824,8 @@ static void ndisc_recv_ns(struct sk_buff
 
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding && 
-		     pneigh_lookup(&nd_tbl, &msg->target, dev, 0))) {
+		     (pneigh = pneigh_lookup(&nd_tbl,
+					     &msg->target, dev, 0)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc != 0 &&
@@ -843,12 +846,17 @@ static void ndisc_recv_ns(struct sk_buff
 			goto out;
 	}
 
+	if (pneigh)
+		is_router = pneigh->flags & NTF_ROUTER;
+	else
+		is_router = idev->cnf.forwarding;
+
 	if (dad) {
 		struct in6_addr maddr;
 
 		ipv6_addr_all_nodes(&maddr);
 		ndisc_send_na(dev, NULL, &maddr, &msg->target,
-			      idev->cnf.forwarding, 0, (ifp != NULL), 1);
+			      is_router, 0, (ifp != NULL), 1);
 		goto out;
 	}
 
@@ -869,7 +877,7 @@ static void ndisc_recv_ns(struct sk_buff
 			     NEIGH_UPDATE_F_OVERRIDE);
 	if (neigh || !dev->hard_header) {
 		ndisc_send_na(dev, neigh, saddr, &msg->target,
-			      idev->cnf.forwarding, 
+			      is_router,
 			      1, (ifp != NULL && inc), inc);
 		if (neigh)
 			neigh_release(neigh);

---
commit b0d3fa351e28e70a8193cc34b28c7cbae283d1d6
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:55:15 2006 +0900

    [IPV6] NDISC: Add proxy_ndp sysctl.
    
    We do not always need proxy NDP functionality even we
    enable forwarding.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a52e9b0..fd97a72 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -759,6 +759,9 @@ conf/all/forwarding - BOOLEAN
 
 	This referred to as global forwarding.
 
+proxy_ndp - BOOLEAN
+	Do proxy ndp.
+
 conf/interface/*:
 	Change special settings per interface.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1d6d3cc..caca57d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -176,6 +176,7 @@ #ifdef CONFIG_IPV6_ROUTE_INFO
 	__s32		accept_ra_rt_info_max_plen;
 #endif
 #endif
+	__s32		proxy_ndp;
 	void		*sysctl;
 };
 
@@ -203,6 +204,7 @@ enum {
 	DEVCONF_ACCEPT_RA_RTR_PREF,
 	DEVCONF_RTR_PROBE_INTERVAL,
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
+	DEVCONF_PROXY_NDP,
 	DEVCONF_MAX
 };
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index af61d92..736ed91 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -556,6 +556,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RTR_PREF=20,
 	NET_IPV6_RTR_PROBE_INTERVAL=21,
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
+	NET_IPV6_PROXY_NDP=23,
 	__NET_IPV6_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fc9cff3..aded046 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -175,6 +175,7 @@ #ifdef CONFIG_IPV6_ROUTE_INFO
 	.accept_ra_rt_info_max_plen = 0,
 #endif
 #endif
+	.proxy_ndp		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -205,6 +206,7 @@ #ifdef CONFIG_IPV6_ROUTE_INFO
 	.accept_ra_rt_info_max_plen = 0,
 #endif
 #endif
+	.proxy_ndp		= 0,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -3329,6 +3331,7 @@ #ifdef CONFIV_IPV6_ROUTE_INFO
 	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
 #endif
+	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
 }
 
 /* Maximum length of ifinfomsg attributes */
@@ -3852,6 +3855,14 @@ #ifdef CONFIV_IPV6_ROUTE_INFO
 #endif
 #endif
 		{
+			.ctl_name	=	NET_IPV6_PROXY_NDP,
+			.procname	=	"proxy_ndp",
+			.data		=	&ipv6_devconf.proxy_ndp,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b2be749..6671691 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -412,7 +412,9 @@ int ip6_forward(struct sk_buff *skb)
 		return -ETIMEDOUT;
 	}
 
-	if (pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+	/* XXX: idev->cnf.proxy_ndp? */
+	if (ipv6_devconf.proxy_ndp &&
+	    pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
 		if (proxied > 0)
 			return ip6_input(skb);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ddf0386..76517a5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -824,6 +824,7 @@ static void ndisc_recv_ns(struct sk_buff
 
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding && 
+		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
 		     (pneigh = pneigh_lookup(&nd_tbl,
 					     &msg->target, dev, 0)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
@@ -966,8 +967,13 @@ static void ndisc_recv_na(struct sk_buff
 		 * has already sent a NA to us.
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
-		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0))
+		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
+		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
+			/* XXX: idev->cnf.prixy_ndp */
+			WARN_ON(skb->dst != NULL &&
+				((struct rt6_info *)skb->dst)->rt6i_idev);
 			goto out;
+		}
 
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,

---
commit 234b8f5d3ea6d7b0f352b219dd0d75dc430dc029
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Sep 17 13:55:18 2006 +0900

    [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 5fc8627..aa2ed8f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -133,20 +133,18 @@ extern int unregister_inet6addr_notifier
 static inline struct inet6_dev *
 __in6_dev_get(struct net_device *dev)
 {
-	return (struct inet6_dev *)dev->ip6_ptr;
+	return rcu_dereference(dev->ip6_ptr);
 }
 
-extern rwlock_t addrconf_lock;
-
 static inline struct inet6_dev *
 in6_dev_get(struct net_device *dev)
 {
 	struct inet6_dev *idev = NULL;
-	read_lock(&addrconf_lock);
-	idev = dev->ip6_ptr;
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
 	if (idev)
 		atomic_inc(&idev->refcnt);
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return idev;
 }
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index e459e1a..34489c1 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -189,6 +189,7 @@ #endif
 	struct ipv6_devconf	cnf;
 	struct ipv6_devstat	stats;
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
+	struct rcu_head		rcu;
 };
 
 extern struct ipv6_devconf ipv6_devconf;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6a7320b..72145d4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1786,7 +1786,7 @@ #ifdef NOTNOW
 			 * use ipv6_get_lladdr if/when it's get exported
 			 */
 
-			read_lock(&addrconf_lock);
+			rcu_read_lock();
 			if ((idev = __in6_dev_get(pkt_dev->odev)) != NULL) {
 				struct inet6_ifaddr *ifp;
 
@@ -1805,7 +1805,7 @@ #ifdef NOTNOW
 				}
 				read_unlock_bh(&idev->lock);
 			}
-			read_unlock(&addrconf_lock);
+			rcu_read_unlock();
 			if (err)
 				printk("pktgen: ERROR: IPv6 link address not availble.\n");
 		}
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index aded046..5352d12 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -119,9 +119,6 @@ static int ipv6_count_addresses(struct i
 static struct inet6_ifaddr		*inet6_addr_lst[IN6_ADDR_HSIZE];
 static DEFINE_RWLOCK(addrconf_hash_lock);
 
-/* Protects inet6 devices */
-DEFINE_RWLOCK(addrconf_lock);
-
 static void addrconf_verify(unsigned long);
 
 static DEFINE_TIMER(addr_chk_timer, addrconf_verify, 0, 0);
@@ -318,6 +315,12 @@ static void addrconf_mod_timer(struct in
 
 /* Nobody refers to this device, we may destroy it. */
 
+static void in6_dev_finish_destroy_rcu(struct rcu_head *head)
+{
+	struct inet6_dev *idev = container_of(head, struct inet6_dev, rcu);
+	kfree(idev);
+}
+
 void in6_dev_finish_destroy(struct inet6_dev *idev)
 {
 	struct net_device *dev = idev->dev;
@@ -332,7 +335,7 @@ #endif
 		return;
 	}
 	snmp6_free_dev(idev);
-	kfree(idev);
+	call_rcu(&idev->rcu, in6_dev_finish_destroy_rcu);
 }
 
 static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
@@ -408,9 +411,8 @@ #endif
 	if (netif_carrier_ok(dev))
 		ndev->if_flags |= IF_READY;
 
-	write_lock_bh(&addrconf_lock);
-	dev->ip6_ptr = ndev;
-	write_unlock_bh(&addrconf_lock);
+	/* protected by rtnl_lock */
+	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
@@ -474,7 +476,7 @@ static void addrconf_forward_change(void
 
 	read_lock(&dev_base_lock);
 	for (dev=dev_base; dev; dev=dev->next) {
-		read_lock(&addrconf_lock);
+		rcu_read_lock();
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.forwarding) ^ (!ipv6_devconf.forwarding);
@@ -482,7 +484,7 @@ static void addrconf_forward_change(void
 			if (changed)
 				dev_forward_change(idev);
 		}
-		read_unlock(&addrconf_lock);
+		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
 }
@@ -543,7 +545,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	int hash;
 	int err = 0;
 
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	if (idev->dead) {
 		err = -ENODEV;			/*XXX*/
 		goto out2;
@@ -612,7 +614,7 @@ #endif
 	in6_ifa_hold(ifa);
 	write_unlock(&idev->lock);
 out2:
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 
 	if (likely(err == 0))
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
@@ -915,7 +917,7 @@ int ipv6_dev_get_saddr(struct net_device
 	memset(&hiscore, 0, sizeof(hiscore));
 
 	read_lock(&dev_base_lock);
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 
 	for (dev = dev_base; dev; dev=dev->next) {
 		struct inet6_dev *idev;
@@ -1127,7 +1129,7 @@ record_it:
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	read_unlock(&dev_base_lock);
 
 	if (!ifa_result)
@@ -1151,7 +1153,7 @@ int ipv6_get_lladdr(struct net_device *d
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
 
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	if ((idev = __in6_dev_get(dev)) != NULL) {
 		struct inet6_ifaddr *ifp;
 
@@ -1165,7 +1167,7 @@ int ipv6_get_lladdr(struct net_device *d
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -1466,7 +1468,7 @@ static void ipv6_regen_rndid(unsigned lo
 	struct inet6_dev *idev = (struct inet6_dev *) data;
 	unsigned long expires;
 
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	write_lock_bh(&idev->lock);
 
 	if (idev->dead)
@@ -1490,7 +1492,7 @@ static void ipv6_regen_rndid(unsigned lo
 
 out:
 	write_unlock_bh(&idev->lock);
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 	in6_dev_put(idev);
 }
 
@@ -2345,10 +2347,10 @@ static int addrconf_ifdown(struct net_de
 	           Do not dev_put!
 	 */
 	if (how == 1) {
-		write_lock_bh(&addrconf_lock);
-		dev->ip6_ptr = NULL;
 		idev->dead = 1;
-		write_unlock_bh(&addrconf_lock);
+
+		/* protected by rtnl_lock */
+		rcu_assign_pointer(dev->ip6_ptr, NULL);
 
 		/* Step 1.5: remove snmp6 entry */
 		snmp6_unregister_dev(idev);
@@ -3565,10 +3567,10 @@ static void __ipv6_ifa_notify(int event,
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
-	read_lock_bh(&addrconf_lock);
+	rcu_read_lock_bh();
 	if (likely(ifp->idev->dead == 0))
 		__ipv6_ifa_notify(event, ifp);
-	read_unlock_bh(&addrconf_lock);
+	rcu_read_unlock_bh();
 }
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index b80fc50..a960476 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -56,7 +56,7 @@ ip6_onlink(struct in6_addr *addr, struct
 	int	onlink;
 
 	onlink = 0;
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
@@ -68,7 +68,7 @@ ip6_onlink(struct in6_addr *addr, struct
 		}
 		read_unlock_bh(&idev->lock);
 	}
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 	return onlink;
 }
 
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 7b7b90d..0e8e067 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -14,7 +14,6 @@ EXPORT_SYMBOL(ndisc_mc_map);
 EXPORT_SYMBOL(register_inet6addr_notifier);
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 EXPORT_SYMBOL(ip6_route_output);
-EXPORT_SYMBOL(addrconf_lock);
 EXPORT_SYMBOL(ipv6_setsockopt);
 EXPORT_SYMBOL(ipv6_getsockopt);
 EXPORT_SYMBOL(inet6_register_protosw);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 99c0cef..c77deb4 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -322,9 +322,9 @@ static void sctp_v6_copy_addrlist(struct
 	struct inet6_ifaddr *ifp;
 	struct sctp_sockaddr_entry *addr;
 
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	if ((in6_dev = __in6_dev_get(dev)) == NULL) {
-		read_unlock(&addrconf_lock);
+		rcu_read_unlock();
 		return;
 	}
 
@@ -343,7 +343,7 @@ static void sctp_v6_copy_addrlist(struct
 	}
 
 	read_unlock(&in6_dev->lock);
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
