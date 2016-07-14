From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipmr/ip6mr: add support for keeping an entry age
Date: Thu, 14 Jul 2016 18:08:50 +0300
Message-ID: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Donald Sharp <sharpd@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35681 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGOWoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:44:24 -0400
Received: by mail-pa0-f45.google.com with SMTP id dx3so43140484pab.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:44:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for hardware offloading of ipmr/ip6mr we need an
interface that allows to check (and later update) the age of entries.
Relying on stats alone can show activity but not actual age of the entry,
furthermore when there're tens of thousands of entries a lot of the
hardware implementations only support "hit" bits which are cleared on
read to denote that the entry was active and shouldn't be aged out,
these can then be naturally translated into age timestamp and will be
compatible with the software forwarding age. Using a lastuse entry doesn't
affect performance because the entries in that cache line are written to
along with the age. Once an entry goes above the member size (32 bits) we
keep it at UINT_MAX as we cannot afford to wrap it which will falsely show
that it was used recently. This is not supposed to happen as entries should
be aged out in matter of minutes or seconds.
Since all new users are encouraged to use ipmr via netlink, this is
exported via the RTA_CACHEINFO attribute which has rta_lastuse entry.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Shrijeet Mukherjee <shm@cumulusnetworks.com>
CC: Satish Ashok <sashok@cumulusnetworks.com>
CC: Donald Sharp <sharpd@cumulusnetworks.com>
CC: David S. Miller <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
---
RTA_CACHEINFO was chosen because there're other useful members of the
struct which will be used later when we gradually remove the ipmr/ip6mr
entry cache limitations.

 include/linux/mroute.h  |  1 +
 include/linux/mroute6.h |  1 +
 net/ipv4/ipmr.c         | 18 +++++++++++++++---
 net/ipv6/ip6mr.c        | 17 ++++++++++++++---
 4 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index bf9b322cb0b0..d351fd3e1049 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -104,6 +104,7 @@ struct mfc_cache {
 			unsigned long bytes;
 			unsigned long pkt;
 			unsigned long wrong_if;
+			unsigned long lastuse;
 			unsigned char ttls[MAXVIFS];	/* TTL thresholds		*/
 		} res;
 	} mfc_un;
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 66982e764051..3987b64040c5 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -92,6 +92,7 @@ struct mfc6_cache {
 			unsigned long bytes;
 			unsigned long pkt;
 			unsigned long wrong_if;
+			unsigned long lastuse;
 			unsigned char ttls[MAXMIFS];	/* TTL thresholds		*/
 		} res;
 	} mfc_un;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5ad48ec77710..b0ba7f6d2731 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1150,6 +1150,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent = mfc->mfcc_parent;
+	c->mfc_un.res.lastuse = jiffies;
 	ipmr_update_thresholds(mrt, c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
@@ -1792,6 +1793,7 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 	vif = cache->mfc_parent;
 	cache->mfc_un.res.pkt++;
 	cache->mfc_un.res.bytes += skb->len;
+	cache->mfc_un.res.lastuse = jiffies;
 
 	if (cache->mfc_origin == htonl(INADDR_ANY) && true_vifi >= 0) {
 		struct mfc_cache *cache_proxy;
@@ -2071,10 +2073,13 @@ drop:
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm)
 {
-	int ct;
-	struct rtnexthop *nhp;
-	struct nlattr *mp_attr;
 	struct rta_mfc_stats mfcs;
+	struct rta_cacheinfo ci;
+	struct nlattr *mp_attr;
+	struct rtnexthop *nhp;
+	long delta;
+	int ct;
+
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mfc_parent >= MAXVIFS)
@@ -2109,7 +2114,14 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
 		return -EMSGSIZE;
 
+	memset(&ci, 0, sizeof(ci));
+	delta = jiffies - c->mfc_un.res.lastuse;
+	/* rta_lastuse is 32 bit, we shouldn't wrap the age */
+	ci.rta_lastuse = min_t(u64, jiffies_delta_to_clock_t(delta), UINT_MAX);
+	if (nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci) < 0)
+		return -EMSGSIZE;
 	rtm->rtm_type = RTN_MULTICAST;
+
 	return 1;
 }
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c7ca0f5d1a3b..6a5f1ca1dcca 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1500,6 +1500,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 	c->mf6c_origin = mfc->mf6cc_origin.sin6_addr;
 	c->mf6c_mcastgrp = mfc->mf6cc_mcastgrp.sin6_addr;
 	c->mf6c_parent = mfc->mf6cc_parent;
+	c->mfc_un.res.lastuse = jiffies;
 	ip6mr_update_thresholds(mrt, c, ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
@@ -2092,6 +2093,7 @@ static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 	vif = cache->mf6c_parent;
 	cache->mfc_un.res.pkt++;
 	cache->mfc_un.res.bytes += skb->len;
+	cache->mfc_un.res.lastuse = jiffies;
 
 	if (ipv6_addr_any(&cache->mf6c_origin) && true_vifi >= 0) {
 		struct mfc6_cache *cache_proxy;
@@ -2234,10 +2236,12 @@ int ip6_mr_input(struct sk_buff *skb)
 static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			       struct mfc6_cache *c, struct rtmsg *rtm)
 {
-	int ct;
-	struct rtnexthop *nhp;
-	struct nlattr *mp_attr;
 	struct rta_mfc_stats mfcs;
+	struct rta_cacheinfo ci;
+	struct nlattr *mp_attr;
+	struct rtnexthop *nhp;
+	long delta;
+	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mf6c_parent >= MAXMIFS)
@@ -2273,7 +2277,14 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
 		return -EMSGSIZE;
 
+	memset(&ci, 0, sizeof(ci));
+	delta = jiffies - c->mfc_un.res.lastuse;
+	/* rta_lastuse is 32 bit, we shouldn't wrap the age */
+	ci.rta_lastuse = min_t(u64, jiffies_delta_to_clock_t(delta), UINT_MAX);
+	if (nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci) < 0)
+		return -EMSGSIZE;
 	rtm->rtm_type = RTN_MULTICAST;
+
 	return 1;
 }
 
-- 
2.4.3
