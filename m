From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 02/18] virtio_test: update for 64 bit features
Date: Wed, 4 May 2011 23:50:41 +0300
Message-ID: <a7227ea03faca5964d4d0975ae1d87251b8b57e5.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Extend the virtio_test tool so it can work with
64 bit features.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 tools/virtio/virtio_test.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/virtio/virtio_test.c b/tools/virtio/virtio_test.c
index df0c6d2..9e65e6d 100644
--- a/tools/virtio/virtio_test.c
+++ b/tools/virtio/virtio_test.c
@@ -55,7 +55,6 @@ void vhost_vq_setup(struct vdev_info *dev, struct vq_info *info)
 {
 	struct vhost_vring_state state = { .index = info->idx };
 	struct vhost_vring_file file = { .index = info->idx };
-	unsigned long long features = dev->vdev.features[0];
 	struct vhost_vring_addr addr = {
 		.index = info->idx,
 		.desc_user_addr = (uint64_t)(unsigned long)info->vring.desc,
@@ -63,6 +62,10 @@ void vhost_vq_setup(struct vdev_info *dev, struct vq_info *info)
 		.used_user_addr = (uint64_t)(unsigned long)info->vring.used,
 	};
 	int r;
+	unsigned long long features = dev->vdev.features[0];
+	if (sizeof features > sizeof dev->vdev.features[0])
+		features |= ((unsigned long long)dev->vdev.features[1]) << 32;
+
 	r = ioctl(dev->control, VHOST_SET_FEATURES, &features);
 	assert(r >= 0);
 	state.num = info->vring.num;
@@ -107,7 +110,8 @@ static void vdev_info_init(struct vdev_info* dev, unsigned long long features)
 	int r;
 	memset(dev, 0, sizeof *dev);
 	dev->vdev.features[0] = features;
-	dev->vdev.features[1] = features >> 32;
+	if (sizeof features > sizeof dev->vdev.features[0])
+		dev->vdev.features[1] = features >> 32;
 	dev->buf_size = 1024;
 	dev->buf = malloc(dev->buf_size);
 	assert(dev->buf);
-- 
1.7.5.53.gc233e
