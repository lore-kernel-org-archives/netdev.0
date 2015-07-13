From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: [PATCH] ipv6: Fix finding best source address in ipv6_dev_get_saddr().
Date: Mon, 13 Jul 2015 23:28:10 +0900
Message-ID: <55A3CAFA.3060404@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ek@google.com, thehajime@gmail.com,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZA==?=
	 =?ISO-2022-JP?B?ZWFraS8bJEI1SEYjMVFMQBsoQg==?=
	<hideaki.yoshifuji@miraclelinux.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36660 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbbGMO2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 10:28:15 -0400
Received: by pdjr16 with SMTP id r16so63806878pdj.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 07:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9131f3de2 ("ipv6: Do not iterate over all interfaces when
finding source address on specific interface.") did not properly
update best source address available.  Plus, it introduced
possible NULL pointer dereference.

Bug was reported by Erik Kline <ek@google.com>.
Based on patch proposed by Hajime Tazaki <thehajime@gmail.com>.

Fixes: 9131f3de24db4dc12199aede7d931e6703e97f3b ("ipv6: Do not
	iterate over all interfaces when finding source address
	on specific interface.")
Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 net/ipv6/addrconf.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4ab74d5..4c9a024 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1358,14 +1358,15 @@ out:
 	return ret;
 }
 
-static void __ipv6_dev_get_saddr(struct net *net,
-				 struct ipv6_saddr_dst *dst,
-				 unsigned int prefs,
-				 const struct in6_addr *saddr,
-				 struct inet6_dev *idev,
-				 struct ipv6_saddr_score *scores)
+static int __ipv6_dev_get_saddr(struct net *net,
+				struct ipv6_saddr_dst *dst,
+				unsigned int prefs,
+				const struct in6_addr *saddr,
+				struct inet6_dev *idev,
+				struct ipv6_saddr_score *scores,
+				int hiscore_idx)
 {
-	struct ipv6_saddr_score *score = &scores[0], *hiscore = &scores[1];
+	struct ipv6_saddr_score *score = &scores[1 - hiscore_idx], *hiscore = &scores[hiscore_idx];
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
@@ -1424,6 +1425,7 @@ static void __ipv6_dev_get_saddr(struct net *net,
 				in6_ifa_hold(score->ifa);
 
 				swap(hiscore, score);
+				hiscore_idx = 1 - hiscore_idx;
 
 				/* restore our iterator */
 				score->ifa = hiscore->ifa;
@@ -1434,18 +1436,20 @@ static void __ipv6_dev_get_saddr(struct net *net,
 	}
 out:
 	read_unlock_bh(&idev->lock);
+	return hiscore_idx;
 }
 
 int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
-	struct ipv6_saddr_score scores[2], *hiscore = &scores[1];
+	struct ipv6_saddr_score scores[2], *hiscore;
 	struct ipv6_saddr_dst dst;
 	struct inet6_dev *idev;
 	struct net_device *dev;
 	int dst_type;
 	bool use_oif_addr = false;
+	int hiscore_idx = 0;
 
 	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
@@ -1454,8 +1458,8 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	dst.label = ipv6_addr_label(net, daddr, dst_type, dst.ifindex);
 	dst.prefs = prefs;
 
-	hiscore->rule = -1;
-	hiscore->ifa = NULL;
+	scores[hiscore_idx].rule = -1;
+	scores[hiscore_idx].ifa = NULL;
 
 	rcu_read_lock();
 
@@ -1480,17 +1484,19 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	}
 
 	if (use_oif_addr) {
-		__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
+		if (idev)
+			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores, hiscore_idx);
 	} else {
 		for_each_netdev_rcu(net, dev) {
 			idev = __in6_dev_get(dev);
 			if (!idev)
 				continue;
-			__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
+			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores, hiscore_idx);
 		}
 	}
 	rcu_read_unlock();
 
+	hiscore = &scores[hiscore_idx];
 	if (!hiscore->ifa)
 		return -EADDRNOTAVAIL;
 
-- 
1.9.1
