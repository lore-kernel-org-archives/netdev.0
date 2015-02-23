From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v3 2/4] ipv4,v6: avoid setting skb->priority when skb->reserved_tailroom is in use in igmpv3/mld
Date: Mon, 23 Feb 2015 19:52:02 +0200
Message-ID: <1424713924-6821-3-git-send-email-eyal.birger@gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
Cc: edumazet@google.com, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36877 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbBWRwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 12:52:19 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so19444326wid.5
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 09:52:18 -0800 (PST)
In-Reply-To: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IGMPv3/MLD packets are sent with TC_PRIO_CONTROL.
skb->priority is set immediately after skb allocation.

skb->reserved_tailroom is also set after allocation and is
used by the IGMPv3/MLD code prior to transmittion.

In order to be able to alias skb->priority and
skb->reserved_tailroom in struct sk_buff, the two fields
must not be used at the same time.

The skb->priority value is not required before the packet
is sent down the IP stack. Therefore, move setting
skb->priority prior to transmittion.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 net/ipv4/igmp.c  | 3 ++-
 net/ipv6/mcast.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 4b1172d..f28dc9c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -339,7 +339,6 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, unsigned int mtu)
 		if (size < 256)
 			return NULL;
 	}
-	skb->priority = TC_PRIO_CONTROL;
 
 	rt = ip_route_output_ports(net, &fl4, NULL, IGMPV3_ALL_MCR, 0,
 				   0, 0,
@@ -391,6 +390,8 @@ static int igmpv3_sendpack(struct sk_buff *skb)
 	struct igmphdr *pig = igmp_hdr(skb);
 	const int igmplen = skb_tail_pointer(skb) - skb_transport_header(skb);
 
+	skb->priority = TC_PRIO_CONTROL;
+
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
 	return ip_local_out(skb);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5ce107c..67e6c0a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1575,7 +1575,6 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
 	if (!skb)
 		return NULL;
 
-	skb->priority = TC_PRIO_CONTROL;
 	skb->reserved_tailroom = skb_end_offset(skb) -
 				 min(mtu, skb_end_offset(skb));
 	skb_reserve(skb, hlen);
@@ -1616,6 +1615,8 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 
+	skb->priority = TC_PRIO_CONTROL;
+
 	rcu_read_lock();
 	idev = __in6_dev_get(skb->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
-- 
2.1.4
