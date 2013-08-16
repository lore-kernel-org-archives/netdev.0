From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/6] vhost_net: use vhost_add_used_and_signal_n() in
	vhost_zerocopy_signal_used()
Date: Fri, 16 Aug 2013 12:54:26 +0300
Message-ID: <20130816095426.GA21821@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1376630190-5912-3-git-send-email-jasowang@redhat.com>
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

On Fri, Aug 16, 2013 at 01:16:26PM +0800, Jason Wang wrote:
> Switch to use vhost_add_used_and_signal_n() to avoid multiple calls to
> vhost_add_used_and_signal(). With the patch we will call at most 2 times
> (consider done_idx warp around) compared to N times w/o this patch.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

So? Does this help performance then?

> ---
>  drivers/vhost/net.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 280ee66..8a6dd0d 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -281,7 +281,7 @@ static void vhost_zerocopy_signal_used(struct vhost_net *net,
>  {
>  	struct vhost_net_virtqueue *nvq =
>  		container_of(vq, struct vhost_net_virtqueue, vq);
> -	int i;
> +	int i, add;
>  	int j = 0;
>  
>  	for (i = nvq->done_idx; i != nvq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
> @@ -289,14 +289,17 @@ static void vhost_zerocopy_signal_used(struct vhost_net *net,
>  			vhost_net_tx_err(net);
>  		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
>  			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
> -			vhost_add_used_and_signal(vq->dev, vq,
> -						  vq->heads[i].id, 0);
>  			++j;
>  		} else
>  			break;
>  	}
> -	if (j)
> -		nvq->done_idx = i;
> +	while (j) {
> +		add = min(UIO_MAXIOV - nvq->done_idx, j);
> +		vhost_add_used_and_signal_n(vq->dev, vq,
> +					    &vq->heads[nvq->done_idx], add);
> +		nvq->done_idx = (nvq->done_idx + add) % UIO_MAXIOV;
> +		j -= add;
> +	}
>  }
>  
>  static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> -- 
> 1.7.1
