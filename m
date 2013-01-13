From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V3 2/2] vhost: handle polling errors
Date: Sun, 13 Jan 2013 13:10:35 +0200
Message-ID: <20130113111035.GA23431@redhat.com>
References: <1357456718-3072-1-git-send-email-jasowang@redhat.com>
	<1357456718-3072-3-git-send-email-jasowang@redhat.com>
	<20130106132201.GC18612@redhat.com> <50EA5139.7000904@redhat.com>
	<20130107145559.GA5901@redhat.com> <50EAE400.6030301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <50EAE400.6030301@redhat.com>
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

On Mon, Jan 07, 2013 at 11:04:32PM +0800, Jason Wang wrote:
> On 01/07/2013 10:55 PM, Michael S. Tsirkin wrote:
> > On Mon, Jan 07, 2013 at 12:38:17PM +0800, Jason Wang wrote:
> >> On 01/06/2013 09:22 PM, Michael S. Tsirkin wrote:
> >>> On Sun, Jan 06, 2013 at 03:18:38PM +0800, Jason Wang wrote:
> >>>> Polling errors were ignored by vhost/vhost_net, this may lead to crash when
> >>>> trying to remove vhost from waitqueue when after the polling is failed. Solve
> >>>> this problem by:
> >>>>
> >>>> - checking the poll->wqh before trying to remove from waitqueue
> >>>> - report an error when poll() returns a POLLERR in vhost_start_poll()
> >>>> - report an error when vhost_start_poll() fails in
> >>>>   vhost_vring_ioctl()/vhost_net_set_backend() which is used to notify the
> >>>>   failure to userspace.
> >>>> - report an error in the data path in vhost_net when meet polling errors.
> >>>>
> >>>> After those changes, we can safely drop the tx polling state in vhost_net since
> >>>> it was replaced by the checking of poll->wqh.
> >>>>
> >>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>>> ---
> >>>>  drivers/vhost/net.c   |   74 ++++++++++++++++--------------------------------
> >>>>  drivers/vhost/vhost.c |   31 +++++++++++++++-----
> >>>>  drivers/vhost/vhost.h |    2 +-
> >>>>  3 files changed, 49 insertions(+), 58 deletions(-)
> >>>>
> >>>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >>>> index d10ad6f..125c1e5 100644
> >>>> --- a/drivers/vhost/net.c
> >>>> +++ b/drivers/vhost/net.c
> >>>> @@ -64,20 +64,10 @@ enum {
> >>>>  	VHOST_NET_VQ_MAX = 2,
> >>>>  };
> >>>>  
> >>>> -enum vhost_net_poll_state {
> >>>> -	VHOST_NET_POLL_DISABLED = 0,
> >>>> -	VHOST_NET_POLL_STARTED = 1,
> >>>> -	VHOST_NET_POLL_STOPPED = 2,
> >>>> -};
> >>>> -
> >>>>  struct vhost_net {
> >>>>  	struct vhost_dev dev;
> >>>>  	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
> >>>>  	struct vhost_poll poll[VHOST_NET_VQ_MAX];
> >>>> -	/* Tells us whether we are polling a socket for TX.
> >>>> -	 * We only do this when socket buffer fills up.
> >>>> -	 * Protected by tx vq lock. */
> >>>> -	enum vhost_net_poll_state tx_poll_state;
> >>>>  	/* Number of TX recently submitted.
> >>>>  	 * Protected by tx vq lock. */
> >>>>  	unsigned tx_packets;
> >>>> @@ -155,24 +145,6 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
> >>>>  	}
> >>>>  }
> >>>>  
> >>>> -/* Caller must have TX VQ lock */
> >>>> -static void tx_poll_stop(struct vhost_net *net)
> >>>> -{
> >>>> -	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> >>>> -		return;
> >>>> -	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
> >>>> -	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
> >>>> -}
> >>>> -
> >>>> -/* Caller must have TX VQ lock */
> >>>> -static void tx_poll_start(struct vhost_net *net, struct socket *sock)
> >>>> -{
> >>>> -	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
> >>>> -		return;
> >>>> -	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
> >>>> -	net->tx_poll_state = VHOST_NET_POLL_STARTED;
> >>>> -}
> >>>> -
> >>>>  /* In case of DMA done not in order in lower device driver for some reason.
> >>>>   * upend_idx is used to track end of used idx, done_idx is used to track head
> >>>>   * of used idx. Once lower device DMA done contiguously, we will signal KVM
> >>>> @@ -227,6 +199,7 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> >>>>  static void handle_tx(struct vhost_net *net)
> >>>>  {
> >>>>  	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> >>>> +	struct vhost_poll *poll = net->poll + VHOST_NET_VQ_TX;
> >>>>  	unsigned out, in, s;
> >>>>  	int head;
> >>>>  	struct msghdr msg = {
> >>>> @@ -252,7 +225,8 @@ static void handle_tx(struct vhost_net *net)
> >>>>  	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> >>>>  	if (wmem >= sock->sk->sk_sndbuf) {
> >>>>  		mutex_lock(&vq->mutex);
> >>>> -		tx_poll_start(net, sock);
> >>>> +		if (vhost_poll_start(poll, sock->file))
> >>>> +			vq_err(vq, "Fail to start TX polling\n");
> >>> s/Fail/Failed/
> >>>
> >>> A question though: how can this happen? Could you clarify please?
> >>> Maybe we can find a way to prevent this error?
> >> Two conditions I think this can happen:
> >>
> >> 1) a buggy userspace disable a queue through TUNSETQUEUE
> >> 2) the net device were gone
> >>
> >> For 1, looks like we can delay the disabling until the refcnt goes to
> >> zero. For 2 may needs more changes.
> > I'd expect keeping a socket reference would prevent both issues.
> > Doesn't it?
> 
> Doesn't work for 2 I think, the socket didn't hold a refcnt of the
> device, so the device can go away at anytime. Although we can change
> this, but it's the behaviour before multiqueue support.

Hmm there's one scenario that does seem to
trigger this: queue can get disabled
and then poll fails.

Is this the only issue?


> >
> >> Not sure it's worth to do this work,
> >> maybe a warning is enough just like other failure.
> > With other failures, you normally can correct the error then
> > kick to have it restart. This is soomething thagt would not
> > work here.
> 
> If userspace is wrote correctly, (e.g passing a fd with correct state)
> it can also be corrected.
> >
> >>>>  		mutex_unlock(&vq->mutex);
> >>>>  		return;
> >>>>  	}
> >>>> @@ -261,7 +235,7 @@ static void handle_tx(struct vhost_net *net)
> >>>>  	vhost_disable_notify(&net->dev, vq);
> >>>>  
> >>>>  	if (wmem < sock->sk->sk_sndbuf / 2)
> >>>> -		tx_poll_stop(net);
> >>>> +		vhost_poll_stop(poll);
> >>>>  	hdr_size = vq->vhost_hlen;
> >>>>  	zcopy = vq->ubufs;
> >>>>  
> >>>> @@ -283,8 +257,10 @@ static void handle_tx(struct vhost_net *net)
> >>>>  
> >>>>  			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> >>>>  			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
> >>>> -				tx_poll_start(net, sock);
> >>>> -				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> >>>> +				if (vhost_poll_start(poll, sock->file))
> >>>> +					vq_err(vq, "Fail to start TX polling\n");
> >>>> +				else
> >>>> +					set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> >>>>  				break;
> >>>>  			}
> >>>>  			/* If more outstanding DMAs, queue the work.
> >>>> @@ -294,8 +270,10 @@ static void handle_tx(struct vhost_net *net)
> >>>>  				    (vq->upend_idx - vq->done_idx) :
> >>>>  				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
> >>>>  			if (unlikely(num_pends > VHOST_MAX_PEND)) {
> >>>> -				tx_poll_start(net, sock);
> >>>> -				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> >>>> +				if (vhost_poll_start(poll, sock->file))
> >>>> +					vq_err(vq, "Fail to start TX polling\n");
> >>>> +				else
> >>>> +					set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> >>>>  				break;
> >>>>  			}
> >>>>  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
> >>>> @@ -360,7 +338,8 @@ static void handle_tx(struct vhost_net *net)
> >>>>  			}
> >>>>  			vhost_discard_vq_desc(vq, 1);
> >>>>  			if (err == -EAGAIN || err == -ENOBUFS)
> >>>> -				tx_poll_start(net, sock);
> >>>> +				if (vhost_poll_start(poll, sock->file))
> >>>> +					vq_err(vq, "Fail to start TX polling\n");
> >>>>  			break;
> >>>>  		}
> >>>>  		if (err != len)
> >>>> @@ -623,7 +602,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
> >>>>  
> >>>>  	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
> >>>>  	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
> >>>> -	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> >>>>  
> >>>>  	f->private_data = n;
> >>>>  
> >>>> @@ -633,29 +611,25 @@ static int vhost_net_open(struct inode *inode, struct file *f)
> >>>>  static void vhost_net_disable_vq(struct vhost_net *n,
> >>>>  				 struct vhost_virtqueue *vq)
> >>>>  {
> >>>> +	struct vhost_poll *poll = n->poll + (vq - n->vqs);
> >>>> +
> >>>>  	if (!vq->private_data)
> >>>>  		return;
> >>>> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> >>>> -		tx_poll_stop(n);
> >>>> -		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> >>>> -	} else
> >>>> -		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
> >>>> +	vhost_poll_stop(poll);
> >>>>  }
> >>>>  
> >>>> -static void vhost_net_enable_vq(struct vhost_net *n,
> >>>> +static int vhost_net_enable_vq(struct vhost_net *n,
> >>>>  				struct vhost_virtqueue *vq)
> >>>>  {
> >>>>  	struct socket *sock;
> >>>> +	struct vhost_poll *poll = n->poll + (vq - n->vqs);
> >>>>  
> >>>>  	sock = rcu_dereference_protected(vq->private_data,
> >>>>  					 lockdep_is_held(&vq->mutex));
> >>>>  	if (!sock)
> >>>> -		return;
> >>>> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> >>>> -		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
> >>>> -		tx_poll_start(n, sock);
> >>>> -	} else
> >>>> -		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
> >>>> +		return 0;
> >>>> +
> >>>> +	return vhost_poll_start(poll, sock->file);
> >>>>  }
> >>>>  
> >>>>  static struct socket *vhost_net_stop_vq(struct vhost_net *n,
> >>>> @@ -833,7 +807,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
> >>>>  		r = vhost_init_used(vq);
> >>>>  		if (r)
> >>>>  			goto err_used;
> >>>> -		vhost_net_enable_vq(n, vq);
> >>>> +		r = vhost_net_enable_vq(n, vq);
> >>>> +		if (r)
> >>>> +			goto err_used;
> >>>>  
> >>>>  		oldubufs = vq->ubufs;
> >>>>  		vq->ubufs = ubufs;
> >>>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> >>>> index 34389f7..5c7a466 100644
> >>>> --- a/drivers/vhost/vhost.c
> >>>> +++ b/drivers/vhost/vhost.c
> >>>> @@ -77,26 +77,41 @@ void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
> >>>>  	init_poll_funcptr(&poll->table, vhost_poll_func);
> >>>>  	poll->mask = mask;
> >>>>  	poll->dev = dev;
> >>>> +	poll->wqh = NULL;
> >>>>  
> >>>>  	vhost_work_init(&poll->work, fn);
> >>>>  }
> >>>>  
> >>>> +/* Stop polling a file. After this function returns, it becomes safe to drop the
> >>>> + * file reference. You must also flush afterwards. */
> >>>> +void vhost_poll_stop(struct vhost_poll *poll)
> >>>> +{
> >>>> +	if (poll->wqh) {
> >>>> +		remove_wait_queue(poll->wqh, &poll->wait);
> >>>> +		poll->wqh = NULL;
> >>>> +	}
> >>>> +}
> >>>> +
> >>>>  /* Start polling a file. We add ourselves to file's wait queue. The caller must
> >>>>   * keep a reference to a file until after vhost_poll_stop is called. */
> >>>> -void vhost_poll_start(struct vhost_poll *poll, struct file *file)
> >>>> +int vhost_poll_start(struct vhost_poll *poll, struct file *file)
> >>>>  {
> >>>>  	unsigned long mask;
> >>>> +	int ret = 0;
> >>>> +
> >>>> +	if (poll->wqh)
> >>>> +		return -EBUSY;
> >>>>  
> >>> I think this should return success: we are already polling.
> >>> Otherwise this would trigger a bug below I think.
> >> Ok.
> >>>>  	mask = file->f_op->poll(file, &poll->table);
> >>>>  	if (mask)
> >>>>  		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
> >>>> -}
> >>>>  
> >>>> -/* Stop polling a file. After this function returns, it becomes safe to drop the
> >>>> - * file reference. You must also flush afterwards. */
> >>>> -void vhost_poll_stop(struct vhost_poll *poll)
> >>>> -{
> >>>> -	remove_wait_queue(poll->wqh, &poll->wait);
> >>>> +	if (mask & POLLERR) {
> >>>> +		ret = -EINVAL;
> >>>> +		vhost_poll_stop(poll);
> >>>> +	}
> >>>> +
> >>>> +	return ret;
> >>>>  }
> >>>>  
> >>>>  static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
> >>>> @@ -792,7 +807,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
> >>>>  		fput(filep);
> >>>>  
> >>>>  	if (pollstart && vq->handle_kick)
> >>>> -		vhost_poll_start(&vq->poll, vq->kick);
> >>>> +		r = vhost_poll_start(&vq->poll, vq->kick);
> >>>>  
> >>>>  	mutex_unlock(&vq->mutex);
> >>>>  
> >>>> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> >>>> index 2639c58..17261e2 100644
> >>>> --- a/drivers/vhost/vhost.h
> >>>> +++ b/drivers/vhost/vhost.h
> >>>> @@ -42,7 +42,7 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
> >>>>  
> >>>>  void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
> >>>>  		     unsigned long mask, struct vhost_dev *dev);
> >>>> -void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> >>>> +int vhost_poll_start(struct vhost_poll *poll, struct file *file);
> >>>>  void vhost_poll_stop(struct vhost_poll *poll);
> >>>>  void vhost_poll_flush(struct vhost_poll *poll);
> >>>>  void vhost_poll_queue(struct vhost_poll *poll);
> >>>> -- 
> >>>> 1.7.1
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
