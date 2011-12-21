From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Wed, 21 Dec 2011 11:06:37 +0200
Message-ID: <20111221090637.GA31592@redhat.com>
References: <20111211144428.GB14381@redhat.com>
	<878vmioh10.fsf@rustcorp.com.au> <20111212115405.GB7946@redhat.com>
	<87iplltd0g.fsf@rustcorp.com.au>
	<20111220190908.GC25689@redhat.com>
	<20111220190946.GD10752@google.com>
	<20111220193055.GA26392@redhat.com>
	<20111220193154.GG10752@google.com>
	<20111220194518.GB26692@redhat.com>
	<87hb0udd2h.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Amit Shah <amit.shah@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87hb0udd2h.fsf@rustcorp.com.au>
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

On Wed, Dec 21, 2011 at 10:13:18AM +1030, Rusty Russell wrote:
> On Tue, 20 Dec 2011 21:45:19 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > On Tue, Dec 20, 2011 at 11:31:54AM -0800, Tejun Heo wrote:
> > > On Tue, Dec 20, 2011 at 09:30:55PM +0200, Michael S. Tsirkin wrote:
> > > > Hmm, in that case it looks like a nasty race could get
> > > > triggered, with try_fill_recv run on multiple CPUs in parallel,
> > > > corrupting the linked list within the vq.
> > > > 
> > > > Using the mutex as my patch did will fix that naturally, as well.
> > > 
> > > Don't know the code but just use nrt wq.  There's even a system one
> > > called system_nrq_wq.
> > > 
> > > Thanks.
> > 
> > We can, but we need the mutex for other reasons, anyway.
> 
> Well, here's the alternate approach.  What do you think?

It looks very clean, thanks. Some documentation suggestions below.
Also - Cc stable on this and the block patch?

> Finding two wq issues makes you justifiably cautious, but it almost
> feels like giving up to simply wrap it in a lock.  The APIs are designed
> to let us do it without a lock; I was just using them wrong.

One thing I note is that this scheme works because there's a single
entity disabling/enabling napi and the refill thread.
So it's possible that Amit will need to add a lock and track NAPI
state anyway to make suspend work. But we'll see.

> Two patches in one mail.  It's gauche, but it's an RFC only (untested).
> 
> Cheers,
> Rusty.
> 
> virtio_net: set/cancel work on ndo_open/ndo_stop
> 
> Michael S. Tsirkin noticed that we could run the refill work after
> ndo_close, which can re-enable napi - we don't disable it until
> virtnet_remove.  This is clearly wrong, so move the workqueue control
> to ndo_open and ndo_stop (aka. virtnet_open and virtnet_close).
> 
> One subtle point: virtnet_probe() could simply fail if it couldn't
> allocate a receive buffer, but that's less polite in virtnet_open() so
> we schedule a refill as we do in the normal receive path if we run out
> of memory.
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -719,6 +719,10 @@ static int virtnet_open(struct net_devic
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
> +	/* Make sure we have some buffersl if oom use wq. */

Typo :)

> +	if (!try_fill_recv(vi, GFP_KERNEL))
> +		schedule_delayed_work(&vi->refill, 0);
> +
>  	virtnet_napi_enable(vi);
>  	return 0;
>  }
> @@ -772,6 +776,8 @@ static int virtnet_close(struct net_devi
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  
> +	/* Make sure refill_work doesn't re-enable napi! */
> +	cancel_delayed_work_sync(&vi->refill);
>  	napi_disable(&vi->napi);
>  
>  	return 0;
> @@ -1082,7 +1088,6 @@ static int virtnet_probe(struct virtio_d
>  
>  unregister:
>  	unregister_netdev(dev);
> -	cancel_delayed_work_sync(&vi->refill);
>  free_vqs:
>  	vdev->config->del_vqs(vdev);
>  free_stats:
> @@ -1121,9 +1126,7 @@ static void __devexit virtnet_remove(str
>  	/* Stop all the virtqueues. */
>  	vdev->config->reset(vdev);
>  
> -
>  	unregister_netdev(vi->dev);
> -	cancel_delayed_work_sync(&vi->refill);
>  
>  	/* Free unused buffers in both send and recv, if any. */
>  	free_unused_bufs(vi);
> 
> 
> virtio_net: use non-reentrant workqueue.
> 
> Michael S. Tsirkin also noticed that we could run the refill work
> multiple CPUs: if we kick off a refill on one CPU and then on another,
> they would both manipulate the queue at the same time (they use
> napi_disable to avoid racing against the receive handler itself).
> 
> Tejun points out that this is what the WQ_NON_REENTRANT flag is for,
> and that there is a convenient system kthread we can use.
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -501,7 +501,7 @@ static void refill_work(struct work_stru
>  	/* In theory, this can happen: if we don't get any buffers in
>  	 * we will *never* try to fill again. */
>  	if (still_empty)
> -		schedule_delayed_work(&vi->refill, HZ/2);
> +		queue_delayed_work(system_nrt_wq, &vi->refill, HZ/2);
>  }
>  
>  static int virtnet_poll(struct napi_struct *napi, int budget)
> @@ -520,7 +520,7 @@ again:
>  
>  	if (vi->num < vi->max / 2) {
>  		if (!try_fill_recv(vi, GFP_ATOMIC))
> -			schedule_delayed_work(&vi->refill, 0);
> +			queue_delayed_work(system_nrt_wq, &vi->refill, 0);
>  	}
>  
>  	/* Out of packets? */
> @@ -721,7 +721,7 @@ static int virtnet_open(struct net_devic
>  
>  	/* Make sure we have some buffersl if oom use wq. */
>  	if (!try_fill_recv(vi, GFP_KERNEL))
> -		schedule_delayed_work(&vi->refill, 0);
> +		queue_delayed_work(&system_nrt_wq, &vi->refill, 0);
>  
>  	virtnet_napi_enable(vi);
>  	return 0;

Maybe document some rules:
- try_fill_recv must always run from napi or with napi disabled ...
- refill only runs when device is open

-- 
MST
