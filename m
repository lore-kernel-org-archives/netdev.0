From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] vhost-net: fix use-after-free in vhost_net_flush
Date: Tue, 25 Jun 2013 17:29:46 +0300
Message-ID: <20130625142946.GA17414@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
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
    "vhost-net: flush outstanding DMAs on memory change"
vhost_net_flush tries to use the argument after passing it
to vhost_net_ubuf_put_and_wait, this results
in use after free.
To fix, don't free the argument in vhost_net_ubuf_put_and_wait,
add an new API for callers that want to free ubufs.

Acked-by: Asias He <asias@redhat.com>
Acked-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

Please review, and queue for 3.10 and stable.
Changes since v1:
	- no functional change, tweaked the commit message

 drivers/vhost/net.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 5c77d6a..534adb0 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -149,6 +149,11 @@ static void vhost_net_ubuf_put_and_wait(struct vhost_net_ubuf_ref *ubufs)
 {
 	kref_put(&ubufs->kref, vhost_net_zerocopy_done_signal);
 	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
+}
+
+static void vhost_net_ubuf_put_wait_and_free(struct vhost_net_ubuf_ref *ubufs)
+{
+	vhost_net_ubuf_put_and_wait(ubufs);
 	kfree(ubufs);
 }
 
@@ -1073,7 +1078,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	mutex_unlock(&vq->mutex);
 
 	if (oldubufs) {
-		vhost_net_ubuf_put_and_wait(oldubufs);
+		vhost_net_ubuf_put_wait_and_free(oldubufs);
 		mutex_lock(&vq->mutex);
 		vhost_zerocopy_signal_used(n, vq);
 		mutex_unlock(&vq->mutex);
@@ -1091,7 +1096,7 @@ err_used:
 	vq->private_data = oldsock;
 	vhost_net_enable_vq(n, vq);
 	if (ubufs)
-		vhost_net_ubuf_put_and_wait(ubufs);
+		vhost_net_ubuf_put_wait_and_free(ubufs);
 err_ubufs:
 	fput(sock->file);
 err_vq:
-- 
MST
