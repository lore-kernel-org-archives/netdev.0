From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Sun, 13 Nov 2011 12:24:28 +0200
Message-ID: <20111113102428.GD15322@redhat.com>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, gorcunov@gmail.com,
	kvm@vger.kernel.org, asias.hejun@gmail.com,
	virtualization@lists.linux-foundation.org, penberg@kernel.org,
	netdev@vger.kernel.org, mingo@elte.hu
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
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

On Sat, Nov 12, 2011 at 12:12:01AM +0200, Sasha Levin wrote:
> This is a patch based on Krishna Kumar's patch series which implements
> multiple VQ support for virtio-net.
> 
> The patch was tested with ver3 of the patch.
> 
> Cc: Krishna Kumar <krkumar2@in.ibm.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Any performance numbers?

> ---
>  tools/kvm/include/kvm/virtio-pci.h |    2 +-
>  tools/kvm/virtio/net.c             |   94 +++++++++++++++++++----------------
>  2 files changed, 52 insertions(+), 44 deletions(-)
> 
> diff --git a/tools/kvm/include/kvm/virtio-pci.h b/tools/kvm/include/kvm/virtio-pci.h
> index 2bbb271..94d20ee 100644
> --- a/tools/kvm/include/kvm/virtio-pci.h
> +++ b/tools/kvm/include/kvm/virtio-pci.h
> @@ -6,7 +6,7 @@
>  
>  #include <linux/types.h>
>  
> -#define VIRTIO_PCI_MAX_VQ	3
> +#define VIRTIO_PCI_MAX_VQ	16
>  #define VIRTIO_PCI_MAX_CONFIG	1
>  
>  struct kvm;
> diff --git a/tools/kvm/virtio/net.c b/tools/kvm/virtio/net.c
> index cee2b5b..0754795 100644
> --- a/tools/kvm/virtio/net.c
> +++ b/tools/kvm/virtio/net.c
> @@ -27,9 +27,8 @@
>  #include <sys/wait.h>
>  
>  #define VIRTIO_NET_QUEUE_SIZE		128
> -#define VIRTIO_NET_NUM_QUEUES		2
> -#define VIRTIO_NET_RX_QUEUE		0
> -#define VIRTIO_NET_TX_QUEUE		1
> +#define VIRTIO_NET_NUM_QUEUES		16
> +#define VIRTIO_NET_IS_RX_QUEUE(x)	(((x) % 2) == 0)
>  
>  struct net_dev;
>  
> @@ -49,14 +48,13 @@ struct net_dev {
>  	struct virtio_net_config	config;
>  	u32				features;
>  
> -	pthread_t			io_rx_thread;
> -	pthread_mutex_t			io_rx_lock;
> -	pthread_cond_t			io_rx_cond;
> -
> -	pthread_t			io_tx_thread;
> -	pthread_mutex_t			io_tx_lock;
> -	pthread_cond_t			io_tx_cond;
> +	pthread_t			io_thread[VIRTIO_NET_NUM_QUEUES];
> +	pthread_mutex_t			io_lock[VIRTIO_NET_NUM_QUEUES];
> +	pthread_cond_t			io_cond[VIRTIO_NET_NUM_QUEUES];
>  
> +	int				rx_vq_num;
> +	int				tx_vq_num;
> +	int				vq_num;
>  	int				tap_fd;
>  	char				tap_name[IFNAMSIZ];
>  
> @@ -78,17 +76,22 @@ static void *virtio_net_rx_thread(void *p)
>  	struct net_dev *ndev = p;
>  	u16 out, in;
>  	u16 head;
> -	int len;
> +	int len, queue_num;
> +
> +	mutex_lock(&ndev->mutex);
> +	queue_num = ndev->rx_vq_num * 2;
> +	ndev->tx_vq_num++;
> +	mutex_unlock(&ndev->mutex);
>  
>  	kvm	= ndev->kvm;
> -	vq	= &ndev->vqs[VIRTIO_NET_RX_QUEUE];
> +	vq	= &ndev->vqs[queue_num];
>  
>  	while (1) {
>  
> -		mutex_lock(&ndev->io_rx_lock);
> +		mutex_lock(&ndev->io_lock[queue_num]);
>  		if (!virt_queue__available(vq))
> -			pthread_cond_wait(&ndev->io_rx_cond, &ndev->io_rx_lock);
> -		mutex_unlock(&ndev->io_rx_lock);
> +			pthread_cond_wait(&ndev->io_cond[queue_num], &ndev->io_lock[queue_num]);
> +		mutex_unlock(&ndev->io_lock[queue_num]);
>  
>  		while (virt_queue__available(vq)) {
>  
> @@ -99,7 +102,7 @@ static void *virtio_net_rx_thread(void *p)
>  			virt_queue__set_used_elem(vq, head, len);
>  
>  			/* We should interrupt guest right now, otherwise latency is huge. */
> -			ndev->vtrans.trans_ops->signal_vq(kvm, &ndev->vtrans, VIRTIO_NET_RX_QUEUE);
> +			ndev->vtrans.trans_ops->signal_vq(kvm, &ndev->vtrans, queue_num);
>  		}
>  
>  	}
> @@ -117,16 +120,21 @@ static void *virtio_net_tx_thread(void *p)
>  	struct net_dev *ndev = p;
>  	u16 out, in;
>  	u16 head;
> -	int len;
> +	int len, queue_num;
> +
> +	mutex_lock(&ndev->mutex);
> +	queue_num = ndev->tx_vq_num * 2 + 1;
> +	ndev->tx_vq_num++;
> +	mutex_unlock(&ndev->mutex);
>  
>  	kvm	= ndev->kvm;
> -	vq	= &ndev->vqs[VIRTIO_NET_TX_QUEUE];
> +	vq	= &ndev->vqs[queue_num];
>  
>  	while (1) {
> -		mutex_lock(&ndev->io_tx_lock);
> +		mutex_lock(&ndev->io_lock[queue_num]);
>  		if (!virt_queue__available(vq))
> -			pthread_cond_wait(&ndev->io_tx_cond, &ndev->io_tx_lock);
> -		mutex_unlock(&ndev->io_tx_lock);
> +			pthread_cond_wait(&ndev->io_cond[queue_num], &ndev->io_lock[queue_num]);
> +		mutex_unlock(&ndev->io_lock[queue_num]);
>  
>  		while (virt_queue__available(vq)) {
>  
> @@ -137,7 +145,7 @@ static void *virtio_net_tx_thread(void *p)
>  			virt_queue__set_used_elem(vq, head, len);
>  		}
>  
> -		ndev->vtrans.trans_ops->signal_vq(kvm, &ndev->vtrans, VIRTIO_NET_TX_QUEUE);
> +		ndev->vtrans.trans_ops->signal_vq(kvm, &ndev->vtrans, queue_num);
>  	}
>  
>  	pthread_exit(NULL);
> @@ -148,20 +156,9 @@ static void *virtio_net_tx_thread(void *p)
>  
>  static void virtio_net_handle_callback(struct kvm *kvm, struct net_dev *ndev, int queue)
>  {
> -	switch (queue) {
> -	case VIRTIO_NET_TX_QUEUE:
> -		mutex_lock(&ndev->io_tx_lock);
> -		pthread_cond_signal(&ndev->io_tx_cond);
> -		mutex_unlock(&ndev->io_tx_lock);
> -		break;
> -	case VIRTIO_NET_RX_QUEUE:
> -		mutex_lock(&ndev->io_rx_lock);
> -		pthread_cond_signal(&ndev->io_rx_cond);
> -		mutex_unlock(&ndev->io_rx_lock);
> -		break;
> -	default:
> -		pr_warning("Unknown queue index %u", queue);
> -	}
> +	mutex_lock(&ndev->io_lock[queue]);
> +	pthread_cond_signal(&ndev->io_cond[queue]);
> +	mutex_unlock(&ndev->io_lock[queue]);
>  }
>  
>  static bool virtio_net__tap_init(const struct virtio_net_params *params,
> @@ -248,14 +245,17 @@ fail:
>  
>  static void virtio_net__io_thread_init(struct kvm *kvm, struct net_dev *ndev)
>  {
> -	pthread_mutex_init(&ndev->io_tx_lock, NULL);
> -	pthread_mutex_init(&ndev->io_rx_lock, NULL);
> +	int i;
>  
> -	pthread_cond_init(&ndev->io_tx_cond, NULL);
> -	pthread_cond_init(&ndev->io_rx_cond, NULL);
> +	for (i = 0; i < ndev->vq_num; i++) {
> +		pthread_mutex_init(&ndev->io_lock[i], NULL);
> +		pthread_cond_init(&ndev->io_cond[i], NULL);
> +	}
>  
> -	pthread_create(&ndev->io_tx_thread, NULL, virtio_net_tx_thread, ndev);
> -	pthread_create(&ndev->io_rx_thread, NULL, virtio_net_rx_thread, ndev);
> +	for (i = 0; i < ndev->vq_num; i += 2) {
> +		pthread_create(&ndev->io_thread[i], NULL, virtio_net_tx_thread, ndev);
> +		pthread_create(&ndev->io_thread[i + 1], NULL, virtio_net_rx_thread, ndev);
> +	}
>  }
>  
>  static inline int tap_ops_tx(struct iovec *iov, u16 out, struct net_dev *ndev)
> @@ -311,13 +311,19 @@ static u32 get_host_features(struct kvm *kvm, void *dev)
>  		| 1UL << VIRTIO_NET_F_HOST_TSO6
>  		| 1UL << VIRTIO_NET_F_GUEST_UFO
>  		| 1UL << VIRTIO_NET_F_GUEST_TSO4
> -		| 1UL << VIRTIO_NET_F_GUEST_TSO6;
> +		| 1UL << VIRTIO_NET_F_GUEST_TSO6
> +		| 1UL << VIRTIO_NET_F_MULTIQUEUE;
>  }
>  
>  static void set_guest_features(struct kvm *kvm, void *dev, u32 features)
>  {
>  	struct net_dev *ndev = dev;
>  
> +	if (features & (1UL << VIRTIO_NET_F_MULTIQUEUE))
> +		ndev->vq_num = ndev->config.num_queues;
> +	else
> +		ndev->vq_num = 2;
> +
>  	ndev->features = features;
>  }
>  
> @@ -395,6 +401,8 @@ void virtio_net__init(const struct virtio_net_params *params)
>  		ndev->info.host_mac.addr[i]	= params->host_mac[i];
>  	}
>  
> +	ndev->config.num_queues = VIRTIO_NET_NUM_QUEUES;
> +
>  	ndev->mode = params->mode;
>  	if (ndev->mode == NET_MODE_TAP) {
>  		if (!virtio_net__tap_init(params, ndev))
> -- 
> 1.7.7.2
