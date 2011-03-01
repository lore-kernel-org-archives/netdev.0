From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/3] [RFC] Changes for MQ vhost
Date: Tue, 1 Mar 2011 21:34:35 +0530
Message-ID: <OFF5B60FC2.DE5700BA-ON65257846.00552576-65257846.00582CA0@in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com> <20110228063443.24908.38147.sendpatchset@krkumar2.in.ibm.com> <20110228100423.GC28006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:38863 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420Ab1CAQDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 11:03:09 -0500
In-Reply-To: <20110228100423.GC28006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 02/28/2011 03:34:23 PM:

> > The number of vhost threads is <= #txqs.  Threads handle more
> > than one txq when #txqs is more than MAX_VHOST_THREADS (4).
>
> It is this sharing that prevents us from just reusing multiple vhost
> descriptors?

Sorry, I didn't understand this question.

> 4 seems a bit arbitrary - do you have an explanation
> on why this is a good number?

I was not sure what is the best way - a sysctl parameter? Or should the
maximum depend on number of host cpus? But that results in too many
threads, e.g. if I have 16 cpus and 16 txqs.

> > +		 struct task_struct *worker; /* worker for this vq */
> > +		 spinlock_t *work_lock;		 /* points to a dev->work_lock[] entry
*/
> > +		 struct list_head *work_list;		 /* points to a dev->work_list[]
entry */
> > +		 int qnum;		 /* 0 for RX, 1 -> n-1 for TX */
>
> Is this right?

Will fix this.

> > @@ -122,12 +128,33 @@ struct vhost_dev {
> >  		 int nvqs;
> >  		 struct file *log_file;
> >  		 struct eventfd_ctx *log_ctx;
> > -		 spinlock_t work_lock;
> > -		 struct list_head work_list;
> > -		 struct task_struct *worker;
> > +		 spinlock_t *work_lock[MAX_VHOST_THREADS];
> > +		 struct list_head *work_list[MAX_VHOST_THREADS];
>
> This looks a bit strange. Won't sticking everything in a single
> array of structures rather than multiple arrays be better for cache
> utilization?

Correct. In that context, which is better:
	struct {
		spinlock_t *work_lock;
		struct list_head *work_list;
	} work[MAX_VHOST_THREADS];
or, to make sure work_lock/work_list is cache-aligned:
	struct work_lock_list {
		spinlock_t work_lock;
		struct list_head work_list;
	} ____cacheline_aligned_in_smp;
and define:
	struct vhost_dev {
		...
		struct work_lock_list work[MAX_VHOST_THREADS];
	};
Second method uses a little more space but each vhost needs only
one (read-only) cache line. I tested with this and can confirm it
aligns each element on a cache-line. BW improved slightly (upto
3%), remote SD improves by upto -4% or so.

> > +static inline int get_nvhosts(int nvqs)
>
> nvhosts -> nthreads?

Yes.

> > +static inline int vhost_get_thread_index(int index, int numtxqs, int
nvhosts)
> > +{
> > +		 return (index % numtxqs) % nvhosts;
> > +}
> > +
>
> As the only caller passes MAX_VHOST_THREADS,
> just use that?

Yes, nice catch.

> >  struct vhost_net {
> >  		 struct vhost_dev dev;
> > -		 struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
> > -		 struct vhost_poll poll[VHOST_NET_VQ_MAX];
> > +		 struct vhost_virtqueue *vqs;
> > +		 struct vhost_poll *poll;
> > +		 struct socket **socks;
> >  		 /* Tells us whether we are polling a socket for TX.
> >  		  * We only do this when socket buffer fills up.
> >  		  * Protected by tx vq lock. */
> > -		 enum vhost_net_poll_state tx_poll_state;
> > +		 enum vhost_net_poll_state *tx_poll_state;
>
> another array?

Yes... I am also allocating twice the space than what is required
to make it's usage simple. Please let me know what you feel about
this.

Thanks,

- KK

