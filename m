From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 2/3] virtio-net: fix num calculation on frag skb
	allocation failure
Date: Wed, 20 Nov 2013 12:37:29 +0200
Message-ID: <20131120103729.GG19341@redhat.com>
References: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
	<1384938447-3775-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1384938447-3775-2-git-send-email-jasowang@redhat.com>
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

On Wed, Nov 20, 2013 at 05:07:26PM +0800, Jason Wang wrote:
> We need decrease the rq->num after we can get a buf through
> virtqueue_get_buf() even if we could not allocate frag skb. Otherwise, the
> refill routine won't be triggered under heavy memory stress since the driver may
> still think there's enough room.
> 
> This bug was introduced by commit 2613af0ed18a11d5c566a81f9a6510b73180660a
> (virtio_net: migrate mergeable rx buffers to page frag allocators).
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

So let's wrap virtqueue_get_buf to make sure we get it right?

> ---
> The patch was needed for 3.12 stable.
> ---
>  drivers/net/virtio_net.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 24fd502..de1d6ca 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -333,6 +333,7 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
>  			head_skb->dev->stats.rx_length_errors++;
>  			return -EINVAL;
>  		}
> +		--rq->num;
>  		if (unlikely(len > MERGE_BUFFER_LEN)) {
>  			pr_debug("%s: rx error: merge buffer too long\n",
>  				 head_skb->dev->name);
> @@ -367,7 +368,6 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
>  			skb_add_rx_frag(curr_skb, num_skb_frags, page,
>  					offset, len, MERGE_BUFFER_LEN);
>  		}
> -		--rq->num;
>  	}
>  	return 0;
>  }
> -- 
> 1.8.3.2
