From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/5] tun: drop broken IFF_VNET_LE
Date: Tue, 16 Dec 2014 15:05:06 +0200
Message-ID: <1418732988-3535-4-git-send-email-mst@redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jason Wang <jasowang@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>, Xi Wang <xii@google.com>,
	Masatake YAMATO <yamato@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use TUNSETVNETLE/TUNGETVNETLE instead.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index c052bd6b..e3e8a0e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -109,9 +109,11 @@ do {								\
  * overload it to mean fasync when stored there.
  */
 #define TUN_FASYNC	IFF_ATTACH_QUEUE
+/* High bits in flags field are unused. */
+#define TUN_VNET_LE     0x80000000
 
 #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
-		      IFF_VNET_LE | IFF_MULTI_QUEUE)
+		      IFF_MULTI_QUEUE)
 #define GOODCOPY_LEN 128
 
 #define FLT_EXACT_COUNT 8
@@ -207,12 +209,12 @@ struct tun_struct {
 
 static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 val)
 {
-	return __virtio16_to_cpu(tun->flags & IFF_VNET_LE, val);
+	return __virtio16_to_cpu(tun->flags & TUN_VNET_LE, val);
 }
 
 static inline __virtio16 cpu_to_tun16(struct tun_struct *tun, u16 val)
 {
-	return __cpu_to_virtio16(tun->flags & IFF_VNET_LE, val);
+	return __cpu_to_virtio16(tun->flags & TUN_VNET_LE, val);
 }
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -1853,6 +1855,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	int sndbuf;
 	int vnet_hdr_sz;
 	unsigned int ifindex;
+	int le;
 	int ret;
 
 	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
@@ -2052,6 +2055,23 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		tun->vnet_hdr_sz = vnet_hdr_sz;
 		break;
 
+	case TUNGETVNETLE:
+		le = !!(tun->flags & TUN_VNET_LE);
+		if (put_user(le, (int __user *)argp))
+			ret = -EFAULT;
+		break;
+
+	case TUNSETVNETLE:
+		if (get_user(le, (int __user *)argp)) {
+			ret = -EFAULT;
+			break;
+		}
+		if (le)
+			tun->flags |= TUN_VNET_LE;
+		else
+			tun->flags &= ~TUN_VNET_LE;
+		break;
+
 	case TUNATTACHFILTER:
 		/* Can be set only for TAPs */
 		ret = -EINVAL;
-- 
MST
