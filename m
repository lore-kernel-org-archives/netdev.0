From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 2/3] vhost: introduce vhost_vq_more_avail()
Date: Wed, 20 Jan 2016 16:09:50 +0200
Message-ID: <20160120160400-mutt-send-email-mst@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
 <1448951985-12385-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448951985-12385-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2015 at 02:39:44PM +0800, Jason Wang wrote:
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Wow new API with no comments anywhere, and no
commit log to say what it's good for.
Want to know what it does and whether
it's correct? You have to read the next patch.

So what is the point of splitting it out?
It's confusing, and in fact it made you
miss a bug.

> ---
>  drivers/vhost/vhost.c | 13 +++++++++++++
>  drivers/vhost/vhost.h |  1 +
>  2 files changed, 14 insertions(+)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 163b365..4f45a03 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1633,6 +1633,19 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
>  }
>  EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
>  
> +bool vhost_vq_more_avail(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> +{
> +	__virtio16 avail_idx;
> +	int r;
> +
> +	r = __get_user(avail_idx, &vq->avail->idx);
> +	if (r)
> +		return false;

So the result is that if the page is not present,
you return false (empty ring) and the
caller will busy wait with preempt disabled.
Nasty.

So it should return something that breaks
the loop, and this means it should have
a different name for the return code
to make sense.

Maybe reverse the polarity: vhost_vq_avail_empty?
And add a comment saying we can't be sure ring
is empty so return false.

> +
> +	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
> +}
> +EXPORT_SYMBOL_GPL(vhost_vq_more_avail);
> +
>  /* OK, now we need to know about added descriptors. */
>  bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  {
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 43284ad..2f3c57c 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
>  			       struct vring_used_elem *heads, unsigned count);
>  void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
>  void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
> +bool vhost_vq_more_avail(struct vhost_dev *, struct vhost_virtqueue *);
>  bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
>  
>  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
> -- 
> 2.5.0
