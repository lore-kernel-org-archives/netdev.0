From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] net: vrf: Minor refactoring for local address patches
Date: Thu,  2 Jun 2016 13:15:10 -0700
Message-ID: <1464898512-5157-2-git-send-email-dsa@cumulusnetworks.com>
References: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33760 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932532AbcFBUQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 16:16:42 -0400
Received: by mail-pf0-f175.google.com with SMTP id b124so35099923pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 13:16:42 -0700 (PDT)
In-Reply-To: <1464898512-5157-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the stripping of the ethernet header from is_ip_tx_frame into the
ipv4 and ipv6 outbound functions. If the packet is destined to a local
address the header is retained since the packet is sent back to netif_rx.

Collapse vrf_send_v4_prep into vrf_process_v4_outbound.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 45 ++++++++++++++++++---------------------------
 1 file changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index aaac4c779047..d678aaeba572 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -125,6 +125,9 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
 
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	ret = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(ret)))
 		dev->stats.tx_errors++;
@@ -145,29 +148,6 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 }
 #endif
 
-static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
-			    struct net_device *vrf_dev)
-{
-	struct rtable *rt;
-	int err = 1;
-
-	rt = ip_route_output_flow(dev_net(vrf_dev), fl4, NULL);
-	if (IS_ERR(rt))
-		goto out;
-
-	/* TO-DO: what about broadcast ? */
-	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
-		ip_rt_put(rt);
-		goto out;
-	}
-
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-	err = 0;
-out:
-	return err;
-}
-
 static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 					   struct net_device *vrf_dev)
 {
@@ -182,10 +162,24 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 				FLOWI_FLAG_SKIP_NH_OIF,
 		.daddr = ip4h->daddr,
 	};
+	struct net *net = dev_net(vrf_dev);
+	struct rtable *rt;
 
-	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
+	rt = ip_route_output_flow(net, &fl4, NULL);
+	if (IS_ERR(rt))
 		goto err;
 
+	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
+		ip_rt_put(rt);
+		goto err;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	if (!ip4h->saddr) {
 		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
 					       RT_SCOPE_LINK);
@@ -206,9 +200,6 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 
 static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 {
-	/* strip the ethernet header added for pass through VRF device */
-	__skb_pull(skb, skb_network_offset(skb));
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return vrf_process_v4_outbound(skb, dev);
-- 
2.1.4
