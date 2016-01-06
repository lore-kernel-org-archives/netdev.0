From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] net: take care of bonding in build_skb_flow_key (v2)
Date: Wed,  6 Jan 2016 17:03:17 +0800
Message-ID: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28288 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbcAFI75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 03:59:57 -0500
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u068xuIM030801
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 08:59:56 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id u068xtsL028521
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 08:59:56 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id u068xtbi028890
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 08:59:55 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a bonding setting, we determines fragment size according to MTU and
PMTU associated to the bonding master. If the slave finds the fragment
size is too big, it drops the fragment and calls ip_rt_update_pmtu(),
passing _skb_ and _pmtu_, trying to update the path MTU.
Problem is that the target device that function ip_rt_update_pmtu actually
tries to update is the slave (skb->dev), not the master. Thus since no
PMTU change happens on master, the fragment size for later packets doesn't
change so all later fragments/packets are dropped too.

The fix is letting build_skb_flow_key() take care of the transition of
device index from bonding slave to the master. That makes the master become
the target device that ip_rt_update_pmtu tries to update PMTU to.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 net/ipv4/route.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..fffc7e6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -523,10 +523,18 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 			       const struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	int oif = skb->dev->ifindex;
 	u8 tos = RT_TOS(iph->tos);
+	struct net_device *master;
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
+	int oif;
+
+	if (skb->dev->flags & IFF_SLAVE) {
+		master = netdev_master_upper_dev_get(skb->dev);
+		oif = master->ifindex;
+	} else {
+		oif = skb->dev->ifindex;
+	}
 
 	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
 }
-- 
2.1.0
