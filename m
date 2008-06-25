From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/4] tun: Allow GSO using virtio_net_hdr
Date: Thu, 26 Jun 2008 00:30:37 +1000
Message-ID: <200806260030.38293.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260029.40267.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39684 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbYFYOa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:30:58 -0400
In-Reply-To: <200806260029.40267.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a IFF_VNET_HDR flag.  This uses the same ABI as virtio_net (ie. prepending
struct virtio_net_hdr to packets) to indicate GSO and checksum information.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |   90 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_tun.h |    2 +
 2 files changed, 91 insertions(+), 1 deletion(-)

diff -r d94590c1550a drivers/net/tun.c
--- a/drivers/net/tun.c	Thu Jun 26 00:21:11 2008 +1000
+++ b/drivers/net/tun.c	Thu Jun 26 00:21:59 2008 +1000
@@ -63,6 +63,7 @@
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
 #include <linux/nsproxy.h>
+#include <linux/virtio_net.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -283,12 +284,24 @@ static __inline__ ssize_t tun_get_user(s
 	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
 	struct sk_buff *skb;
 	size_t len = count, align = 0;
+	struct virtio_net_hdr gso = { 0 };
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) > count)
 			return -EINVAL;
 
 		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
+			return -EFAULT;
+	}
+
+	if (tun->flags & TUN_VNET_HDR) {
+		if ((len -= sizeof(gso)) > count)
+			return -EINVAL;
+
+		if (gso.hdr_len > len)
+			return -EINVAL;
+
+		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
 			return -EFAULT;
 	}
 
@@ -322,8 +335,45 @@ static __inline__ ssize_t tun_get_user(s
 		break;
 	};
 
-	if (tun->flags & TUN_NOCHECKSUM)
+	if (gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		if (!skb_partial_csum_set(skb, gso.csum_start,
+					  gso.csum_offset)) {
+			tun->dev->stats.rx_dropped++;
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+	} else if (tun->flags & TUN_NOCHECKSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		pr_debug("GSO!\n");
+		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		case VIRTIO_NET_HDR_GSO_TCPV4:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV6:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+			break;
+		default:
+			tun->dev->stats.rx_dropped++;
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+
+		if (gso.gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+
+		skb_shinfo(skb)->gso_size = gso.gso_size;
+		if (skb_shinfo(skb)->gso_size == 0) {
+			tun->dev->stats.rx_dropped++;
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+
+		/* Header must be checked, and gso_segs computed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
 
 	netif_rx_ni(skb);
 	tun->dev->last_rx = jiffies;
@@ -367,6 +417,39 @@ static __inline__ ssize_t tun_put_user(s
 		if (memcpy_toiovec(iv, (void *) &pi, sizeof(pi)))
 			return -EFAULT;
 		total += sizeof(pi);
+	}
+
+	if (tun->flags & TUN_VNET_HDR) {
+		struct virtio_net_hdr gso = { 0 }; /* no info leak */
+		if ((len -= sizeof(gso)) < 0)
+			return -EINVAL;
+
+		if (skb_is_gso(skb)) {
+			struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+			/* This is a hint as to how much should be linear. */
+			gso.hdr_len = skb_headlen(skb);
+			gso.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCPV4)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else
+				BUG();
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		} else
+			gso.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			gso.csum_start = skb->csum_start - skb_headroom(skb);
+			gso.csum_offset = skb->csum_offset;
+		} /* else everything is zero */
+
+		if (unlikely(memcpy_toiovec(iv, (void *)&gso, sizeof(gso))))
+			return -EFAULT;
+		total += sizeof(gso);
 	}
 
 	len = min_t(int, skb->len, len);
@@ -583,6 +666,11 @@ static int tun_set_iff(struct net *net, 
 	else
 		tun->flags &= ~TUN_ONE_QUEUE;
 
+	if (ifr->ifr_flags & IFF_VNET_HDR)
+		tun->flags |= TUN_VNET_HDR;
+	else
+		tun->flags &= ~TUN_VNET_HDR;
+
 	file->private_data = tun;
 	tun->attached = 1;
 	get_net(dev_net(tun->dev));
@@ -669,7 +757,8 @@ static int tun_chr_ioctl(struct inode *i
 		/* Currently this just means: "what IFF flags are valid?".
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
-		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE,
+		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
+				IFF_VNET_HDR,
 				(unsigned int __user*)argp);
 	}
 
diff -r d94590c1550a include/linux/if_tun.h
--- a/include/linux/if_tun.h	Thu Jun 26 00:21:11 2008 +1000
+++ b/include/linux/if_tun.h	Thu Jun 26 00:21:59 2008 +1000
@@ -33,6 +33,7 @@
 #define TUN_NO_PI	0x0040
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
+#define TUN_VNET_HDR 	0x0200
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -50,6 +51,7 @@
 #define IFF_TAP		0x0002
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
+#define IFF_VNET_HDR	0x4000
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
