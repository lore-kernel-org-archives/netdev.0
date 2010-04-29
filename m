From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] macvtap: add ioctl to modify vnet header size
Date: Thu, 29 Apr 2010 16:51:58 +0300
Message-ID: <20100429135158.GA26303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933154Ab0D3RV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:21:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds TUNSETVNETHDRSZ/TUNGETVNETHDRSZ support
to macvtap.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This just mirrors the support in tun,
http://lkml.org/lkml/2010/3/17/221
so that we can make vhost mergeable buffers work with macvtap as well.

I plan to merge both patches through vhost tree together
with mergeable buffer support. Comments?

 drivers/net/macvtap.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d97e1fd..6451c4b 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -37,6 +37,7 @@
 struct macvtap_queue {
 	struct sock sk;
 	struct socket sock;
+	int vnet_hdr_sz;
 	struct macvlan_dev *vlan;
 	struct file *file;
 	unsigned int flags;
@@ -280,6 +281,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	sock_init_data(&q->sock, &q->sk);
 	q->sk.sk_write_space = macvtap_sock_write_space;
 	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
+	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
@@ -440,14 +442,14 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	int vnet_hdr_len = 0;
 
 	if (q->flags & IFF_VNET_HDR) {
-		vnet_hdr_len = sizeof(vnet_hdr);
+		vnet_hdr_len = q->vnet_hdr_sz;
 
 		err = -EINVAL;
 		if ((len -= vnet_hdr_len) < 0)
 			goto err;
 
 		err = memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
-					   vnet_hdr_len);
+					   sizeof(vnet_hdr));
 		if (err < 0)
 			goto err;
 		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
@@ -529,7 +531,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
-		vnet_hdr_len = sizeof (vnet_hdr);
+		vnet_hdr_len = q->vnet_hdr_sz;
 		if ((len -= vnet_hdr_len) < 0)
 			return -EINVAL;
 
@@ -537,7 +539,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (ret)
 			return ret;
 
-		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, vnet_hdr_len))
+		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
 	}
 
@@ -622,6 +624,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	struct ifreq __user *ifr = argp;
 	unsigned int __user *up = argp;
 	unsigned int u;
+	int __user *sp = argp;
+	int s;
 	int ret;
 
 	switch (cmd) {
@@ -667,6 +671,25 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		q->sk.sk_sndbuf = u;
 		return 0;
 
+	case TUNGETVNETHDRSZ:
+		s = q->vnet_hdr_sz;
+		if (put_user(s, sp))
+			ret = -EFAULT;
+		break;
+
+	case TUNSETVNETHDRSZ:
+		if (get_user(s, sp)) {
+			ret = -EFAULT;
+			break;
+		}
+		if (s < (int)sizeof(struct virtio_net_hdr)) {
+			ret = -EINVAL;
+			break;
+		}
+
+		q->vnet_hdr_sz = s;
+		break;
+
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-- 
1.7.1.rc1.22.g3163
