From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V4 net-next 1/3] vhost: better detection of available
	buffers
Date: Fri, 6 Jan 2017 21:55:24 +0200
Message-ID: <20170106214903-mutt-send-email-mst@kernel.org>
References: <1483668797-24112-1-git-send-email-jasowang@redhat.com>
	<1483668797-24112-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, wexu@redhat.com,
	stefanha@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1483668797-24112-2-git-send-email-jasowang@redhat.com>
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

On Fri, Jan 06, 2017 at 10:13:15AM +0800, Jason Wang wrote:
> This patch tries to do several tweaks on vhost_vq_avail_empty() for a
> better performance:
> 
> - check cached avail index first which could avoid userspace memory access.
> - using unlikely() for the failure of userspace access
> - check vq->last_avail_idx instead of cached avail index as the last
>   step.
> 
> This patch is need for batching supports which needs to peek whether
> or not there's still available buffers in the ring.
> 
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index d643260..9f11838 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -2241,11 +2241,15 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	__virtio16 avail_idx;
>  	int r;
>  
> +	if (vq->avail_idx != vq->last_avail_idx)
> +		return false;
> +
>  	r = vhost_get_user(vq, avail_idx, &vq->avail->idx);
> -	if (r)
> +	if (unlikely(r))
>  		return false;
> +	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
>  
> -	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
> +	return vq->avail_idx == vq->last_avail_idx;
>  }
>  EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);

So again, this did not address the issue I pointed out in v1:
if we have 1 buffer in RX queue and
that is not enough to store the whole packet,
vhost_vq_avail_empty returns false, then we re-read
the descriptors again and again.

You have saved a single index access but not the more expensive
descriptor access.

I think that a way to address this could be to have this
return current index for the caller. Then as long as that
index isn't changed, you don't poke at descriptor ring.

> -- 
> 2.7.4
