From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net 2/2] vhost: fix ubuf_info cleanup
Date: Thu, 6 Jun 2013 15:20:46 +0300
Message-ID: <1370521145-9723-3-git-send-email-mst@redhat.com>
References: <1370521145-9723-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tommi Rantala <tt.rantala@gmail.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1370521145-9723-1-git-send-email-mst@redhat.com>
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

vhost_net_clear_ubuf_info didn't clear ubuf_info
after kfree, this could trigger double free.
Fix this and simplify this code to make it more robust: make sure
ubuf info is always freed through vhost_net_clear_ubuf_info.

Reported-by: Tommi Rantala <tt.rantala@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 6b00f64..7fc47f7 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -155,14 +155,11 @@ static void vhost_net_ubuf_put_and_wait(struct vhost_net_ubuf_ref *ubufs)
 
 static void vhost_net_clear_ubuf_info(struct vhost_net *n)
 {
-
-	bool zcopy;
 	int i;
 
-	for (i = 0; i < n->dev.nvqs; ++i) {
-		zcopy = vhost_net_zcopy_mask & (0x1 << i);
-		if (zcopy)
-			kfree(n->vqs[i].ubuf_info);
+	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
+		kfree(n->vqs[i].ubuf_info);
+		n->vqs[i].ubuf_info = NULL;
 	}
 }
 
@@ -171,7 +168,7 @@ int vhost_net_set_ubuf_info(struct vhost_net *n)
 	bool zcopy;
 	int i;
 
-	for (i = 0; i < n->dev.nvqs; ++i) {
+	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
 		zcopy = vhost_net_zcopy_mask & (0x1 << i);
 		if (!zcopy)
 			continue;
@@ -183,12 +180,7 @@ int vhost_net_set_ubuf_info(struct vhost_net *n)
 	return 0;
 
 err:
-	while (i--) {
-		zcopy = vhost_net_zcopy_mask & (0x1 << i);
-		if (!zcopy)
-			continue;
-		kfree(n->vqs[i].ubuf_info);
-	}
+	vhost_net_clear_ubuf_info(n);
 	return -ENOMEM;
 }
 
@@ -196,12 +188,12 @@ void vhost_net_vq_reset(struct vhost_net *n)
 {
 	int i;
 
+	vhost_net_clear_ubuf_info(n);
+
 	for (i = 0; i < VHOST_NET_VQ_MAX; i++) {
 		n->vqs[i].done_idx = 0;
 		n->vqs[i].upend_idx = 0;
 		n->vqs[i].ubufs = NULL;
-		kfree(n->vqs[i].ubuf_info);
-		n->vqs[i].ubuf_info = NULL;
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
 	}
-- 
MST
