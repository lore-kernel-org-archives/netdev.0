From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] [RFC] Changes for MQ vhost
Date: Mon, 28 Feb 2011 12:04:23 +0200
Message-ID: <20110228100423.GC28006@redhat.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
 <20110228063443.24908.38147.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, eric.dumazet@gmail.com,
	arnd@arndb.de, netdev@vger.kernel.org, horms@verge.net.au,
	avi@redhat.com, anthony@codemonkey.ws, kvm@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110228063443.24908.38147.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2011 at 12:04:43PM +0530, Krishna Kumar wrote:
> Changes for mq vhost.
> 
> vhost_net_open is changed to allocate a vhost_net and return.
> The remaining initializations are delayed till SET_OWNER.
> SET_OWNER is changed so that the argument is used to determine
> how many txqs to use.  Unmodified qemu's will pass NULL, so
> this is recognized and handled as numtxqs=1.
> 
> The number of vhost threads is <= #txqs.  Threads handle more
> than one txq when #txqs is more than MAX_VHOST_THREADS (4).

It is this sharing that prevents us from just reusing multiple vhost
descriptors?  4 seems a bit arbitrary - do you have an explanation
on why this is a good number?


> The same thread handles both RX and TX - tested with tap/bridge
> so far (TBD: needs some changes in macvtap driver to support
> the same).
> 
> I had to convert space->tab in vhost_attach_cgroups* to avoid
> checkpatch errors.


Separate patch pls, I'll apply that right away.

>  
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  drivers/vhost/net.c   |  295 ++++++++++++++++++++++++++--------------
>  drivers/vhost/vhost.c |  225 +++++++++++++++++++-----------
>  drivers/vhost/vhost.h |   39 ++++-
>  3 files changed, 378 insertions(+), 181 deletions(-)
> 
> diff -ruNp org/drivers/vhost/vhost.h new/drivers/vhost/vhost.h
> --- org/drivers/vhost/vhost.h	2011-02-08 09:05:09.000000000 +0530
> +++ new/drivers/vhost/vhost.h	2011-02-28 11:48:06.000000000 +0530
> @@ -35,11 +35,11 @@ struct vhost_poll {
>  	wait_queue_t              wait;
>  	struct vhost_work	  work;
>  	unsigned long		  mask;
> -	struct vhost_dev	 *dev;
> +	struct vhost_virtqueue	  *vq;  /* points back to vq */
>  };
>  
>  void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
> -		     unsigned long mask, struct vhost_dev *dev);
> +		     unsigned long mask, struct vhost_virtqueue *vq);
>  void vhost_poll_start(struct vhost_poll *poll, struct file *file);
>  void vhost_poll_stop(struct vhost_poll *poll);
>  void vhost_poll_flush(struct vhost_poll *poll);
> @@ -108,8 +108,14 @@ struct vhost_virtqueue {
>  	/* Log write descriptors */
>  	void __user *log_base;
>  	struct vhost_log *log;
> +	struct task_struct *worker; /* worker for this vq */
> +	spinlock_t *work_lock;	/* points to a dev->work_lock[] entry */
> +	struct list_head *work_list;	/* points to a dev->work_list[] entry */
> +	int qnum;	/* 0 for RX, 1 -> n-1 for TX */

Is this right?

>  };
>  
> +#define MAX_VHOST_THREADS	4
> +
>  struct vhost_dev {
>  	/* Readers use RCU to access memory table pointer
>  	 * log base pointer and features.
> @@ -122,12 +128,33 @@ struct vhost_dev {
>  	int nvqs;
>  	struct file *log_file;
>  	struct eventfd_ctx *log_ctx;
> -	spinlock_t work_lock;
> -	struct list_head work_list;
> -	struct task_struct *worker;
> +	spinlock_t *work_lock[MAX_VHOST_THREADS];
> +	struct list_head *work_list[MAX_VHOST_THREADS];

This looks a bit strange. Won't sticking everything in a single
array of structures rather than multiple arrays be better for cache
utilization?

>  };
>  
> -long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
> +/*
> + * Return maximum number of vhost threads needed to handle RX & TX.
> + * Upto MAX_VHOST_THREADS are started, and threads can be shared
> + * among different vq's if numtxqs > MAX_VHOST_THREADS.
> + */
> +static inline int get_nvhosts(int nvqs)

nvhosts -> nthreads?

> +{
> +	return min_t(int, nvqs / 2, MAX_VHOST_THREADS);
> +}
> +
> +/*
> + * Get index of an existing thread that will handle this txq/rxq.
> + * The same thread handles both rx[index] and tx[index].
> + */
> +static inline int vhost_get_thread_index(int index, int numtxqs, int nvhosts)
> +{
> +	return (index % numtxqs) % nvhosts;
> +}
> +

As the only caller passes MAX_VHOST_THREADS,
just use that?

> +int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs);
> +void vhost_free_vqs(struct vhost_dev *dev);
> +long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs,
> +		    int nvhosts);
>  long vhost_dev_check_owner(struct vhost_dev *);
>  long vhost_dev_reset_owner(struct vhost_dev *);
>  void vhost_dev_cleanup(struct vhost_dev *);
> diff -ruNp org/drivers/vhost/net.c new/drivers/vhost/net.c
> --- org/drivers/vhost/net.c	2011-02-08 09:05:09.000000000 +0530
> +++ new/drivers/vhost/net.c	2011-02-28 11:48:53.000000000 +0530
> @@ -32,12 +32,6 @@
>   * Using this limit prevents one virtqueue from starving others. */
>  #define VHOST_NET_WEIGHT 0x80000
>  
> -enum {
> -	VHOST_NET_VQ_RX = 0,
> -	VHOST_NET_VQ_TX = 1,
> -	VHOST_NET_VQ_MAX = 2,
> -};
> -
>  enum vhost_net_poll_state {
>  	VHOST_NET_POLL_DISABLED = 0,
>  	VHOST_NET_POLL_STARTED = 1,
> @@ -46,12 +40,13 @@ enum vhost_net_poll_state {
>  
>  struct vhost_net {
>  	struct vhost_dev dev;
> -	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
> -	struct vhost_poll poll[VHOST_NET_VQ_MAX];
> +	struct vhost_virtqueue *vqs;
> +	struct vhost_poll *poll;
> +	struct socket **socks;
>  	/* Tells us whether we are polling a socket for TX.
>  	 * We only do this when socket buffer fills up.
>  	 * Protected by tx vq lock. */
> -	enum vhost_net_poll_state tx_poll_state;
> +	enum vhost_net_poll_state *tx_poll_state;

another array?

>  };
>  
>  /* Pop first len bytes from iovec. Return number of segments used. */
> @@ -91,28 +86,28 @@ static void copy_iovec_hdr(const struct 
>  }
>  
>  /* Caller must have TX VQ lock */
> -static void tx_poll_stop(struct vhost_net *net)
> +static void tx_poll_stop(struct vhost_net *net, int qnum)
>  {
> -	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> +	if (likely(net->tx_poll_state[qnum] != VHOST_NET_POLL_STARTED))
>  		return;
> -	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
> -	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
> +	vhost_poll_stop(&net->poll[qnum]);
> +	net->tx_poll_state[qnum] = VHOST_NET_POLL_STOPPED;
>  }
>  
>  /* Caller must have TX VQ lock */
> -static void tx_poll_start(struct vhost_net *net, struct socket *sock)
> +static void tx_poll_start(struct vhost_net *net, struct socket *sock, int qnum)
>  {
> -	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
> +	if (unlikely(net->tx_poll_state[qnum] != VHOST_NET_POLL_STOPPED))
>  		return;
> -	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
> -	net->tx_poll_state = VHOST_NET_POLL_STARTED;
> +	vhost_poll_start(&net->poll[qnum], sock->file);
> +	net->tx_poll_state[qnum] = VHOST_NET_POLL_STARTED;
>  }
>  
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
> -static void handle_tx(struct vhost_net *net)
> +static void handle_tx(struct vhost_virtqueue *vq)
>  {
> -	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> +	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
>  	unsigned out, in, s;
>  	int head;
>  	struct msghdr msg = {
> @@ -136,7 +131,7 @@ static void handle_tx(struct vhost_net *
>  	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>  	if (wmem >= sock->sk->sk_sndbuf) {
>  		mutex_lock(&vq->mutex);
> -		tx_poll_start(net, sock);
> +		tx_poll_start(net, sock, vq->qnum);
>  		mutex_unlock(&vq->mutex);
>  		return;
>  	}
> @@ -145,7 +140,7 @@ static void handle_tx(struct vhost_net *
>  	vhost_disable_notify(vq);
>  
>  	if (wmem < sock->sk->sk_sndbuf / 2)
> -		tx_poll_stop(net);
> +		tx_poll_stop(net, vq->qnum);
>  	hdr_size = vq->vhost_hlen;
>  
>  	for (;;) {
> @@ -160,7 +155,7 @@ static void handle_tx(struct vhost_net *
>  		if (head == vq->num) {
>  			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>  			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
> -				tx_poll_start(net, sock);
> +				tx_poll_start(net, sock, vq->qnum);
>  				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>  				break;
>  			}
> @@ -190,7 +185,7 @@ static void handle_tx(struct vhost_net *
>  		err = sock->ops->sendmsg(NULL, sock, &msg, len);
>  		if (unlikely(err < 0)) {
>  			vhost_discard_vq_desc(vq, 1);
> -			tx_poll_start(net, sock);
> +			tx_poll_start(net, sock, vq->qnum);
>  			break;
>  		}
>  		if (err != len)
> @@ -282,9 +277,9 @@ err:
>  
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
> -static void handle_rx_big(struct vhost_net *net)
> +static void handle_rx_big(struct vhost_virtqueue *vq,
> +			  struct vhost_net *net)
>  {
> -	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
>  	unsigned out, in, log, s;
>  	int head;
>  	struct vhost_log *vq_log;
> @@ -392,9 +387,9 @@ static void handle_rx_big(struct vhost_n
>  
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
> -static void handle_rx_mergeable(struct vhost_net *net)
> +static void handle_rx_mergeable(struct vhost_virtqueue *vq,
> +				struct vhost_net *net)
>  {
> -	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
>  	unsigned uninitialized_var(in), log;
>  	struct vhost_log *vq_log;
>  	struct msghdr msg = {
> @@ -498,99 +493,196 @@ static void handle_rx_mergeable(struct v
>  	mutex_unlock(&vq->mutex);
>  }
>  
> -static void handle_rx(struct vhost_net *net)
> +static void handle_rx(struct vhost_virtqueue *vq)
>  {
> +	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
> +
>  	if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF))
> -		handle_rx_mergeable(net);
> +		handle_rx_mergeable(vq, net);
>  	else
> -		handle_rx_big(net);
> +		handle_rx_big(vq, net);
>  }
>  
>  static void handle_tx_kick(struct vhost_work *work)
>  {
>  	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
>  						  poll.work);
> -	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
>  
> -	handle_tx(net);
> +	handle_tx(vq);
>  }
>  
>  static void handle_rx_kick(struct vhost_work *work)
>  {
>  	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
>  						  poll.work);
> -	struct vhost_net *net = container_of(vq->dev, struct vhost_net, dev);
>  
> -	handle_rx(net);
> +	handle_rx(vq);
>  }
>  
>  static void handle_tx_net(struct vhost_work *work)
>  {
> -	struct vhost_net *net = container_of(work, struct vhost_net,
> -					     poll[VHOST_NET_VQ_TX].work);
> -	handle_tx(net);
> +	struct vhost_virtqueue *vq = container_of(work, struct vhost_poll,
> +						  work)->vq;
> +
> +	handle_tx(vq);
>  }
>  
>  static void handle_rx_net(struct vhost_work *work)
>  {
> -	struct vhost_net *net = container_of(work, struct vhost_net,
> -					     poll[VHOST_NET_VQ_RX].work);
> -	handle_rx(net);
> +	struct vhost_virtqueue *vq = container_of(work, struct vhost_poll,
> +						  work)->vq;
> +
> +	handle_rx(vq);
>  }
>  
> -static int vhost_net_open(struct inode *inode, struct file *f)
> +void vhost_free_vqs(struct vhost_dev *dev)
>  {
> -	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
> -	struct vhost_dev *dev;
> -	int r;
> +	struct vhost_net *n = container_of(dev, struct vhost_net, dev);
> +	int i;
>  
> -	if (!n)
> -		return -ENOMEM;
> +	if (!n->vqs)
> +		return;
>  
> -	dev = &n->dev;
> -	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
> -	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
> -	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
> -	if (r < 0) {
> -		kfree(n);
> -		return r;
> +	/* vhost_net_open does kzalloc, so this loop will not panic */
> +	for (i = 0; i < get_nvhosts(dev->nvqs); i++) {
> +		kfree(dev->work_list[i]);
> +		kfree(dev->work_lock[i]);
>  	}
>  
> -	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
> -	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
> -	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> +	kfree(n->socks);
> +	kfree(n->tx_poll_state);
> +	kfree(n->poll);
> +	kfree(n->vqs);
> +
> +	/*
> +	 * Reset so that vhost_net_release (which gets called when
> +	 * vhost_dev_set_owner() call fails) will notice.
> +	 */
> +	n->vqs = NULL;
> +}
>  
> -	f->private_data = n;
> +int vhost_setup_vqs(struct vhost_dev *dev, int numtxqs)
> +{
> +	struct vhost_net *n = container_of(dev, struct vhost_net, dev);
> +	int nvhosts;
> +	int i, nvqs;
> +	int ret = -ENOMEM;
> +
> +	if (numtxqs < 0 || numtxqs > VIRTIO_MAX_TXQS)
> +		return -EINVAL;
> +
> +	if (numtxqs == 0) {
> +		/* Old qemu doesn't pass arguments to set_owner, use 1 txq */
> +		numtxqs = 1;
> +	}
> +
> +	/* Get total number of virtqueues */
> +	nvqs = numtxqs * 2;
> +
> +	n->vqs = kmalloc(nvqs * sizeof(*n->vqs), GFP_KERNEL);
> +	n->poll = kmalloc(nvqs * sizeof(*n->poll), GFP_KERNEL);
> +	n->socks = kmalloc(nvqs * sizeof(*n->socks), GFP_KERNEL);
> +	n->tx_poll_state = kmalloc(nvqs * sizeof(*n->tx_poll_state),
> +				   GFP_KERNEL);
> +	if (!n->vqs || !n->poll || !n->socks || !n->tx_poll_state)
> +		goto err;
> +
> +	/* Get total number of vhost threads */
> +	nvhosts = get_nvhosts(nvqs);
> +
> +	for (i = 0; i < nvhosts; i++) {
> +		dev->work_lock[i] = kmalloc(sizeof(*dev->work_lock[i]),
> +					    GFP_KERNEL);
> +		dev->work_list[i] = kmalloc(sizeof(*dev->work_list[i]),
> +					    GFP_KERNEL);
> +		if (!dev->work_lock[i] || !dev->work_list[i])
> +			goto err;
> +		if (((unsigned long) dev->work_lock[i] & (SMP_CACHE_BYTES - 1))
> +		    ||
> +		    ((unsigned long) dev->work_list[i] & SMP_CACHE_BYTES - 1))
> +			pr_debug("Unaligned buffer @ %d - Lock: %p List: %p\n",
> +				 i, dev->work_lock[i], dev->work_list[i]);
> +	}
> +
> +	/* 'numtxqs' RX followed by 'numtxqs' TX queues */
> +	for (i = 0; i < numtxqs; i++)
> +		n->vqs[i].handle_kick = handle_rx_kick;
> +	for (; i < nvqs; i++)
> +		n->vqs[i].handle_kick = handle_tx_kick;
> +
> +	ret = vhost_dev_init(dev, n->vqs, nvqs, nvhosts);
> +	if (ret < 0)
> +		goto err;
> +
> +	for (i = 0; i < numtxqs; i++)
> +		vhost_poll_init(&n->poll[i], handle_rx_net, POLLIN, &n->vqs[i]);
> +
> +	for (; i < nvqs; i++) {
> +		vhost_poll_init(&n->poll[i], handle_tx_net, POLLOUT,
> +				&n->vqs[i]);
> +		n->tx_poll_state[i] = VHOST_NET_POLL_DISABLED;
> +	}
>  
>  	return 0;
> +
> +err:
> +	/* Free all pointers that may have been allocated */
> +	vhost_free_vqs(dev);
> +
> +	return ret;
> +}
> +
> +static int vhost_net_open(struct inode *inode, struct file *f)
> +{
> +	struct vhost_net *n = kzalloc(sizeof *n, GFP_KERNEL);
> +	int ret = -ENOMEM;
> +
> +	if (n) {
> +		struct vhost_dev *dev = &n->dev;
> +
> +		f->private_data = n;
> +		mutex_init(&dev->mutex);
> +
> +		/* Defer all other initialization till user does SET_OWNER */
> +		ret = 0;
> +	}
> +
> +	return ret;
>  }
>  
>  static void vhost_net_disable_vq(struct vhost_net *n,
>  				 struct vhost_virtqueue *vq)
>  {
> +	int qnum = vq->qnum;
> +
>  	if (!vq->private_data)
>  		return;
> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> -		tx_poll_stop(n);
> -		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> -	} else
> -		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
> +	if (qnum < n->dev.nvqs / 2) {
> +		/* qnum is less than half, we are RX */
> +		vhost_poll_stop(&n->poll[qnum]);
> +	} else {	/* otherwise we are TX */
> +		tx_poll_stop(n, qnum);
> +		n->tx_poll_state[qnum] = VHOST_NET_POLL_DISABLED;
> +	}
>  }
>  
>  static void vhost_net_enable_vq(struct vhost_net *n,
>  				struct vhost_virtqueue *vq)
>  {
>  	struct socket *sock;
> +	int qnum = vq->qnum;
>  
>  	sock = rcu_dereference_protected(vq->private_data,
>  					 lockdep_is_held(&vq->mutex));
>  	if (!sock)
>  		return;
> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> -		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
> -		tx_poll_start(n, sock);
> -	} else
> -		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
> +	if (qnum < n->dev.nvqs / 2) {
> +		/* qnum is less than half, we are RX */
> +		vhost_poll_start(&n->poll[qnum], sock->file);
> +	} else {
> +		n->tx_poll_state[qnum] = VHOST_NET_POLL_STOPPED;
> +		tx_poll_start(n, sock, qnum);
> +	}
>  }
>  
>  static struct socket *vhost_net_stop_vq(struct vhost_net *n,
> @@ -607,11 +699,12 @@ static struct socket *vhost_net_stop_vq(
>  	return sock;
>  }
>  
> -static void vhost_net_stop(struct vhost_net *n, struct socket **tx_sock,
> -			   struct socket **rx_sock)
> +static void vhost_net_stop(struct vhost_net *n)
>  {
> -	*tx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_TX);
> -	*rx_sock = vhost_net_stop_vq(n, n->vqs + VHOST_NET_VQ_RX);
> +	int i;
> +
> +	for (i = n->dev.nvqs - 1; i >= 0; i--)
> +		n->socks[i] = vhost_net_stop_vq(n, &n->vqs[i]);
>  }
>  
>  static void vhost_net_flush_vq(struct vhost_net *n, int index)
> @@ -622,26 +715,33 @@ static void vhost_net_flush_vq(struct vh
>  
>  static void vhost_net_flush(struct vhost_net *n)
>  {
> -	vhost_net_flush_vq(n, VHOST_NET_VQ_TX);
> -	vhost_net_flush_vq(n, VHOST_NET_VQ_RX);
> +	int i;
> +
> +	for (i = n->dev.nvqs - 1; i >= 0; i--)
> +		vhost_net_flush_vq(n, i);
>  }
>  
>  static int vhost_net_release(struct inode *inode, struct file *f)
>  {
>  	struct vhost_net *n = f->private_data;
> -	struct socket *tx_sock;
> -	struct socket *rx_sock;
> +	struct vhost_dev *dev = &n->dev;
> +	int i;
>  
> -	vhost_net_stop(n, &tx_sock, &rx_sock);
> +	vhost_net_stop(n);
>  	vhost_net_flush(n);
> -	vhost_dev_cleanup(&n->dev);
> -	if (tx_sock)
> -		fput(tx_sock->file);
> -	if (rx_sock)
> -		fput(rx_sock->file);
> +	vhost_dev_cleanup(dev);
> +
> +	for (i = n->dev.nvqs - 1; i >= 0; i--)
> +		if (n->socks[i])
> +			fput(n->socks[i]->file);
> +
>  	/* We do an extra flush before freeing memory,
>  	 * since jobs can re-queue themselves. */
>  	vhost_net_flush(n);
> +
> +	/* Free all old pointers */
> +	vhost_free_vqs(dev);
> +
>  	kfree(n);
>  	return 0;
>  }
> @@ -719,7 +819,7 @@ static long vhost_net_set_backend(struct
>  	if (r)
>  		goto err;
>  
> -	if (index >= VHOST_NET_VQ_MAX) {
> +	if (index >= n->dev.nvqs) {
>  		r = -ENOBUFS;
>  		goto err;
>  	}
> @@ -741,9 +841,9 @@ static long vhost_net_set_backend(struct
>  	oldsock = rcu_dereference_protected(vq->private_data,
>  					    lockdep_is_held(&vq->mutex));
>  	if (sock != oldsock) {
> -                vhost_net_disable_vq(n, vq);
> -                rcu_assign_pointer(vq->private_data, sock);
> -                vhost_net_enable_vq(n, vq);
> +		vhost_net_disable_vq(n, vq);
> +		rcu_assign_pointer(vq->private_data, sock);
> +		vhost_net_enable_vq(n, vq);
>  	}
>  
>  	mutex_unlock(&vq->mutex);
> @@ -765,22 +865,25 @@ err:
>  
>  static long vhost_net_reset_owner(struct vhost_net *n)
>  {
> -	struct socket *tx_sock = NULL;
> -	struct socket *rx_sock = NULL;
>  	long err;
> +	int i;
> +
>  	mutex_lock(&n->dev.mutex);
>  	err = vhost_dev_check_owner(&n->dev);
> -	if (err)
> -		goto done;
> -	vhost_net_stop(n, &tx_sock, &rx_sock);
> +	if (err) {
> +		mutex_unlock(&n->dev.mutex);
> +		return err;
> +	}
> +
> +	vhost_net_stop(n);
>  	vhost_net_flush(n);
>  	err = vhost_dev_reset_owner(&n->dev);
> -done:
>  	mutex_unlock(&n->dev.mutex);
> -	if (tx_sock)
> -		fput(tx_sock->file);
> -	if (rx_sock)
> -		fput(rx_sock->file);
> +
> +	for (i = n->dev.nvqs - 1; i >= 0; i--)
> +		if (n->socks[i])
> +			fput(n->socks[i]->file);
> +
>  	return err;
>  }
>  
> @@ -809,7 +912,7 @@ static int vhost_net_set_features(struct
>  	}
>  	n->dev.acked_features = features;
>  	smp_wmb();
> -	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
> +	for (i = 0; i < n->dev.nvqs; ++i) {
>  		mutex_lock(&n->vqs[i].mutex);
>  		n->vqs[i].vhost_hlen = vhost_hlen;
>  		n->vqs[i].sock_hlen = sock_hlen;
> diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
> --- org/drivers/vhost/vhost.c	2011-01-19 20:01:29.000000000 +0530
> +++ new/drivers/vhost/vhost.c	2011-02-25 21:18:14.000000000 +0530
> @@ -70,12 +70,12 @@ static void vhost_work_init(struct vhost
>  
>  /* Init poll structure */
>  void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
> -		     unsigned long mask, struct vhost_dev *dev)
> +		     unsigned long mask, struct vhost_virtqueue *vq)
>  {
>  	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
>  	init_poll_funcptr(&poll->table, vhost_poll_func);
>  	poll->mask = mask;
> -	poll->dev = dev;
> +	poll->vq = vq;
>  
>  	vhost_work_init(&poll->work, fn);
>  }
> @@ -97,29 +97,30 @@ void vhost_poll_stop(struct vhost_poll *
>  	remove_wait_queue(poll->wqh, &poll->wait);
>  }
>  
> -static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
> -				unsigned seq)
> +static bool vhost_work_seq_done(struct vhost_virtqueue *vq,
> +				struct vhost_work *work, unsigned seq)
>  {
>  	int left;
> -	spin_lock_irq(&dev->work_lock);
> +	spin_lock_irq(vq->work_lock);
>  	left = seq - work->done_seq;
> -	spin_unlock_irq(&dev->work_lock);
> +	spin_unlock_irq(vq->work_lock);
>  	return left <= 0;
>  }
>  
> -static void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
> +static void vhost_work_flush(struct vhost_virtqueue *vq,
> +			     struct vhost_work *work)
>  {
>  	unsigned seq;
>  	int flushing;
>  
> -	spin_lock_irq(&dev->work_lock);
> +	spin_lock_irq(vq->work_lock);
>  	seq = work->queue_seq;
>  	work->flushing++;
> -	spin_unlock_irq(&dev->work_lock);
> -	wait_event(work->done, vhost_work_seq_done(dev, work, seq));
> -	spin_lock_irq(&dev->work_lock);
> +	spin_unlock_irq(vq->work_lock);
> +	wait_event(work->done, vhost_work_seq_done(vq, work, seq));
> +	spin_lock_irq(vq->work_lock);
>  	flushing = --work->flushing;
> -	spin_unlock_irq(&dev->work_lock);
> +	spin_unlock_irq(vq->work_lock);
>  	BUG_ON(flushing < 0);
>  }
>  
> @@ -127,26 +128,26 @@ static void vhost_work_flush(struct vhos
>   * locks that are also used by the callback. */
>  void vhost_poll_flush(struct vhost_poll *poll)
>  {
> -	vhost_work_flush(poll->dev, &poll->work);
> +	vhost_work_flush(poll->vq, &poll->work);
>  }
>  
> -static inline void vhost_work_queue(struct vhost_dev *dev,
> +static inline void vhost_work_queue(struct vhost_virtqueue *vq,
>  				    struct vhost_work *work)
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&dev->work_lock, flags);
> +	spin_lock_irqsave(vq->work_lock, flags);
>  	if (list_empty(&work->node)) {
> -		list_add_tail(&work->node, &dev->work_list);
> +		list_add_tail(&work->node, vq->work_list);
>  		work->queue_seq++;
> -		wake_up_process(dev->worker);
> +		wake_up_process(vq->worker);
>  	}
> -	spin_unlock_irqrestore(&dev->work_lock, flags);
> +	spin_unlock_irqrestore(vq->work_lock, flags);
>  }
>  
>  void vhost_poll_queue(struct vhost_poll *poll)
>  {
> -	vhost_work_queue(poll->dev, &poll->work);
> +	vhost_work_queue(poll->vq, &poll->work);
>  }
>  
>  static void vhost_vq_reset(struct vhost_dev *dev,
> @@ -176,17 +177,17 @@ static void vhost_vq_reset(struct vhost_
>  
>  static int vhost_worker(void *data)
>  {
> -	struct vhost_dev *dev = data;
> +	struct vhost_virtqueue *vq = data;
>  	struct vhost_work *work = NULL;
>  	unsigned uninitialized_var(seq);
>  
> -	use_mm(dev->mm);
> +	use_mm(vq->dev->mm);
>  
>  	for (;;) {
>  		/* mb paired w/ kthread_stop */
>  		set_current_state(TASK_INTERRUPTIBLE);
>  
> -		spin_lock_irq(&dev->work_lock);
> +		spin_lock_irq(vq->work_lock);
>  		if (work) {
>  			work->done_seq = seq;
>  			if (work->flushing)
> @@ -194,18 +195,18 @@ static int vhost_worker(void *data)
>  		}
>  
>  		if (kthread_should_stop()) {
> -			spin_unlock_irq(&dev->work_lock);
> +			spin_unlock_irq(vq->work_lock);
>  			__set_current_state(TASK_RUNNING);
>  			break;
>  		}
> -		if (!list_empty(&dev->work_list)) {
> -			work = list_first_entry(&dev->work_list,
> +		if (!list_empty(vq->work_list)) {
> +			work = list_first_entry(vq->work_list,
>  						struct vhost_work, node);
>  			list_del_init(&work->node);
>  			seq = work->queue_seq;
>  		} else
>  			work = NULL;
> -		spin_unlock_irq(&dev->work_lock);
> +		spin_unlock_irq(vq->work_lock);
>  
>  		if (work) {
>  			__set_current_state(TASK_RUNNING);
> @@ -214,7 +215,7 @@ static int vhost_worker(void *data)
>  			schedule();
>  
>  	}
> -	unuse_mm(dev->mm);
> +	unuse_mm(vq->dev->mm);
>  	return 0;
>  }
>  
> @@ -258,7 +259,7 @@ static void vhost_dev_free_iovecs(struct
>  }
>  
>  long vhost_dev_init(struct vhost_dev *dev,
> -		    struct vhost_virtqueue *vqs, int nvqs)
> +		    struct vhost_virtqueue *vqs, int nvqs, int nvhosts)
>  {
>  	int i;
>  
> @@ -269,20 +270,34 @@ long vhost_dev_init(struct vhost_dev *de
>  	dev->log_file = NULL;
>  	dev->memory = NULL;
>  	dev->mm = NULL;
> -	spin_lock_init(&dev->work_lock);
> -	INIT_LIST_HEAD(&dev->work_list);
> -	dev->worker = NULL;
>  
>  	for (i = 0; i < dev->nvqs; ++i) {
> -		dev->vqs[i].log = NULL;
> -		dev->vqs[i].indirect = NULL;
> -		dev->vqs[i].heads = NULL;
> -		dev->vqs[i].dev = dev;
> -		mutex_init(&dev->vqs[i].mutex);
> +		struct vhost_virtqueue *vq = &dev->vqs[i];
> +		int j;
> +
> +		if (i < nvhosts) {
> +			spin_lock_init(dev->work_lock[i]);
> +			INIT_LIST_HEAD(dev->work_list[i]);
> +			j = i;
> +		} else {
> +			/* Share work with another thread */
> +			j = vhost_get_thread_index(i, nvqs / 2, nvhosts);
> +		}
> +
> +		vq->work_lock = dev->work_lock[j];
> +		vq->work_list = dev->work_list[j];
> +
> +		vq->worker = NULL;
> +		vq->qnum = i;
> +		vq->log = NULL;
> +		vq->indirect = NULL;
> +		vq->heads = NULL;
> +		vq->dev = dev;
> +		mutex_init(&vq->mutex);
>  		vhost_vq_reset(dev, dev->vqs + i);
> -		if (dev->vqs[i].handle_kick)
> -			vhost_poll_init(&dev->vqs[i].poll,
> -					dev->vqs[i].handle_kick, POLLIN, dev);
> +		if (vq->handle_kick)
> +			vhost_poll_init(&vq->poll,
> +					vq->handle_kick, POLLIN, vq);
>  	}
>  
>  	return 0;
> @@ -296,65 +311,124 @@ long vhost_dev_check_owner(struct vhost_
>  }
>  
>  struct vhost_attach_cgroups_struct {
> -        struct vhost_work work;
> -        struct task_struct *owner;
> -        int ret;
> +	struct vhost_work work;
> +	struct task_struct *owner;
> +	int ret;
>  };
>  
>  static void vhost_attach_cgroups_work(struct vhost_work *work)
>  {
> -        struct vhost_attach_cgroups_struct *s;
> -        s = container_of(work, struct vhost_attach_cgroups_struct, work);
> -        s->ret = cgroup_attach_task_all(s->owner, current);
> +	struct vhost_attach_cgroups_struct *s;
> +	s = container_of(work, struct vhost_attach_cgroups_struct, work);
> +	s->ret = cgroup_attach_task_all(s->owner, current);
> +}
> +
> +static int vhost_attach_cgroups(struct vhost_virtqueue *vq)
> +{
> +	struct vhost_attach_cgroups_struct attach;
> +	attach.owner = current;
> +	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
> +	vhost_work_queue(vq, &attach.work);
> +	vhost_work_flush(vq, &attach.work);
> +	return attach.ret;
> +}
> +
> +static void __vhost_stop_workers(struct vhost_dev *dev, int nvhosts)
> +{
> +	int i;
> +
> +	for (i = 0; i < nvhosts; i++) {
> +		WARN_ON(!list_empty(dev->vqs[i].work_list));
> +		if (dev->vqs[i].worker) {
> +			kthread_stop(dev->vqs[i].worker);
> +			dev->vqs[i].worker = NULL;
> +		}
> +	}
> +
> +	if (dev->mm)
> +		mmput(dev->mm);
> +	dev->mm = NULL;
> +}
> +
> +static void vhost_stop_workers(struct vhost_dev *dev)
> +{
> +	__vhost_stop_workers(dev, get_nvhosts(dev->nvqs));
>  }
>  
> -static int vhost_attach_cgroups(struct vhost_dev *dev)
> -{
> -        struct vhost_attach_cgroups_struct attach;
> -        attach.owner = current;
> -        vhost_work_init(&attach.work, vhost_attach_cgroups_work);
> -        vhost_work_queue(dev, &attach.work);
> -        vhost_work_flush(dev, &attach.work);
> -        return attach.ret;
> +static int vhost_start_workers(struct vhost_dev *dev)
> +{
> +	int nvhosts = get_nvhosts(dev->nvqs);
> +	int i, err;
> +
> +	for (i = 0; i < dev->nvqs; ++i) {
> +		struct vhost_virtqueue *vq = &dev->vqs[i];
> +
> +		if (i < nvhosts) {
> +			/* Start a new thread */
> +			vq->worker = kthread_create(vhost_worker, vq,
> +						    "vhost-%d-%d",
> +						    current->pid, i);
> +			if (IS_ERR(vq->worker)) {
> +				i--;	/* no thread to clean at this index */
> +				err = PTR_ERR(vq->worker);
> +				goto err;
> +			}
> +
> +			wake_up_process(vq->worker);
> +
> +			/* avoid contributing to loadavg */
> +			err = vhost_attach_cgroups(vq);
> +			if (err)
> +				goto err;
> +		} else {
> +			/* Share work with an existing thread */
> +			int j = vhost_get_thread_index(i, dev->nvqs / 2,
> +						       nvhosts);
> +
> +			vq->worker = dev->vqs[j].worker;
> +		}
> +	}
> +	return 0;
> +
> +err:
> +	__vhost_stop_workers(dev, i);
> +	return err;
>  }
>  
>  /* Caller should have device mutex */
> -static long vhost_dev_set_owner(struct vhost_dev *dev)
> +static long vhost_dev_set_owner(struct vhost_dev *dev, int numtxqs)
>  {
> -	struct task_struct *worker;
>  	int err;
>  	/* Is there an owner already? */
>  	if (dev->mm) {
>  		err = -EBUSY;
>  		goto err_mm;
>  	}
> +
> +	err = vhost_setup_vqs(dev, numtxqs);
> +	if (err)
> +		goto err_mm;
> +
>  	/* No owner, become one */
>  	dev->mm = get_task_mm(current);
> -	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
> -	if (IS_ERR(worker)) {
> -		err = PTR_ERR(worker);
> -		goto err_worker;
> -	}
> -
> -	dev->worker = worker;
> -	wake_up_process(worker);	/* avoid contributing to loadavg */
>  
> -	err = vhost_attach_cgroups(dev);
> +	/* Start threads */
> +	err =  vhost_start_workers(dev);
>  	if (err)
> -		goto err_cgroup;
> +		goto free_vqs;
>  
>  	err = vhost_dev_alloc_iovecs(dev);
>  	if (err)
> -		goto err_cgroup;
> +		goto clean_workers;
>  
>  	return 0;
> -err_cgroup:
> -	kthread_stop(worker);
> -	dev->worker = NULL;
> -err_worker:
> +clean_workers:
> +	vhost_stop_workers(dev);
> +free_vqs:
>  	if (dev->mm)
>  		mmput(dev->mm);
>  	dev->mm = NULL;
> +	vhost_free_vqs(dev);
>  err_mm:
>  	return err;
>  }
> @@ -408,14 +482,7 @@ void vhost_dev_cleanup(struct vhost_dev 
>  	kfree(rcu_dereference_protected(dev->memory,
>  					lockdep_is_held(&dev->mutex)));
>  	RCU_INIT_POINTER(dev->memory, NULL);
> -	WARN_ON(!list_empty(&dev->work_list));
> -	if (dev->worker) {
> -		kthread_stop(dev->worker);
> -		dev->worker = NULL;
> -	}
> -	if (dev->mm)
> -		mmput(dev->mm);
> -	dev->mm = NULL;
> +	vhost_stop_workers(dev);
>  }
>  
>  static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
> @@ -775,7 +842,7 @@ long vhost_dev_ioctl(struct vhost_dev *d
>  
>  	/* If you are not the owner, you can become one */
>  	if (ioctl == VHOST_SET_OWNER) {
> -		r = vhost_dev_set_owner(d);
> +		r = vhost_dev_set_owner(d, arg);
>  		goto done;
>  	}
>  
