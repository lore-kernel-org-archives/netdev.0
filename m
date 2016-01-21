From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 3/3] vhost_net: basic polling support
Date: Thu, 21 Jan 2016 07:13:18 +0200
Message-ID: <20160121064759-mutt-send-email-mst@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
 <1448951985-12385-4-git-send-email-jasowang@redhat.com>
 <20160120143524.GA27168@redhat.com>
 <56A03E57.2020400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yang Zhang <yang.zhang.wz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbcAUFNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 00:13:21 -0500
Content-Disposition: inline
In-Reply-To: <56A03E57.2020400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 10:11:35AM +0800, Yang Zhang wrote:
> On 2016/1/20 22:35, Michael S. Tsirkin wrote:
> >On Tue, Dec 01, 2015 at 02:39:45PM +0800, Jason Wang wrote:
> >>This patch tries to poll for new added tx buffer or socket receive
> >>queue for a while at the end of tx/rx processing. The maximum time
> >>spent on polling were specified through a new kind of vring ioctl.
> >>
> >>Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>---
> >>  drivers/vhost/net.c        | 72 ++++++++++++++++++++++++++++++++++++++++++----
> >>  drivers/vhost/vhost.c      | 15 ++++++++++
> >>  drivers/vhost/vhost.h      |  1 +
> >>  include/uapi/linux/vhost.h | 11 +++++++
> >>  4 files changed, 94 insertions(+), 5 deletions(-)
> >>
> >>diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >>index 9eda69e..ce6da77 100644
> >>--- a/drivers/vhost/net.c
> >>+++ b/drivers/vhost/net.c
> >>@@ -287,6 +287,41 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> >>  	rcu_read_unlock_bh();
> >>  }
> >>
> >>+static inline unsigned long busy_clock(void)
> >>+{
> >>+	return local_clock() >> 10;
> >>+}
> >>+
> >>+static bool vhost_can_busy_poll(struct vhost_dev *dev,
> >>+				unsigned long endtime)
> >>+{
> >>+	return likely(!need_resched()) &&
> >>+	       likely(!time_after(busy_clock(), endtime)) &&
> >>+	       likely(!signal_pending(current)) &&
> >>+	       !vhost_has_work(dev) &&
> >>+	       single_task_running();
> >>+}
> >>+
> >>+static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
> >>+				    struct vhost_virtqueue *vq,
> >>+				    struct iovec iov[], unsigned int iov_size,
> >>+				    unsigned int *out_num, unsigned int *in_num)
> >>+{
> >>+	unsigned long uninitialized_var(endtime);
> >>+
> >>+	if (vq->busyloop_timeout) {
> >>+		preempt_disable();
> >>+		endtime = busy_clock() + vq->busyloop_timeout;
> >>+		while (vhost_can_busy_poll(vq->dev, endtime) &&
> >>+		       !vhost_vq_more_avail(vq->dev, vq))
> >>+			cpu_relax();
> >>+		preempt_enable();
> >>+	}
> >
> >Isn't there a way to call all this after vhost_get_vq_desc?
> >First, this will reduce the good path overhead as you
> >won't have to play with timers and preemption.
> >
> >Second, this will reduce the chance of a pagefault on avail ring read.
> >
> >>+
> >>+	return vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
> >>+				 out_num, in_num, NULL, NULL);
> >>+}
> >>+
> >>  /* Expects to be always run from workqueue - which acts as
> >>   * read-size critical section for our kind of RCU. */
> >>  static void handle_tx(struct vhost_net *net)
> >>@@ -331,10 +366,9 @@ static void handle_tx(struct vhost_net *net)
> >>  			      % UIO_MAXIOV == nvq->done_idx))
> >>  			break;
> >>
> >>-		head = vhost_get_vq_desc(vq, vq->iov,
> >>-					 ARRAY_SIZE(vq->iov),
> >>-					 &out, &in,
> >>-					 NULL, NULL);
> >>+		head = vhost_net_tx_get_vq_desc(net, vq, vq->iov,
> >>+						ARRAY_SIZE(vq->iov),
> >>+						&out, &in);
> >>  		/* On error, stop handling until the next kick. */
> >>  		if (unlikely(head < 0))
> >>  			break;
> >>@@ -435,6 +469,34 @@ static int peek_head_len(struct sock *sk)
> >>  	return len;
> >>  }
> >>
> >>+static int vhost_net_peek_head_len(struct vhost_net *net, struct sock *sk)
> >
> >Need a hint that it's rx related in the name.
> >
> >>+{
> >>+	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
> >>+	struct vhost_virtqueue *vq = &nvq->vq;
> >>+	unsigned long uninitialized_var(endtime);
> >>+
> >>+	if (vq->busyloop_timeout) {
> >>+		mutex_lock(&vq->mutex);
> >
> >This appears to be called under vq mutex in handle_rx.
> >So how does this work then?
> >
> >
> >>+		vhost_disable_notify(&net->dev, vq);
> >
> >This appears to be called after disable notify
> >in handle_rx - so why disable here again?
> >
> >>+
> >>+		preempt_disable();
> >>+		endtime = busy_clock() + vq->busyloop_timeout;
> >>+
> >>+		while (vhost_can_busy_poll(&net->dev, endtime) &&
> >>+		       skb_queue_empty(&sk->sk_receive_queue) &&
> >>+		       !vhost_vq_more_avail(&net->dev, vq))
> >>+			cpu_relax();
> >
> >This seems to mix in several items.
> >RX queue is normally not empty. I don't think
> >we need to poll for that.
> 
> I have seen the RX queue is easy to be empty under some extreme conditions
> like lots of small packet. So maybe the check is useful here.

It's not useful *here*.
If you have an rx packet but no space in the ring,
this will exit immediately.

It might be useful elsewhere but I doubt it -
if rx ring is out of buffers, you are better off
backing out and giving guest some breathing space.

> -- 
> best regards
> yang
