From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 2/2] vhost: relax used address alignment
Date: Thu, 25 Dec 2014 17:05:10 +0200
Message-ID: <1419517332-12291-3-git-send-email-mst@redhat.com>
References: <1419517332-12291-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1419517332-12291-1-git-send-email-mst@redhat.com>
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
 drivers/vhost/vhost.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ed71b53..cb807d0 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -713,9 +713,13 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 			r = -EFAULT;
 			break;
 		}
-		if ((a.avail_user_addr & (sizeof *vq->avail->ring - 1)) ||
-		    (a.used_user_addr & (sizeof *vq->used->ring - 1)) ||
-		    (a.log_guest_addr & (sizeof *vq->used->ring - 1))) {
+
+		/* Make sure it's safe to cast pointers to vring types. */
+		BUILD_BUG_ON(__alignof__ *vq->avail > VRING_AVAIL_ALIGN_SIZE);
+		BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
+		if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
+		    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
+		    (a.log_guest_addr & (sizeof(u64) - 1))) {
 			r = -EINVAL;
 			break;
 		}
-- 
MST
