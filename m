From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 4/9] virtio-net: correctly handle XDP_PASS for
	linearized packets
Date: Fri, 23 Dec 2016 07:57:26 -0800
Message-ID: <585D4966.9060605@gmail.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-5-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-5-git-send-email-jasowang@redhat.com>
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
> When XDP_PASS were determined for linearized packets, we try to get
> new buffers in the virtqueue and build skbs from them. This is wrong,
> we should create skbs based on existed buffers instead. Fixing them by
> creating skb based on xdp_page.
> 
> With this patch "ping 192.168.100.4 -s 3900 -M do" works for XDP_PASS.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 58ad40e..470293e 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -578,8 +578,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  		act = do_xdp_prog(vi, rq, xdp_prog, xdp_page, offset, len);
>  		switch (act) {
>  		case XDP_PASS:
> -			if (unlikely(xdp_page != page))
> -				__free_pages(xdp_page, 0);
> +			/* We can only create skb based on xdp_page. */
> +			if (unlikely(xdp_page != page)) {
> +				rcu_read_unlock();
> +				put_page(page);
> +				head_skb = page_to_skb(vi, rq, xdp_page,
> +						       0, len, PAGE_SIZE);
> +				return head_skb;
> +			}
>  			break;
>  		case XDP_TX:
>  			if (unlikely(xdp_page != page))
> 

Great thanks. This was likely working before because of the memory
leak fixed in 3/9.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
