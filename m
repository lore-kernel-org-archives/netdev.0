From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/3] virtio_ring: unify direct/indirect code paths.
Date: Fri, 05 Sep 2014 12:25:40 +0930
Message-ID: <87egvqkc7n.fsf@rustcorp.com.au>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-4-git-send-email-rusty@rustcorp.com.au>
	<CALCETrVCR+Zm9RtF7gGmO-XcMAb4fLsxKMG-aEABqhbywF9+Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CALCETrVCR+Zm9RtF7gGmO-XcMAb4fLsxKMG-aEABqhbywF9+Jw@mail.gmail.com>
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

Andy Lutomirski <luto@amacapital.net> writes:
> On Tue, Sep 2, 2014 at 9:29 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> virtqueue_add() populates the virtqueue descriptor table from the sgs
>> given.  If it uses an indirect descriptor table, then it puts a single
>> descriptor in the descriptor table pointing to the kmalloc'ed indirect
>> table where the sg is populated.
>>
>> Previously vring_add_indirect() did the allocation and the simple
>> linear layout.  We replace that with alloc_indirect() which allocates
>> the indirect table then chains it like the normal descriptor table so
>> we can reuse the core logic.
>>
>
>> +       if (vq->indirect && total_sg > 1 && vq->vq.num_free)
>> +               desc = alloc_indirect(total_sg, gfp);
>> +       else
>> +               desc = NULL;
>> +
>> +       if (desc) {
>> +               /* Use a single buffer which doesn't continue */
>> +               vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
>> +               vq->vring.desc[head].addr = virt_to_phys(desc);
>> +               /* avoid kmemleak false positive (hidden by virt_to_phys) */
>> +               kmemleak_ignore(desc);
>> +               vq->vring.desc[head].len = total_sg * sizeof(struct vring_desc);
>> +
>> +               /* Set up rest to use this indirect table. */
>> +               i = 0;
>> +               total_sg = 1;
>
> This is a little too magical for me.  Would it make sense to add a new
> variable for this (total_root_descs or something)?

Agreed, it's a little hacky.

Here's the diff (I actually merged this into the patch, but no point
re-xmitting):

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index a4ebbffac141..6d2b5310c991 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -131,7 +131,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	struct scatterlist *sg;
 	struct vring_desc *desc;
-	unsigned int i, n, avail, uninitialized_var(prev);
+	unsigned int i, n, avail, descs_used, uninitialized_var(prev);
 	int head;
 	bool indirect;
 
@@ -179,17 +179,18 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 
 		/* Set up rest to use this indirect table. */
 		i = 0;
-		total_sg = 1;
+		descs_used = 1;
 		indirect = true;
 	} else {
 		desc = vq->vring.desc;
 		i = head;
+		descs_used = total_sg;
 		indirect = false;
 	}
 
-	if (vq->vq.num_free < total_sg) {
+	if (vq->vq.num_free < descs_used) {
 		pr_debug("Can't add buf len %i - avail = %i\n",
-			 total_sg, vq->vq.num_free);
+			 descs_used, vq->vq.num_free);
 		/* FIXME: for historical reasons, we force a notify here if
 		 * there are outgoing parts to the buffer.  Presumably the
 		 * host should service the ring ASAP. */
@@ -200,7 +201,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	}
 
 	/* We're about to use some buffers from the free list. */
-	vq->vq.num_free -= total_sg;
+	vq->vq.num_free -= descs_used;
 
 	for (n = 0; n < out_sgs; n++) {
 		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
