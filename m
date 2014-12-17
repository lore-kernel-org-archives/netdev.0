From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 10/10] Revert "drivers/net: Disable UFO through virtio"
Date: Wed, 17 Dec 2014 13:20:55 -0500
Message-ID: <1418840455-22598-11-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:65480 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaLQSVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:31 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so14069387qcw.9
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:30 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3d0ad09412ffe00c9afa201d01effdb6023d09b4.
Now that we've split UFO into v4 and v6 version, we can turn
back UFO support for ipv4.  Full IPv6 support will come later as
it requires extending vnet header structure.

Any older VM that assumes IPv6 support is included in UFO
will continue to use UFO and the host will generate fragment
ids for it, thus preserving connectivity.

Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
CC: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b0bc8ea..534b633 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -491,17 +491,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-		{
-			static bool warned;
-
-			if (!warned) {
-				warned = true;
-				netdev_warn(dev,
-					    "host using disabled UFO feature; please fix it\n");
-			}
 			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 			break;
-		}
 		case VIRTIO_NET_HDR_GSO_TCPV6:
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
@@ -890,6 +881,8 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
 			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 		else
 			BUG();
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
@@ -1749,7 +1742,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |= NETIF_F_TSO
+			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
 		/* Individual feature bits: what can host handle? */
@@ -1759,9 +1752,11 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_TSO6;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
 			dev->hw_features |= NETIF_F_TSO_ECN;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
+			dev->hw_features |= NETIF_F_UFO;
 
 		if (gso)
-			dev->features |= dev->hw_features & NETIF_F_ALL_TSO;
+			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
@@ -1799,7 +1794,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
-	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_UFO))
 		vi->big_packets = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
@@ -1993,9 +1989,9 @@ static struct virtio_device_id id_table[] = {
 static unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
-	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_TSO6,
+	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
-	VIRTIO_NET_F_GUEST_ECN,
+	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
-- 
1.9.3
