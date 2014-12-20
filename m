From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: relax used address alignment
Date: Sun, 21 Dec 2014 01:14:05 +0200
Message-ID: <1419117201-24590-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
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

virtio 1.0 only requires used address to be 4 byte aligned,
vhost required 8 bytes (size of vring_used_elem).
Fix up vhost to match that.

Additionally, while vhost correctly requires 8 byte
alignment for log, it's unconnected to used ring:
it's a consequence that log has u64 entries.
Tweak code to make that clearer.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ed71b53..97996fc 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -713,9 +713,12 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 			r = -EFAULT;
 			break;
 		}
-		if ((a.avail_user_addr & (sizeof *vq->avail->ring - 1)) ||
-		    (a.used_user_addr & (sizeof *vq->used->ring - 1)) ||
-		    (a.log_guest_addr & (sizeof *vq->used->ring - 1))) {
+
+		BUILD_BUG_ON(__alignof__ *vq->avail != 2);
+		BUILD_BUG_ON(__alignof__ *vq->used != 4);
+		if ((a.avail_user_addr & (__alignof__ *vq->avail - 1)) ||
+		    (a.used_user_addr & (__alignof__ *vq->used - 1)) ||
+		    (a.log_guest_addr & (sizeof(u64) - 1))) {
 			r = -EINVAL;
 			break;
 		}
-- 
MST
