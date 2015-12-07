From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] vxlan: interpret IP headers for ECN correctly
Date: Mon,  7 Dec 2015 16:29:08 +0100
Message-ID: <47068a34770a946e847903daa73d130d4fcbbc0e.1449502140.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932891AbbLGP3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 10:29:17 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 67F1C41
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2015 15:29:17 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-102.brq.redhat.com [10.40.204.102])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB7FTGG2018293
	for <netdev@vger.kernel.org>; Mon, 7 Dec 2015 10:29:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking for outer IP header, use the actual socket address family, not
the address family of the default destination which is not set for metadata
based interfaces (and doesn't have to match the address family of the
received packet even if it was set).

Fix also the misleading comment.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a5734d4c..2718b836c1e7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1158,7 +1158,6 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	struct pcpu_sw_netstats *stats;
 	union vxlan_addr saddr;
 	int err = 0;
-	union vxlan_addr *remote_ip;
 
 	/* For flow based devices, map all packets to VNI 0 */
 	if (vs->flags & VXLAN_F_COLLECT_METADATA)
@@ -1169,7 +1168,6 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	if (!vxlan)
 		goto drop;
 
-	remote_ip = &vxlan->default_dst.remote_ip;
 	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
@@ -1179,8 +1177,8 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
 		goto drop;
 
-	/* Re-examine inner Ethernet packet */
-	if (remote_ip->sa.sa_family == AF_INET) {
+	/* Get data from the outer IP header */
+	if (vxlan_get_sk_family(vs) == AF_INET) {
 		oip = ip_hdr(skb);
 		saddr.sin.sin_addr.s_addr = oip->saddr;
 		saddr.sa.sa_family = AF_INET;
-- 
1.8.3.1
