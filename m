From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2 2/2] macvtap: signal truncated packets
Date: Tue, 10 Dec 2013 13:49:46 +0800
Message-ID: <1386654586-18151-2-git-send-email-jasowang@redhat.com>
References: <1386654586-18151-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705Ab3LJFu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 00:50:26 -0500
In-Reply-To: <1386654586-18151-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvtap_put_user() never return a value grater than iov length, this in fact
bypasses the truncated checking in macvtap_recvmsg(). Fix this by always
returning the size of packet plus the possible vlan header to let the trunca
checking work.

Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from v1:
- increase total unconditionally
- do not move the structure veth out of the vlan handling block
---
 drivers/net/macvtap.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 957cc5c..ded4b2c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -770,7 +770,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	int ret;
 	int vnet_hdr_len = 0;
 	int vlan_offset = 0;
-	int copied;
+	int copied, offset;
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
@@ -785,7 +785,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
 	}
-	copied = vnet_hdr_len;
+	offset = copied = vnet_hdr_len;
+	copied += skb->len;
 
 	if (!vlan_tx_tag_present(skb))
 		len = min_t(int, skb->len, len);
@@ -800,24 +801,24 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 		len = min_t(int, skb->len + VLAN_HLEN, len);
+		copied += VLAN_HLEN;
 
 		copy = min_t(int, vlan_offset, len);
-		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
+		ret = skb_copy_datagram_const_iovec(skb, 0, iv, offset, copy);
 		len -= copy;
-		copied += copy;
+		offset += copy;
 		if (ret || !len)
 			goto done;
 
 		copy = min_t(int, sizeof(veth), len);
-		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
+		ret = memcpy_toiovecend(iv, (void *)&veth, offset, copy);
 		len -= copy;
-		copied += copy;
+		offset += copy;
 		if (ret || !len)
 			goto done;
 	}
 
-	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
-	copied += len;
+	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, offset, len);
 
 done:
 	return ret ? ret : copied;
@@ -875,7 +876,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	}
 
 	ret = macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
-	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
+	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
 out:
-- 
1.8.3.2
