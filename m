From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sat, 12 Jan 2013 23:21:44 +0900
Message-ID: <50F17178.3090705@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36697 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753633Ab3ALOVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |   14 +++++++++++-
 net/ipv6/addrconf.c |    4 +++-
 net/ipv6/ndisc.c    |   60 +++++++++++++++++++++++++++++++++++++++++++++++----
 net/ipv6/route.c    |    2 ++
 4 files changed, 74 insertions(+), 6 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 3c53257..1de4e0c 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -52,6 +52,7 @@ enum {
 #include <linux/hash.h>
 
 #include <net/neighbour.h>
+#include <net/firewire.h>
 
 struct ctl_table;
 struct inet6_dev;
@@ -127,10 +128,19 @@ static int ndisc_addr_option_pad(unsigned short type)
 	}
 }
 
+static int ndisc_addr_option_postpad(unsigned short type)
+{
+	switch (type) {
+	case ARPHRD_IEEE1394:	return sizeof(struct fwnet_peerinfo);
+	default:		return 0;
+	}
+}
+
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
 	return NDISC_OPT_SPACE(dev->addr_len +
-			       ndisc_addr_option_pad(dev->type));
+			       ndisc_addr_option_pad(dev->type) +
+			       ndisc_addr_option_postpad(dev->type));
 }
 
 static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
@@ -203,6 +213,8 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
 extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
 					     struct net_device *dev, int dir);
 
+extern void			ndisc_update_peerinfo(struct net_device *dev,
+						      void *lladdr);
 
 /*
  *	IGMP
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 408cac4a..9a0728a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1729,6 +1729,7 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_IPGRE:
 		return addrconf_ifid_gre(eui, dev);
 	case ARPHRD_IEEE802154:
+	case ARPHRD_IEEE1394:
 		return addrconf_ifid_eui64(eui, dev);
 	}
 	return -1;
@@ -2571,7 +2572,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_ARCNET) &&
 	    (dev->type != ARPHRD_INFINIBAND) &&
-	    (dev->type != ARPHRD_IEEE802154)) {
+	    (dev->type != ARPHRD_IEEE802154) &&
+	    (dev->type != ARPHRD_IEEE1394)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 99cd286..9a0ba9c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -72,6 +72,8 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
+#include <net/firewire.h>
+
 /* Set to 3 to get tracing... */
 #define ND_DEBUG 1
 
@@ -143,6 +145,22 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
+#if defined(CONFIG_FIREWIRE_NET)
+static u8 *__ndisc_fill_addr_option_firewire_postpad(u8 *opt, int space, void *data,
+						     struct net_device *dev)
+{
+	if (likely(space >= sizeof(struct fwnet_peerinfo))) {
+		fwnet_fill_peerinfo(dev, (__be64 *)data, (struct fwnet_peerinfo *)opt);
+		opt += sizeof(struct fwnet_peerinfo);
+		space -= sizeof(struct fwnet_peerinfo);
+	}
+	if (space > 0)
+		memset(opt, 0, space);
+
+	return opt + space;
+}
+#endif
+
 static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
 				  struct net_device *dev)
 {
@@ -160,9 +178,20 @@ static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
 	memcpy(opt+2, data, data_len);
 	data_len += 2;
 	opt += data_len;
-	if ((space -= data_len) > 0)
-		memset(opt, 0, space);
-	return opt + space;
+
+	if ((space -= data_len) > 0) {
+		switch (dev->type) {
+#if defined(CONFIG_FIREWIRE_NET)
+		case ARPHRD_IEEE1394:
+			opt = __ndisc_fill_addr_option_firewire_postpad(opt, space,
+									data, dev);
+#endif
+		default:
+			memset(opt, 0, space);
+			opt += space;
+		}
+	}
+	return opt;
 }
 
 static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
@@ -366,6 +395,19 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
+void ndisc_update_peerinfo(struct net_device *dev, void *lladdr)
+{
+#if defined(CONFIG_FIREWIRE_NET)
+	switch (dev->type) {
+	case ARPHRD_IEEE1394:
+		fwnet_update_peerinfo(dev, lladdr, (struct fwnet_peerinfo *)((__u64 *)lladdr + 1));
+		break;
+	default:
+		break;
+	}
+#endif
+}
+
 static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *daddr,
 				       const struct in6_addr *saddr,
@@ -798,6 +840,9 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		neigh_update(neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE);
+
+	ndisc_update_peerinfo(dev, lladdr);
+
 	if (neigh || !dev->header_ops) {
 		ndisc_send_na(dev, neigh, saddr, &msg->target,
 			      is_router,
@@ -905,6 +950,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
 			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0));
 
+		ndisc_update_peerinfo(dev, lladdr);
+
 		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
 			/*
 			 * Change: router to host
@@ -970,6 +1017,8 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 			     NEIGH_UPDATE_F_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER);
 		neigh_release(neigh);
+
+		ndisc_update_peerinfo(skb->dev, lladdr);
 	}
 out:
 	return;
@@ -1223,6 +1272,8 @@ skip_linkparms:
 			     NEIGH_UPDATE_F_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
 			     NEIGH_UPDATE_F_ISROUTER);
+
+		ndisc_update_peerinfo(skb->dev, lladdr);
 	}
 
 	if (!ipv6_accept_ra(in6_dev))
@@ -1405,7 +1456,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!ret)
 		goto release;
 
-	if (dev->addr_len) {
+	/* XXX* We have not idea about IEEE1394 peer infomation */
+	if (dev->addr_len && dev->type != ARPHRD_IEEE1394) {
 		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
 		if (!neigh) {
 			ND_PRINTK(2, warn,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 621b68e..27c5127 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1795,6 +1795,8 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
+	ndisc_update_peerinfo(skb->dev, lladdr);
+
 	nrt = ip6_rt_copy(rt, &msg->dest);
 	if (!nrt)
 		goto out;
-- 
1.7.9.5
