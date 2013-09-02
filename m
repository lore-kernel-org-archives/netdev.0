From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 6/6] vhost_net: correctly limit the max pending buffers
Date: Mon, 2 Sep 2013 08:56:09 +0300
Message-ID: <20130902055609.GC19838@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-7-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1377836962-49780-7-git-send-email-jasowang@redhat.com>
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

On Fri, Aug 30, 2013 at 12:29:22PM +0800, Jason Wang wrote:
> As Michael point out, We used to limit the max pending DMAs to get better cache
> utilization. But it was not done correctly since it was one done when there's no
> new buffers submitted from guest. Guest can easily exceeds the limitation by
> keeping sending packets.
> 
> So this patch moves the check into main loop. Tests shows about 5%-10%
> improvement on per cpu throughput for guest tx. But a 5% drop on per cpu
> transaction rate for a single session TCP_RR.

Any explanation for the drop? single session TCP_RR is unlikely to
exceed VHOST_MAX_PEND, correct?

> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c |   15 ++++-----------
>  1 files changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index d09c17c..592e1f2 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -363,6 +363,10 @@ static void handle_tx(struct vhost_net *net)
>  		if (zcopy)
>  			vhost_zerocopy_signal_used(net, vq);
>  
> +		if ((nvq->upend_idx + vq->num - VHOST_MAX_PEND) % UIO_MAXIOV ==
> +		    nvq->done_idx)
> +			break;
> +
>  		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
>  					 ARRAY_SIZE(vq->iov),
>  					 &out, &in,
> @@ -372,17 +376,6 @@ static void handle_tx(struct vhost_net *net)
>  			break;
>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
>  		if (head == vq->num) {
> -			int num_pends;
> -
> -			/* If more outstanding DMAs, queue the work.
> -			 * Handle upend_idx wrap around
> -			 */
> -			num_pends = likely(nvq->upend_idx >= nvq->done_idx) ?
> -				    (nvq->upend_idx - nvq->done_idx) :
> -				    (nvq->upend_idx + UIO_MAXIOV -
> -				     nvq->done_idx);
> -			if (unlikely(num_pends > VHOST_MAX_PEND))
> -				break;
>  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
>  				vhost_disable_notify(&net->dev, vq);
>  				continue;
> -- 
> 1.7.1
