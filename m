From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] macvtap: Use iovec iterators
Date: Fri, 07 Nov 2014 21:22:25 +0800
Message-ID: <E1XmjUf-0005EM-Ap@gondolin.me.apana.org.au>
References: <20141107132135.GA20022@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcrl@kvack.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the use of skb_copy_datagram_const_iovec in
favour of the iovec iterator-based skb_copy_datagram_iter.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/macvtap.c |   46 +++++++++++++++++++++-------------------------
 1 file changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 880cc09..cea99d4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -15,6 +15,7 @@
 #include <linux/cdev.h>
 #include <linux/idr.h>
 #include <linux/fs.h>
+#include <linux/uio.h>
 
 #include <net/ipv6.h>
 #include <net/net_namespace.h>
@@ -778,31 +779,29 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 /* Put packet to the user space buffer */
 static ssize_t macvtap_put_user(struct macvtap_queue *q,
 				const struct sk_buff *skb,
-				const struct iovec *iv, int len)
+				struct iov_iter *iter)
 {
 	int ret;
 	int vnet_hdr_len = 0;
 	int vlan_offset = 0;
-	int copied, total;
+	int total;
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
 		vnet_hdr_len = q->vnet_hdr_sz;
-		if ((len -= vnet_hdr_len) < 0)
+		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
 		macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
 
-		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
+		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
+		    sizeof(vnet_hdr))
 			return -EFAULT;
 	}
-	total = copied = vnet_hdr_len;
+	total = vnet_hdr_len;
 	total += skb->len;
 
-	if (!vlan_tx_tag_present(skb))
-		len = min_t(int, skb->len, len);
-	else {
-		int copy;
+	if (vlan_tx_tag_present(skb)) {
 		struct {
 			__be16 h_vlan_proto;
 			__be16 h_vlan_TCI;
@@ -811,37 +810,33 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
-		len = min_t(int, skb->len + VLAN_HLEN, len);
 		total += VLAN_HLEN;
 
-		copy = min_t(int, vlan_offset, len);
-		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
-		len -= copy;
-		copied += copy;
-		if (ret || !len)
+		ret = skb_copy_datagram_iter(skb, 0, iter, vlan_offset);
+		if (ret || !iov_iter_count(iter))
 			goto done;
 
-		copy = min_t(int, sizeof(veth), len);
-		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
-		len -= copy;
-		copied += copy;
-		if (ret || !len)
+		ret = copy_to_iter(&veth, sizeof(veth), iter);
+		if (ret != sizeof(veth) || !iov_iter_count(iter))
 			goto done;
 	}
 
-	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
+	ret = skb_copy_datagram_iter(skb, vlan_offset, iter,
+				     skb->len - vlan_offset);
 
 done:
 	return ret ? ret : total;
 }
 
 static ssize_t macvtap_do_read(struct macvtap_queue *q,
-			       const struct iovec *iv, unsigned long len,
+			       const struct iovec *iv, unsigned long segs,
+			       unsigned long len,
 			       int noblock)
 {
 	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 	ssize_t ret = 0;
+	struct iov_iter iter;
 
 	while (len) {
 		if (!noblock)
@@ -863,7 +858,8 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 			schedule();
 			continue;
 		}
-		ret = macvtap_put_user(q, skb, iv, len);
+		iov_iter_init(&iter, READ, iv, segs, len);
+		ret = macvtap_put_user(q, skb, &iter);
 		kfree_skb(skb);
 		break;
 	}
@@ -886,7 +882,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = macvtap_do_read(q, iv, len, file->f_flags & O_NONBLOCK);
+	ret = macvtap_do_read(q, iv, count, len, file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
@@ -1117,7 +1113,7 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int ret;
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	ret = macvtap_do_read(q, m->msg_iov, total_len,
+	ret = macvtap_do_read(q, m->msg_iov, m->msg_iovlen, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
