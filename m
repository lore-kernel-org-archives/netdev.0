From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] net: take care of bonding in build_skb_flow_key (v4)
Date: Thu, 21 Jan 2016 13:32:58 +0800
Message-ID: <1453354378-3018-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com, sd@queasysnail.net,
	jay.vosburgh@canonical.com, zyjzyj2000@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16533 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbcAUF3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 00:29:48 -0500
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
 net/ipv4/route.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..7e766b5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -524,10 +524,19 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	int oif = skb->dev->ifindex;
+	struct net_device *master;
 	u8 tos = RT_TOS(iph->tos);
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
 
+	if (netif_is_bond_slave(skb->dev)) {
+		rcu_read_lock();
+		master = netdev_master_upper_dev_get_rcu(skb->dev);
+		if (master)
+			oif = master->ifindex;
+		rcu_read_unlock();
+	}
+
 	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
-- 
2.1.0
