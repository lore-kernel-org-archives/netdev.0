From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 2/3] net: Add L3 Rx handler to IPv4 processing
Date: Fri, 28 Aug 2015 17:34:22 -0700
Message-ID: <1440808463-14526-3-git-send-email-dsa@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33617 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbbH2Aec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:34:32 -0400
Received: by pacgr6 with SMTP id gr6so4636730pac.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 17:34:31 -0700 (PDT)
In-Reply-To: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an L3 RX handler has been set for the current skb device then the
skb is run through the NF_HOOK for NF_INET_PRE_ROUTING with a dummy
function to not further process the packet. From there the skb is passed
to the L3 RX handler. The L3 RX handler maintains the same semantics as
the current RX handler -- it can modify the skb and ask for another pass,
consume it or just ignore the packet and have it continue on.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_input.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f4fc8a77aaa7..75da9dc0e8f5 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -372,11 +372,17 @@ static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 	return NET_RX_DROP;
 }
 
+static int ip_rcv_first_pass(struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
+
 /*
  * 	Main IP Receive routine.
  */
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
+	rx_handler_func_t *rx_handler;
 	const struct iphdr *iph;
 	u32 len;
 
@@ -386,6 +392,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	if (skb->pkt_type == PACKET_OTHERHOST)
 		goto drop;
 
+another_round:
+	rx_handler = rcu_dereference(skb->dev->l3_rx_handler);
 
 	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
 
@@ -453,9 +461,29 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
+	if (rx_handler) {
+		int rc;
+
+		rc = NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
+			     dev, NULL, ip_rcv_first_pass);
+		if (rc != 0)
+			return rc;
+
+		switch (rx_handler(&skb)) {
+		case RX_HANDLER_CONSUMED:
+			return 0;
+		case RX_HANDLER_ANOTHER:
+			rx_handler = NULL;
+			goto another_round;
+		case RX_HANDLER_PASS:
+			return ip_rcv_finish(NULL, skb);
+		default:
+			pr_err("Invalid return for L3 rx_handler\n");
+		}
+	}
+
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
-		       dev, NULL,
-		       ip_rcv_finish);
+		       dev, NULL, ip_rcv_finish);
 
 csum_error:
 	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_CSUMERRORS);
-- 
1.9.1
