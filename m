From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: [PATCH net-next v2] ipv6: Do not iterate over all interfaces when
 finding source address on specific interface.
Date: Fri, 10 Jul 2015 16:58:31 +0900
Message-ID: <559F7B27.6030205@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: davem@davemloft.net, netdev@vger.kernel.org, ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36015 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbbGJH6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 03:58:36 -0400
Received: by pacgz10 with SMTP id gz10so91176828pac.3
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 00:58:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If outgoing interface is specified and the candidate address is
restricted to the outgoing interface, it is enough to iterate
over that given interface only.

Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Acked-by: Erik Kline <ek@google.com>
---
 net/ipv6/addrconf.c | 197 ++++++++++++++++++++++++++++------------------------
 1 file changed, 107 insertions(+), 90 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..4ab74d5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1358,15 +1358,94 @@ out:
 	return ret;
 }
 
+static void __ipv6_dev_get_saddr(struct net *net,
+				 struct ipv6_saddr_dst *dst,
+				 unsigned int prefs,
+				 const struct in6_addr *saddr,
+				 struct inet6_dev *idev,
+				 struct ipv6_saddr_score *scores)
+{
+	struct ipv6_saddr_score *score = &scores[0], *hiscore = &scores[1];
+
+	read_lock_bh(&idev->lock);
+	list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
+		int i;
+
+		/*
+		 * - Tentative Address (RFC2462 section 5.4)
+		 *  - A tentative address is not considered
+		 *    "assigned to an interface" in the traditional
+		 *    sense, unless it is also flagged as optimistic.
+		 * - Candidate Source Address (section 4)
+		 *  - In any case, anycast addresses, multicast
+		 *    addresses, and the unspecified address MUST
+		 *    NOT be included in a candidate set.
+		 */
+		if ((score->ifa->flags & IFA_F_TENTATIVE) &&
+		    (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
+			continue;
+
+		score->addr_type = __ipv6_addr_type(&score->ifa->addr);
+
+		if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
+			     score->addr_type & IPV6_ADDR_MULTICAST)) {
+			net_dbg_ratelimited("ADDRCONF: unspecified / multicast address assigned as unicast address on %s",
+					    idev->dev->name);
+			continue;
+		}
+
+		score->rule = -1;
+		bitmap_zero(score->scorebits, IPV6_SADDR_RULE_MAX);
+
+		for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
+			int minihiscore, miniscore;
+
+			minihiscore = ipv6_get_saddr_eval(net, hiscore, dst, i);
+			miniscore = ipv6_get_saddr_eval(net, score, dst, i);
+
+			if (minihiscore > miniscore) {
+				if (i == IPV6_SADDR_RULE_SCOPE &&
+				    score->scopedist > 0) {
+					/*
+					 * special case:
+					 * each remaining entry
+					 * has too small (not enough)
+					 * scope, because ifa entries
+					 * are sorted by their scope
+					 * values.
+					 */
+					goto out;
+				}
+				break;
+			} else if (minihiscore < miniscore) {
+				if (hiscore->ifa)
+					in6_ifa_put(hiscore->ifa);
+
+				in6_ifa_hold(score->ifa);
+
+				swap(hiscore, score);
+
+				/* restore our iterator */
+				score->ifa = hiscore->ifa;
+
+				break;
+			}
+		}
+	}
+out:
+	read_unlock_bh(&idev->lock);
+}
+
 int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
-	struct ipv6_saddr_score scores[2],
-				*score = &scores[0], *hiscore = &scores[1];
+	struct ipv6_saddr_score scores[2], *hiscore = &scores[1];
 	struct ipv6_saddr_dst dst;
+	struct inet6_dev *idev;
 	struct net_device *dev;
 	int dst_type;
+	bool use_oif_addr = false;
 
 	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
@@ -1380,97 +1459,35 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 
 	rcu_read_lock();
 
-	for_each_netdev_rcu(net, dev) {
-		struct inet6_dev *idev;
-
-		/* Candidate Source Address (section 4)
-		 *  - multicast and link-local destination address,
-		 *    the set of candidate source address MUST only
-		 *    include addresses assigned to interfaces
-		 *    belonging to the same link as the outgoing
-		 *    interface.
-		 * (- For site-local destination addresses, the
-		 *    set of candidate source addresses MUST only
-		 *    include addresses assigned to interfaces
-		 *    belonging to the same site as the outgoing
-		 *    interface.)
-		 */
-		if (((dst_type & IPV6_ADDR_MULTICAST) ||
-		     dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
-		    dst.ifindex && dev->ifindex != dst.ifindex)
-			continue;
-
-		idev = __in6_dev_get(dev);
-		if (!idev)
-			continue;
-
-		read_lock_bh(&idev->lock);
-		list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
-			int i;
-
-			/*
-			 * - Tentative Address (RFC2462 section 5.4)
-			 *  - A tentative address is not considered
-			 *    "assigned to an interface" in the traditional
-			 *    sense, unless it is also flagged as optimistic.
-			 * - Candidate Source Address (section 4)
-			 *  - In any case, anycast addresses, multicast
-			 *    addresses, and the unspecified address MUST
-			 *    NOT be included in a candidate set.
-			 */
-			if ((score->ifa->flags & IFA_F_TENTATIVE) &&
-			    (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
-				continue;
-
-			score->addr_type = __ipv6_addr_type(&score->ifa->addr);
+	/* Candidate Source Address (section 4)
+	 *  - multicast and link-local destination address,
+	 *    the set of candidate source address MUST only
+	 *    include addresses assigned to interfaces
+	 *    belonging to the same link as the outgoing
+	 *    interface.
+	 * (- For site-local destination addresses, the
+	 *    set of candidate source addresses MUST only
+	 *    include addresses assigned to interfaces
+	 *    belonging to the same site as the outgoing
+	 *    interface.)
+	 */
+	if (dst_dev) {
+		if ((dst_type & IPV6_ADDR_MULTICAST) ||
+		    dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) {
+			idev = __in6_dev_get(dst_dev);
+			use_oif_addr = true;
+		}
+	}
 
-			if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
-				     score->addr_type & IPV6_ADDR_MULTICAST)) {
-				net_dbg_ratelimited("ADDRCONF: unspecified / multicast address assigned as unicast address on %s",
-						    dev->name);
+	if (use_oif_addr) {
+		__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
+	} else {
+		for_each_netdev_rcu(net, dev) {
+			idev = __in6_dev_get(dev);
+			if (!idev)
 				continue;
-			}
-
-			score->rule = -1;
-			bitmap_zero(score->scorebits, IPV6_SADDR_RULE_MAX);
-
-			for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
-				int minihiscore, miniscore;
-
-				minihiscore = ipv6_get_saddr_eval(net, hiscore, &dst, i);
-				miniscore = ipv6_get_saddr_eval(net, score, &dst, i);
-
-				if (minihiscore > miniscore) {
-					if (i == IPV6_SADDR_RULE_SCOPE &&
-					    score->scopedist > 0) {
-						/*
-						 * special case:
-						 * each remaining entry
-						 * has too small (not enough)
-						 * scope, because ifa entries
-						 * are sorted by their scope
-						 * values.
-						 */
-						goto try_nextdev;
-					}
-					break;
-				} else if (minihiscore < miniscore) {
-					if (hiscore->ifa)
-						in6_ifa_put(hiscore->ifa);
-
-					in6_ifa_hold(score->ifa);
-
-					swap(hiscore, score);
-
-					/* restore our iterator */
-					score->ifa = hiscore->ifa;
-
-					break;
-				}
-			}
+			__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
 		}
-try_nextdev:
-		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
 
-- 
1.9.1
