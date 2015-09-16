From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 08/30] ipv4: Compute net once in ip_rcv
Date: Tue, 15 Sep 2015 20:03:56 -0500
Message-ID: <1442365458-16349-8-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39225 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbbIPBLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:11:47 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_input.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f4fc8a77aaa7..ff908863f22e 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -378,6 +378,7 @@ drop:
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	const struct iphdr *iph;
+	struct net *net;
 	u32 len;
 
 	/* When the interface is in promisc. mode, drop all the crap
@@ -387,11 +388,12 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 
 
-	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
+	net = dev_net(dev);
+	IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_IN, skb->len);
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
 
@@ -417,7 +419,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	BUILD_BUG_ON(IPSTATS_MIB_ECT1PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_1);
 	BUILD_BUG_ON(IPSTATS_MIB_ECT0PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_0);
 	BUILD_BUG_ON(IPSTATS_MIB_CEPKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_CE);
-	IP_ADD_STATS_BH(dev_net(dev),
+	IP_ADD_STATS_BH(net,
 			IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
 			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 
@@ -431,7 +433,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
@@ -441,7 +443,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 * Note this now means skb->len holds ntohs(iph->tot_len).
 	 */
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -458,9 +460,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		       ip_rcv_finish);
 
 csum_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_CSUMERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_CSUMERRORS);
 inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
 drop:
 	kfree_skb(skb);
 out:
-- 
2.2.1
