From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] skbuff: struct ubuf_info callback type safety
Date: Mon, 9 Apr 2012 13:24:02 +0300
Message-ID: <20120409102402.GA5255@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <xma@us.ibm.com>, Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The skb struct ubuf_info callback gets passed struct ubuf_info
itself, not the arg value as the field name and the function signature
seem to imply. Rename the arg field to ctx to match usage,
add documentation and change the callback argument type
to make usage clear and to have compiler check correctness.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c    |    2 +-
 drivers/vhost/vhost.c  |    5 ++---
 drivers/vhost/vhost.h  |    2 +-
 include/linux/skbuff.h |    7 ++++---
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f0da2c3..1f21d2a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -238,7 +238,7 @@ static void handle_tx(struct vhost_net *net)
 
 				vq->heads[vq->upend_idx].len = len;
 				ubuf->callback = vhost_zerocopy_callback;
-				ubuf->arg = vq->ubufs;
+				ubuf->ctx = vq->ubufs;
 				ubuf->desc = vq->upend_idx;
 				msg.msg_control = ubuf;
 				msg.msg_controllen = sizeof(ubuf);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 947f00d..51e4c1e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1598,10 +1598,9 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 	kfree(ubufs);
 }
 
-void vhost_zerocopy_callback(void *arg)
+void vhost_zerocopy_callback(struct ubuf_info *ubuf)
 {
-	struct ubuf_info *ubuf = arg;
-	struct vhost_ubuf_ref *ubufs = ubuf->arg;
+	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
 
 	/* set len = 1 to mark this desc buffers done DMA */
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 8dcf4cc..8de1fd5 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -188,7 +188,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len);
-void vhost_zerocopy_callback(void *arg);
+void vhost_zerocopy_callback(struct ubuf_info *);
 int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
 
 #define vq_err(vq, fmt, ...) do {                                  \
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3337027..4c3f138 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -238,11 +238,12 @@ enum {
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
- * The desc is used to track userspace buffer index.
+ * The ctx field is used to track device context.
+ * The desc field is used to track userspace buffer index.
  */
 struct ubuf_info {
-	void (*callback)(void *);
-	void *arg;
+	void (*callback)(struct ubuf_info *);
+	void *ctx;
 	unsigned long desc;
 };
 
-- 
1.7.9.111.gf3fb0
