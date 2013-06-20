From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net for-stable] vhost-net: fix use-after-free in
	vhost_net_flush
Date: Thu, 20 Jun 2013 14:51:29 +0300
Message-ID: <20130620115129.GA4165@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
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

vhost_net_ubuf_put_and_wait has a confusing name:
it will actually also free it's argument.
Thus since commit 1280c27f8e29acf4af2da914e80ec27c3dbd5c01
vhost_net_flush tries to use the argument after passing it
to vhost_net_ubuf_put_and_wait, this results
in use after free.
To fix, don't free the argument in vhost_net_ubuf_put_and_wait,
add an new API for callers that want to free ubufs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

I sent the same patch against 3.10 separately.
This one is for stable, against 3.9/3.8 - the code moved around
since then.
Not sending to stable directly since Dave Miller handles
it for net drivers normally.

 drivers/vhost/net.c   | 4 ++--
 drivers/vhost/vhost.c | 5 +++++
 drivers/vhost/vhost.h | 1 +
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ec6fb3f..e5ff7a5 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -856,7 +856,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	mutex_unlock(&vq->mutex);
 
 	if (oldubufs) {
-		vhost_ubuf_put_and_wait(oldubufs);
+		vhost_ubuf_put_wait_and_free(oldubufs);
 		mutex_lock(&vq->mutex);
 		vhost_zerocopy_signal_used(n, vq);
 		mutex_unlock(&vq->mutex);
@@ -874,7 +874,7 @@ err_used:
 	rcu_assign_pointer(vq->private_data, oldsock);
 	vhost_net_enable_vq(n, vq);
 	if (ubufs)
-		vhost_ubuf_put_and_wait(ubufs);
+		vhost_ubuf_put_wait_and_free(ubufs);
 err_ubufs:
 	fput(sock->file);
 err_vq:
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 9759249..c01d22f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1581,5 +1581,10 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 {
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
 	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
+}
+
+void vhost_ubuf_put_wait_and_free(struct vhost_ubuf_ref *ubufs)
+{
+	vhost_ubuf_put_and_wait(ubufs);
 	kfree(ubufs);
 }
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 17261e2..b53cb28 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -63,6 +63,7 @@ struct vhost_ubuf_ref {
 struct vhost_ubuf_ref *vhost_ubuf_alloc(struct vhost_virtqueue *, bool zcopy);
 void vhost_ubuf_put(struct vhost_ubuf_ref *);
 void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *);
+void vhost_ubuf_put_wait_and_free(struct vhost_ubuf_ref *);
 
 struct ubuf_info;
 
-- 
MST
