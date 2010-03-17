From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] tun: add ioctl to modify vnet header size
Date: Wed, 17 Mar 2010 17:45:02 +0200
Message-ID: <20100317154501.GA5244@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio added mergeable buffers mode where 2 bytes of extra info is put
after vnet header but before actual data (tun does not need this data).
In hindsight, it would have been better to add the new info *before* the
packet: as it is, users need a lot of tricky code to skip the extra 2
bytes in the middle of the iovec, and in fact applications seem to get
it wrong, and only work with specific iovec layout.  The fact we might
need to split iovec also means we might in theory overflow iovec max
size.

This patch adds a simpler way for applications to handle this,
and future proofs the interface against further extensions,
by making the size of the virtio net header configurable
from userspace. As a result, tun driver will simply
skip the extra 2 bytes on both input and output.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c      |   31 +++++++++++++++++++++++++++----
 include/linux/if_tun.h |    2 ++
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ce1efa4..0b11222 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -110,6 +110,8 @@ struct tun_struct {
 	struct tap_filter       txflt;
 	struct socket		socket;
 
+	int			vnet_hdr_sz;
+
 #ifdef TUN_DEBUG
 	int debug;
 #endif
@@ -559,7 +561,7 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 	}
 
 	if (tun->flags & TUN_VNET_HDR) {
-		if ((len -= sizeof(gso)) > count)
+		if ((len -= tun->vnet_hdr_sz) > count)
 			return -EINVAL;
 
 		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
@@ -571,7 +573,7 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 
 		if (gso.hdr_len > len)
 			return -EINVAL;
-		offset += sizeof(gso);
+		offset += tun->vnet_hdr_sz;
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
@@ -714,7 +716,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 
 	if (tun->flags & TUN_VNET_HDR) {
 		struct virtio_net_hdr gso = { 0 }; /* no info leak */
-		if ((len -= sizeof(gso)) < 0)
+		if ((len -= tun->vnet_hdr_sz) < 0)
 			return -EINVAL;
 
 		if (skb_is_gso(skb)) {
@@ -745,7 +747,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
 					       sizeof(gso))))
 			return -EFAULT;
-		total += sizeof(gso);
+		total += tun->vnet_hdr_sz;
 	}
 
 	len = min_t(int, skb->len, len);
@@ -1029,6 +1031,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->dev = dev;
 		tun->flags = flags;
 		tun->txflt.count = 0;
+		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
 		err = -ENOMEM;
 		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
@@ -1170,6 +1173,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	struct sock_fprog fprog;
 	struct ifreq ifr;
 	int sndbuf;
+	int vnet_hdr_sz;
 	int ret;
 
 	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
@@ -1315,6 +1319,25 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		tun->socket.sk->sk_sndbuf = sndbuf;
 		break;
 
+	case TUNGETVNETHDRSZ:
+		vnet_hdr_sz = tun->vnet_hdr_sz;
+		if (copy_to_user(argp, &vnet_hdr_sz, sizeof(vnet_hdr_sz)))
+			ret = -EFAULT;
+		break;
+
+	case TUNSETVNETHDRSZ:
+		if (copy_from_user(&vnet_hdr_sz, argp, sizeof(vnet_hdr_sz))) {
+			ret = -EFAULT;
+			break;
+		}
+		if (vnet_hdr_sz < (int)sizeof(struct virtio_net_hdr)) {
+			ret = -EINVAL;
+			break;
+		}
+
+		tun->vnet_hdr_sz = vnet_hdr_sz;
+		break;
+
 	case TUNATTACHFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 1350a24..06b1829 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -51,6 +51,8 @@
 #define TUNSETSNDBUF   _IOW('T', 212, int)
 #define TUNATTACHFILTER _IOW('T', 213, struct sock_fprog)
 #define TUNDETACHFILTER _IOW('T', 214, struct sock_fprog)
+#define TUNGETVNETHDRSZ _IOR('T', 215, int)
+#define TUNSETVNETHDRSZ _IOW('T', 216, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
1.7.0.18.g0d53a5
