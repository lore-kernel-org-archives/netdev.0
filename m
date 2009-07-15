From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 2/2] tun: Allow tap device to send/receive UFO
 packets.
Date: Tue, 14 Jul 2009 17:21:04 -0700
Message-ID: <1247617264.4998.77.camel@IBM-19B5263ED41-009047018100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:42643 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330AbZGOAVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 20:21:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6EKL4uJ023835
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 16:21:04 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6F0L96N178096
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:21:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6F0IZ60028337
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 2/2] tun: Allow tap device to send/receive UFO packets.

- Allow setting UFO on tap device and handle UFO packets.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---------------------------------------------------------

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dfc1054..a998b6a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -641,6 +641,9 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		case VIRTIO_NET_HDR_GSO_TCPV6:
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			break;
 		default:
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
@@ -726,6 +729,8 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else
 				BUG();
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
@@ -1073,7 +1078,8 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 	old_features = dev->features;
 	/* Unset features, set them as we chew on the arg. */
 	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST
-				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6));
+				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6
+				    |NETIF_F_UFO));
 
 	if (arg & TUN_F_CSUM) {
 		features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
@@ -1090,6 +1096,11 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 				features |= NETIF_F_TSO6;
 			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
 		}
+
+		if (arg & TUN_F_UFO) {
+			features |= NETIF_F_UFO;
+			arg &= ~TUN_F_UFO;
+		}
 	}
 
 	/* This gives the user a way to test for new features in future by
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 915ba57..3f5fd52 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -62,6 +62,7 @@
 #define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */
 #define TUN_F_TSO6	0x04	/* I can handle TSO for IPv6 packets */
 #define TUN_F_TSO_ECN	0x08	/* I can handle TSO with ECN bits. */
+#define TUN_F_UFO	0x10	/* I can handle UFO packets */
 
 /* Protocol info prepended to the packets (when IFF_NO_PI is not set) */
 #define TUN_PKT_STRIP	0x0001


