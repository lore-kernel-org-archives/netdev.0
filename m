From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: igmp: Use ingress interface rather than vrf device
Date: Tue, 15 Aug 2017 18:38:42 -0700
Message-ID: <1502847522-13020-1-git-send-email-dsahern@gmail.com>
Cc: nikolay@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33162 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752697AbdHPBiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 21:38:51 -0400
Received: by mail-pg0-f68.google.com with SMTP id u185so3981481pgb.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 18:38:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anuradha reported that statically added groups for interfaces enslaved
to a VRF device were not persisting. The problem is that igmp queries
and reports need to use the data in the in_dev for the real ingress
device rather than the VRF device. Update igmp_rcv accordingly.

Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
Reported-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/igmp.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 9f86b5133605..ab183af0b5b6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1007,10 +1007,18 @@ int igmp_rcv(struct sk_buff *skb)
 {
 	/* This basically follows the spec line by line -- see RFC1112 */
 	struct igmphdr *ih;
-	struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+	struct net_device *dev = skb->dev;
+	struct in_device *in_dev;
 	int len = skb->len;
 	bool dropped = true;
 
+	if (netif_is_l3_master(dev)) {
+		dev = dev_get_by_index_rcu(dev_net(dev), IPCB(skb)->iif);
+		if (!dev)
+			goto drop;
+	}
+
+	in_dev = __in_dev_get_rcu(dev);
 	if (!in_dev)
 		goto drop;
 
-- 
2.1.4
