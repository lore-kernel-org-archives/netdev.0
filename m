From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] virtio-net: coalesce rx frags when possible
	during rx
Date: Thu, 31 Oct 2013 13:41:53 +0200
Message-ID: <20131031114153.GD8976@redhat.com>
References: <1383215313-23651-1-git-send-email-jasowang@redhat.com>
	<1383215313-23651-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1383215313-23651-2-git-send-email-jasowang@redhat.com>
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

On Thu, Oct 31, 2013 at 06:28:33PM +0800, Jason Wang wrote:
> Commit 2613af0ed18a11d5c566a81f9a6510b73180660a (virtio_net: migrate mergeable
> rx buffers to page frag allocators) try to increase the payload/truesize for
> MTU-sized traffic. But this will introduce the extra overhead for GSO packets
> received because of the frag list. This commit tries to reduce this issue by
> coalesce the possible rx frags when possible during rx. Test result shows the
> about 15% improvement on full size GSO packet receiving (and even better than
> commit 2613af0ed18a11d5c566a81f9a6510b73180660a).
> 
> Before this commit:
> ./netperf -H 192.168.100.4
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4
> () port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    20303.87
> 
> After this commit:
> ./netperf -H 192.168.100.4
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4 () port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    23841.26
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Good idea.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 113ee93..4ff4f78 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -305,7 +305,7 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
>  	struct sk_buff *curr_skb = head_skb;
>  	char *buf;
>  	struct page *page;
> -	int num_buf, len;
> +	int num_buf, len, offset;
>  
>  	num_buf = hdr->mhdr.num_buffers;
>  	while (--num_buf) {
> @@ -342,9 +342,15 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
>  			head_skb->truesize += MAX_PACKET_LEN;
>  		}
>  		page = virt_to_head_page(buf);
> -		skb_add_rx_frag(curr_skb, num_skb_frags, page,
> -				buf - (char *)page_address(page), len,
> -				MAX_PACKET_LEN);
> +		offset = buf - (char *)page_address(page);
> +		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
> +			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
> +					     offset, len, MAX_PACKET_LEN);
> +		} else {
> +			skb_add_rx_frag(curr_skb, num_skb_frags, page,
> +					offset, len,
> +					MAX_PACKET_LEN);
> +		}
>  		--rq->num;
>  	}
>  	return 0;
> -- 
> 1.8.1.2
