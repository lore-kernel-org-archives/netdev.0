From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v3 5/5] virtio-net: initial rx sysfs support,
	export mergeable rx buffer size
Date: Thu, 16 Jan 2014 20:50:51 +0200
Message-ID: <20140116185051.GB29522@redhat.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-5-git-send-email-mwdalton@google.com>
	<20140116115340.GC29061@redhat.com>
	<CANJ5vPJZACr=y3uRv0Rnq330jQCi4dLvhyQd88ascZjBg_jfUw@mail.gmail.com>
	<CANJ5vPJi=k1Wk43j+-XjSgnnAS5uO9wrYQuDnrdfA5A+DGxvQg@mail.gmail.com>
	<1389895481.31367.411.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1389895481.31367.411.camel@edumazet-glaptop2.roam.corp.google.com>
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

On Thu, Jan 16, 2014 at 10:04:41AM -0800, Eric Dumazet wrote:
> On Thu, 2014-01-16 at 09:27 -0800, Michael Dalton wrote:
> > Sorry, just realized - I think disabling NAPI is necessary but not
> > sufficient. There is also the issue that refill_work() could be
> > scheduled. If refill_work() executes, it will re-enable NAPI. We'd need
> > to cancel the vi->refill delayed work to prevent this AFAICT, and also
> > ensure that no other function re-schedules vi->refill or re-enables NAPI
> > (virtnet_open/close, virtnet_set_queues, and virtnet_freeze/restore).
> > 
> > How is the following sequence of operations:
> > rtnl_lock();
> > cancel_delayed_work_sync(&vi->refill);
> > napi_disable(&rq->napi);
> > read rq->mrg_avg_pkt_len
> > virtnet_enable_napi();
> > rtnl_unlock();
> > 
> > Additionally, if we disable NAPI when reading this file, perhaps
> > the permissions should be changed to 400 so that an unprivileged
> > user cannot temporarily disable network RX processing by reading these
> > sysfs files. Does that sound reasonable?
> 
> I think all this complexity makes no sense to me.
> 
> Who cares of sysfs reading a value that might be updated ?
> This is purely a debugging utility.
> 
> As soon as you read the value, it might already have changed anyway.
> 
> Its a integer, just read it without special care.

That's fine too as far as I'm concerned.

> 
> atomic_read() has also same 'problem', and we do not care.
> 
> Make sure that a recompute (aka ewma_add()) does not store intermediate
> wrong values, by using ACCESS_ONCE(), and thats enough. No need for the
> seqcount overhead.
> 
> diff --git a/lib/average.c b/lib/average.c
> index 99a67e662b3c..044e0b7f28a8 100644
> --- a/lib/average.c
> +++ b/lib/average.c
> @@ -53,8 +53,10 @@ EXPORT_SYMBOL(ewma_init);
>   */
>  struct ewma *ewma_add(struct ewma *avg, unsigned long val)
>  {
> -	avg->internal = avg->internal  ?
> -		(((avg->internal << avg->weight) - avg->internal) +
> +	unsigned long internal = ACCESS_ONCE(avg->internal);
> +
> +	ACCESS_ONCE(avg->internal) = internal  ?
> +		(((internal << avg->weight) - internal) +
>  			(val << avg->factor)) >> avg->weight :
>  		(val << avg->factor);
>  	return avg;
> 
