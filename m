From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] tun: Modify const aio_read iovec per do_sock_read
Date: Mon, 03 Nov 2014 13:44:37 +0800
Message-ID: <E1XlARR-0007K9-MK@gondolin.me.apana.org.au>
References: <20141103053751.GA27845@gondor.apana.org.au>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

 drivers/net/tun.c |   28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9dd3746..657f811 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1230,11 +1230,11 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 static ssize_t tun_put_user(struct tun_struct *tun,
 			    struct tun_file *tfile,
 			    struct sk_buff *skb,
-			    const struct iovec *iv, int len)
+			    struct iovec *iv, int len)
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
-	int vlan_offset = 0, copied;
+	int vlan_offset = 0;
 	int vlan_hlen = 0;
 	int vnet_hdr_sz = 0;
 
@@ -1244,16 +1244,18 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	if (tun->flags & TUN_VNET_HDR)
 		vnet_hdr_sz = tun->vnet_hdr_sz;
 
+	total = skb->len + vlan_hlen + vnet_hdr_sz;
+
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
 			return -EINVAL;
 
-		if (len < skb->len + vlan_hlen + vnet_hdr_sz) {
+		if (len < total) {
 			/* Packet will be striped */
 			pi.flags |= TUN_PKT_STRIP;
 		}
 
-		if (memcpy_toiovecend(iv, (void *) &pi, 0, sizeof(pi)))
+		if (memcpy_toiovec(iv, (void *)&pi, sizeof(pi)))
 			return -EFAULT;
 		total += sizeof(pi);
 	}
@@ -1299,15 +1301,11 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 			gso.flags = VIRTIO_NET_HDR_F_DATA_VALID;
 		} /* else everything is zero */
 
-		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
-					       sizeof(gso))))
+		if (unlikely(memcpy_toiovec(iv, (void *)&gso, sizeof(gso))))
 			return -EFAULT;
-		total += vnet_hdr_sz;
 	}
 
-	copied = total;
 	len = min_t(int, skb->len + vlan_hlen, len);
-	total += skb->len + vlan_hlen;
 	if (vlan_hlen) {
 		int copy, ret;
 		struct {
@@ -1321,21 +1319,19 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 
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
 
-	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
+	skb_copy_datagram_iovec(skb, vlan_offset, iv, len);
 
 done:
 	tun->dev->stats.tx_packets++;
@@ -1345,7 +1341,7 @@ done:
 }
 
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
-			   const struct iovec *iv, ssize_t len, int noblock)
+			   struct iovec *iv, ssize_t len, int noblock)
 {
 	struct sk_buff *skb;
 	ssize_t ret = 0;
@@ -1387,7 +1383,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = tun_do_read(tun, tfile, iv, len,
+	ret = tun_do_read(tun, tfile, (struct iovec *)iv, len,
 			  file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
