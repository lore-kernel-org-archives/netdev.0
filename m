From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 06/18] virtio_ring: avail event index interface
Date: Wed, 4 May 2011 23:51:19 +0300
Message-ID: <b00ef5d572ec9bc3b884c496025512abc1f14349.1304541919.git.mst@redhat.com>
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

Define a new feature bit for the host to
declare that it uses an avail_event index
(like Xen) instead of a feature bit
to enable/disable interrupts.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/virtio_ring.h |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index f5c1b75..f791772 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -32,6 +32,9 @@
 /* The Guest publishes the used index for which it expects an interrupt
  * at the end of the avail ring. Host should ignore the avail->flags field. */
 #define VIRTIO_RING_F_USED_EVENT_IDX	29
+/* The Host publishes the avail index for which it expects a kick
+ * at the end of the used ring. Guest should ignore the used->flags field. */
+#define VIRTIO_RING_F_AVAIL_EVENT_IDX	32
 
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc {
@@ -96,11 +99,13 @@ struct vring {
  *	__u16 used_flags;
  *	__u16 used_idx;
  *	struct vring_used_elem used[num];
+ *	__u16 avail_event_idx;
  * };
  */
-/* We publish the used event index at the end of the available ring.
- * It is at the end for backwards compatibility. */
+/* We publish the used event index at the end of the available ring, and vice
+ * versa. They are at the end for backwards compatibility. */
 #define vring_used_event(vr) ((vr)->avail->ring[(vr)->num])
+#define vring_avail_event(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
 
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 			      unsigned long align)
@@ -116,7 +121,7 @@ static inline unsigned vring_size(unsigned int num, unsigned long align)
 {
 	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
 		 + align - 1) & ~(align - 1))
-		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
+		+ sizeof(__u16) * 3 + sizeof(struct vring_used_elem) * num;
 }
 
 #ifdef __KERNEL__
-- 
1.7.5.53.gc233e
