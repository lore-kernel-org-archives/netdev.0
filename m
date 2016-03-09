From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 5/7] raw: Use l3_dev for L3 ingress raw packet delivery
Date: Wed,  9 Mar 2016 13:50:09 -0800
Message-ID: <1457560209-13221-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35955 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934101AbcCIVuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:50:12 -0500
Received: by mail-pa0-f65.google.com with SMTP id 1so4199287pal.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:50:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Use the in-dev passed by the packet dispatcher for the L3 phase. If
there are places where code uses skb->dev, use the netif_get_l3_dev()
helper to get l3_dev.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 net/ipv4/raw.c | 11 +++++------
 net/ipv6/raw.c |  2 +-
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8d22de74080c..7802ce24a42d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -173,22 +173,22 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 	struct hlist_head *head;
 	int delivered = 0;
 	struct net *net;
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
 
 	read_lock(&raw_v4_hashinfo.lock);
 	head = &raw_v4_hashinfo.ht[hash];
 	if (hlist_empty(head))
 		goto out;
 
-	net = dev_net(skb->dev);
+	net = dev_net(dev);
 	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
 			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+			     dev->ifindex);
 
 	while (sk) {
 		delivered = 1;
 		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
-		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
-				   skb->dev->ifindex)) {
+		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr, dev->ifindex)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
@@ -196,8 +196,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 				raw_rcv(sk, clone);
 		}
 		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
-				     iph->saddr, iph->daddr,
-				     skb->dev->ifindex);
+				     iph->saddr, iph->daddr, dev->ifindex);
 	}
 out:
 	read_unlock(&raw_v4_hashinfo.lock);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fa59dd7a427e..22d001f0645d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -175,7 +175,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	if (!sk)
 		goto out;
 
-	net = dev_net(skb->dev);
+	net = dev_net(netif_get_l3_dev(skb->dev));
 	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, inet6_iif(skb));
 
 	while (sk) {
-- 
2.7.0.rc3.207.g0ac5344
