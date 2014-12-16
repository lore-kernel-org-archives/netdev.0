From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 4/5] macvtap: drop broken IFF_VNET_LE
Date: Tue, 16 Dec 2014 15:05:10 +0200
Message-ID: <1418732988-3535-5-git-send-email-mst@redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jason Wang <jasowang@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use TUNSETVNETLE/TUNGETVNETLE instead.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/macvtap.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index de88285..f1f0df1 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -45,16 +45,18 @@ struct macvtap_queue {
 	struct list_head next;
 };
 
-#define MACVTAP_FEATURES (IFF_VNET_HDR | IFF_VNET_LE | IFF_MULTI_QUEUE)
+#define MACVTAP_FEATURES (IFF_VNET_HDR | IFF_MULTI_QUEUE)
+
+#define MACVTAP_VNET_LE 0x80000000
 
 static inline u16 macvtap16_to_cpu(struct macvtap_queue *q, __virtio16 val)
 {
-	return __virtio16_to_cpu(q->flags & IFF_VNET_LE, val);
+	return __virtio16_to_cpu(q->flags & MACVTAP_VNET_LE, val);
 }
 
 static inline __virtio16 cpu_to_macvtap16(struct macvtap_queue *q, u16 val)
 {
-	return __cpu_to_virtio16(q->flags & IFF_VNET_LE, val);
+	return __cpu_to_virtio16(q->flags & MACVTAP_VNET_LE, val);
 }
 
 static struct proto macvtap_proto = {
@@ -1082,6 +1084,21 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		q->vnet_hdr_sz = s;
 		return 0;
 
+	case TUNGETVNETLE:
+		s = !!(q->flags & MACVTAP_VNET_LE);
+		if (put_user(s, sp))
+			return -EFAULT;
+		return 0;
+
+	case TUNSETVNETLE:
+		if (get_user(s, sp))
+			return -EFAULT;
+		if (s)
+			q->flags |= MACVTAP_VNET_LE;
+		else
+			q->flags &= ~MACVTAP_VNET_LE;
+		return 0;
+
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-- 
MST
