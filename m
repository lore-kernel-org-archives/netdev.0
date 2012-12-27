From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] vhost_net: correct error hanlding in
	vhost_net_set_backend()
Date: Thu, 27 Dec 2012 14:39:19 +0800
Message-ID: <1356590360-32770-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Fix the leaking of oldubufs and fd refcnt when fail to initialized used ring.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ebd08b2..629d6b5 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -834,8 +834,10 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 		vhost_net_enable_vq(n, vq);
 
 		r = vhost_init_used(vq);
-		if (r)
-			goto err_vq;
+		if (r) {
+			sock = NULL;
+			goto err_used;
+		}
 
 		n->tx_packets = 0;
 		n->tx_zcopy_err = 0;
@@ -859,8 +861,14 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	mutex_unlock(&n->dev.mutex);
 	return 0;
 
+err_used:
+	if (oldubufs)
+		vhost_ubuf_put_and_wait(oldubufs);
+	if (oldsock)
+		fput(oldsock->file);
 err_ubufs:
-	fput(sock->file);
+	if (sock)
+		fput(sock->file);
 err_vq:
 	mutex_unlock(&vq->mutex);
 err:
-- 
1.7.1
