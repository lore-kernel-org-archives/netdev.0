From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Fri, 27 Dec 2013 12:55:43 +0800
Message-ID: <52BD084F.5040301@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>	
	<1387239389-13216-2-git-send-email-mwdalton@google.com>	
	<52B7F065.3010707@redhat.com>	
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>	
	<20131223193704.GC1582@redhat.com>	
	<CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>
	<1388094991.12212.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>, Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1388094991.12212.34.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 12/27/2013 05:56 AM, Eric Dumazet wrote:
> On Thu, 2013-12-26 at 13:28 -0800, Michael Dalton wrote:
>> On Mon, Dec 23, 2013 at 11:37 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>> So there isn't a conflict with respect to locking.
>>>
>>> Is it problematic to use same page_frag with both GFP_ATOMIC and with
>>> GFP_KERNEL? If yes why?
>> I believe it is safe to use the same page_frag and I will send out a
>> followup patchset using just the per-receive page_frags. For future
>> consideration, Eric noted that disabling NAPI before GFP_KERNEL
>> allocs can potentially inhibit virtio-net network processing for some
>> time (e.g., during a blocking memory allocation or preemption).
> Yep, using napi_disable() in the refill process looks quite inefficient
> to me, it not buggy.
>
> napi_disable() is a big hammer, while whole idea of having a process to
> block on GFP_KERNEL allocations is to allow some asynchronous behavior.
>
> I have hard time to convince myself virtio_net is safe anyway with this
> work queue thing.
>
> virtnet_open() seems racy for example :
>
>         for (i = 0; i < vi->max_queue_pairs; i++) {
>                 if (i < vi->curr_queue_pairs)
>                         /* Make sure we have some buffers: if oom use wq. */
>                         if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>                                 schedule_delayed_work(&vi->refill, 0);
>                 virtnet_napi_enable(&vi->rq[i]);
>
>
> What if the workqueue is scheduled _before_ the call to virtnet_napi_enable(&vi->rq[i]) ?

Then napi_disable() in refill_work() will busy wait until napi is
enabled by virtnet_napi_enable() which looks safe. Looks like the real
issue is in virtnet_restore() who calls try_fill_recv() in neither napi
context nor napi disabled context.
>
> refill_work() will happily conflict with another cpu, two cpus could 
> call try_fill_recv() at the same time, or worse napi_enable() would crash.
>
> I do not have time to make a full check, but I guess there are
> other races like this one.
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c51a98867a40..b8e2adb5d0c2 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -726,16 +726,18 @@ again:
>  static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> +	bool refill = false;
>  	int i;
>  
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		if (i < vi->curr_queue_pairs)
>  			/* Make sure we have some buffers: if oom use wq. */
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> -				schedule_delayed_work(&vi->refill, 0);
> +				refill = true;
>  		virtnet_napi_enable(&vi->rq[i]);
>  	}
> -
> +	if (refill)
> +		schedule_delayed_work(&vi->refill, 0);
>  	return 0;
>  }
>  
>
>
>
>
>
