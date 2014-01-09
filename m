From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 3/3] xen-netfront: use new skb_checksum_setup function
Date: Thu, 9 Jan 2014 10:02:48 +0000
Message-ID: <1389261768-30606-4-git-send-email-paul.durrant@citrix.com>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:17892 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbaAIKCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:02:53 -0500
In-Reply-To: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_setup to set up partial checksum offsets rather
then a private implementation.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |   48 +++-----------------------------------------
 1 file changed, 3 insertions(+), 45 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e59acb1..c41537b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -859,9 +859,7 @@ static RING_IDX xennet_fill_frags(struct netfront_info *np,
 
 static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 {
-	struct iphdr *iph;
-	int err = -EPROTO;
-	int recalculate_partial_csum = 0;
+	bool recalculate_partial_csum = false;
 
 	/*
 	 * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
@@ -873,54 +871,14 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 		struct netfront_info *np = netdev_priv(dev);
 		np->rx_gso_checksum_fixup++;
 		skb->ip_summed = CHECKSUM_PARTIAL;
-		recalculate_partial_csum = 1;
+		recalculate_partial_csum = true;
 	}
 
 	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
 
-	if (skb->protocol != htons(ETH_P_IP))
-		goto out;
-
-	iph = (void *)skb->data;
-
-	switch (iph->protocol) {
-	case IPPROTO_TCP:
-		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
-					  offsetof(struct tcphdr, check)))
-			goto out;
-
-		if (recalculate_partial_csum) {
-			struct tcphdr *tcph = tcp_hdr(skb);
-			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 skb->len - iph->ihl*4,
-							 IPPROTO_TCP, 0);
-		}
-		break;
-	case IPPROTO_UDP:
-		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
-					  offsetof(struct udphdr, check)))
-			goto out;
-
-		if (recalculate_partial_csum) {
-			struct udphdr *udph = udp_hdr(skb);
-			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 skb->len - iph->ihl*4,
-							 IPPROTO_UDP, 0);
-		}
-		break;
-	default:
-		if (net_ratelimit())
-			pr_err("Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
-			       iph->protocol);
-		goto out;
-	}
-
-	err = 0;
-
-out:
-	return err;
+	return skb_checksum_setup(skb, recalculate_partial_csum);
 }
 
 static int handle_incoming_queue(struct net_device *dev,
-- 
1.7.10.4
