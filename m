From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] ipv6: Check RA for sllao when configuring optimistic ipv6 address (v2)
Date: Wed,  4 Jan 2012 15:49:15 -0500
Message-ID: <1325710155-30289-1-git-send-email-nhorman@tuxdriver.com>
References: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59105 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337Ab2ADUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 15:49:24 -0500
In-Reply-To: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently Dave noticed that a test we did in ipv6_add_addr to see if we next hop
route for the interface we're adding an addres to was wrong (see commit
7ffbcecbeed91e5874e9a1cfc4c0cbb07dac3069).  for one, it never triggers, and two,
it was completely wrong to begin with.  This test was meant to cover this
section of RFC 4429:

3.3 Modifications to RFC 2462 Stateless Address Autoconfiguration

   * (modifies section 5.5) A host MAY choose to configure a new address
        as an Optimistic Address.  A host that does not know the SLLAO
        of its router SHOULD NOT configure a new address as Optimistic.
        A router SHOULD NOT configure an Optimistic Address.

This patch should bring us into proper compliance with the above clause.  Since
we only add a SLAAC address after we've received a RA which may or may not
contain a source link layer address option, we can pass a pointer to that option
to addrconf_prefix_rcv (which may be null if the option is not present), and
only set the optimistic flag if the option was found in the RA.

Change notes:
(v2) modified the new parameter to addrconf_prefix_rcv to be a bool rather than
a pointer to make its use more clear as per request from davem.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
---
 include/net/addrconf.h |    3 ++-
 net/ipv6/addrconf.c    |    4 ++--
 net/ipv6/ndisc.c       |    4 +++-
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index cbc6bb0..f68dce2 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -151,7 +151,8 @@ extern int ipv6_chk_mcast_addr(struct net_device *dev,
 			       const struct in6_addr *src_addr);
 extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);
 
-extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);
+extern void addrconf_prefix_rcv(struct net_device *dev,
+				u8 *opt, int len, bool sllao);
 
 /*
  *	anycast prototypes (anycast.c)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 647e6cb..3513cce 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1803,7 +1803,7 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 	return idev;
 }
 
-void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
+void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 {
 	struct prefix_info *pinfo;
 	__u32 valid_lft;
@@ -1934,7 +1934,7 @@ ok:
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
-			    !net->ipv6.devconf_all->forwarding)
+			    !net->ipv6.devconf_all->forwarding && sllao)
 				addr_flags = IFA_F_OPTIMISTIC;
 #endif
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3b1fe4b..d8f02ef 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1368,7 +1368,9 @@ skip_routeinfo:
 		for (p = ndopts.nd_opts_pi;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
-			addrconf_prefix_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3);
+			addrconf_prefix_rcv(skb->dev, (u8 *)p,
+					    (p->nd_opt_len) << 3,
+					    ndopts.nd_opts_src_lladdr != NULL);
 		}
 	}
 
-- 
1.7.7.5
