From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] vhost_net: stop rx net polling when possible
Date: Sun, 17 Aug 2014 12:20:56 +0200
Message-ID: <20140817102056.GB21622@redhat.com>
References: <1408074008-4357-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1408074008-4357-1-git-send-email-jasowang@redhat.com>
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

On Fri, Aug 15, 2014 at 11:40:08AM +0800, Jason Wang wrote:
> After rx vq was enabled, we never stop polling its socket. This is sub optimal
> when may lead unnecessary wake-ups after the rx net work has already been
> queued. This could be optimized by stopping polling the rx net sock when
> processing both rx and tx and restart it afterward. This could save unnecessary
> wake-ups and even unnecessary spin locks acquiring with the help of commit
> 9e641bdcfa4ef4d6e2fbaa59c1be0ad5d1551fd5 "net-tun: restructure tun_do_read for
> better sleep/wakeup efficiency".

OK so the point is to avoid expensive wake_up_process calls?
It's a bit unfortunate that we are adding/removing things from wait
queue which certainly does take extra spin-locks.




> Test shows significant CPU% savings during almost all the cases:
> 
> Guest rx stream:
> size(B)/sessions/throughput/cpu/normalized thru/
> 64/1/+0.7773%   -8.6224%     +10.2866%
> 64/2/+0.6335%   -13.9109%    +16.8946%
> 64/4/-0.8182%   -14.8336%    +16.4565%
> 64/8/+0.4830%   -13.7675%    +16.5256%
> 256/1/-7.0963%  -12.6880%    +6.4043%
> 256/2/-1.3982%  -11.5424%    +11.4678%
> 256/4/-0.0350%  -11.8323%    +13.3806%
> 256/8/-1.5830%  -12.7693%    +12.8238%
> 1024/1/-7.4895% -19.1449%       +14.4152%
> 1024/2/-7.4575% -19.4018%       +14.8195%
> 1024/4/-0.3881% -9.1183%        +9.6061%
> 1024/8/+0.4713% -11.0155%       +12.9087%
> 4096/1/+0.8786%  -8.4050%        +10.1355%
> 4096/2/+0.0098%  -15.3094%       +18.0885%
> 4096/4/+0.0445%  -10.8247%       +12.1886%
> 4096/8/-2.1317%  -12.5111%       +11.8637%
> 16384/1/-0.0008% -6.1891%        +6.5966%
> 16384/2/-0.0117% -16.2716%       +19.4198%
> 16384/4/+0.0001% -5.9197%        +6.2923%
> 16384/8/+0.0173% -7.6681%        +8.3236%
> 65535/1/+0.0011% -10.3594%       +11.5578%
> 65535/2/-0.4108%  -14.4304%       +16.3838%
> 65535/4/+0.0011%  -10.3594%       +11.5578%
> 65535/8/-0.4108%  -14.4304%       +16.3838%
> 
> Guest tx stream:
> size(B)/sessions/throughput/cpu/normalized thru/
> 64/1/-0.6228%     -2.1936%     +1.6060%
> 64/2/+0.8646%     -3.5063%     +4.5297%
> 64/4/+0.8733%     -3.2495%     +4.2613%
> 64/8/+1.4290%     -3.5593%     +5.1724%
> 256/1/+7.2098%    -3.1122%     +10.6535%
> 256/2/-10.1408%   -6.8230%     -3.5607%
> 256/4/-11.3531%   -6.7085%     -4.9785%
> 256/8/-10.2723%   -6.5628%     -3.9701%
> 1024/1/-18.9329%  -13.6162%    -6.1547%
> 1024/2/-0.3728%   -1.3181%     +0.9580%
> 1024/4/+0.0125%   -3.6338%     +3.7838%
> 1024/8/-0.0030%   -2.7282%     +2.8017%
> 4096/1/+16.9367%  -1.9435%     +19.2543%
> 4096/2/+0.0121%   -6.1682%     +6.5866%
> 4096/4/+0.0019%   -3.8510%     +4.0072%
> 4096/8/-0.0222%   -4.1368%     +4.2922%
> 16384/1/-0.0026%  -8.6892%     +9.5132%
> 16384/2/-0.0012%  -10.1676%    +11.3171%
> 16384/4/+0.0196%  -1.2551%     +1.2908%
> 16384/8/+0.1303%  -3.2634%     +3.5082%
> 65535/1/+0.0019%  -3.4694%     +3.5961%
> 65535/2/-0.0003%  -0.7635%     +0.7690%
> 65535/4/-0.0219%  -2.7875%     +2.8448%
> 65535/8/+0.1137%  -2.7922%     +2.9894%
> 
> TCP_RR:
> size(B)/sessions/throughput/cpu/normalized thru/
> 256/1/+1.9004%    -4.7985%     +7.0366%
> 256/25/-4.7366%   -11.0809%    +7.1349%
> 256/50/+3.9808%   -5.2037%     +9.6887%
> 4096/1/+2.1619%   -0.7303%     +2.9134%
> 4096/25/-13.1836% -14.7298%    +1.8134%
> 4096/50/-11.1990% -15.4763%    +5.0605%
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Could you split RX/TX parts out please, and benchmark separately?

They are really independent.




> ---
>  drivers/vhost/net.c | 26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 8dae2f7..d4a9742 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -334,6 +334,8 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>  static void handle_tx(struct vhost_net *net)
>  {
>  	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
> +	struct vhost_virtqueue *rx_vq = &net->vqs[VHOST_NET_VQ_RX].vq;
> +	struct vhost_poll *rx_poll = &net->poll[VHOST_NET_VQ_RX];
>  	struct vhost_virtqueue *vq = &nvq->vq;
>  	unsigned out, in, s;
>  	int head;
> @@ -348,15 +350,18 @@ static void handle_tx(struct vhost_net *net)
>  	size_t len, total_len = 0;
>  	int err;
>  	size_t hdr_size;
> -	struct socket *sock;
> +	struct socket *sock, *rxsock;
>  	struct vhost_net_ubuf_ref *uninitialized_var(ubufs);
> -	bool zcopy, zcopy_used;
> +	bool zcopy, zcopy_used, poll = false;
>  
>  	mutex_lock(&vq->mutex);
> +	mutex_lock(&rx_vq->mutex);
>  	sock = vq->private_data;
> +	rxsock = rx_vq->private_data;
>  	if (!sock)
>  		goto out;
>  
> +	vhost_poll_stop(rx_poll);
>  	vhost_disable_notify(&net->dev, vq);
>  
>  	hdr_size = nvq->vhost_hlen;
> @@ -451,11 +456,17 @@ static void handle_tx(struct vhost_net *net)
>  		total_len += len;
>  		vhost_net_tx_packet(net);
>  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> -			vhost_poll_queue(&vq->poll);
> +			poll = true;
>  			break;
>  		}
>  	}
> +
> +	if (rxsock)
> +		vhost_poll_start(rx_poll, rxsock->file);
> +	if (poll)
> +		vhost_poll_queue(&vq->poll);
>  out:
> +	mutex_unlock(&rx_vq->mutex);
>  	mutex_unlock(&vq->mutex);
>  }
>  
> @@ -554,6 +565,7 @@ err:
>  static void handle_rx(struct vhost_net *net)
>  {
>  	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_RX];
> +	struct vhost_poll *poll = &net->poll[VHOST_NET_VQ_RX];
>  	struct vhost_virtqueue *vq = &nvq->vq;
>  	unsigned uninitialized_var(in), log;
>  	struct vhost_log *vq_log;
> @@ -580,6 +592,8 @@ static void handle_rx(struct vhost_net *net)
>  	sock = vq->private_data;
>  	if (!sock)
>  		goto out;
> +
> +	vhost_poll_stop(poll);
>  	vhost_disable_notify(&net->dev, vq);
>  
>  	vhost_hlen = nvq->vhost_hlen;
> @@ -660,10 +674,12 @@ static void handle_rx(struct vhost_net *net)
>  			vhost_log_write(vq, vq_log, log, vhost_len);
>  		total_len += vhost_len;
>  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> -			vhost_poll_queue(&vq->poll);
> -			break;
> +			vhost_poll_queue(poll);
> +			goto out;
>  		}
>  	}
> +
> +	vhost_poll_start(poll, sock->file);
>  out:
>  	mutex_unlock(&vq->mutex);
>  }
> -- 
> 1.9.1
