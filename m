From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/8] net: Change SKB_GSO_DODGY to be a tx_flag
Date: Thu, 16 Jun 2016 10:51:55 -0700
Message-ID: <1466099522-690741-2-git-send-email-tom@herbertland.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46281 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755121AbcFPRwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:23 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHobfb003095
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kxw30q59-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:22 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1376f5e233eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:21 -0700
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces gso_type SKB_GSO_DODGY with a new tx_flag named
SKBTX_UNTRUSTED_SOURCE. This more generically desrcibes the skb
being created from a untrusted source as a characteristic of and skbuff.
This also frees up one gso_type flag bit.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/xen-netfront.c      | 2 +-
 include/linux/netdev_features.h | 3 ++-
 include/linux/netdevice.h       | 1 -
 include/linux/skbuff.h          | 6 ++++--
 include/linux/virtio_net.h      | 2 +-
 net/core/dev.c                  | 2 +-
 net/core/skbuff.c               | 2 +-
 net/packet/af_packet.c          | 2 +-
 8 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 96ccd4e..6f5ae17 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -854,7 +854,7 @@ static int xennet_set_skb_gso(struct sk_buff *skb,
 		SKB_GSO_TCPV6;
 
 	/* Header must be checked, and gso_segs computed. */
-	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+	skb_shinfo(skb)->tx_flags |= SKBTX_UNTRUSTED_SOURCE;
 	skb_shinfo(skb)->gso_segs = 0;
 
 	return 0;
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9c6c8ef..ab15c6a 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -37,7 +37,7 @@ enum {
 	NETIF_F_TSO_BIT			/* ... TCPv4 segmentation */
 		= NETIF_F_GSO_SHIFT,
 	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
-	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKB_GSO_DODGY */
+	NETIF_F_GSO_RSVD,		/* ... Reserved */
 	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
 	NETIF_F_TSO_MANGLEID_BIT,	/* ... IPV4 ID mangling allowed */
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
@@ -57,6 +57,7 @@ enum {
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
 		NETIF_F_GSO_SCTP_BIT,
 
+	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKBTX_UNTRUSTED_SOURCE */
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
 	NETIF_F_FCOE_MTU_BIT,		/* Supports max FCoE MTU, 2158 bytes*/
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 890158e..5969028 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4023,7 +4023,6 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_FIXEDID != (NETIF_F_TSO_MANGLEID >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dc0fca7..be34e06 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -387,6 +387,9 @@ enum {
 
 	/* generate software time stamp when entering packet scheduling */
 	SKBTX_SCHED_TSTAMP = 1 << 6,
+
+	/* skb created from untrusted source */
+	SKBTX_UNTRUSTED_SOURCE = 1 << 7,
 };
 
 #define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP    | \
@@ -460,8 +463,7 @@ enum {
 	SKB_GSO_TCPV4 = 1 << 0,
 	SKB_GSO_UDP = 1 << 1,
 
-	/* This indicates the skb is from an untrusted source. */
-	SKB_GSO_DODGY = 1 << 2,
+	SKB_GSO_RSVD = 1 << 2,
 
 	/* This indicates the tcp segment has CWR set. */
 	SKB_GSO_TCP_ECN = 1 << 3,
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 1c912f8..5814c8e 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -47,7 +47,7 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 		skb_shinfo(skb)->gso_type = gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
-		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->tx_flags |= SKBTX_UNTRUSTED_SOURCE;
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b148357..3d73640 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3057,7 +3057,7 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
 		else
 			hdr_len += sizeof(struct udphdr);
 
-		if (shinfo->gso_type & SKB_GSO_DODGY)
+		if (skb_shinfo(skb)->tx_flags & SKBTX_UNTRUSTED_SOURCE)
 			gso_segs = DIV_ROUND_UP(skb->len - hdr_len,
 						shinfo->gso_size);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e7ec6d3..2126b88 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3305,11 +3305,11 @@ perform_csum_check:
 
 		/* Update type to add partial and then remove dodgy if set */
 		type |= SKB_GSO_PARTIAL;
-		type &= ~SKB_GSO_DODGY;
 
 		/* Update GSO info and prepare to start updating headers on
 		 * our way back down the stack of protocols.
 		 */
+		skb_shinfo(segs)->tx_flags &= ~SKBTX_UNTRUSTED_SOURCE;
 		skb_shinfo(segs)->gso_size = skb_shinfo(head_skb)->gso_size;
 		skb_shinfo(segs)->gso_segs = partial_segs;
 		skb_shinfo(segs)->gso_type = type;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d1f3b9e..a8f75bd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2468,7 +2468,7 @@ static int packet_snd_vnet_gso(struct sk_buff *skb,
 	skb_shinfo(skb)->gso_type = vnet_hdr->gso_type;
 
 	/* Header must be checked, and gso_segs computed. */
-	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+	skb_shinfo(skb)->tx_flags |= SKBTX_UNTRUSTED_SOURCE;
 	skb_shinfo(skb)->gso_segs = 0;
 	return 0;
 }
-- 
2.8.0.rc2
