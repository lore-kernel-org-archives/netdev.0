From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Sat, 30 Oct 2010 22:06:03 +0200
Message-ID: <20101030200603.GA19033@redhat.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
 <1288240804.14342.1.camel@localhost.localdomain>
 <20101028052021.GD5599@redhat.com>
 <1288286062.11251.15.camel@localhost.localdomain>
 <20101029081027.GB22688@redhat.com>
 <1288366988.4110.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288366988.4110.5.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 29, 2010 at 08:43:08AM -0700, Shirley Ma wrote:
> On Fri, 2010-10-29 at 10:10 +0200, Michael S. Tsirkin wrote:
> > Hmm. I don't yet understand. We are still doing copies into the per-vq
> > buffer, and the data copied is really small.  Is it about cache line
> > bounces?  Could you try figuring it out?
> 
> per-vq buffer is much less expensive than 3 put_copy() call. I will
> collect the profiling data to show that.

What about __put_user? Maybe the access checks are the ones
that add the cost here? I attach patches to strip access checks:
they are not needed as we do them on setup time already, anyway.
Can you try them out and see if performance is improved for you please?
On top of this, we will need to add some scheme to accumulate signals,
but that is a separate issue.

> > > > 2. How about flushing out queued stuff before we exit
> > > >    the handle_tx loop? That would address most of
> > > >    the spec issue. 
> > > 
> > > The performance is almost as same as the previous patch. I will
> > resubmit
> > > the modified one, adding vhost_add_used_and_signal_n after handle_tx
> > > loop for processing pending queue.
> > > 
> > > This patch was a part of modified macvtap zero copy which I haven't
> > > submitted yet. I found this helped vhost TX in general. This pending
> > > queue will be used by DMA done later, so I put it in vq instead of a
> > > local variable in handle_tx.
> > > 
> > > Thanks
> > > Shirley
> > 
> > BTW why do we need another array? Isn't heads field exactly what we
> > need
> > here?
> 
> head field is only for up to 32, the more used buffers add and signal
> accumulated the better performance is from test results.

I think we should separate the used update and signalling.  Interrupts
are expensive so I can believe accumulating even up to 100 of them
helps. But used head copies are already prety cheap. If we cut the
overhead by x32, that should make them almost free?

> That's was one
> of the reason I didn't use heads. The other reason was I used these
> buffer for pending dma done in mavctap zero copy patch. It could be up
> to vq->num in worse case.

We can always increase that, not an issue.

> Thanks
> Shirley

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=1

commit f983547ed65a90c73b3e5eeee707041cc04acb0e
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Tue Sep 21 14:18:01 2010 +0200

    vhost: copy_to_user -> __copy_to_user
    
    We do access_ok checks at setup time, so we don't need to
    redo them on each access.
    
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 54ba561..5109bc0 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1245,7 +1245,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 	start = vq->last_used_idx % vq->num;
 	used = vq->used->ring + start;
-	if (copy_to_user(used, heads, count * sizeof *used)) {
+	if (__copy_to_user(used, heads, count * sizeof *used)) {
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=2

commit 85337783cb9487246ed067592e50a5ee800e2683
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Sun Sep 19 15:56:30 2010 +0200

    vhost: get/put_user -> __get/__put_user
    
    We do access_ok checks on all ring values on an ioctl,
    so we don't need to redo them on each access.
    
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 3440197..54ba561 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1082,7 +1082,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
-	if (unlikely(get_user(vq->avail_idx, &vq->avail->idx))) {
+	if (unlikely(__get_user(vq->avail_idx, &vq->avail->idx))) {
 		vq_err(vq, "Failed to access avail idx at %p\n",
 		       &vq->avail->idx);
 		return -EFAULT;
@@ -1103,8 +1103,8 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
-	if (unlikely(get_user(head,
-			      &vq->avail->ring[last_avail_idx % vq->num]))) {
+	if (unlikely(__get_user(head,
+				&vq->avail->ring[last_avail_idx % vq->num]))) {
 		vq_err(vq, "Failed to read head: idx %d address %p\n",
 		       last_avail_idx,
 		       &vq->avail->ring[last_avail_idx % vq->num]);
@@ -1203,17 +1203,17 @@ int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int len)
 	/* The virtqueue contains a ring of used buffers.  Get a pointer to the
 	 * next entry in that used ring. */
 	used = &vq->used->ring[vq->last_used_idx % vq->num];
-	if (put_user(head, &used->id)) {
+	if (__put_user(head, &used->id)) {
 		vq_err(vq, "Failed to write used id");
 		return -EFAULT;
 	}
-	if (put_user(len, &used->len)) {
+	if (__put_user(len, &used->len)) {
 		vq_err(vq, "Failed to write used len");
 		return -EFAULT;
 	}
 	/* Make sure buffer is written before we update index. */
 	smp_wmb();
-	if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
+	if (__put_user(vq->last_used_idx + 1, &vq->used->idx)) {
 		vq_err(vq, "Failed to increment used idx");
 		return -EFAULT;
 	}
@@ -1306,7 +1306,7 @@ void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	 * interrupts. */
 	smp_mb();
 
-	if (get_user(flags, &vq->avail->flags)) {
+	if (__get_user(flags, &vq->avail->flags)) {
 		vq_err(vq, "Failed to get flags");
 		return;
 	}
@@ -1357,7 +1357,7 @@ bool vhost_enable_notify(struct vhost_virtqueue *vq)
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
 	smp_mb();
-	r = get_user(avail_idx, &vq->avail->idx);
+	r = __get_user(avail_idx, &vq->avail->idx);
 	if (r) {
 		vq_err(vq, "Failed to check avail idx at %p: %d\n",
 		       &vq->avail->idx, r);

--uAKRQypu60I7Lcqm--
