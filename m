From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] IPv6 Update for net-2.6.19, Take 2
Date: Thu, 21 Sep 2006 15:59:52 +0900 (JST)
Message-ID: <20060921.155952.14019351.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:28423 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750718AbWIUG5l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 02:57:41 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Here is the update for IPv6 for net-2.6.19, take 2.

Changes:
 - Fix IsRouter flag in NAs.
 - Add HA/MN Support.

With these changesets, net-2.6.19 will be able to handle fundermental
not only CN (Correspondent Node) operation but also HA (Home Agent) /
MN (Mobile Node) operations.

Please pull them from
	git://git.skbuff.net/yoshfuji/net-2.6.19-20060920-inet6/

Regards,

HEADLINES
---------

    [IPV6] NDISC: Handle NDP messages to proxied addresses.
    [IPV6]: Don't forward packets to proxied link-local address.
    [IPV6] NDISC: Avoid updating neighbor cache for proxied address in receiving NA.
    [IPV6] NDISC: Set per-entry is_router flag in Proxy NA.
    [IPV6] NDISC: Add proxy_ndp sysctl.
    [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
    [IPV6] NDISC: Fix is_router flag setting.
    [IPV6] ADDRCONF: Allow non-DAD'able addresses.
    [IPV6] ADDRCONF: Mobile IPv6 Home Address support.

DIFFSTAT
--------

 Documentation/networking/ip-sysctl.txt |    3 +
 include/linux/if_addr.h                |    2 +
 include/linux/ipv6.h                   |    2 +
 include/linux/sysctl.h                 |    1 
 include/net/addrconf.h                 |   16 +---
 include/net/if_inet6.h                 |    1 
 include/net/neighbour.h                |    1 
 net/core/neighbour.c                   |   11 ++-
 net/core/pktgen.c                      |    4 +
 net/ipv6/addrconf.c                    |  128 +++++++++++++++++++++++---------
 net/ipv6/anycast.c                     |    4 +
 net/ipv6/ip6_output.c                  |   62 ++++++++++++++++
 net/ipv6/ipv6_syms.c                   |    1 
 net/ipv6/ndisc.c                       |   28 ++++++-
 net/sctp/ipv6.c                        |    6 +-
 15 files changed, 206 insertions(+), 64 deletions(-)

CHANGESETS
----------

commit 6ef7db482e882f77a17afc9f8fef8a91790b4a7a
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
commit aa4c21e2fffb000050159fdc2c3e787b582de825
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
commit 7ea6509133777769fc48e14157a488408c072317
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
commit d7e08f2ffa3acf89e4572614daadbf760d162477
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
commit ed14bea8cb2fd82df4c6b519ea88608bba760be4
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
index 1e5a296..825a291 100644
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
@@ -3337,6 +3339,7 @@ #ifdef CONFIV_IPV6_ROUTE_INFO
 	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
 #endif
+	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
 }
 
 /* Maximum length of ifinfomsg attributes */
@@ -3860,6 +3863,14 @@ #ifdef CONFIV_IPV6_ROUTE_INFO
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
commit c0aba136f10284d488662491af60923fe5e51190
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
index 825a291..c09ebb7 100644
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
 
@@ -2342,10 +2344,10 @@ static int addrconf_ifdown(struct net_de
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
@@ -3573,10 +3575,10 @@ static void __ipv6_ifa_notify(int event,
 
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
index fd87e3c..249e503 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -321,9 +321,9 @@ static void sctp_v6_copy_addrlist(struct
 	struct inet6_ifaddr *ifp;
 	struct sctp_sockaddr_entry *addr;
 
-	read_lock(&addrconf_lock);
+	rcu_read_lock();
 	if ((in6_dev = __in6_dev_get(dev)) == NULL) {
-		read_unlock(&addrconf_lock);
+		rcu_read_unlock();
 		return;
 	}
 
@@ -342,7 +342,7 @@ static void sctp_v6_copy_addrlist(struct
 	}
 
 	read_unlock(&in6_dev->lock);
-	read_unlock(&addrconf_lock);
+	rcu_read_unlock();
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */

---
commit 171b3685c04b914a944e91fb59f91479f05d7ee1
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Sep 20 12:23:14 2006 +0900

    [IPV6] NDISC: Fix is_router flag setting.
    
    We did not send appropriate IsRouter flag if the forwarding setting is
    positive even value.  Let's give 1/0 value to ndisc_send_na().
    
    Also, existing users of ndisc_send_na() give 0/1 to override,
    we can omit redundant operation in that function.
    
    Bug hinted by Nicolas Dichtel <nicolas.dichtel@6wind.com>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 76517a5..0304b5f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -496,7 +496,7 @@ static void ndisc_send_na(struct net_dev
         msg->icmph.icmp6_unused = 0;
         msg->icmph.icmp6_router    = router;
         msg->icmph.icmp6_solicited = solicited;
-        msg->icmph.icmp6_override  = !!override;
+        msg->icmph.icmp6_override  = override;
 
         /* Set the target address. */
 	ipv6_addr_copy(&msg->target, solicited_addr);
@@ -847,10 +847,7 @@ static void ndisc_recv_ns(struct sk_buff
 			goto out;
 	}
 
-	if (pneigh)
-		is_router = pneigh->flags & NTF_ROUTER;
-	else
-		is_router = idev->cnf.forwarding;
+	is_router = !!(pneigh ? pneigh->flags & NTF_ROUTER : idev->cnf.forwarding);
 
 	if (dad) {
 		struct in6_addr maddr;

---
commit c0a110109f0b1cd4eae43618009e16423be63d3d
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Wed Sep 20 19:30:07 2006 +0900

    [IPV6] ADDRCONF: Allow non-DAD'able addresses.
    
    IFA_F_NODAD flag, similar to IN6_IFF_NODAD in BSDs, is introduced
    to skip DAD.
    
    This flag should be set to Mobile IPv6 Home Address(es) on Mobile
    Node because DAD would fail if we should perform DAD; our Home Agent
    protects our Home Address(es).
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index e159045..ca24b9d 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -38,6 +38,7 @@ #define IFA_MAX (__IFA_MAX - 1)
 #define IFA_F_SECONDARY		0x01
 #define IFA_F_TEMPORARY		IFA_F_SECONDARY
 
+#define	IFA_F_NODAD		0x02
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c09ebb7..adb583a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1873,12 +1873,11 @@ err_exit:
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
-			  __u32 prefered_lft, __u32 valid_lft)
+			  __u8 ifa_flags, __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
-	__u8 ifa_flags = 0;
 	int scope;
 
 	ASSERT_RTNL();
@@ -1971,7 +1970,7 @@ int addrconf_add_ifaddr(void __user *arg
 
 	rtnl_lock();
 	err = inet6_addr_add(ireq.ifr6_ifindex, &ireq.ifr6_addr, ireq.ifr6_prefixlen,
-			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			     IFA_F_PERMANENT, INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	rtnl_unlock();
 	return err;
 }
@@ -2514,7 +2513,8 @@ static void addrconf_dad_start(struct in
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
-	    !(ifp->flags&IFA_F_TENTATIVE)) {
+	    !(ifp->flags&IFA_F_TENTATIVE) ||
+	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
@@ -2912,28 +2912,25 @@ inet6_rtm_deladdr(struct sk_buff *skb, s
 	return inet6_addr_del(ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
-static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 prefered_lft,
-			     u32 valid_lft)
+static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
+			     u32 prefered_lft, u32 valid_lft)
 {
-	int ifa_flags = 0;
-
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 
 	if (valid_lft == INFINITY_LIFE_TIME)
-		ifa_flags = IFA_F_PERMANENT;
+		ifa_flags |= IFA_F_PERMANENT;
 	else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
 	if (prefered_lft == 0)
-		ifa_flags = IFA_F_DEPRECATED;
+		ifa_flags |= IFA_F_DEPRECATED;
 	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
 		 (prefered_lft != INFINITY_LIFE_TIME))
 		prefered_lft = 0x7FFFFFFF/HZ;
 
 	spin_lock_bh(&ifp->lock);
-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED|IFA_F_PERMANENT)) | ifa_flags;
-
+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD)) | ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -2955,7 +2952,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	struct in6_addr *pfx;
 	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
-	u32 valid_lft, preferred_lft;
+	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
+	u8 ifa_flags;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -2982,6 +2980,9 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	if (dev == NULL)
 		return -ENODEV;
 
+	/* We ignore other flags so far. */
+	ifa_flags = ifm->ifa_flags & IFA_F_NODAD;
+
 	ifa = ipv6_get_ifaddr(pfx, dev, 1);
 	if (ifa == NULL) {
 		/*
@@ -2989,14 +2990,14 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		 * userspace alreay relies on not having to provide this.
 		 */
 		return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
-				      preferred_lft, valid_lft);
+				      ifa_flags, preferred_lft, valid_lft);
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
 	    !(nlh->nlmsg_flags & NLM_F_REPLACE))
 		err = -EEXIST;
 	else
-		err = inet6_addr_modify(ifa, preferred_lft, valid_lft);
+		err = inet6_addr_modify(ifa, ifa_flags, preferred_lft, valid_lft);
 
 	in6_ifa_put(ifa);
 

---
commit cfdb1fae3f585db40068d3eb500a3e3db189f958
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Wed Sep 20 19:30:08 2006 +0900

    [IPV6] ADDRCONF: Mobile IPv6 Home Address support.
    
    IFA_F_HOMEADDRESS is introduced for Mobile IPv6 Home Addresses on
    Mobile Node.
    
    The IFA_F_HOMEADDRESS flag should be set for Mobile IPv6 Home
    Addresses for 2 purposes. 1) We need to check this on receipt of
    Type 2 Routing Header (RFC3775 Secion 6.4), 2) We prefer Home
    Address(es) in source address selection (RFC3484 Section 5 Rule 4).
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index ca24b9d..dbe8f61 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -39,6 +39,7 @@ #define IFA_F_SECONDARY		0x01
 #define IFA_F_TEMPORARY		IFA_F_SECONDARY
 
 #define	IFA_F_NODAD		0x02
+#define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index aa2ed8f..44f1b67 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -61,12 +61,8 @@ extern int			addrconf_set_dstaddr(void _
 extern int			ipv6_chk_addr(struct in6_addr *addr,
 					      struct net_device *dev,
 					      int strict);
-/* XXX: this is a placeholder till addrconf supports */
 #ifdef CONFIG_IPV6_MIP6
-static inline int ipv6_chk_home_addr(struct in6_addr *addr)
-{
-	return 0;
-}
+extern int			ipv6_chk_home_addr(struct in6_addr *addr);
 #endif
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
 						struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index adb583a..c186763 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1038,9 +1038,27 @@ int ipv6_dev_get_saddr(struct net_device
 					continue;
 			}
 
-			/* Rule 4: Prefer home address -- not implemented yet */
+			/* Rule 4: Prefer home address */
+#ifdef CONFIG_IPV6_MIP6
+			if (hiscore.rule < 4) {
+				if (ifa_result->flags & IFA_F_HOMEADDRESS)
+					hiscore.attrs |= IPV6_SADDR_SCORE_HOA;
+				hiscore.rule++;
+			}
+			if (ifa->flags & IFA_F_HOMEADDRESS) {
+				score.attrs |= IPV6_SADDR_SCORE_HOA;
+				if (!(ifa_result->flags & IFA_F_HOMEADDRESS)) {
+					score.rule = 4;
+					goto record_it;
+				}
+			} else {
+				if (hiscore.attrs & IPV6_SADDR_SCORE_HOA)
+					continue;
+			}
+#else
 			if (hiscore.rule < 4)
 				hiscore.rule++;
+#endif
 
 			/* Rule 5: Prefer outgoing interface */
 			if (hiscore.rule < 5) {
@@ -2759,6 +2777,26 @@ void if6_proc_exit(void)
 }
 #endif	/* CONFIG_PROC_FS */
 
+#ifdef CONFIG_IPV6_MIP6
+/* Check if address is a home address configured on any interface. */
+int ipv6_chk_home_addr(struct in6_addr *addr)
+{
+	int ret = 0;
+	struct inet6_ifaddr * ifp;
+	u8 hash = ipv6_addr_hash(addr);
+	read_lock_bh(&addrconf_hash_lock);
+	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
+		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
+		    (ifp->flags & IFA_F_HOMEADDRESS)) {
+			ret = 1;
+			break;
+		}
+	}
+	read_unlock_bh(&addrconf_hash_lock);
+	return ret;
+}
+#endif
+
 /*
  *	Periodic address status verification
  */
@@ -2930,7 +2968,7 @@ static int inet6_addr_modify(struct inet
 		prefered_lft = 0x7FFFFFFF/HZ;
 
 	spin_lock_bh(&ifp->lock);
-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD)) | ifa_flags;
+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -2981,7 +3019,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		return -ENODEV;
 
 	/* We ignore other flags so far. */
-	ifa_flags = ifm->ifa_flags & IFA_F_NODAD;
+	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
 
 	ifa = ipv6_get_ifaddr(pfx, dev, 1);
 	if (ifa == NULL) {

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
