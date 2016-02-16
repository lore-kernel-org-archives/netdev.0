From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 6/7] vxlan: clean up rx error path
Date: Tue, 16 Feb 2016 21:59:02 +0100
Message-ID: <62914665f0e1f1b8d31f031acb69282778629ad9.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbcBPU7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:37 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 0B3BC32D3A3
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:37 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxT00018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:36 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are unrecognized flags present in the vxlan header, it doesn't
make much sense to return the packet for further UDP processing, especially
considering that for other invalid flag combinations we drop the packet
because of previous checks.

This means we return positive value only at the beginning of the function
where tun_dst is not yet allocated. This allows us to get rid of the
bad_flags and error jump labels.

When we're dropping packet, we need to free tun_dst now.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 35 ++++++++++++++---------------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 40f61c15a4a6..6cb26a8a1615 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1278,16 +1278,19 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
-		goto error;
+		return 1;
 
 	unparsed = *vxlan_hdr(skb);
-	if (unparsed.vx_flags & VXLAN_HF_VNI) {
-		unparsed.vx_flags &= ~VXLAN_HF_VNI;
-		unparsed.vx_vni &= ~VXLAN_VNI_MASK;
-	} else {
-		/* VNI flag always required to be set */
-		goto bad_flags;
+	/* VNI flag always required to be set */
+	if (!(unparsed.vx_flags & VXLAN_HF_VNI)) {
+		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
+			   ntohl(vxlan_hdr(skb)->vx_flags),
+			   ntohl(vxlan_hdr(skb)->vx_vni));
+		/* Return non vxlan pkt */
+		return 1;
 	}
+	unparsed.vx_flags &= ~VXLAN_HF_VNI;
+	unparsed.vx_vni &= ~VXLAN_VNI_MASK;
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
@@ -1327,29 +1330,19 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		 * is more robust and provides a little more security in
 		 * adding extensions to VXLAN.
 		 */
-
-		goto bad_flags;
+		goto drop;
 	}
 
 	vxlan_rcv(vs, skb, md, vxlan_vni(vxlan_hdr(skb)->vx_vni), tun_dst);
 	return 0;
 
 drop:
-	/* Consume bad packet */
-	kfree_skb(skb);
-	return 0;
-
-bad_flags:
-	netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-		   ntohl(vxlan_hdr(skb)->vx_flags),
-		   ntohl(vxlan_hdr(skb)->vx_vni));
-
-error:
 	if (tun_dst)
 		dst_release((struct dst_entry *)tun_dst);
 
-	/* Return non vxlan pkt */
-	return 1;
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
 }
 
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
-- 
1.8.3.1
