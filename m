From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net v2] vhost: fix a theoretical race in
 device cleanup
Date: Thu, 13 Feb 2014 18:01:13 +0800
Message-ID: <52FC97E9.2080808@redhat.com>
References: <1392284540-2031-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>
Return-path: <virtio-dev-return-384-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <1392284540-2031-1-git-send-email-mst@redhat.com>
List-Id: netdev.vger.kernel.org

On 02/13/2014 05:45 PM, Michael S. Tsirkin wrote:
> vhost_zerocopy_callback accesses VQ right after it drops a ubuf
> reference.  In theory, this could race with device removal which waits
> on the ubuf kref, and crash on use after free.
>
> Do all accesses within rcu read side critical section, and synchronize
> on release.
>
> Since callbacks are always invoked from bh, synchronize_rcu_bh seems
> enough and will help release complete a bit faster.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> This is was previously posted as part of patch
> series, but it's an independent fix really.
> Theoretical race so not needed for stable I think.
>
> changes from v1:
> 	fixed typo in commit log
>
>  drivers/vhost/net.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index b12176f..f1be80d 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -308,6 +308,8 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>  	struct vhost_virtqueue *vq = ubufs->vq;
>  	int cnt;
>  
> +	rcu_read_lock_bh();
> +
>  	/* set len to mark this desc buffers done DMA */
>  	vq->heads[ubuf->desc].len = success ?
>  		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
> @@ -322,6 +324,8 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>  	 */
>  	if (cnt <= 1 || !(cnt % 16))
>  		vhost_poll_queue(&vq->poll);
> +
> +	rcu_read_unlock_bh();
>  }
>  
>  /* Expects to be always run from workqueue - which acts as
> @@ -804,6 +808,8 @@ static int vhost_net_release(struct inode *inode, struct file *f)
>  		fput(tx_sock->file);
>  	if (rx_sock)
>  		fput(rx_sock->file);
> +	/* Make sure no callbacks are outstanding */
> +	synchronize_rcu_bh();
>  	/* We do an extra flush before freeing memory,
>  	 * since jobs can re-queue themselves. */
>  	vhost_net_flush(n);

Acked-by: Jason Wang <jasowang@redhat.com>
