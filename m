From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 01/14] virtio: event index interface
Date: Fri, 20 May 2011 02:10:17 +0300
Message-ID: <995d19795d84a76f9836f4d9484fb4ef8eae36e9.1305846412.git.mst@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1305846412.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Define a new feature bit for the guest and host to utilize
an event index (like Xen) instead if a flag bit to enable/disable
interrupts and kicks.

Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/virtio_ring.h |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index e4d144b..70b0b39 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -29,6 +29,12 @@
 /* We support indirect buffer descriptors */
 #define VIRTIO_RING_F_INDIRECT_DESC	28
 
+/* The Guest publishes the used index for which it expects an interrupt
+ * at the end of the avail ring. Host should ignore the avail->flags field. */
+/* The Host publishes the avail index for which it expects a kick
+ * at the end of the used ring. Guest should ignore the used->flags field. */
+#define VIRTIO_RING_F_EVENT_IDX		29
+
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc {
 	/* Address (guest-physical). */
@@ -83,6 +89,7 @@ struct vring {
  *	__u16 avail_flags;
  *	__u16 avail_idx;
  *	__u16 available[num];
+ *	__u16 used_event_idx;
  *
  *	// Padding to the next align boundary.
  *	char pad[];
@@ -91,8 +98,14 @@ struct vring {
  *	__u16 used_flags;
  *	__u16 used_idx;
  *	struct vring_used_elem used[num];
+ *	__u16 avail_event_idx;
  * };
  */
+/* We publish the used event index at the end of the available ring, and vice
+ * versa. They are at the end for backwards compatibility. */
+#define vring_used_event(vr) ((vr)->avail->ring[(vr)->num])
+#define vring_avail_event(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
+
 static inline void vring_init(struct vring *vr, unsigned int num, void *p,
 			      unsigned long align)
 {
@@ -107,7 +120,7 @@ static inline unsigned vring_size(unsigned int num, unsigned long align)
 {
 	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
 		 + align - 1) & ~(align - 1))
-		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
+		+ sizeof(__u16) * 3 + sizeof(struct vring_used_elem) * num;
 }
 
 #ifdef __KERNEL__
-- 
1.7.5.53.gc233e
