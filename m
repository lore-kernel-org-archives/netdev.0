From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] macvtap: Modify const aio_read iovec per do_sock_read
Date: Mon, 03 Nov 2014 13:44:38 +0800
Message-ID: <E1XlARS-0007KK-2J@gondolin.me.apana.org.au>
References: <20141103053751.GA27845@gondor.apana.org.au>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59319 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaKCFop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 00:44:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I started working on this patch after discovering the horror of
skb_copy_datagram_iovec and skb_copy_datagram_const_iovec.  It's
ridiculous to have two versions of the same thing.  Especially when
the reason they exist is because of a stupid disagreement between
fs and net on how we should itereate over iovecs.

To reiterate, fs wants to keep the iovecs themselves constant and
use iterators to keep state while net is used to keeping the state
within the iovecs.

Without judging the merits of either approach, we should stick to
one of them.  And regardless of which one we end up picking, we
can always kill skb_copy_datagram_const_iovec which is plain wrong
as it starts from the very beginning of the iovec every single time.

This patch uses the do_sock_read approach of casting the const away
for the time being.  If we end up going the other way we can trivially
convert this over to using iterators.  In the mean time this would at
least allow us to kill skb_copy_datagram_const_iovec.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/macvtap.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 6f226de..d830e25 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -776,12 +776,12 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 /* Put packet to the user space buffer */
 static ssize_t macvtap_put_user(struct macvtap_queue *q,
 				const struct sk_buff *skb,
-				const struct iovec *iv, int len)
+				struct iovec *iv, int len)
 {
 	int ret;
 	int vnet_hdr_len = 0;
 	int vlan_offset = 0;
-	int copied, total;
+	int total;
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
@@ -791,10 +791,10 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 		macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
 
-		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
+		if (memcpy_toiovec(iv, (void *)&vnet_hdr, sizeof(vnet_hdr)))
 			return -EFAULT;
 	}
-	total = copied = vnet_hdr_len;
+	total = vnet_hdr_len;
 	total += skb->len;
 
 	if (!vlan_tx_tag_present(skb))
@@ -813,28 +813,26 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		total += VLAN_HLEN;
 
 		copy = min_t(int, vlan_offset, len);
-		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
+		ret = skb_copy_datagram_iovec(skb, 0, iv, copy);
 		len -= copy;
-		copied += copy;
 		if (ret || !len)
 			goto done;
 
 		copy = min_t(int, sizeof(veth), len);
-		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
+		ret = memcpy_toiovec(iv, (void *)&veth, copy);
 		len -= copy;
-		copied += copy;
 		if (ret || !len)
 			goto done;
 	}
 
-	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
+	ret = skb_copy_datagram_iovec(skb, vlan_offset, iv, len);
 
 done:
 	return ret ? ret : total;
 }
 
 static ssize_t macvtap_do_read(struct macvtap_queue *q,
-			       const struct iovec *iv, unsigned long len,
+			       struct iovec *iv, unsigned long len,
 			       int noblock)
 {
 	DEFINE_WAIT(wait);
@@ -884,7 +882,8 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = macvtap_do_read(q, iv, len, file->f_flags & O_NONBLOCK);
+	ret = macvtap_do_read(q, (struct iovec *)iv, len,
+			      file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
