From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Fri, 12 Feb 2010 14:27:47 -0800
Message-ID: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:57867 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab0BLW2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 17:28:00 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1CMP8pm001475
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 15:25:08 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1CMRrNi059640
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 15:27:54 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1CMRrG3027825
	for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 15:27:53 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GSO/checksum offload support to macvtap driver and applies
on top of Arnd's refcnt bugfix.
	http://patchwork.ozlabs.org/patch/45136/

Added flags field to macvtap_queue to enable/disable processing of
virtio_net_hdr via IFF_VNET_HDR. This flag is checked to prepend virtio_net_hdr
in the receive path and process/skip virtio_net_hdr in the send path.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index fe7656b..5f70f13 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -17,6 +17,7 @@
 #include <net/net_namespace.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <linux/virtio_net.h>
 
 /*
  * A macvtap queue is the central object of this driver, it connects
@@ -37,6 +38,7 @@ struct macvtap_queue {
 	struct socket sock;
 	struct macvlan_dev *vlan;
 	struct file *file;
+	unsigned int flags;
 };
 
 static struct proto macvtap_proto = {
@@ -286,6 +288,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	sock_init_data(&q->sock, &q->sk);
 	q->sk.sk_allocation = GFP_ATOMIC; /* for now */
 	q->sk.sk_write_space = macvtap_sock_write_space;
+	q->flags = IFF_VNET_HDR;
 
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
@@ -328,6 +331,29 @@ out:
 	return mask;
 }
 
+static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
+						size_t len, size_t linear,
+						int noblock, int *err)
+{
+	struct sk_buff *skb;
+
+	/* Under a page?  Don't bother with paged skb. */
+	if (prepad + len < PAGE_SIZE || !linear)
+		linear = len;
+
+	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
+				   err);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, prepad);
+	skb_put(skb, linear);
+	skb->data_len = len - linear;
+	skb->len += len - linear;
+
+	return skb;
+}
+
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q,
 				const struct iovec *iv, size_t count,
@@ -336,31 +362,99 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	struct sk_buff *skb;
 	size_t len = count;
 	int err;
+	struct virtio_net_hdr vnet_hdr = { 0 };
+	int vnet_hdr_len = 0;
+	unsigned short gso_type = 0;
+
+	if (q->flags & IFF_VNET_HDR) {
+		vnet_hdr_len = sizeof(vnet_hdr); 
+
+		err = -EINVAL;
+		if ((len -= vnet_hdr_len) < 0)
+			goto out;
+
+		err = (memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
+					   vnet_hdr_len));
+		if (err < 0)
+			goto out;			
+
+		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+		     vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 > 
+							vnet_hdr.hdr_len)
+			vnet_hdr.hdr_len = vnet_hdr.csum_start +
+						vnet_hdr.csum_offset + 2;
+
+		err = -EINVAL;
+		if (vnet_hdr.hdr_len > len)
+			goto out;
+
+		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+			switch (vnet_hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+			case VIRTIO_NET_HDR_GSO_TCPV4:
+				gso_type = SKB_GSO_TCPV4;
+				break;
+			case VIRTIO_NET_HDR_GSO_TCPV6:
+				gso_type = SKB_GSO_TCPV6;
+				break;
+			case VIRTIO_NET_HDR_GSO_UDP:
+				gso_type = SKB_GSO_UDP;
+				break;
+			default:
+				goto out;
+			}
+
+			if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
+				gso_type |= SKB_GSO_TCP_ECN;
+               
+			if (vnet_hdr.gso_size == 0)
+				goto out;
+		}
+	}
 
 	if (unlikely(len < ETH_HLEN))
-		return -EINVAL;
+		goto out;
 
-	skb = sock_alloc_send_skb(&q->sk, NET_IP_ALIGN + len, noblock, &err);
+	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, len, vnet_hdr.hdr_len,
+				noblock, &err);
+	if (!skb)
+		goto out;
 
-	if (!skb) {
-		macvlan_count_rx(q->vlan, 0, false, false);
-		return err;
-	}
+	err = -EFAULT;
+	if (skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len, len))
+		goto out_free;
 
-	skb_reserve(skb, NET_IP_ALIGN);
-	skb_put(skb, count);
+	skb_set_network_header(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_hdr(skb)->h_proto;
+
+	if (vnet_hdr_len) {
+		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+			err = -EINVAL;
+			if (!skb_partial_csum_set(skb, vnet_hdr.csum_start,
+						  vnet_hdr.csum_offset))
+				goto out_free;
+		}
 
-	if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
-		macvlan_count_rx(q->vlan, 0, false, false);
-		kfree_skb(skb);
-		return -EFAULT;
-	}
+		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+			skb_shinfo(skb)->gso_size = vnet_hdr.gso_size;
+			skb_shinfo(skb)->gso_type = gso_type;
 
-	skb_set_network_header(skb, ETH_HLEN);
+			/* Header must be checked, and gso_segs computed. */
+			skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+			skb_shinfo(skb)->gso_segs = 0;
+		}
+	}
 
 	macvlan_start_xmit(skb, q->vlan->dev);
 
+	macvlan_count_rx(q->vlan, skb->len, 1, 0);
 	return count;
+
+out_free:
+	kfree_skb(skb);
+out:
+	macvlan_count_rx(q->vlan, 0, false, false);
+	return -EINVAL;
 }
 
 static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
@@ -387,14 +481,54 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 {
 	struct macvlan_dev *vlan = q->vlan;
 	int ret;
+	int vnet_hdr_len = 0;
+
+	if (q->flags & IFF_VNET_HDR) {
+		struct virtio_net_hdr vnet_hdr = { 0 };
+
+		vnet_hdr_len = sizeof(vnet_hdr);
+		if ((len -= vnet_hdr_len) < 0)
+			return -EINVAL;
+
+		if (skb_is_gso(skb)) {
+			struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+			/* This is a hint as to how much should be linear. */
+			vnet_hdr.hdr_len = skb_headlen(skb);
+			vnet_hdr.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCPV4)
+				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				vnet_hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		} else
+			vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			vnet_hdr.csum_start = skb->csum_start -
+						skb_headroom(skb);
+			vnet_hdr.csum_offset = skb->csum_offset;
+		} /* else everything is zero */
+
+		if (unlikely(memcpy_toiovecend(iv, (void *)&vnet_hdr, 0,
+								vnet_hdr_len)))
+			return -EFAULT;
+	}
+
 
 	len = min_t(int, skb->len, len);
 
-	ret = skb_copy_datagram_const_iovec(skb, 0, iv, 0, len);
+	ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len, len);
 
 	macvlan_count_rx(vlan, len, ret == 0, 0);
 
-	return ret ? ret : len;
+	return ret ? ret : (len + vnet_hdr_len);
 }
 
 static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
@@ -460,14 +594,23 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	unsigned int __user *up = argp;
 	unsigned int u;
 	char devname[IFNAMSIZ];
+	int ret;
 
 	switch (cmd) {
 	case TUNSETIFF:
 		/* ignore the name, just look at flags */
 		if (get_user(u, &ifr->ifr_flags))
 			return -EFAULT;
-		if (u != (IFF_TAP | IFF_NO_PI))
-			return -EINVAL;
+		q = macvtap_file_get_queue(file);
+		if (!q)
+			return -ENOLINK;
+
+		if (u & IFF_VNET_HDR)
+			q->flags |= IFF_VNET_HDR;
+		else
+			q->flags &= ~IFF_VNET_HDR;
+
+		macvtap_file_put_queue(q);
 		return 0;
 
 	case TUNGETIFF:
@@ -475,17 +618,23 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		if (!q)
 			return -ENOLINK;
 		memcpy(devname, q->vlan->dev->name, sizeof(devname));
-		macvtap_file_put_queue(q);
 
+		ret = 0;
 		if (copy_to_user(&ifr->ifr_name, q->vlan->dev->name, IFNAMSIZ) ||
-		    put_user((TUN_TAP_DEV | TUN_NO_PI), &ifr->ifr_flags))
-			return -EFAULT;
-		return 0;
+		    put_user(q->flags, &ifr->ifr_flags))
+			ret =  -EFAULT;
+		macvtap_file_put_queue(q);
+		return ret;
 
 	case TUNGETFEATURES:
-		if (put_user((IFF_TAP | IFF_NO_PI), up))
-			return -EFAULT;
-		return 0;
+		q = macvtap_file_get_queue(file);
+		if (!q)
+			return -ENOLINK;
+		ret = 0;
+		if (put_user(q->flags, up))
+			ret = -EFAULT;
+		macvtap_file_put_queue(q);
+		return ret;
 
 	case TUNSETSNDBUF:
 		if (get_user(u, up))
@@ -499,18 +648,14 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return 0;
 
 	case TUNSETOFFLOAD:
-		/* let the user check for future flags */
-		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-			  TUN_F_TSO_ECN | TUN_F_UFO))
-			return -EINVAL;
-
-		/* TODO: add support for these, so far we don't
-			 support any offload */
-		if (arg & (TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-			 TUN_F_TSO_ECN | TUN_F_UFO))
-			return -EINVAL;
-
-		return 0;
+		q = macvtap_file_get_queue(file);
+		if (!q)
+			return -ENOLINK;
+		ret = 0;
+		if (!(q->flags & IFF_VNET_HDR))
+			ret =  -EINVAL;
+		macvtap_file_put_queue(q);
+		return ret;
 
 	default:
 		return -EINVAL;




