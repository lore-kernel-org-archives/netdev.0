From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH resend] [IPV6] remove sysctl accept_source_route
Date: Sat,  5 May 2012 22:28:57 +0200
Message-ID: <1336249737-26661-1-git-send-email-eldad@fogrefinery.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only place where the accpet_source_route flag is checked is when we
are processing the type 2 routing header. In that case we only allow it if
it (1) has only segments left = 1 and (2) if it matches our home address,
which is the behavior required by RFC 6275 (see sections 8.5, 11.3.3), and
it doesn't make sense to block rh2 when we're a mobile node.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/linux/ipv6.h |    2 --
 net/ipv6/addrconf.c  |   10 ----------
 net/ipv6/exthdrs.c   |    6 ------
 3 files changed, 18 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 8260ef7..a77c6fe 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -162,7 +162,6 @@ struct ipv6_devconf {
 #endif
 #endif
 	__s32		proxy_ndp;
-	__s32		accept_source_route;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	__s32		optimistic_dad;
 #endif
@@ -208,7 +207,6 @@ enum {
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
 	DEVCONF_PROXY_NDP,
 	DEVCONF_OPTIMISTIC_DAD,
-	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e3b3421..bca2acf 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -194,7 +194,6 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 #endif
 	.proxy_ndp		= 0,
-	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 };
@@ -228,7 +227,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 #endif
 	.proxy_ndp		= 0,
-	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 };
@@ -3905,7 +3903,6 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 #endif
 	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
-	array[DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
 #endif
@@ -4535,13 +4532,6 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
-			.procname	= "accept_source_route",
-			.data		= &ipv6_devconf.accept_source_route,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
 			.procname       = "optimistic_dad",
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index aa0a51e..597cf2a 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -337,12 +337,8 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	struct ipv6_rt_hdr *hdr;
 	struct rt0_hdr *rthdr;
 	struct net *net = dev_net(skb->dev);
-	int accept_source_route = net->ipv6.devconf_all->accept_source_route;
 
 	idev = __in6_dev_get(skb->dev);
-	if (idev && accept_source_route > idev->cnf.accept_source_route)
-		accept_source_route = idev->cnf.accept_source_route;
-
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
@@ -393,8 +389,6 @@ looped_back:
 	switch (hdr->type) {
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	case IPV6_SRCRT_TYPE_2:
-		if (accept_source_route < 0)
-			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
 			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-- 
1.7.10
