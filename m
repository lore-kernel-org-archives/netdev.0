From: Erik Nordmark <nordmark@arista.com>
Subject: [PATCH net-next v4] ipv6 addrconf: Implemented enhanced DAD (RFC7527)
Date: Thu,  1 Dec 2016 21:44:00 -0800
Message-ID: <1480657440-29816-1-git-send-email-nordmark@arista.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        Erik Nordmark <nordmark@arista.com>,
        Bob Gilligan <gilligan@arista.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:33162 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753395AbcLBFqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 00:46:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implemented RFC7527 Enhanced DAD.
IPv6 duplicate address detection can fail if there is some temporary
loopback of Ethernet frames. RFC7527 solves this by including a random
nonce in the NS messages used for DAD, and if an NS is received with the
same nonce it is assumed to be a looped back DAD probe and is ignored.
RFC7527 is enabled by default. Can be disabled by setting both of
conf/{all,interface}/enhanced_dad to zero.

Signed-off-by: Erik Nordmark <nordmark@arista.com>
Signed-off-by: Bob Gilligan <gilligan@arista.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

---

v2: renamed sysctl and made it default to true, plus minor code review fixes
v3: respun with later net-next; fixed whitespace issues
v4: fixed kbuild test robot for route.c; added Reviewed-by

 Documentation/networking/ip-sysctl.txt |  9 +++++++++
 include/linux/ipv6.h                   |  1 +
 include/net/if_inet6.h                 |  1 +
 include/net/ndisc.h                    |  5 ++++-
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 22 +++++++++++++++++++++-
 net/ipv6/ndisc.c                       | 31 ++++++++++++++++++++++++++++---
 net/ipv6/route.c                       |  2 +-
 8 files changed, 66 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5af48dd..d9ef566 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1729,6 +1729,15 @@ drop_unsolicited_na - BOOLEAN
 
 	By default this is turned off.
 
+enhanced_dad - BOOLEAN
+	Include a nonce option in the IPv6 neighbor solicitation messages used for
+	duplicate address detection per RFC7527. A received DAD NS will only signal
+	a duplicate address if the nonce is different. This avoids any false
+	detection of duplicates due to loopback of the NS messages that we send.
+	The nonce option will be sent on an interface unless both of
+	conf/{all,interface}/enhanced_dad are set to FALSE.
+	Default: TRUE
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 3f95233..671d014 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -68,6 +68,7 @@ struct ipv6_devconf {
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	__s32		seg6_require_hmac;
 #endif
+	__u32		enhanced_dad;
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b0576cb..0fa4c32 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -55,6 +55,7 @@ struct inet6_ifaddr {
 	__u8			stable_privacy_retry;
 
 	__u16			scope;
+	__u64			dad_nonce;
 
 	unsigned long		cstamp;	/* created timestamp */
 	unsigned long		tstamp; /* updated timestamp */
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index be1fe228..d562a2f 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -31,6 +31,7 @@ enum {
 	ND_OPT_PREFIX_INFO = 3,		/* RFC2461 */
 	ND_OPT_REDIRECT_HDR = 4,	/* RFC2461 */
 	ND_OPT_MTU = 5,			/* RFC2461 */
+	ND_OPT_NONCE = 14,              /* RFC7527 */
 	__ND_OPT_ARRAY_MAX,
 	ND_OPT_ROUTE_INFO = 24,		/* RFC4191 */
 	ND_OPT_RDNSS = 25,		/* RFC5006 */
@@ -121,6 +122,7 @@ struct ndisc_options {
 #define nd_opts_pi_end			nd_opt_array[__ND_OPT_PREFIX_INFO_END]
 #define nd_opts_rh			nd_opt_array[ND_OPT_REDIRECT_HDR]
 #define nd_opts_mtu			nd_opt_array[ND_OPT_MTU]
+#define nd_opts_nonce			nd_opt_array[ND_OPT_NONCE]
 #define nd_802154_opts_src_lladdr	nd_802154_opt_array[ND_OPT_SOURCE_LL_ADDR]
 #define nd_802154_opts_tgt_lladdr	nd_802154_opt_array[ND_OPT_TARGET_LL_ADDR]
 
@@ -398,7 +400,8 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 int ndisc_rcv(struct sk_buff *skb);
 
 void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr);
+		   const struct in6_addr *daddr, const struct in6_addr *saddr,
+		   u64 nonce);
 
 void ndisc_send_rs(struct net_device *dev,
 		   const struct in6_addr *saddr, const struct in6_addr *daddr);
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 53561be..eaf65dc 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -181,6 +181,7 @@ enum {
 	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
 	DEVCONF_SEG6_ENABLED,
 	DEVCONF_SEG6_REQUIRE_HMAC,
+	DEVCONF_ENHANCED_DAD,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4c387dc..c1e124b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -242,6 +242,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	.seg6_require_hmac	= 0,
 #endif
+	.enhanced_dad           = 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -292,6 +293,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	.seg6_require_hmac	= 0,
 #endif
+	.enhanced_dad           = 1,
 };
 
 /* Check if a valid qdisc is available */
@@ -3735,12 +3737,21 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 {
 	unsigned long rand_num;
 	struct inet6_dev *idev = ifp->idev;
+	u64 nonce;
 
 	if (ifp->flags & IFA_F_OPTIMISTIC)
 		rand_num = 0;
 	else
 		rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
 
+	nonce = 0;
+	if (idev->cnf.enhanced_dad ||
+	    dev_net(idev->dev)->ipv6.devconf_all->enhanced_dad) {
+		do
+			get_random_bytes(&nonce, 6);
+		while (nonce == 0);
+	}
+	ifp->dad_nonce = nonce;
 	ifp->dad_probes = idev->cnf.dad_transmits;
 	addrconf_mod_dad_work(ifp, rand_num);
 }
@@ -3918,7 +3929,8 @@ static void addrconf_dad_work(struct work_struct *w)
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any);
+	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any,
+		      ifp->dad_nonce);
 out:
 	in6_ifa_put(ifp);
 	rtnl_unlock();
@@ -4962,6 +4974,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	array[DEVCONF_SEG6_REQUIRE_HMAC] = cnf->seg6_require_hmac;
 #endif
+	array[DEVCONF_ENHANCED_DAD] = cnf->enhanced_dad;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -6070,6 +6083,13 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	},
 #endif
 	{
+		.procname       = "enhanced_dad",
+		.data           = &ipv6_devconf.enhanced_dad,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
+	{
 		/* sentinel */
 	}
 };
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d8e6714..eb35f73 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -233,6 +233,7 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 		case ND_OPT_SOURCE_LL_ADDR:
 		case ND_OPT_TARGET_LL_ADDR:
 		case ND_OPT_MTU:
+		case ND_OPT_NONCE:
 		case ND_OPT_REDIRECT_HDR:
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
 				ND_PRINTK(2, warn,
@@ -568,7 +569,8 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 }
 
 void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr)
+		   const struct in6_addr *daddr, const struct in6_addr *saddr,
+		   u64 nonce)
 {
 	struct sk_buff *skb;
 	struct in6_addr addr_buf;
@@ -588,6 +590,8 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 	if (inc_opt)
 		optlen += ndisc_opt_addr_space(dev,
 					       NDISC_NEIGHBOUR_SOLICITATION);
+	if (nonce != 0)
+		optlen += 8;
 
 	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
@@ -605,6 +609,13 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
 				       dev->dev_addr,
 				       NDISC_NEIGHBOUR_SOLICITATION);
+	if (nonce != 0) {
+		u8 *opt = skb_put(skb, 8);
+
+		opt[0] = ND_OPT_NONCE;
+		opt[1] = 8 >> 3;
+		memcpy(opt + 2, &nonce, 6);
+	}
 
 	ndisc_send_skb(skb, daddr, saddr);
 }
@@ -693,12 +704,12 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
-		ndisc_send_ns(dev, target, target, saddr);
+		ndisc_send_ns(dev, target, target, saddr, 0);
 	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, target, &mcaddr, saddr);
+		ndisc_send_ns(dev, target, &mcaddr, saddr, 0);
 	}
 }
 
@@ -742,6 +753,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	int dad = ipv6_addr_any(saddr);
 	bool inc;
 	int is_router = -1;
+	u64 nonce = 0;
 
 	if (skb->len < sizeof(struct nd_msg)) {
 		ND_PRINTK(2, warn, "NS: packet too short\n");
@@ -786,6 +798,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			return;
 		}
 	}
+	if (ndopts.nd_opts_nonce)
+		memcpy(&nonce, (u8 *)(ndopts.nd_opts_nonce + 1), 6);
 
 	inc = ipv6_addr_is_multicast(daddr);
 
@@ -794,6 +808,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 have_ifp:
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
+				if (nonce != 0 && ifp->dad_nonce == nonce) {
+					u8 *np = (u8 *)&nonce;
+					/* Matching nonce if looped back */
+					ND_PRINTK(2, notice,
+						  "%s: IPv6 DAD loopback for address %pI6c nonce %02x:%02x:%02x:%02x:%02x:%02x ignored\n",
+						  ifp->idev->dev->name,
+						  &ifp->addr,
+						  np[0], np[1], np[2], np[3],
+						  np[4], np[5]);
+					goto out;
+				}
 				/*
 				 * We are colliding with another node
 				 * who is doing DAD
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b317bb1..aac7818 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -527,7 +527,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 		container_of(w, struct __rt6_probe_work, work);
 
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
-	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL);
+	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL, 0);
 	dev_put(work->dev);
 	kfree(work);
 }
-- 
1.8.1.4
