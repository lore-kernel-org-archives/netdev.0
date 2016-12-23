From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 6/9] virtio-net: make rx buf size estimation works for
	XDP
Date: Fri, 23 Dec 2016 08:02:06 -0800
Message-ID: <585D4A7E.6040507@gmail.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-7-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-7-git-send-email-jasowang@redhat.com>
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

On 16-12-23 06:37 AM, Jason Wang wrote:
> We don't update ewma rx buf size in the case of XDP. This will lead
> underestimation of rx buf size which causes host to produce more than
> one buffers. This will greatly increase the possibility of XDP page
> linearization.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 0778dc8..77ae358 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -584,10 +584,12 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  				put_page(page);
>  				head_skb = page_to_skb(vi, rq, xdp_page,
>  						       0, len, PAGE_SIZE);
> +				ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>  				return head_skb;
>  			}
>  			break;
>  		case XDP_TX:
> +			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>  			if (unlikely(xdp_page != page))
>  				goto err_xdp;
>  			rcu_read_unlock();
> @@ -596,6 +598,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  		default:
>  			if (unlikely(xdp_page != page))
>  				__free_pages(xdp_page, 0);
> +			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>  			goto err_xdp;
>  		}
>  	}
> 

Looks needed although I guess it will only be the case with
MTU > ETH_DATA_LEN because of the clamp in get_mergeable_buf_len().
Although XDP setup allows MTU up to page_size - hdr so certainly
will happen with ~MTU > 1500.

I need to add some various MTU tests to my setup.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
