From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 34/50] vhost/net: virtio 1.0 byte swap
Date: Mon, 1 Dec 2014 18:05:34 +0200
Message-ID: <1417449619-24896-35-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417449619-24896-1-git-send-email-mst@redhat.com>
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

I had to add an explicit tag to suppress compiler warning:
gcc isn't smart enough to notice that
len is always initialized since function is called with size > 0.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/vhost/net.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index dce5c58..c218188 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -416,7 +416,7 @@ static void handle_tx(struct vhost_net *net)
 			struct ubuf_info *ubuf;
 			ubuf = nvq->ubuf_info + nvq->upend_idx;
 
-			vq->heads[nvq->upend_idx].id = head;
+			vq->heads[nvq->upend_idx].id = cpu_to_vhost32(vq, head);
 			vq->heads[nvq->upend_idx].len = VHOST_DMA_IN_PROGRESS;
 			ubuf->callback = vhost_zerocopy_callback;
 			ubuf->ctx = nvq->ubufs;
@@ -500,6 +500,10 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	int headcount = 0;
 	unsigned d;
 	int r, nlogs = 0;
+	/* len is always initialized before use since we are always called with
+	 * datalen > 0.
+	 */
+	u32 uninitialized_var(len);
 
 	while (datalen > 0 && headcount < quota) {
 		if (unlikely(seg >= UIO_MAXIOV)) {
@@ -527,13 +531,14 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 			nlogs += *log_num;
 			log += *log_num;
 		}
-		heads[headcount].id = d;
-		heads[headcount].len = iov_length(vq->iov + seg, in);
-		datalen -= heads[headcount].len;
+		heads[headcount].id = cpu_to_vhost32(vq, d);
+		len = iov_length(vq->iov + seg, in);
+		heads[headcount].len = cpu_to_vhost32(vq, len);
+		datalen -= len;
 		++headcount;
 		seg += in;
 	}
-	heads[headcount - 1].len += datalen;
+	heads[headcount - 1].len = cpu_to_vhost32(vq, len - datalen);
 	*iovcount = seg;
 	if (unlikely(log))
 		*log_num = nlogs;
-- 
MST
