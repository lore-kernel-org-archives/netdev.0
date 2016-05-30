From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 2/2] vhost_net: conditionally enable tx polling
Date: Mon, 30 May 2016 18:55:21 +0300
Message-ID: <20160530155521.GA5427@redhat.com>
References: <1464590874-39539-1-git-send-email-jasowang@redhat.com>
 <1464590874-39539-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464590874-39539-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 30, 2016 at 02:47:54AM -0400, Jason Wang wrote:
> We always poll tx for socket, this is sub optimal since:
> 
> - it will be only used when we exceed the sndbuf of the socket.
> - since we use two independent polls for tx and vq, this will slightly
>   increase the waitqueue traversing time and more important, vhost
>   could not benefit from commit
>   9e641bdcfa4ef4d6e2fbaa59c1be0ad5d1551fd5 ("net-tun: restructure
>   tun_do_read for better sleep/wakeup efficiency") even if we've
>   stopped rx polling during handle_rx since tx poll were still left in
>   the waitqueue.

Why is this an issue?
sock_def_write_space only wakes up when queue is half empty,
not on each packet.
        if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf)

I suspect the issue is with your previous patch,
it now pokes at the spinlock on data path
where it used not to.

Is that right?


> 
> Fix this by conditionally enable tx polling only when -EAGAIN were
> met.
> 
> Test shows about 8% improvement on guest rx pps.
> 
> Before: ~1350000
> After:  ~1460000
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index e91603b..5a05fa0 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -378,6 +378,7 @@ static void handle_tx(struct vhost_net *net)
>  		goto out;
>  
>  	vhost_disable_notify(&net->dev, vq);
> +	vhost_net_disable_vq(net, vq);
>  
>  	hdr_size = nvq->vhost_hlen;
>  	zcopy = nvq->ubufs;
> @@ -459,6 +460,8 @@ static void handle_tx(struct vhost_net *net)
>  					% UIO_MAXIOV;
>  			}
>  			vhost_discard_vq_desc(vq, 1);
> +			if (err == -EAGAIN)
> +				vhost_net_enable_vq(net, vq);
>  			break;
>  		}
>  		if (err != len)
> -- 
> 1.8.3.1
