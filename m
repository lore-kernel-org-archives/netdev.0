From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net 3/3] vhost: fix a theoretical race in device cleanup
Date: Wed, 12 Feb 2014 18:36:57 +0200
Message-ID: <1392222846-26699-4-git-send-email-mst@redhat.com>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1392222846-26699-1-git-send-email-mst@redhat.com>
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

vhost_zerocopy_callback accesses VQ right after
it drops the last ubuf reference.
In theory, this could race with device removal
which waits on the ubuf kref, and crash
on use after free.

Do all accesses within rcu read side critical
section, and all synchronize on release.

Since callbacks are always invoked from bh,
synchronize_rcu_bh seems enough and will help
release complete a bit faster.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7eaf2de..78a9d42 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -308,6 +308,8 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	struct vhost_virtqueue *vq = ubufs->vq;
 	int cnt;
 
+	rcu_read_lock_bh();
+
 	/* set len to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = success ?
 		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
@@ -322,6 +324,8 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	 */
 	if (cnt <= 1 || !(cnt % 16))
 		vhost_poll_queue(&vq->poll);
+
+	rcu_read_unlock_bh();
 }
 
 /* Expects to be always run from workqueue - which acts as
@@ -804,6 +808,8 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 		fput(tx_sock->file);
 	if (rx_sock)
 		fput(rx_sock->file);
+	/* Make sure no callbacks are outstanding */
+	synchronize_rcu_bh();
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
-- 
MST
