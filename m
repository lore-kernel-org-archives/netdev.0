From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] virtio_net: lower limit on buffer size
Date: Fri, 2 Jun 2017 09:16:15 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1706020914510.7009@file01.intranet.prod.int.rdu2.redhat.com>
References: <1496361148-4603-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496361148-4603-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 2 Jun 2017, Michael S. Tsirkin wrote:

> commit d85b758f72b0 "virtio_net: fix support for small rings"
> was supposed to increase the buffer size for small rings
> but had an unintentional side effect of decreasing
> it for large rings. This seems to break some setups -
> it's not yet clear why, but increasing buffer size
> back to what it was before helps.
> 
> Fixes: d85b758f72b0 "virtio_net: fix support for small rings"
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Can reporters please confirm whether the following helps?
> If it does I think we should queue it even though I expect I'll need to
> investigate the exact reasons for the failure down the road - probably
> a hypervisor bug.

Hi

This patch fixes the problem for me.

Mikulas

>  drivers/net/virtio_net.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 87b5c20..60abb5d 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -842,7 +842,7 @@ static unsigned int get_mergeable_buf_len(struct receive_queue *rq,
>  	unsigned int len;
>  
>  	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
> -				rq->min_buf_len - hdr_len, PAGE_SIZE - hdr_len);
> +				rq->min_buf_len, PAGE_SIZE - hdr_len);
>  	return ALIGN(len, L1_CACHE_BYTES);
>  }
>  
> @@ -2039,7 +2039,8 @@ static unsigned int mergeable_min_buf_len(struct virtnet_info *vi, struct virtqu
>  	unsigned int buf_len = hdr_len + ETH_HLEN + VLAN_HLEN + packet_len;
>  	unsigned int min_buf_len = DIV_ROUND_UP(buf_len, rq_size);
>  
> -	return max(min_buf_len, hdr_len);
> +	return max(max(min_buf_len, hdr_len) - hdr_len,
> +		   (unsigned int)GOOD_PACKET_LEN);
>  }
>  
>  static int virtnet_find_vqs(struct virtnet_info *vi)
> -- 
> MST
> 
