From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: ipmr/ip6mr: add support for keeping an entry age
Date: Thu, 14 Jul 2016 19:28:27 +0300
Message-ID: <1468513707-19016-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
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
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34427 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbcGPAH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 20:07:57 -0400
Received: by mail-pa0-f47.google.com with SMTP id fi15so43334535pac.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 17:07:57 -0700 (PDT)
In-Reply-To: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
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
affect performance because the members in that cache line are written to
along with the age.
Since all new users are encouraged to use ipmr via netlink, this is
exported via the RTA_EXPIRES attribute.
Also do a minor local variable declaration style adjustment - arrange them
longest to shortest.

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
v2: Just reuse RTA_EXPIRES instead to minimize the attr size and simplify,
others will be added when needed

 include/linux/mroute.h  |  1 +
 include/linux/mroute6.h |  1 +
 net/ipv4/ipmr.c         | 13 +++++++++----
 net/ipv6/ip6mr.c        | 13 +++++++++----
 4 files changed, 20 insertions(+), 8 deletions(-)

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
index 5ad48ec77710..e0d76f5f0113 100644
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
@@ -2071,10 +2073,10 @@ drop:
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm)
 {
-	int ct;
-	struct rtnexthop *nhp;
-	struct nlattr *mp_attr;
 	struct rta_mfc_stats mfcs;
+	struct nlattr *mp_attr;
+	struct rtnexthop *nhp;
+	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mfc_parent >= MAXVIFS)
@@ -2106,7 +2108,10 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
-	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
+	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
+	    nla_put_u64_64bit(skb, RTA_EXPIRES,
+			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+			      RTA_PAD))
 		return -EMSGSIZE;
 
 	rtm->rtm_type = RTN_MULTICAST;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c7ca0f5d1a3b..7adce139d92a 100644
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
@@ -2234,10 +2236,10 @@ int ip6_mr_input(struct sk_buff *skb)
 static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			       struct mfc6_cache *c, struct rtmsg *rtm)
 {
-	int ct;
-	struct rtnexthop *nhp;
-	struct nlattr *mp_attr;
 	struct rta_mfc_stats mfcs;
+	struct nlattr *mp_attr;
+	struct rtnexthop *nhp;
+	int ct;
 
 	/* If cache is unresolved, don't try to parse IIF and OIF */
 	if (c->mf6c_parent >= MAXMIFS)
@@ -2270,7 +2272,10 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	mfcs.mfcs_packets = c->mfc_un.res.pkt;
 	mfcs.mfcs_bytes = c->mfc_un.res.bytes;
 	mfcs.mfcs_wrong_if = c->mfc_un.res.wrong_if;
-	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) < 0)
+	if (nla_put_64bit(skb, RTA_MFC_STATS, sizeof(mfcs), &mfcs, RTA_PAD) ||
+	    nla_put_u64_64bit(skb, RTA_EXPIRES,
+			      jiffies_to_clock_t(c->mfc_un.res.lastuse),
+			      RTA_PAD))
 		return -EMSGSIZE;
 
 	rtm->rtm_type = RTN_MULTICAST;
-- 
2.4.3
