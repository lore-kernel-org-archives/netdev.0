From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: enable tx interrupt
Date: Wed, 15 Oct 2014 02:11:54 +0300
Message-ID: <20141014231154.GA23806@redhat.com>
References: <1413323524-23380-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413323524-23380-1-git-send-email-mst@redhat.com>
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

On Wed, Oct 15, 2014 at 12:53:59AM +0300, Michael S. Tsirkin wrote:
>  static void skb_xmit_done(struct virtqueue *vq)
>  {
>  	struct virtnet_info *vi = vq->vdev->priv;
> +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>  
> -	/* Suppress further interrupts. */
> -	virtqueue_disable_cb(vq);
> -

One note here: current code seems racy because of doing
virtqueue_disable_cb from skb_xmit_done that I'm dropping here: there's
no guarantee we don't get an interrupt while tx ring is running, and if
that happens we can end up with interrupts disabled forever.

> -	/* We were probably waiting for more output buffers. */
> -	netif_wake_subqueue(vi->dev, vq2txq(vq));
> +	if (napi_schedule_prep(&sq->napi)) {
> +		__napi_schedule(&sq->napi);
> +	}
>  }
>  
>  static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
